--[[
	Els Loader — fast loader for Els Hub.
	Trims the client (flags, effects, junk, loading screens) and, with KillScripts,
	disables the game's own scripts for a fast load — never the ones Els Hub needs
	(Packages.Synchronizer/Net, ClientLoader, the kept Controllers, PlayerModule).
	Drop in autoexec; the hub is read from ElsConfig.HubFile / HubUrl, or embedded
	above in a combined build.
	Options: getgenv().ElsConfig = { Timer = false, PauseContent = false, ... }
]]

local ELS_T0 = os.clock()
local ElsEnv = (getgenv and getgenv()) or _G
if ElsEnv.__ElsLoaderRan then return end
ElsEnv.__ElsLoaderRan = true

local ELS_VERSION = "1.0"
local ELS_TAG = "[ELS LOADER]"

local ElsConfig = {
	HubFile = "Els_Hub.lua", -- Els Hub in the executor's workspace folder
	HubUrl = nil,            -- or a raw link to Els Hub
	AnyPlace = false,        -- true = run on any game
	Timer = true,            -- "ELS LOADER" badge on screen
	Telemetry = true,        -- kill Roblox telemetry
	LowGraphics = true,      -- low graphics flags + settings
	NetFlags = true,         -- network flags (packet processing)
	ContentFlags = true,     -- asset download flags
	PauseContent = true,     -- pause meshes/textures until character or bases
	NoEffects = true,        -- Bloom/Blur/SunRays/DoF/Atmosphere/shadows
	Junk = true,             -- remove Sounds / PlayWaveEvents / Events
	EarlyStrip = true,       -- strip Map decals/effects before Els Hub
	PrioBases = false,       -- preload all bases at once (off: steals bandwidth, hub drops half)
	HideLoading = true,      -- remove loading screens
	HideGameButtons = true,  -- hide Shop / Rebirth / Index / Duels / Trade / Codes
	EscMenu = true,          -- Esc = Els mini menu (Leave / Reset) instead of Roblox menu
	NoRobloxMenu = true,     -- disable Roblox CoreScripts + destroy Esc menu, keep StarterScript
	NoMachines = true,       -- destroy fuses / incubator / wheels / boards on arrival
	NoMovingAnimals = true,  -- destroy scrolling brainrots (RenderedMovingAnimals)
	NoNotifications = true,  -- no game messages ("base locked", "you got robbed"…)
	NoBrainrotPreload = false, -- destroy BrainrotPreloadingController (hub keeps it: leave false)
	BigTags = true,          -- Els tag on big buyable brainrots (like fastload)
	BigTagMin = 10e6,        -- min generation to show the tag (10M/s)
	No3D = false,            -- disable 3D rendering until character spawns
	Timeline = true,         -- write Els_load_timeline.txt
	-- opti-style speed, hub-safe: KillScripts keeps every player-side script (the
	-- tools + GUIs the hub puppets for steal/clone/carpet) and only cuts world-side
	-- scripts, so features keep working. Flip it off if anything game-side breaks.
	KillScripts = true,      -- cut game scripts for speed; steal/clone now use direct remotes so they survive
	KillPlayerScripts = true,-- full-opti: ALSO cut player-side scripts. Steal + clone now fire direct remotes (begin->hold->grab) when the game callbacks are gone, so they survive. Set false if steal breaks.
	AntiKick = false,        -- redo the anticheat heartbeat (ACRem + HMAC-SHA256); turn on ONLY if full-opti gets you kicked
	KeepScripts = {},        -- extra LocalScript names to never disable (e.g. { "MyScript" })
	ReenableAfter = 45,      -- seconds after load the game's scripts are switched back on (0 = never)
	AutoDeliver = true,      -- fire the game's deliver remote when you carry a brainrot into your own delivery zone
}
do
	local elsUser = ElsEnv.ElsConfig
	if type(elsUser) == "table" then
		for k, v in pairs(elsUser) do ElsConfig[k] = v end
	end
end

-- Els A/B test: create "Els_test.txt" (lines like PauseContent=false). Every other
-- launch applies it (tag "test"), the other does not (tag "base"); compare timelines.
local elsLoadTag = "els"
if isfile and readfile and writefile then
	local okT, hasTest = pcall(isfile, "Els_test.txt")
	if okT and hasTest then
		local count = 0
		pcall(function()
			if isfile("Els_test_count.txt") then count = tonumber(readfile("Els_test_count.txt")) or 0 end
		end)
		count = count + 1
		pcall(writefile, "Els_test_count.txt", tostring(count))
		if count % 2 == 0 then
			elsLoadTag = "test"
			pcall(function()
				for k, v in string.gmatch(readfile("Els_test.txt"), "([%w_]+)%s*=%s*([%w_]+)") do
					if v == "true" then ElsConfig[k] = true elseif v == "false" then ElsConfig[k] = false end
				end
			end)
		else
			elsLoadTag = "base"
		end
	end
end
-- tag written to Els_load_timeline.txt to compare runs
if elsLoadTag == "els" and ElsConfig.NoBrainrotPreload == true then elsLoadTag = "nopreload" end

local ELS_PLACES = {
	[109983668079237] = true,
	[96342491571673] = true,
	[123923334828954] = true,
	[120148879522453] = true,
}
while game.PlaceId == 0 do task.wait() end
if not ELS_PLACES[game.PlaceId] and ElsConfig.AnyPlace ~= true then
	ElsEnv.__ElsLoaderRan = nil
	return
end

local Els = {
	Name = "Els Loader",
	Version = ELS_VERSION,
	Config = ElsConfig,
	Started = ELS_T0,
	Marks = {},
	Ready = false,
}
ElsEnv.ElsLoader = Els
_G.ElsLoader = Els
-- same globals as fastload, for scripts that read them
ElsEnv.FastLoad = true
ElsEnv.LoadPending = true
ElsEnv.LoadTag = elsLoadTag

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local elsMarkList, elsMarkT = {}, {}
local function ElsMark(name)
	local t = os.clock() - ELS_T0
	elsMarkT[name] = t
	elsMarkList[#elsMarkList + 1] = string.format("%s=%.2f", name, t)
	Els.Marks[name] = t
end

-- Els Hub sets __Els_VelFlying during its TPs: destroy nothing then
local function ElsBusy()
	return _G.__Els_VelFlying == true
end

-- same rule as Els Hub: anything tagged ElsVisual is untouchable
local function ElsKeep(inst)
	local x = inst
	while x and x ~= game do
		if x:GetAttribute("ElsVisual") == true or x.Name == "Unlock" then return true end
		x = x.Parent
	end
	return false
end

local function ElsDestroy(inst)
	if ElsBusy() then return end
	task.defer(pcall, inst.Destroy, inst)
end

ElsMark("start")

-- Els AntiKick: redo the game's anticheat heartbeat (ACRem), like opti. Server
-- sends a 64-hex key on a RemoteEvent; client must reply HMAC-SHA256(key,
-- time_bucket .. "|OK") continuously or it gets kicked. KillScripts cuts the game
-- script that did this, so we redo it. This is the GAME's remote, not the hub.
if ElsConfig.AntiKick ~= false then
	local band, bor, bxor, bnot = bit32.band, bit32.bor, bit32.bxor, bit32.bnot
	local lshift, rshift, rrotate = bit32.lshift, bit32.rshift, bit32.rrotate
	local byte, char = string.byte, string.char
	local K = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}
	local function elsWord(v)
		return char(band(rshift(v, 24), 255), band(rshift(v, 16), 255), band(rshift(v, 8), 255), band(v, 255))
	end
	local function elsSha256(msg)
		local bits = #msg * 8
		local n = msg .. "\128"
		n = n .. string.rep("\0", (56 - #n % 64) % 64) .. elsWord(math.floor(bits / 4294967296)) .. elsWord(bits % 4294967296)
		local h = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 }
		local w = table.create(64)
		for i = 1, #n, 64 do
			for j = 0, 15 do
				local p = i + j * 4
				w[j] = bor(lshift(byte(n, p), 24), lshift(byte(n, p + 1), 16), lshift(byte(n, p + 2), 8), byte(n, p + 3))
			end
			for j = 16, 63 do
				local a, b = w[j - 15], w[j - 2]
				w[j] = band(w[j - 16] + bxor(rrotate(a, 7), rrotate(a, 18), rshift(a, 3)) + w[j - 7]
					+ bxor(rrotate(b, 17), rrotate(b, 19), rshift(b, 10)), 0xffffffff)
			end
			local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
			for j = 0, 63 do
				local t1 = band(hh + bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
					+ bxor(band(e, f), band(bnot(e), g)) + K[j + 1] + w[j], 0xffffffff)
				local t2 = band(bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
					+ bxor(band(a, b), band(a, c), band(b, c)), 0xffffffff)
				hh, g, f, e, d, c, b, a = g, f, e, band(d + t1, 0xffffffff), c, b, a, band(t1 + t2, 0xffffffff)
			end
			h[1], h[2], h[3], h[4] = band(h[1] + a, 0xffffffff), band(h[2] + b, 0xffffffff), band(h[3] + c, 0xffffffff), band(h[4] + d, 0xffffffff)
			h[5], h[6], h[7], h[8] = band(h[5] + e, 0xffffffff), band(h[6] + f, 0xffffffff), band(h[7] + g, 0xffffffff), band(h[8] + hh, 0xffffffff)
		end
		return elsWord(h[1]) .. elsWord(h[2]) .. elsWord(h[3]) .. elsWord(h[4]) .. elsWord(h[5]) .. elsWord(h[6]) .. elsWord(h[7]) .. elsWord(h[8])
	end
	local function elsHex(s)
		return (s:gsub(".", function(c) return string.format("%02x", byte(c)) end))
	end

	-- same remote search as opti: direct ACRem, else a RemoteEvent hidden under a
	-- rarely-used service and carrying one of the known anticheat names
	local SERVICES = { "GamepadService", "BadgeService", "CookiesService", "AdService", "AnimationFromVideoCreatorService" }
	local NAMES = { ACRem = true, RobloxChatSystemMessage = true, Chat = true, AFK = true, FisherMan = true, ["WhyAreTheyTargetingMe!!"] = true }
	local function elsFindRemote()
		local rs = game:FindFirstChildOfClass("ReplicatedStorage")
		local direct = rs and rs:FindFirstChild("ACRem")
		if direct and direct:IsA("RemoteEvent") then return direct end
		for _, svc in ipairs(SERVICES) do
			local ok, s = pcall(game.FindService, game, svc)
			local re = (ok and s) and s:FindFirstChildOfClass("RemoteEvent") or nil
			if re and NAMES[re.Name] then return re end
		end
		return nil
	end

	task.spawn(function()
		local ipad, opad      -- HMAC inner/outer keys, set when the server sends the key
		local remote, conn
		local function elsSetKey(k)
			local m = k .. string.rep("\0", 64 - #k)
			local ip, op = table.create(64), table.create(64)
			for i = 1, 64 do
				ip[i] = char(bxor(byte(m, i), 0x36))
				op[i] = char(bxor(byte(m, i), 0x5c))
			end
			ipad, opad = table.concat(ip), table.concat(op)
		end
		local function elsPayload(t)
			local mac = elsSha256(opad .. elsSha256(ipad .. t .. "|OK"))
			return string.format("%010d", t) .. elsHex(mac)
		end
		local function elsBind(re)
			if conn then conn:Disconnect() end
			remote = re
			conn = re.OnClientEvent:Connect(function(msg)
				if type(msg) == "string" and #msg == 64 and msg:match("^%x+$") then elsSetKey(msg) end
			end)
		end
		local lastBucket
		local lastHello = -math.huge
		while true do
			if not remote or not remote.Parent then
				local re = elsFindRemote()
				if re and re ~= remote then elsBind(re) end
			end
			local now = os.clock()
			-- no key yet: ping until the server answers
			if remote and not ipad and now - lastHello >= 1 then
				lastHello = now
				pcall(function() remote:FireServer("hello") end)
			end
			-- key received: sign the server time bucket on every change
			local ws = game:FindFirstChildOfClass("Workspace")
			local bucket = ws and math.floor(ws:GetServerTimeNow() / 2) or 0
			if ws and bucket ~= lastBucket and remote and ipad then
				pcall(function() remote:FireServer(elsPayload(bucket)) end)
				lastBucket = bucket
			end
			task.wait(0.1)
		end
	end)
	ElsMark("antikick")
end

-- Els KillScripts: disable the game's scripts for a fast load. Always kept: ClientLoader
-- (loads the 14 Controllers), Packages (Synchronizer/Net, required live), every
-- ModuleScript (the Controllers), and Tool scripts. World-side scripts (Workspace
-- entities, loose ReplicatedStorage) and CoreScripts (except StarterScript) are cut.
-- With KillPlayerScripts off (safe v2) we also keep player-side scripts (PlayerScripts/
-- PlayerGui). With it on (full-opti) we cut those too: clone fires its teleport remote
-- directly and steal uses engine prompts + direct remotes, so neither needs them.
if ElsConfig.KillScripts == true then
	local killPlayer = ElsConfig.KillPlayerScripts == true
	local elsOff = {}
	local SCRIPT_KEEP = { ClientLoader = true }
	if type(ElsConfig.KeepScripts) == "table" then
		for _, n in ipairs(ElsConfig.KeepScripts) do SCRIPT_KEEP[tostring(n)] = true end
	end
	local CORE_KEEP = { StarterScript = true }
	-- always keep Tools + Packages; keep player-side too unless full-opti is on
	local function elsPlayerSide(x)
		local plr = Players.LocalPlayer
		local char = plr and plr.Character
		local a = x
		while a and a ~= game do
			if a:IsA("Tool") then return true end
			if a.Name == "Packages" and a.Parent == ReplicatedStorage then return true end
			if not killPlayer then
				if plr and a == plr then return true end
				if char and a == char then return true end
			end
			a = a.Parent
		end
		return false
	end
	local function elsMute(x)
		local cn = x.ClassName
		if cn == "CoreScript" then
			if not CORE_KEEP[x.Name] then pcall(function() x.Enabled = false end) end
			return
		end
		if cn ~= "Script" and cn ~= "LocalScript" then return end -- never a ModuleScript
		if SCRIPT_KEEP[x.Name] then return end
		if not Players.LocalPlayer then return end -- can't tell player-side yet: keep it
		if elsPlayerSide(x) then return end
		if ElsKeep(x) then return end
		elsOff[x] = true
		pcall(function() x.Enabled = false end)
	end
	local elsMuteConn = game.DescendantAdded:Connect(elsMute)
	local back = tonumber(ElsConfig.ReenableAfter) or 45
	if back > 0 then
		task.delay(back, function()
			elsMuteConn:Disconnect() -- late scripts were kept off until now; from here nothing is touched
			ElsEnv.__ElsScriptsBack = true
			for sc in pairs(elsOff) do
				if sc.Parent then pcall(function() sc.Enabled = true end) end
			end
			table.clear(elsOff)
			ElsMark("scripts-back")
		end)
	end
	-- initial pass runs once LocalPlayer exists, so player-side detection is reliable
	task.spawn(function()
		while not Players.LocalPlayer do task.wait() end
		local SKIP_ROOT = { CoreGui = true, CorePackages = true, RobloxReplicatedStorage = true }
		for _, svc in ipairs(game:GetChildren()) do
			if not SKIP_ROOT[svc.Name] then
				local okD, list = pcall(svc.GetDescendants, svc)
				if okD then for _, d in ipairs(list) do elsMute(d) end end
			end
		end
		ElsMark("kill")
	end)
end

-- Els No Roblox Menu: disable Roblox CoreScripts as they appear (the Esc menu is
-- never built), keeping StarterScript. Game scripts are untouched.
if ElsConfig.NoRobloxMenu ~= false then
	local ELS_CORE_KEEP = { StarterScript = true }
	local function elsCore(x)
		if x.ClassName == "CoreScript" and not ELS_CORE_KEEP[x.Name] then
			pcall(function() x.Enabled = false end)
		end
	end
	-- CoreScripts live in CoreGui: listen there, not the whole game, to avoid a Lua
	-- call for each of the thousands of instances replicated during load
	pcall(function()
		local elsCG = game:FindFirstChildOfClass("CoreGui")
		if elsCG then elsCG.DescendantAdded:Connect(elsCore) else game.DescendantAdded:Connect(elsCore) end
	end)
	-- if the menu was already built before the loader, destroy it
	local ELS_MENU_GUI = { SettingsClippingShield = true, SettingsShield = true }
	local function elsMenuGui(x)
		if ELS_MENU_GUI[x.Name] then task.defer(pcall, x.Destroy, x) end
	end
	task.spawn(function()
		local cg = game:FindFirstChildOfClass("CoreGui")
		local rg = cg and (cg:FindFirstChild("RobloxGui") or cg:WaitForChild("RobloxGui", 10))
		if not rg then return end
		local ok, list = pcall(rg.GetDescendants, rg)
		if ok then
			for _, d in ipairs(list) do elsCore(d) end
		end
		for _, c in ipairs(rg:GetChildren()) do elsMenuGui(c) end
		pcall(function() rg.ChildAdded:Connect(elsMenuGui) end)
		ElsMark("core")
	end)
end

-- Els AutoDeliver: while you carry a stolen brainrot and stand in YOUR base's delivery zone, fire the game's deliver remote (the client script
-- that did it is cut by KillScripts). Remote found the same passive way as the admin panel: its name is a hash of the GUID + job id + the Net salt.
if ElsConfig.AutoDeliver ~= false then
	task.spawn(function()
		local CollectionService = game:GetService("CollectionService")
		local lp = Players.LocalPlayer
		while not lp do task.wait() lp = Players.LocalPlayer end
		local EVENT, PAYLOAD = "b3ab4417-65d0-4f5d-8562-8f51d1c4305d", "ac28d486-82cf-438e-9bc3-566ef66cc4ce"
		local EVENT2, PAYLOAD2 = "8b2abeb7-37e3-4739-a9d8-6fb2d58d966c", "7c7745c9-ae67-4244-a463-78872bbd5977"
		local SALT0 = "2b857474-f9cc-4ddd-a4f1-28be8b6c1b38"
		local KNOWN = { "StealService/Grab", "WorldBrainrotService/Grab", "WorldBrainrotService/Drop", "InventoryService/Sort", "Tools/Cooldown", "NotificationService/Notify" }
		local band, bor, bxor, bnot = bit32.band, bit32.bor, bit32.bxor, bit32.bnot
		local lshift, rshift, rrotate, byte = bit32.lshift, bit32.rshift, bit32.rrotate, string.byte
		local K = {
			0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
			0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
			0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
			0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
		}
		local function sha(msg)
			local bits = #msg * 8
			local function word(v) return string.char(band(rshift(v, 24), 255), band(rshift(v, 16), 255), band(rshift(v, 8), 255), band(v, 255)) end
			local n = msg .. "\128"
			n = n .. string.rep("\0", (56 - #n % 64) % 64) .. word(math.floor(bits / 4294967296)) .. word(bits % 4294967296)
			local h = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 }
			local w = table.create(64)
			for i = 1, #n, 64 do
				for j = 0, 15 do
					local p = i + j * 4
					w[j] = bor(lshift(byte(n, p), 24), lshift(byte(n, p + 1), 16), lshift(byte(n, p + 2), 8), byte(n, p + 3))
				end
				for j = 16, 63 do
					local a, b = w[j - 15], w[j - 2]
					w[j] = band(w[j - 16] + bxor(rrotate(a, 7), rrotate(a, 18), rshift(a, 3)) + w[j - 7] + bxor(rrotate(b, 17), rrotate(b, 19), rshift(b, 10)), 0xffffffff)
				end
				local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
				for j = 0, 63 do
					local t1 = band(hh + bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25)) + bxor(band(e, f), band(bnot(e), g)) + K[j + 1] + w[j], 0xffffffff)
					local t2 = band(bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22)) + bxor(band(a, b), band(a, c), band(b, c)), 0xffffffff)
					hh, g, f, e, d, c, b, a = g, f, e, band(d + t1, 0xffffffff), c, b, a, band(t1 + t2, 0xffffffff)
				end
				for k, v in ipairs({ a, b, c, d, e, f, g, hh }) do h[k] = band(h[k] + v, 0xffffffff) end
			end
			return string.format(string.rep("%08x", 8), h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8])
		end
		local MIX = {
			function(e, s, j) return e .. s .. j end,
			function(e, s, j) return e .. j .. s end,
			function(e, s, j) return s .. e .. j end,
			function(e, s) return e .. s end,
		}
		local function find(net, name, salt, prefix)
			local job = game.JobId
			local out, g = table.create(#name), 0
			for i = 1, #name do
				local ch = string.sub(name, i, i)
				if ch == "/" then out[i] = ch
				else
					out[i] = string.char(32 + ((byte(ch) - 32) + (byte(job, g % #job + 1) % 95)) % 95)
					g += 1
				end
			end
			local enc = table.concat(out)
			for _, mix in ipairs(MIX) do
				local r = net:FindFirstChild(prefix .. sha(mix(enc, salt, job)))
				if r then return r end
			end
		end
		local UUID = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
		local function works(net, c)
			for _, n in ipairs(KNOWN) do
				if find(net, n, c, "RE/") or find(net, n, c, "RF/") then return true end
			end
			return false
		end
		local salt, saltTry, saltBusy = nil, -10, false
		-- the Net salt moves with game updates: the live one is a GUID inside the Net module's bytecode / the game's memory (same search as meerko loader)
		local function findSalt(net)
			if salt then return salt end
			if works(net, SALT0) then salt = SALT0 return salt end
			if saltBusy or os.clock() - saltTry < 5 then return nil end
			saltBusy, saltTry = true, os.clock()
			pcall(function()
				local seen, found, job = {}, nil, game.JobId
				local function try(v)
					if found or type(v) ~= "string" or #v ~= 36 or v == job or seen[v] then return end
					seen[v] = true
					if string.match(v, "^" .. UUID .. "$") and works(net, v) then found = v end
				end
				if getscriptbytecode then
					local mods = net:GetDescendants()
					mods[#mods + 1] = net
					for _, m in ipairs(mods) do
						if m:IsA("ModuleScript") then
							local ok, bc = pcall(getscriptbytecode, m)
							if ok and type(bc) == "string" then
								for v in string.gmatch(bc, UUID) do try(v) end
							end
						end
					end
				end
				if not found and getgc then
					local objs = getgc(true)
					for i = 1, #objs do
						if found then break end
						local o = objs[i]
						if type(o) == "table" then
							pcall(function() for k, v in next, o do try(v) try(k) end end)
						elseif type(o) == "function" and islclosure and islclosure(o) and debug.getconstants then
							pcall(function() for _, c in debug.getconstants(o) do try(c) end end)
						end
						if i % 4000 == 0 then task.wait() end
					end
				end
				if found then salt = found end
			end)
			saltBusy = false
			return salt
		end
		local cache = {}
		local function event(guid)
			local r = cache[guid]
			if r and r.Parent then return r end
			local pk = ReplicatedStorage:FindFirstChild("Packages")
			local net = pk and pk:FindFirstChild("Net")
			if not net or game.JobId == "" then return nil end
			local s = findSalt(net)
			r = s and find(net, guid, s, "RE/")
			if r and r:IsA("RemoteEvent") then cache[guid] = r return r end
			return nil
		end

		-- my base: the hub's __Els_MyPlot, else the plot whose synced Owner is me
		local mine
		local function ownerIsMe(o)
			if o == lp then return true end
			return type(o) == "table" and o.UserId == lp.UserId
		end
		local function chanOf(name)
			local ok, ch = pcall(function() return _G.XenSyncGet and _G.XenSyncGet(name) end)
			return ok and ch or nil
		end
		local function myPlot()
			local plots = Workspace:FindFirstChild("Plots")
			if not plots then return nil end
			local m = mine and plots:FindFirstChild(mine)
			if m then return m end
			mine = nil
			local n = _G.__Els_MyPlot
			if n and plots:FindFirstChild(tostring(n)) then mine = tostring(n) return plots[mine] end
			if not _G.sProp then return nil end
			for _, p in ipairs(plots:GetChildren()) do
				local ch = chanOf(p.Name)
				local ok, o = pcall(_G.sProp, ch, "Owner")
				if ok and ch and ownerIsMe(o) then mine = p.Name return p end
			end
			return nil
		end

		local lastStage
		local function dbg(stage)
			if stage ~= lastStage and ElsEnv.ElsDeliverDebug ~= false then
				lastStage = stage
				warn("[ELS DELIVER] " .. stage)
			end
		end
		local function stealing()
			if lp:GetAttribute("Stealing") then return true end
			local c = lp.Character
			return c ~= nil and c:GetAttribute("Stealing") == true
		end
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.MaxParts = 1
		local boxPlot, last = nil, 0
		RunService.Heartbeat:Connect(function()
			local nowc = os.clock()
			if nowc - last < 0.05 then return end
			last = nowc
			if not stealing() then lastStage = nil return end
			local char = lp.Character
			if not char then return end
			local plot = myPlot()
			if not plot then dbg("carrying, but my base was not found") return end
			-- the animals I am taking out of my own base are not a delivery
			local ch = chanOf(plot.Name)
			local okL, list = pcall(function() return _G.sProp(ch, "AnimalList") end)
			if okL and type(list) == "table" then
				for _, a in pairs(list) do
					if type(a) == "table" and a.Steal == lp.UserId then dbg("carrying from my own base") return end
				end
			end
			if plot ~= boxPlot or #params.FilterDescendantsInstances == 0 then
				boxPlot = plot
				local boxes = {}
				for _, part in ipairs(CollectionService:GetTagged("PlotDeliveryHitbox")) do
					if part:IsA("BasePart") and part:IsDescendantOf(plot) then
						part.CanQuery = true
						boxes[#boxes + 1] = part
					end
				end
				params.FilterDescendantsInstances = boxes
				if #boxes == 0 then dbg("no delivery zone in " .. plot.Name) end
			end
			if #Workspace:GetPartBoundsInBox(CFrame.new(char:GetPivot().Position), Vector3.new(4, 4, 2), params) == 0 then dbg("carrying, walking to the zone of " .. plot.Name) return end
			last = os.clock()
			local ev = event(EVENT)
			if ev then
				ev:FireServer(PAYLOAD)
				ev:FireServer(PAYLOAD)
				dbg("in my zone: delivered")
				return
			end
			local fb = event(EVENT2)
			if fb then fb:FireServer(PAYLOAD2) dbg("in my zone: delivered (fallback remote)") return end
			dbg("in my zone, but the deliver remote was not found (salt " .. tostring(salt ~= nil) .. ")")
		end)
	end)
	ElsMark("deliver")
end

-- Els Timer: load badge in Els Hub colors
local elsTimerDone = false
if ElsConfig.Timer ~= false then
	task.spawn(function()
		local parent
		for _ = 1, 100 do
			local ok, h = pcall(function() return gethui and gethui() end)
			if ok and h then parent = h break end
			parent = game:FindFirstChildOfClass("CoreGui")
			if parent then break end
			task.wait()
		end
		if not parent then return end
		local old = parent:FindFirstChild("ElsLoader")
		if old then old:Destroy() end

		-- thin card, bottom-right: accent bar, "els" gradient, 3 bouncing dots during
		-- load (replaced by the time at the end), and a progress line at the bottom
		local ELS_BG = Color3.fromRGB(6, 22, 44)
		local ELS_BG2 = Color3.fromRGB(10, 32, 60)
		local ELS_LINE = Color3.fromRGB(28, 70, 110)
		local ELS_TXT = Color3.fromRGB(226, 238, 248)
		local ELS_DIM = Color3.fromRGB(120, 156, 190)
		local ELS_ACC = Color3.fromRGB(20, 84, 140)
		local ELS_ACC2 = Color3.fromRGB(120, 186, 228)
		local ELS_GREEN = Color3.fromRGB(140, 220, 255)
		local ELS_RED = Color3.fromRGB(235, 85, 95)
		local WHITE = Color3.new(1, 1, 1)

		local function elsNew(class, props, parent)
			local x = Instance.new(class)
			for k, v in pairs(props) do x[k] = v end
			if parent then x.Parent = parent end
			return x
		end
		local function elsTween(o, t, props, style, dir)
			pcall(function()
				TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
			end)
		end
		local function elsFont(lbl, weight, fallback)
			local ok = pcall(function() lbl.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", weight) end)
			if not ok then lbl.Font = fallback end
		end

		local W, H = 248, 54
		local elsGui = elsNew("ScreenGui", {
			Name = "ElsLoader", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 2147483000,
		})
		local card = elsNew("Frame", {
			Name = "ElsCard", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, 30),
			Size = UDim2.fromOffset(W, H), BackgroundColor3 = ELS_BG, BackgroundTransparency = 1,
			BorderSizePixel = 0, ClipsDescendants = true,
		}, elsGui)
		elsNew("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
		local cardStroke = elsNew("UIStroke", { Color = ELS_LINE, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
		elsNew("UIGradient", { Rotation = 90, Color = ColorSequence.new(WHITE, Color3.fromRGB(176, 198, 222)) }, card)
		local group = elsNew("CanvasGroup", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1,
		}, card)
		-- the rounded CanvasGroup clips the bottom line at the card corners
		elsNew("UICorner", { CornerRadius = UDim.new(0, 10) }, group)

		-- vertical accent bar on the left
		local side = elsNew("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(3, 30),
			BackgroundColor3 = WHITE, BorderSizePixel = 0,
		}, group)
		elsNew("UICorner", { CornerRadius = UDim.new(1, 0) }, side)
		elsNew("UIGradient", { Rotation = 90, Color = ColorSequence.new(ELS_ACC2, ELS_ACC) }, side)

		-- "els" gradient + "loader"
		local brand = elsNew("TextLabel", {
			Position = UDim2.fromOffset(22, 9), Size = UDim2.fromOffset(40, 18), BackgroundTransparency = 1,
			TextSize = 17, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left, Text = "els",
		}, group)
		elsFont(brand, Enum.FontWeight.Heavy, Enum.Font.GothamBlack)
		local brandGrad = elsNew("UIGradient", { Color = ColorSequence.new(ELS_ACC2, Color3.fromRGB(64, 136, 196)) }, brand)
		local tag = elsNew("TextLabel", {
			Position = UDim2.fromOffset(52, 13), Size = UDim2.fromOffset(60, 12), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = ELS_DIM, TextXAlignment = Enum.TextXAlignment.Left,
			Text = "LOADER",
		}, group)

		local status = elsNew("TextLabel", {
			Position = UDim2.fromOffset(22, 29), Size = UDim2.fromOffset(150, 14), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = ELS_DIM, TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Loading",
		}, group)

		-- 3 bouncing dots on the right during load
		local dotsBox = elsNew("Frame", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(36, 16),
			BackgroundTransparency = 1,
		}, group)
		local dots = {}
		for i = 1, 3 do
			local d = elsNew("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 6 + (i - 1) * 12, 0.5, 0),
				Size = UDim2.fromOffset(6, 6), BackgroundColor3 = i == 2 and ELS_ACC2 or ELS_ACC, BorderSizePixel = 0,
			}, dotsBox)
			elsNew("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
			dots[i] = d
		end

		-- time (hidden until the end)
		local num = elsNew("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(90, 28),
			BackgroundTransparency = 1, TextSize = 24, TextColor3 = ELS_GREEN, TextXAlignment = Enum.TextXAlignment.Right,
			TextTransparency = 1, Text = "",
		}, group)
		elsFont(num, Enum.FontWeight.Heavy, Enum.Font.GothamBlack)
		local numScale = elsNew("UIScale", { Scale = 0.7 }, num)

		-- bottom line
		local track = elsNew("Frame", {
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = ELS_BG2, BorderSizePixel = 0, ClipsDescendants = true,
		}, group)
		local fill = elsNew("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, track)
		elsNew("UIGradient", { Color = ColorSequence.new(ELS_ACC, ELS_ACC2) }, fill)
		local shine = elsNew("Frame", {
			Position = UDim2.fromScale(-0.3, 0), Size = UDim2.fromScale(0.3, 1), BackgroundColor3 = ELS_ACC2,
			BorderSizePixel = 0, ZIndex = 2,
		}, track)
		elsNew("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
			}),
		}, shine)

		-- entrance: the card slides up and fades in
		elsGui.Parent = parent
		elsTween(card, 0.5, { Position = UDim2.new(1, -18, 1, -18), BackgroundTransparency = 0.04 })
		elsTween(cardStroke, 0.5, { Transparency = 0 })
		elsTween(group, 0.5, { GroupTransparency = 0 })

		-- loading: no number, animation only
		while not elsTimerDone and os.clock() - ELS_T0 < 60 do
			local t = os.clock()
			for i, d in ipairs(dots) do
				local k = math.max(0, math.sin(t * 7 - i * 0.9))
				d.Position = UDim2.new(0, 6 + (i - 1) * 12, 0.5, -5 * k)
				d.BackgroundTransparency = 0.45 - 0.45 * k
			end
			side.BackgroundTransparency = 0.25 * (1 - math.abs(math.sin(t * 2.5)))
			brandGrad.Offset = Vector2.new(math.sin(t * 1.6) * 0.35, 0)
			shine.Position = UDim2.fromScale(((t - ELS_T0) * 0.8) % 1.6 - 0.3, 0)
			status.Text = "Loading" .. string.rep(".", math.floor(t * 3) % 4)
			task.wait()
		end

		-- same measure as fastload (LoadedIn): game loaded + character spawned
		local total = elsMarkT.character or (os.clock() - ELS_T0)
		local col = total < 1.5 and ELS_GREEN or (total < 3 and ELS_ACC2 or ELS_RED)

		-- end: dots fade out, the time takes their place
		for _, d in ipairs(dots) do elsTween(d, 0.2, { BackgroundTransparency = 1, Size = UDim2.fromOffset(2, 2) }) end
		shine.Visible = false
		side.BackgroundTransparency = 0
		brandGrad.Offset = Vector2.zero
		elsTween(fill, 0.5, { Size = UDim2.fromScale(1, 1) })
		elsTween(cardStroke, 0.3, { Color = ELS_ACC })
		status.Text = "You loaded in"
		elsTween(status, 0.3, { TextColor3 = ELS_TXT })
		task.wait(0.15)
		num.Text = string.format("%.2fs", total)
		num.TextColor3 = col
		elsTween(num, 0.3, { TextTransparency = 0 })
		elsTween(numScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)

		task.wait(6)
		elsTween(card, 0.4, { Position = UDim2.new(1, -18, 1, 30), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		elsTween(cardStroke, 0.4, { Transparency = 1 })
		elsTween(group, 0.4, { GroupTransparency = 1 })
		task.wait(0.45)
		elsGui:Destroy()
	end)
end

-- Els Flags: telemetry, graphics, network, asset download
local ELS_TELEMETRY = {
	AMPVerifiedTelemetryHundredthsPercentage="0",AdIntegrationEventsThrottlePointsHundredthsPercent="0",
	AdIntegrationImpressionEventThrottleEventIngestHundredthsPercent="0",
	AdIntegrationViewableTimeEventThrottleEventIngestHundredthsPercent="0",
	AdditionalPrePauseStatsHundredthsPercentage="0",AnalyticsCDNProbeInfluxPermyriad="0",
	AnalyticsForXBoxCrash_JoinInfluxHundredthsPercentage="0",AnalyticsNS1CDNProbeChancePercent="0",
	AppConfigurationTelemetryNewEventsThrottleHundredthsPercent="0",
	AppConfigurationTelemetryThrottleHundredthsPercent="0",AssetRequestPointsHundredthsPercent="0",
	AssetRequestStatsHundredthsPercent="0",AssetResolutionWorkflowStatsHundredthsPercent="0",
	AssetResolutionWorkflowTelemetryFailureEventThrottleHundredthsPercent="0",
	AssetServiceComposeDecalAsyncLoggingHundredthsPercentage="0",
	AssetWorkflowTelemetryEventThrottleDeferredAssetsPerMillionth="0",
	AssetWorkflowTelemetryEventThrottlePerMillionth="0",AtlasOverflowReportHundredthsPercent2="0",
	AvatarChatSubsessionStatsEventThrottleHundrethsPercentV2="0",
	AvatarFacechatLODCameraDisableTelemetryThrottleHundrethsPercent="0",
	AvatarFacechatPipelinePerformanceTelemetryThrottleHundrethsPercent="0",
	AvatarFacechatReplicationOverRCCTelemetryThrottleHundrethsPercent="0",
	BadgesApiUsageTelemetryHundredthsPercent="0",BatchAssetAPIWorkflowStatsHundredthsPercent="0",
	BatchLogMessageIngestHundredthsPercent="0",BgUpdateRedirectsHttpErrInfluxHundredthsPercentage="0",
	BrandProjectDecisionTelemetryThrottleHundredths="0",BrowserTrackerIdTelemetryThrottleHundredthsPercent="0",
	CEVLowMemoryWarningIgnoredTelemetryThrottleHundredthsPercent="0",
	CEVLowMemoryWarningTelemetryThrottleHundredthsPercent="0",CLI179323ReportHundredthsPercent="0",
	CLI193954AddCsgDictionaryServiceTelemetrySessionEventHundredths="0",
	CLI202494ReportThrottleHundredthsPercent="0",CLI46794SendInputTelemetryHundredthsPercentage="0",
	CLI52064InfluxHundredthsPercentage="0",CLI61964InfluxThresholdHundredths="0",
	CaaTelemetryThrottleHundredthsPercent="0",
	CafTelemetryIntegrationAppLaunchTelemetryThrottleHundredthsPercent="0",
	CanvasGroupRenderPath_ReportHundredthsPercent="0",CapabilityErrorDetailedEventIngestHundredthsPercentage="0",
	CapabilityErrorDetailedPointsHundredthsPercentage="0",CapabilityRegularUseEventIngestHundredthsPercentage="0",
	CapabilityRegularUsePointsHundredthsPercentage="0",CapabilityTelemetryThrottleHundredthsPercent="0",
	CapabilityUnassignedUseEventIngestHundredthsPercentage="0",
	CapabilityUnassignedUsePointsHundredthsPercentage="0",
	CharacterLoadingEventConnectionTelemetryThrottleHundredthsPercent="0",
	ClientConnectionAttemptResultPointsThrottleHundredthsPercent="0",
	ClientLightingTechnologyChangedTelemetryHundredthsPercent="0",ClientNetworkInfluxHundredthsPercentage="0",
	ClientReplicatorStatsEventsThrottleHP="0",ClientReportInitExpJobStatsHundredthPercent="0",
	ClientReportLuaConnectionSignalsInfluxHundrethsPercentage="0",
	ClientSideUserHashingTelemetryThrottleHundredthsPercent="0",ClientStatsWithFacsBWPerHundPercent="0",
	CollectAnalyticsForSystemMenu="false",CollectSessionBatteryTelemetry="false",
	CollectionServicePerformanceTelemetryThrottleHP="0",CollectionsQueryUsageTelemetryEnabled="false",
	ComponentManagerTelemetryThrottleHundrethsPercent="0",ComponentMapLiveStatsThrottleHundredthsPercent="0",
	ConfigModuleRequireAttemptReportHundredthsPercentage="0",ConnectionClosedPointsThrottleHundredthsPercent="0",
	ContentProviderPreloadHangTelemetryHundredthsPercentage="0",CookieProtocolAnalyticsHundredthsPercentage="0",
	CookieProtocolAnalyticsPriorityHundredthsPercentage="0",CoreGuiRenderOverflowKicksReportHundredthsPercent="0",
	CoreScriptTelemetryDownSamplingThousandthsPercent="0",CoreScriptsAnalyticsHundredthsPercentage="0",
	CrashUploadForceFullPercentagePlaceId="0",CrashUploadToBacktracePercentage="0",
	CrashUploadToSentryWindowsPercentage="0",CsgOperationMetricsHundredthsPercentage="0",
	DPJProgressHaltReportThrottleHP="0",DataModelPatcherErrorInfluxHundredthsPercentage="0",
	DataModelPatcherFunnelInfluxHundredthsPercentage="0",DataPingTracerFpsInfoThrottleHundredthsPercent="0",
	DataStoreInfluxReportNonParsableDataPerMyriad="0",DataStoreInfluxReportNonParsableDataPerMyriadWithKey="0",
	DestroyedModuleRequireReportHundredthsPercentage="0",DetailedBandwidthStatsInfluxHundrethsPercentage="0",
	DisconnectReasonDiagThrottlePercent="0",DownloadBandwidthNetworkIdFailInfluxHundredthsPercentage="0",
	DragDetectorDragAnalyticsThrottleHundredthsPercent="0",DynamicReloaderFailureInfluxHundrethsPercentage="0",
	DynamicReloaderFileFailureInfluxHundrethsPercentage="0",DynamicTextureManagerReportingHundredthsPercent="0",
	EditableImageEventStreamReportPercent="0",EditableImageInitLoggingHundredthsPercentage="0",
	EditableMemoryTelemetryHundredthsPercentage="0",EditableMeshAPIUsageLoggingHundredthsPercentage="0",
	EditableMeshInitLoggingHundredthsPercentage="0",EditableMeshRuntimeErrorLoggingHundredthsPercentage="0",
	EditableMeshSessionLoggingHundredthsPercentage="0",EditableMeshUnpublishLoggingHundredthsPercentage="0",
	EditableSessionTelemetryHundredthsPercentage="0",EmitFSSizeTelemetry="false",EmitFSUploadTelemetry="false",
	EmitOpTypeInRCCTelemetry="false",EmitSSSnapSizeTelemetry="false",EnableAdRewardNotificationTelemetry="false",
	EnableAnimatorApiTelemetryToGrafana="false",EnableAudioPlayerTelemetry2="false",
	EnableAvatarChangeTelemetryJoinDelay="false",EnableAvatarFacechatReplOverRCCTelemetry="false",
	EnableCCLAbilityUsageTelemetry="false",EnableCCLCustomAbilityPointsSampling="false",
	EnableCCLLibraryLoadTelemetry="false",EnableCanvasGroupRenderPathTelemetry2="false",
	EnableCppSoundTelemetry7="false",EnableCrossExperienceVoiceIgnoreLowMemoryWarningTelemetry="false",
	EnableDLICAdoptionTelemetry="false",EnableDeprecatedPerformPurchaseTelemetry="false",
	EnableDesktopWebViewTelemetry="false",EnableDesktopWebViewTelemetryUrlField="false",
	EnableForceOTAAnalytics="false",EnableInExperienceAvatarChangeTelemetry="false",
	EnableLogCullingTelemetryForControl="false",EnableModifiedAudioTelemetry="false",
	EnablePartyVoiceMemoryPhaseTelemetry="false",
	EnablePaymentsProtocolPerformSubscriptionPurchaseTelemetry="false",EnablePerfDataGatherTelemetry2="false",
	EnablePerfStatsAPI="false",EnablePlayersGetFriendsAsyncTelemetry="false",EnablePreloadingTelemetry="false",
	EnableRobloxSubscriptionPurchaseEngineTelemetry="false",EnableUploadTelemetry="false",
	EnableWebGameJoinBtidTelemetry="false",EnableWebLoginTokenTelemetry="false",
	EngineStabilityRandomDeferReportingPercentage="0",EngineStabilityReportThrottleHundredthsPercent="0",
	EphemeralStatsInfluxReportingPriorityHundredthsPercent="0",
	EphemeralStatsInfluxReportingThrottleHundredthsPercent="0",EventIngestInstrumentThrottleHundrethsPercent="0",
	ExtractPackageDefinition_DehydrationGameRccPointsHundredthsPercent="0",
	ExtractPackageDefinition_DehydrationTelemetryHundredthsPercent="0",
	ExtractPackageDefinition_HydrationGameRccPointsHundredthsPercent="0",
	ExtractPackageDefinition_HydrationTelemetryHundredthsPercent="0",FrustumPerfTelemetryThrottleHP="0",
	GamePassPurchaseAnalyticsThrottleHundredthsPercent="0",GamePhysicsMetricsReportingHundredthsPercentage="0",
	GetDiskUsageSamplingPercent="0",GpuHDRSupportReportThrottleHundredthsPercent="0",
	GraphicsVulkanAnalyticsHundredthPercent="0",GroupsApiUsageTelemetryHundredthsPercent="0",
	GuiClassUsageAnalytics_ReportHundredthsPercent="0",
	GuiServiceChromeSignalAPIAnalytics_ReportHundredthsPercent="0",
	GuiServiceMenuConnectionTelemetry_ReportHundredthsPercent="0",
	GuiServiceSetMenuOpenTelemetry_ReportHundredthsPercent="0",HSRMismatchTelemetryHundredthsPercentage="0",
	Http2StatsHundredthsPercent="0",HttpBatchApiShutdownInfluxHundrethsPercentage="0",
	HttpCacheCleanupMetricsHundredthsPercent="0",HttpConnTrackPointsHundredthsPercent="0",
	HttpConnXferPointsHundredthsPercent="0",HttpDownloadBandwidthInfluxHundredthsPercentage="0",
	HttpDownloadBandwidthInfluxHundredthsPercentageV2="0",HttpGAFailureReportPercent="0",
	HttpInfluxHundredthsPercentage="0",HttpInfluxReportsPerMillion="0",HttpReportCLI111800HundredthsPercent="0",
	HttpServiceAggregateBandwidthReportThrottleHundredthsPercentage="0",
	HttpServiceBandwidthReportThrottleHundredthsPercentage="0",HttpServiceEventReportThrottleHundredthPercent="0",
	HttpServiceOpenCloudReportUrlHundredthsPercentage="0",
	HttpServicePluginRequestReportThrottleHundredthPercent="0",
	HttpServiceRequestTimeReportThrottleHundredthsPercentage="0",HttpServiceTlsProbeInfluxHundrethsPercentage="0",
	HttpServiceTransportFailureInfluxHundrethsPercentage="0",HttpStatsDnsErrorInfluxReportsPerMillion="0",
	HttpStatsErrorInfluxReportsPerMillion="0",HttpWrapperTelemetryHundredthsPercent="0",
	HumanoidAssetSwapperOnApplyNewMakeupAssetsLoggingHundredthsPercentage="0",
	HumanoidSimWorldReportPercentageHundredths="0",HumanoidStateChangeEventIngestThrottleHundrethsPercent="0",
	IASReportPlaceStatUsageHundrethsPercent="0",ISRInputPingStatsTelemetryThrottleHundredthsPercent="0",
	IdempotentDevProductPurchaseAnalyticsThrottleHundredthsPercent="0",
	IkControlTelemetryEventsThrottleHundrethsPercent="0",
	ImmersiveAdImpressionEventPointsThrottleHundrethsPercent="0",
	ImmersiveAdLoadPointsThrottleHundredthsPercent="0",ImmersiveAdPerfDataPointsThrottleHundredthsPercent="0",
	ImmersiveAdProgressPointsThrottleHundredthsPercent="0",
	ImmersiveAdTeleportEventPointsThrottleHundrethsPercent="0",
	ImmersiveAdUnloadPointsThrottleHundredthsPercent="0",
	ImmersiveAdVideoCompletionEventPointsThrottleHundrethsPercent="0",
	ImmersiveAdViewableImpressionPointsThrottleHundredthsPercent="0",
	InferredCrashReportToBacktraceThrottleHundredthsPercentage="0",InfluxReportRCCStatsHundredthsPercentage="0",
	InfluxReportingPackageAnalyticsHundrethsPercent="0",
	InvalidNumPropertyAssignReportHundredthsPercentage="0",InvalidStringAtomReportHundredthsPercentage="0",
	InvalidTelemetryInputEventThrottleHundredthsPercentage="0",JoinAllInfluxHundredthsPercentage="0",
	JoinGameFailureInfluxHundredthsPercentage="0",JoinInfluxHundredthsPercentage="0",
	JoinInfoLengthReportHundredthsPercentage="0",KeyboardLayoutUsage_ReportHundredthsPercent="0",
	LDLPGSStatsRatePercent="0",LargePropertiesAnalyticsHundredthsPercentage="0",
	LcDeformerPropertySetEventHundredthsPercentageSentEventIngest="0",LegacyStyleUsed_ReportPercentHundredths="0",
	LegacyTelemetryStatsActionThrottleHundredthsPercent="0",LibMpTelemetrySamplePermyriad="0",
	LinkingProtocolInfluxEventIngestsHundredthsPercentage="0",LinkingProtocolInfluxHundredthsPercentage="0",
	LinkingProtocolInfluxPointsHundredthsPercentage="0",LinkingProtocolInfluxPriorityHundredthsPercentage="0",
	LmsDisableReportingHundredthPercent="0",LmsInfluxDbHundredthsPercentage="0",
	LoadAssetAsyncTelemetryThrottleHundredthsPercent="0",LoadAssetTelemetryThrottleHundredthsPercent="0",
	LoadAssetVersionTelemetryThrottleHundredthsPercent="0",
	LoadStreamAnimationFailureTelemetryHundredthsPercentage="0",
	LocServicePerformanceAnalyticsHundredthsPercentage="0",LocalizationAnalyticsSamplesPerMillion="0",
	LocalizationTableAnalyticsSenderClientToServerSampleRateHundrethsPercent="0",
	LocalizationTableAnalyticsSenderServerToHttpSampleRateHundrethsPercent="0",
	LogLineReportingHundredthsPercent="0",LogReportingStatsHundredthsPercent="0",
	LongAvatarAssetTelemetryThrottleHundredthsPercent="0",LuaGcStatsCycleEphemeralHundrethsPercentage="0",
	LuaGcStatsEphemeralHundrethsPercentage="0",LuaGcStatsInfluxHundrethsPercentage="0",
	LuaGcStatsNonDefaultInfluxHundrethsPercentage="0",LuauCodegenAggregateStatsEventHundredthsPercent="0",
	LuauCodegenStatsEventHundredthsPercent="0",LuauHeapProfilerTelemetryHundredthsPercentage="0",
	LuauRefinementTelemetryInfluxPriorityHundredthsPercentage="0",
	LuobuDevPublishAnalyticsHundredthsPercentage="0",MarketplaceApiUsageTelemetryHundredthsPercent="0",
	MemoryPageFaultsTelemetryEnabledHundredthPercent="0",MeshCompressionSampleRateHundredthsPercent="0",
	MeshSimplificationLoggingHundredthPercentage="0",MissingDataPingReportThrottleHundredthsPercent="0",
	NavigationServiceInfluxDbPercentStatsReported="0",NetPermEventReportPerMyriadEventIngest="0",
	NetworkDataSenderHaltReportThrottleHP="0",NetworkEmulationConfigPointsThrottleHundredthsPercent="0",
	NetworkFilterReportSizingRemovalCharacterHundrethsPercentage="0",NetworkObjectsStatsHundredthsPercentage="0",
	NetworkPhysicsSenderHaltReportThrottleHP="0",NetworkReportJDIProcessingKibanaPerHunPercent="0",
	NewCSGAPISessionStatsHundredthsPercentage="0",NewSettingsEndpointExceptionInfluxPermyriad="0",
	OpenTelemetrySampleRateHundredthPercent="0",PPJProgressHaltReportThrottleHP="0",
	PackageAnalyticsHundredthsPercentage="0",PacketErrorInfluxHundredthsPercentage="0",
	ParallelLuaStatsEventHundredthsPercent="0",ParallelLuaStatsInfluxHundrethsPercentage="0",
	PathfindingHFBHighMemoryThrottleHundrethsPercentPoints="0",
	PathfindingHighComputeImplTimeReportThrottleHundrethsPercentPoints="0",
	PathfindingLargeTileThrottleHundrethsPercentPoints="0",
	PathfindingPartPositionExceedTileCapacityThrottleHundrethsPercentPoints="0",
	PathfindingRaycastLoopCapThrottleHundrethsPercentPoints="0",
	PathfindingStatsPerRequestThrottleHundrethsPercentEIPerRequest="0",
	PathfindingStatsPerRequestThrottleHundrethsPercentEIPerSession="0",
	PathfindingStatsPerRequestThrottleHundrethsPercentPoints="0",PerPauseStatsInfluxHundredthsPercentage="0",
	PercentApiRequestsRecordGoogleAnalytics="0",PercentReportingLeaveGameAnalytics="0",
	PercentileTelemetryHundredPercent="0",PerfDataAdaptiveTelemetryV2ThrottleHundredthsPercent="0",
	PerfDataOnTelemetryV2ThrottleHundredthsPercent="0",
	PerformanceControlComputeTelemetryHundredthPercentageSentEventIngest="0",
	PerformanceControlComputeTelemetryHundredthPercentageSentPoint="0",
	PerformanceControlEventIngestHundredthPercentageSent="0",PerformanceControlPointsHundredthPercentageSent="0",
	PerformanceControlTelemetryHundredthPercentageSentEventIngest="0",
	PerformanceControlTelemetryHundredthPercentageSentPoint="0",
	PerformanceTelemetryGlobalThrottleHundredthsPercent="0",PhysicsMemoryTelemetryHundredthsPercentage="0",
	PlayerApiUsageTelemetryHundredthsPercent="0",PlayerHumanoidTypeAnalyticsReportPercent="0",
	PlayersApiUsageTelemetryHundredthsPercent="0",PostJoinSetsStatsHundredths="0",
	PredictedSpawnPrewarmStatsThrottleHP="0",ProductInfoCacheInvalidatedTelemetryHundredthsPercent="0",
	PurchasePayloadOutcomeTelemetryThrottleHundredthsPercent="0",
	RCCPhysicsSimulationLoadStatsReportingThresholdPercentHundredths="0",
	RCCSimulatingInterpolationCorrectionDistanceReportingThresholdPercentHundredths="0",
	RCCThumbnailReportHundredthsPercent="0",RM3T0CadenceExperimentTelemetryHundredthsPercent="0",
	RUCalculation_ReportHundredthsPercent="0",RUDryRunTelemetryHundredthsPercent="0",
	RakNetDecryptionFailureReportHundredthsPercent="0",RakNetMissingPingPongReportThrottleHundredthsPercent="0",
	RakNetPingTracePointsEventThrottlePerMillion="0",RakNetStoppedProductionReportHundredthsPercentage="0",
	RaknetBandwidthInfluxHundredthsPercentageV2="0",RaknetDownloadBandwidthInfluxHundredthsPercentage="0",
	RbxStorageCategoryStatsThrottleHP="0",RbxStorageRollingStatsHundredthsPercent="0",
	RbxTelemetryForTelemetryBindingsEventThrottleHundredthsPercentage="0",
	RbxTransportDummyClientPingStatsThrottleHP="0",
	RbxmFileManagerOperationalEventLoggingThrottleHundredthsPercent="0",RccTemporaryAutosaveLoggingPercentage="0",
	RealtimeMediaRtcStatsThrottleHundredthsPercent="0",ReceiptHandlingTelemetryEventHundredthsPercent="0",
	RenderReportShadowMapUpdateTimeHundredthPercent="0",RenderShaderLoadAnalyticsHundredthPercent="0",
	ReplicatorDataPingReportHundredthPercentage="0",ReplicatorJdiReportThrottlePercent="0",
	ReplicatorJoinDataItemStatsInfluxHundrethsPercentage="0",
	ReplicatorJoinDataItemV2StatsInfluxHundrethsPercentage="0",ReplicatorJoinSnapInfluxHundrethsPercentage="0",
	ReplicatorVariantSpeedReportPerHundredthPercentage="0",ReportAUMPAnalyticsPercentageHundredths="0",
	ReportAnimationReplicationTelemetry="false",ReportBadGlyphProviderIdHundredthsPercent="0",
	ReportBaseNetworkMetricsStatsHundredths="0",ReportBasePlayerGuiClassUsageTelemetryHundredthsPercent="0",
	ReportBatchedRaycastTelemetry="false",ReportCharHashDescriptionLCEventsThrottleHundrethsPercent="0",
	ReportClientJoinRxStatsHundrethsPercentage="0",ReportClientProcessPacketMetricsStatsHundredths="0",
	ReportContextActionServiceBindEventsHundrethsPercent2="0",ReportControllerManagerPercent="0",
	ReportDeadKickCodeUsageDetailedHundredthsPercentage="0",ReportDeadKickCodeUsageHundredthsPercentage="0",
	ReportDebugCallstackThrottleHundredthPercent="0",ReportDropPktStatsToInflux_HundredthsPercentage="0",
	ReportGamepadUsageEventThrottleHundrethsPercent="0",ReportHangStatusThrottleHundredthPercent="0",
	ReportHumanoidRigPercentageHundredths="0",
	ReportInteractivitySelectionModeSummaryEventThrottleHundrethsPercent="0",
	ReportJoinDataItemCacheEfficiencyHundrethsPercentage2="0",
	ReportJoinDataItemV2CacheEfficiencyHundrethsPercentage2="0",
	ReportJoinInstaceStatsToEventIngestHundredthsPercent="0",ReportLatencyStatsHundredthsPercentage="0",
	ReportLightTypeTelemetry="false",ReportLodDataStatsHundredthsPercentage="0",
	ReportManifestParseLoadingErrorHundrethsPercentage="0",ReportMeshLodTelemetry="false",
	ReportMeshManagerUsedUnusedTelemetry="false",ReportMeshManagerVersionTelemetry="false",
	ReportMeshStreamingTelemetry3="false",ReportNetworkSyncMemoryUsage2HundredthsPercentage="0",
	ReportOutputDeviceInfoEventRateHundredthsPercentage="0",ReportOutputDeviceInfoRateHundredthsPercentage="0",
	ReportParameterContentHundredthsPercent="0",ReportPath2DAnalyticsEnabled_Perf="false",
	ReportPath2DInstanceAPICallsHundrethsPercent="0",ReportPath2DRecomputeTimeHundrethsPercent="0",
	ReportPhysicsFPSStatsForInfluxHundredthsPercentage="0",ReportRTLSupportValueThrottleHundrethsPercent="0",
	ReportRaknetDeferredTimeMsHundredthsPercentage="0",ReportRbxTransportTimeDifferenceTelemetry="false",
	ReportRbxTransportTimeInitializationTelemetry="false",
	ReportRecordingDeviceInfoEventRateHundredthsPercentage="0",
	ReportRecordingDeviceInfoRateHundredthsPercentage="0",
	ReportReplicateDestroySettingInfluxHundredthsPercentage="0",
	ReportReplicatorSessionSummaryStatsToInfluxHundredthsPercent="0",
	ReportReplicatorStatsToInfluxHundredthsPercent="0",ReportRigDescriptionCountTelemetry="false",
	ReportSimulationToFBLatencyInfluxHundredthsPercentage="0",
	ReportTextScraperHttpFailureMessageHundredthsPercentage="0",ReportTextureStreamingTelemetry7="false",
	ReportTimeBetweenTTClientHundredthsPercentage="0",ReportTimeBetweenTTServerHundredthsPercentage="0",
	ReportTopReplicationContainerAndAvatarStatsHundredths="0",
	ReportUserInputServiceGestureEventsHundrethsPercent="0",ReportVREnabledEventThrottleHundrethsPercent3="0",
	ReportVRRefreshRateChangeBelowLowerBoundThrottleHundrethsPercent="0",
	ReportVirtualCursorEventThrottleHundrethsPercent3="0",ReportollectionServiceEventThrottleHundrethsPercent="0",
	RestrictedReadStatsHundredthsPercent="0",
	RobloxTelemetryAvatarEditorServiceItemDetailsBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryAvatarMetricsTrackSingularAssetRequestThrottleHundredthsPercent="0",
	RobloxTelemetryClientDisconnectEventsThrottleHundredthsPercent="0",
	RobloxTelemetryClientDisconnectPointsThrottleHundredthsPercent="0",
	RobloxTelemetryDeveloperSubscriptionProductInfoAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryGamePassOwnershipBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryGamePassesProductInfoBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryGetBundleDetailsBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryLoadTestEndThrottleHundredthsPercent="0",
	RobloxTelemetryLoadTestEndV2ThrottleHundredthsPercent="0",
	RobloxTelemetryLoadTestStartThrottleHundredthsPercent="0",
	RobloxTelemetryLogDeleteFailureEventThrottleHundredthsPercent="0",
	RobloxTelemetryMarketplaceDeprecatedSubscriptionFuncUseThrottleHundredthsPercent="0",
	RobloxTelemetryPacketMissFrameWindowMetricsThrottleHundredthsPercent="0",
	RobloxTelemetryProductInfoBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryProductInfoBatchingValidationAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryRankProductsBatchingAnalyticsThrottleHundredthsPercent="0",
	RobloxTelemetryRccDisconnectEventsThrottleHundredthsPercent="0",
	RobloxTelemetryRccDisconnectPointsThrottleHundredthsPercent="0",
	RobloxTelemetryRealtimeConnectionEventsThrottleHundredthsPercent="0",
	RobloxTelemetryRealtimeEventsThrottleHundredthsPercent="0",
	RobloxTelemetrySharedStringReplicationPointsThrottleHundredthsPercent="0",
	RobloxTelemetryStatThresholdHundredthsPercent="0",
	RobloxTelemetryTopRecommendedProductsBatchingAnalyticsThrottleHundredthsPercent="0",
	RuntimeContentTelemetryHundredthsPercentage="0",RuntimeInjectorTelemetryThrottleHundredthsPercent="0",
	RuppDeserializationErrorReportHundredthsPercent="0",
	ScreenGuiSafeAreaPropertiesAnalyticsEventIngest_ReportHundredthsPercent="0",
	ScreenGuiTopbarSafeInsetsAnalyticsEventIngest_ReportHundredthsPercent="0",
	ScreenTimeStatReporterToInfluxHundredthsPercentage="0",ScriptContextTelemetryThrottleHundredthsPercent="0",
	SendJoinTimeDeltasToDiagLuobu_HundredthsPercentage="0",SendJoinTimeDeltasToDiag_HundredthsPercentage="0",
	SendLegacyChatTelemetry="false",SendLowMemoryTelemetry2="false",SendRenderFidelityTelemetry2="false",
	SendScreenOrientationToEventIngestHundredthsPercentage="0",
	ServerReportRakNetBandwidthTelemetryHundredthsPercentage="0",ServerStatsReportingPerHundPercent="0",
	SessionPauseStatsInfluxHundredthsPercentage="0",
	SessionReportAppSuccessEventIngestThrottleHundredthsPercent="0",
	SessionReportAppSuccessPointsThrottleHundredthsPercent="0",
	SessionReportCrashErrorEventIngestThrottleHundredthsPercent="0",
	SessionReportCrashErrorPointsThrottleHundredthsPercent="0",
	SessionReportSuccessEventIngestThrottleHundredthsPercent="0",
	SessionReportSuccessPointsThrottleHundredthsPercent="0",SessionStreamTotalStatsThrottleHP="0",
	SimAeroDedupCollisionTelemetryHundredthsPercentage="0",SimFluidSaveOrPublishStatsHundredthsPercentage="0",
	SimFluidSessionStatsHundredthsPercentage="0",SimPhysicsSteppingMethodStatsHundredthsPercentage="0",
	SimReportAveWorldstepTimeEventIngestPercent="0",SimReportAveWorldstepTimePercent="0",
	StrictStringConvertReportHundredthsPercentage="0",StyleQueryUsageAnalytics_ReportHundredthsPercent="0",
	StylingAnalyticsHundredthsPercentage="0",StylingAnalyticsPostGameSessionEventHundredthsPercentage="0",
	SurfaceControllerErrorTelemetryThrottleHundredthsPercent="0",TaskLibExclusiveReportHundredthsPercentage="0",
	TaskLibReportBadDesynchronizeCallHundrethsPercentage="0",
	TaskLibReportBadSynchronizeCallHundrethsPercentage="0",TcClientReplicatorStatsEventsThrottleHP="0",
	TcServerReplicatorStatsEventsThrottleHP="0",
	TeamCreateSaveCompressionFailureTelemetryThrottleHundredthsPercent="0",
	TelemetryContextInfoMismatchThrottleHundredthPercent="0",TelemetryProfilerHundredthsPercentage="0",
	TelemetryStressTestPerMyriad="0",TelemetryStressTestPerMyriad2="0",
	TeleportClientNetworkErrorInfluxHundredthsPercentage="0",TeleportErrorDebugInfluxHundredthsPercentage="0",
	TeleportExceptionInfluxHundredthsPercentage="0",TeleportV2InvocationsAnalyticsInfluxHundredthsPercentage="0",
	TeleportV2InvocationsInfluxHundredthsPercentage="0",TeleportV2TeleportSuccessInfluxHundredthsPercentage="0",
	TeleportValidationErrorInfluxHundredthsPercentage="0",
	TextChatServiceRoundtripLatencySampleRateHundrethsPercent="0",
	TextChatTelemetrySendAsyncFailureThrottlePermyriad="0",
	TextSafetyAnalyticsSenderClientToServerSampleRateHundrethsPercent="0",
	TextScraperReportMatchedExpiredSourceHundredthsPercent="0",TextUsageData_ReportHundredthsPercent="0",
	TouchQueueMetricsInfluxHundredthsPercentage2="0",TraceRouteTelemetryRealThrottleHundredthsPercent="0",
	TraceRouteTelemetryThrottleHundredthsPercent="0",TrackingGcStatsHundredths="0",
	UICornerStats_ReportHundredthsPercent="0",UIDragDetectorDragAnalyticsThrottleHundredthsPercent="0",
	UIListLayoutStats_ReportHundredthsPercent2="0",UIPerfSplitCoreDev_ReportHundredthsPercent2="0",
	UISYS1483_ReportRatePercentHundredths="0",UIScrollingTime_ReportHundredthsPercent2="0",
	UIShadowStats_ReportHundredthsPercent="0",UIStylingUpdateTime_ReportHundredthsPercent="0",
	UITimeOnGameLoaded_ReportHundredthsPercent="0",Vector3CurveTelemetryEventsThrottleHundrethsPercent="0",
	VideoFrameErrorMetricsReportHundredthsPercent="0",VideoMetricsABRReportPlaySessionHundredthsPercent="0",
	VideoMetricsClientHundredthsPercent="0",VideoMetricsClientHundredthsPercentMomentsOverride="0",
	VideoMetricsServiceHundredthsPercent="0",VideoOldEncryptedVideoFormatMetricsReportHundredthsPercent="0",
	VideoRCCMetricsReportHundredthsPercent="0",VideoSamplerCreatedHundredthsPercent="0",
	VideoSamplerGetSamplesAtTimesAsyncHundredthsPercent="0",
	VideoServiceMetricsEventstreamReportHundredthsPercent="0",VideoStatsInfluxReportHundredthsPercent="0",
	VideoStatsInfluxReportHundredthsPercentMomentsOverride="0",VideoTTFFMetricsReportHundredthsPercent="0",
	VideoTTFFMetricsReportHundredthsPercentMomentsOverride="0",VideoThumbnailMetricsReportHundredthsPercent="0",
	VoiceChatCallEndTelemetryHundredthsPercentage="0",VoiceChatNoIceCandidatesTelemetryHundredthsPercentage="0",
	VoiceChatPeerConnectionFailedTelemetryThrottleHundredthsPercent="0",
	VoiceRtcStatsEventIngestThrottleHundredthsPercent="0",
	VoiceRtcStatsSplitEventIngestThrottleHundredthsPercent="0",
	VoiceVolumeControlsChangePerUserEventIngestThrottleHundredthsPercent="0",
	VoiceVolumeControlsJoinEventIngestThrottleHundredthsPercent="0",
	VoiceVolumeControlsLeaveEventIngestThrottleHundredthsPercent="0",
	VoiceVolumeControlsPointsThrottleHundredthsPercent="0",WHAM1707UploadFailureTelemetryPercent="0",
	WeakExpiredRequireReportHundredthsPercent="0",WebSocketConnectResultPointsHundredthsPercent="0",
	WebSocketDisconnectPointsHundredthsPercent="0",WebStreamClientEventReportThrottleHundredthPercent="0",
	WinLinkingProtocolInfluxHundredthsPercentage="0",WinLinkingProtocolInfluxPriorityHundredthsPercentage="0",
	WindowsNewWebBrowserTelemetryThrottleHundredthsPercent="0",
	WindowsWebViewTelemetryThrottleHundredthsPercent="0",WiringApiEventIngestHundredthsPercent="0",
	WiringApiReportingHundredthsPercent="0",WrapDeformerCreationLoggingHundredthsPercentage="0",
	WrapLayeredDeformerTextureTransferLoggingHundredthsPercentage="0",
	WrapTextureTransferOnPerformTransferLoggingHundredthsPercentage="0",
	kAssetsUploadApiFlowTelemetryEventLoggingPerMyriad="0",
}

local elsCanFlag = type(setfflag) == "function"
local ELS_PREFIX = { "DFFlag", "DFInt", "DFString", "DFLog", "FFlag", "FInt", "FString", "FLog" }
local function ElsFlag(k, v)
	pcall(setfflag, k, v)
	for _, p in ipairs(ELS_PREFIX) do
		if string.sub(k, 1, #p) == p then
			pcall(setfflag, string.sub(k, #p + 1), v)
			break
		end
	end
end

if elsCanFlag then
	if ElsConfig.Telemetry ~= false then
		task.defer(function()
			for k, v in pairs(ELS_TELEMETRY) do pcall(setfflag, k, v) end
			ElsMark("telemetry")
		end)
	end
	if ElsConfig.LowGraphics ~= false then
		for k, v in pairs({
			DebugFRMQualityLevelOverride = "1",
			RenderLocalLightUpdatesMax = "1", RenderLocalLightUpdatesMin = "1",
			FastGPULightCulling3 = "True",
			DebugGraphicsPreferD3D11 = "True", DebugGraphicsPreferD3D11FL10 = "True",
			GraphicsEnableD3D10Compute = "True", DebugGraphicsDisableDirect3D11 = "False",
			FIntFRMMinGrassDistance = "0", FIntFRMMaxGrassDistance = "0", FIntRenderGrassDetailStrands = "0",
			FIntRenderShadowIntensity = "0", FIntDebugForceMSAASamples = "0", FFlagDisablePostFx = "True",
			DFFlagTextureQualityOverrideEnabled = "True", DFIntTextureQualityOverride = "1",
			FIntTerrainArraySliceSize = "4", FFlagDebugGraphicsDisableMetal = "False",
			DFIntCSGLevelOfDetailSwitchingDistance = "0", DFIntCSGLevelOfDetailSwitchingDistanceL12 = "0",
			DFIntCSGLevelOfDetailSwitchingDistanceL23 = "0", DFIntCSGLevelOfDetailSwitchingDistanceL34 = "0",
		}) do ElsFlag(k, v) end
	end
	if ElsConfig.NetFlags ~= false then
		for k, v in pairs({
			ClientPacketHealthyAllocationPercent = "100", ClientPacketMinMicroseconds = "0",
			MaxProcessPacketsStepsPerCyclic = "50", MaxProcessPacketsJobScaling = "100",
			MaxProcessPacketsStepsAccumulated = "150", ClientPacketMaxFrameMicroseconds = "200000",
			ClientPacketHealthyMsPerSecondLimit = "1000", ClientPacketUnhealthyContEscMsPerSecond = "1000",
			RakNetLoopMs = "1", MaxStreamPacketsPerStep = "128", MaxConsecutiveStreamJobWorkLoad = "8",
			TaskSchedulerTasksDefaultMaxTimeMsPerCycle = "30", GCReducesQuotaPercent = "0",
		}) do ElsFlag(k, v) end
	end
	if ElsConfig.ContentFlags ~= false then
		for k, v in pairs({
			AssetProviderWorkflowExecutorSleepMicroSeconds = "1000", NetAssetInlineBytesPerStep = "65536",
			ContentProviderJobDutyCycleMicroseconds = "8000", MaxContentProviderRunsPerStep = "40",
			MaxContentProviderRunsAccumulated = "80", HttpBatchApi_minWaitMs = "0", HttpBatchApi_maxWaitMs = "5",
			NumConcurrentBatchWorkflowsPerAssetProviderInstance = "8", DynamicTextureManagerPrepareBudgetMicroSeconds = "8000",
			TM2SkipMipsForUnstreamable2 = "True", FixTextureCompositorFramebufferManagement2 = "True",
			DebugDisableExpensiveDedupNetAssetCompare = "true",
		}) do ElsFlag(k, v) end
	end
	if ElsConfig.PauseContent ~= false then
		-- pause meshes/textures while the game replicates, resume once the character or bases arrive
		local ELS_PAUSE = {
			DebugRenderMeshPauseContentRequests = true,
			DebugContentProviderSkipPreloadFromTextureManager = true,
			DebugPauseVoxelizer = true,
		}
		for k in pairs(ELS_PAUSE) do ElsFlag(k, "true") end
		Els.Paused = true
		task.spawn(function()
			local t0 = os.clock()
			repeat
				local lp = Players.LocalPlayer
				local c = lp and lp.Character
				if c and c:FindFirstChild("HumanoidRootPart") then break end
				local plots = Workspace:FindFirstChild("Plots")
				if plots and #plots:GetChildren() > 0 then break end
				task.wait()
			until os.clock() - t0 > 20
			for k in pairs(ELS_PAUSE) do ElsFlag(k, "false") end
			Els.Paused = false
			ElsMark("unpause")
		end)
	end
	ElsMark("flags")
end

-- Els Hub: compiled right away so it can run as soon as LocalPlayer exists
local elsHubFn
do
	-- combined build (hub+loader in one file): the hub is embedded at the top of
	-- the file in _ELS_EMBEDDED_HUB. In loader-only mode this global is nil and we
	-- fall back to HubFile / HubUrl, so the same file works both ways.
	local embedded = _ELS_EMBEDDED_HUB
	if type(embedded) == "string" and embedded ~= "" then
		local okL, fn, err = pcall(loadstring, embedded, "=ElsHub")
		if okL and fn then
			elsHubFn = fn
			Els.HubSource = "embedded"
			ElsMark("hub-compiled")
		else
			warn(ELS_TAG .. " embedded Els Hub failed to compile: " .. tostring(err or fn))
		end
	end
	local file = ElsConfig.HubFile
	if not elsHubFn and type(file) == "string" and file ~= "" and isfile and readfile then
		local okE, exists = pcall(isfile, file)
		if okE and exists then
			local okR, src = pcall(readfile, file)
			if okR and type(src) == "string" then
				local okL, fn, err = pcall(loadstring, src, "=ElsHub")
				if okL and fn then
					elsHubFn = fn
					Els.HubSource = file
					ElsMark("hub-compiled")
				else
					warn(ELS_TAG .. " Els Hub failed to compile: " .. tostring(err or fn))
				end
			end
		end
	end
end

-- Els Junk: useless folders (Els Hub removes them too, this is just earlier)
if ElsConfig.Junk ~= false then
	local ELS_JUNK = { Sounds = ReplicatedStorage, PlayWaveEvents = ReplicatedStorage, Events = Workspace }
	local function elsJunk(x)
		local where = ELS_JUNK[x.Name]
		if where and x.Parent == where then ElsDestroy(x) end
	end
	ReplicatedStorage.ChildAdded:Connect(elsJunk)
	Workspace.ChildAdded:Connect(elsJunk)
	for _, c in ipairs(ReplicatedStorage:GetChildren()) do elsJunk(c) end
	for _, c in ipairs(Workspace:GetChildren()) do elsJunk(c) end

	-- like fastload: remove ReplicatedStorage.Controllers.EventController (not in the
	-- hub's KEEP list, so safe). With NoBrainrotPreload = true, also remove
	-- BrainrotPreloadingController — but the hub KEEPS that one, so leave it false.
	local ELS_CTRL_KILL = { EventController = true }
	if ElsConfig.NoBrainrotPreload == true then ELS_CTRL_KILL.BrainrotPreloadingController = true end
	local function elsControllers(f)
		if f.Name ~= "Controllers" or f.Parent ~= ReplicatedStorage then return end
		local function elsEvt(x)
			if ELS_CTRL_KILL[x.Name] then ElsDestroy(x) end
		end
		f.ChildAdded:Connect(elsEvt)
		for _, x in ipairs(f:GetChildren()) do elsEvt(x) end
	end
	ReplicatedStorage.ChildAdded:Connect(elsControllers)
	local elsCtrl = ReplicatedStorage:FindFirstChild("Controllers")
	if elsCtrl then elsControllers(elsCtrl) end
end

-- Els Machines: fuses, incubator, wheels, boards, shops… same list as Els Hub
-- (WS_KILL), destroyed on arrival. Big floors (>= 30x30, low) are moved out first,
-- like Els_KillKeepFloor, so you never fall into the void.
if ElsConfig.NoMachines ~= false then
	local ELS_MACHINES = {
		FuseMachine = true, HalloweenFuseMachine = true, XzFusionMECircuit6zX = true,
		IncubatorMachine = true, CraftingMachine = true, JumpLTMMachine = true,
		RNGMachine = true, DiggingMachine = true,
		CrystalSpinWheel = true, EclipseSpinWheel = true, EclipseWheel = true, RoueEclipse = true,
		AdminBoard = true, SoccerScoreBoard = true, EventBoard = true,
		RobuxShop = true, ShopNPCRobuxIdle = true, LosTraders = true, TradePlazaPortal = true,
		StPatricksPot = true, UFO = true, Present = true,
	}
	local elsFloorKeep
	local function elsIsFloor(p)
		if not (p:IsA("BasePart") and p.CanCollide) then return false end
		local s = p.Size
		return math.max(s.X, s.Z) >= 30 and math.min(s.X, s.Z) >= 30 and p.Position.Y < 30 and p.Name ~= "Part"
	end
	local function elsKillMachine(x)
		if not ELS_MACHINES[x.Name] or x.Parent ~= Workspace then return end
		if ElsBusy() or ElsKeep(x) then return end
		-- Els Hub already loaded: let it handle this with its own function
		if type(_G.Els_KillKeepFloor) == "function" then
			pcall(_G.Els_KillKeepFloor, x)
			return
		end
		local floors = {}
		local ok, list = pcall(x.GetDescendants, x)
		if ok then
			for _, d in ipairs(list) do
				if elsIsFloor(d) then floors[#floors + 1] = d end
			end
		end
		if #floors > 0 then
			if not (elsFloorKeep and elsFloorKeep.Parent) then
				elsFloorKeep = Instance.new("Folder")
				elsFloorKeep.Name = "ElsLoaderFloorKeep"
				elsFloorKeep:SetAttribute("ElsVisual", true)
				elsFloorKeep.Parent = Workspace
			end
			for _, f in ipairs(floors) do pcall(function() f.Parent = elsFloorKeep end) end
		end
		task.defer(pcall, x.Destroy, x)
	end
	-- a model sometimes arrives empty then fills: wait a frame before sorting floors
	Workspace.ChildAdded:Connect(function(x)
		if ELS_MACHINES[x.Name] then task.defer(elsKillMachine, x) end
	end)
	for _, c in ipairs(Workspace:GetChildren()) do elsKillMachine(c) end
end

-- Els Moving Animals: scrolling brainrots are never rendered (the hub removes the
-- folder too, this is from the first child)
if ElsConfig.NoMovingAnimals ~= false then
	task.spawn(function()
		local rma = Workspace:WaitForChild("RenderedMovingAnimals", 60)
		if not rma then return end
		local function elsUnrender(x)
			if ElsBusy() then return end
			task.defer(pcall, x.Destroy, x)
		end
		rma.ChildAdded:Connect(elsUnrender)
		for _, x in ipairs(rma:GetChildren()) do elsUnrender(x) end
		ElsMark("rma")
	end)
end

-- Els Loading: Roblox + game loading screens
if ElsConfig.HideLoading ~= false then
	task.spawn(function()
		for _ = 1, 30 do
			pcall(function() ReplicatedFirst:RemoveDefaultLoadingScreen() end)
			if game:IsLoaded() then break end
			task.wait(0.1)
		end
	end)
	task.spawn(function()
		local cg = game:FindFirstChildOfClass("CoreGui")
		if not cg then return end
		local function elsHideLayer(x)
			if x:IsA("LayerCollector") then pcall(function() x.Enabled = false end) end
		end
		local ELS_CORE_LOADING = { RobloxLoadingGUI = true, DevGUIBlackoutCurtain = true }
		local function elsLift(x)
			if not ELS_CORE_LOADING[x.Name] then return end
			elsHideLayer(x)
			for _, d in ipairs(x:GetDescendants()) do elsHideLayer(d) end
			x.DescendantAdded:Connect(elsHideLayer)
		end
		for _, c in ipairs(cg:GetChildren()) do elsLift(c) end
		cg.ChildAdded:Connect(elsLift)
	end)
	task.spawn(function()
		local lp = Players.LocalPlayer
		while not lp do
			task.wait()
			lp = Players.LocalPlayer
		end
		local pg = lp:WaitForChild("PlayerGui", 30)
		if not pg then return end
		-- only disable (no Destroy): if the game looks for the GUI it still finds it
		local function elsHideLoad(g)
			if not g:IsA("ScreenGui") or string.sub(g.Name, 1, 3) == "Els" then return end
			local ln = string.lower(g.Name)
			if string.find(ln, "load", 1, true) or string.find(ln, "intro", 1, true) or string.find(ln, "splash", 1, true)
				or string.find(ln, "transition", 1, true) or string.find(ln, "curtain", 1, true) then
				pcall(function() g.Enabled = false end)
			end
		end
		for _, g in ipairs(pg:GetChildren()) do elsHideLoad(g) end
		local con = pg.ChildAdded:Connect(elsHideLoad)
		task.delay(30, function() con:Disconnect() end)
	end)
end

-- Els No3D (optional): no 3D rendering until the character is here
if ElsConfig.No3D == true then
	pcall(function() RunService:Set3dRenderingEnabled(false) end)
	task.spawn(function()
		local t0 = os.clock()
		repeat
			local lp = Players.LocalPlayer
			if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then break end
			task.wait()
		until os.clock() - t0 > 25
		pcall(function() RunService:Set3dRenderingEnabled(true) end)
	end)
end

-- Els Effects: post-process, shadows, atmosphere
if ElsConfig.NoEffects ~= false then
	task.spawn(function()
		pcall(function() Lighting.GlobalShadows = false end)
		local ELS_FX = { BloomEffect = true, BlurEffect = true, SunRaysEffect = true, DepthOfFieldEffect = true, Atmosphere = true }
		local elsHooked = setmetatable({}, { __mode = "k" })
		local function elsFx(x)
			if not ELS_FX[x.ClassName] or string.sub(x.Name, 1, 3) == "Els" then return end
			if x:IsA("Atmosphere") then
				pcall(function() x.Density = 0; x.Haze = 0; x.Glare = 0 end)
				return
			end
			local function elsOff()
				pcall(function() x.Enabled = false end)
				if x:IsA("BlurEffect") then pcall(function() x.Size = 0 end) end
			end
			elsOff()
			if not elsHooked[x] then
				elsHooked[x] = true
				x:GetPropertyChangedSignal("Enabled"):Connect(function() if x.Enabled then elsOff() end end)
				if x:IsA("BlurEffect") then
					x:GetPropertyChangedSignal("Size"):Connect(function() if x.Size > 0 then elsOff() end end)
				end
			end
		end
		for _, x in ipairs(Lighting:GetChildren()) do elsFx(x) end
		Lighting.ChildAdded:Connect(elsFx)
		local elsCamCon
		local function elsCam(c)
			if elsCamCon then elsCamCon:Disconnect(); elsCamCon = nil end
			if not c then return end
			for _, x in ipairs(c:GetChildren()) do elsFx(x) end
			elsCamCon = c.ChildAdded:Connect(elsFx)
		end
		elsCam(Workspace.CurrentCamera)
		Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() elsCam(Workspace.CurrentCamera) end)
		Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
			if Lighting.GlobalShadows then pcall(function() Lighting.GlobalShadows = false end) end
		end)
	end)
end

-- Els Graphics: low quality + terrain
if ElsConfig.LowGraphics ~= false then
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
	pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
	pcall(function() settings().Rendering.EagerBulkExecution = true end)
	task.spawn(function()
		local t = Workspace:WaitForChild("Terrain", 30)
		if not t then return end
		pcall(function()
			if sethiddenproperty then sethiddenproperty(t, "Decoration", false) else t.Decoration = false end
		end)
		pcall(function() t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0 end)
	end)
end

-- Els Early Strip: the Map, before Els Hub takes over (only what the hub already
-- removes: decals/textures; effects are just disabled). Plots and characters are
-- never touched: the hub handles those.
if ElsConfig.EarlyStrip ~= false then
	task.spawn(function()
		local map = Workspace:WaitForChild("Map", 30)
		if not map then return end
		local ELS_MAP_FX = { ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true }
		local function elsStrip(d)
			local cn = d.ClassName
			if cn == "Decal" or cn == "Texture" then
				if not ElsKeep(d) then ElsDestroy(d) end
			elseif ELS_MAP_FX[cn] then
				pcall(function() d.Enabled = false end)
			end
		end
		local con = map.DescendantAdded:Connect(elsStrip)
		for _, d in ipairs(map:GetDescendants()) do elsStrip(d) end
		ElsMark("map")
		task.delay(30, function() con:Disconnect() end)
	end)
end

-- Els Prio Bases: request the bases first from ContentProvider
if ElsConfig.PrioBases ~= false then
	task.spawn(function()
		local plots = Workspace:WaitForChild("Plots", 30)
		if not plots then return end
		local t = os.clock()
		while #plots:GetChildren() == 0 and os.clock() - t < 20 do task.wait() end
		local list = plots:GetChildren()
		if #list == 0 then return end
		local t1 = os.clock()
		pcall(function() ContentProvider:PreloadAsync(list) end)
		print(string.format("%s bases preloaded at %.2fs (%d bases, %.2fs)", ELS_TAG, os.clock() - ELS_T0, #list, os.clock() - t1))
		ElsMark("prio")
	end)
end

-- Els Game Buttons: hide the game's big left-side buttons. We hide (Visible =
-- false), never destroy, so game scripts that look for them still find them.
-- Matched by name OR text (FR + EN, the game translates the text), and only when
-- at least 3 of these buttons share the same ScreenGui.
if ElsConfig.HideGameButtons ~= false then
	task.spawn(function()
		local lp = Players.LocalPlayer
		while not lp do
			task.wait()
			lp = Players.LocalPlayer
		end
		local pg = lp:WaitForChild("PlayerGui", 30)
		if not pg then return end

		-- full PlayerGui scans wait until load is done: during load they would take
		-- CPU from the game for nothing
		if not game:IsLoaded() then game.Loaded:Wait() end

		local ELS_BUTTON_KEYS = {
			boutique = true, shop = true, store = true,
			renaissance = true, rebirth = true, rebirths = true,
			index = true,
			duels = true, duel = true,
			echange = true, echanges = true, trade = true, trades = true, trading = true,
			codes = true, code = true,
		}
		local function elsKey(s)
			if type(s) ~= "string" or s == "" then return nil end
			s = string.lower(s)
			s = string.gsub(s, "\195\169", "e") -- é
			s = string.gsub(s, "\195\168", "e") -- è
			s = string.gsub(s, "[^%a]", "")
			return s
		end
		local function elsMatches(btn)
			if ELS_BUTTON_KEYS[elsKey(btn.Name) or ""] then return true end
			for _, d in ipairs(btn:GetDescendants()) do
				if d:IsA("TextLabel") or d:IsA("TextButton") then
					if ELS_BUTTON_KEYS[elsKey(d.Text) or ""] or ELS_BUTTON_KEYS[elsKey(d.Name) or ""] then return true end
				end
			end
			if btn:IsA("TextButton") and ELS_BUTTON_KEYS[elsKey(btn.Text) or ""] then return true end
			return false
		end

		local elsHidden = setmetatable({}, { __mode = "k" })
		local function elsHide(btn)
			pcall(function() btn.Visible = false end)
			if elsHidden[btn] then return end
			elsHidden[btn] = true
			btn:GetPropertyChangedSignal("Visible"):Connect(function()
				if btn.Visible then pcall(function() btn.Visible = false end) end
			end)
		end

		local function elsScan()
			for _, sg in ipairs(pg:GetChildren()) do
				if sg:IsA("ScreenGui") and string.sub(sg.Name, 1, 3) ~= "Els" then
					local found = {}
					for _, d in ipairs(sg:GetDescendants()) do
						if d:IsA("GuiButton") and not elsHidden[d] and elsMatches(d) then
							found[#found + 1] = d
						end
					end
					-- already seen once in this ScreenGui: accept latecomers
					local known = sg:GetAttribute("ElsButtonsHidden") == true
					if #found >= 3 or (known and #found > 0) then
						for _, b in ipairs(found) do elsHide(b) end
						pcall(function() sg:SetAttribute("ElsButtonsHidden", true) end)
						if not Els.ButtonsHidden then
							Els.ButtonsHidden = true
							ElsMark("buttons")
						end
					end
				end
			end
		end

		local queued = false
		local function elsQueue()
			if queued then return end
			queued = true
			task.delay(0.25, function()
				queued = false
				pcall(elsScan)
			end)
		end
		pcall(elsScan)
		local con = pg.DescendantAdded:Connect(elsQueue)
		for _, t in ipairs({ 2, 5, 10, 20, 40 }) do task.delay(t, elsQueue) end
		task.delay(60, function() con:Disconnect() end)
	end)
end

-- Els Notifications: game messages ("you locked your base…", "X robbed you…").
-- The hub keeps NotificationController loaded, so we don't touch the script, only
-- the display: the GUI stays (Enabled/Visible = false), the controller can keep
-- writing to it with no error, nothing shows and nothing renders.
if ElsConfig.NoNotifications ~= false then
	task.spawn(function()
		local lp = Players.LocalPlayer
		while not lp do
			task.wait()
			lp = Players.LocalPlayer
		end
		local pg = lp:WaitForChild("PlayerGui", 30)
		if not pg then return end

		local elsOff = setmetatable({}, { __mode = "k" })
		local function elsKeepOff(x, prop)
			pcall(function() x[prop] = false end)
			if elsOff[x] then return end
			elsOff[x] = true
			x:GetPropertyChangedSignal(prop):Connect(function()
				if x[prop] then pcall(function() x[prop] = false end) end
			end)
			if not Els.NotificationsHidden then
				Els.NotificationsHidden = true
				ElsMark("notif")
			end
		end
		local function elsIsEls(x)
			return string.sub(x.Name, 1, 3) == "Els"
		end
		local function elsNotifName(x)
			return string.find(string.lower(x.Name), "notif", 1, true) ~= nil
		end
		local function elsNorm(s)
			s = string.lower(s)
			s = string.gsub(s, "<[^>]->", "")    -- RichText tags
			s = string.gsub(s, "\195\169", "e")  -- é
			s = string.gsub(s, "\195\168", "e")  -- è
			return s
		end
		-- message phrases FR + EN (never "voler"/"steal" alone: those are steal prompts)
		local ELS_NOTIF_WORDS = {
			"verrouill", "locked", " a vole", "vous a vole", "vole votre", "vole ton", "stole",
		}

		local function elsHideTop(lbl, sg)
			local top, depth = lbl, 0
			while top.Parent and top.Parent ~= sg do
				top = top.Parent
				depth = depth + 1
			end
			if top:IsA("GuiObject") then elsKeepOff(top, "Visible") end
			-- message placed near the root = notifications ScreenGui: the next ones
			-- will be hidden as they arrive
			if depth <= 1 then
				pcall(function() sg:SetAttribute("ElsNotifHost", true) end)
			end
		end

		local function elsCheck(x)
			if not x.Parent then return end
			if x:IsA("ScreenGui") then
				if not elsIsEls(x) and elsNotifName(x) then elsKeepOff(x, "Enabled") end
				return
			end
			if not x:IsA("GuiObject") then return end
			local sg = x:FindFirstAncestorOfClass("ScreenGui")
			if not sg or elsIsEls(sg) or elsOff[sg] then return end
			-- ScreenGui already seen: anything new placed at its root is hidden
			if x.Parent == sg and sg:GetAttribute("ElsNotifHost") == true then
				elsKeepOff(x, "Visible")
				return
			end
			-- container named "Notification…"
			local a = x
			while a and a ~= sg do
				if elsNotifName(a) and a:IsA("GuiObject") then
					elsKeepOff(a, "Visible")
					return
				end
				a = a.Parent
			end
			-- otherwise match the message text
			if x:IsA("TextLabel") and x.Text ~= "" then
				local t = elsNorm(x.Text)
				for _, w in ipairs(ELS_NOTIF_WORDS) do
					if string.find(t, w, 1, true) then
						elsHideTop(x, sg)
						return
					end
				end
			end
		end

		-- text is often set just after the label is created: recheck a frame later
		pg.DescendantAdded:Connect(function(x)
			task.defer(elsCheck, x)
			if x:IsA("TextLabel") then task.delay(0.1, elsCheck, x) end
		end)
		for _, x in ipairs(pg:GetDescendants()) do pcall(elsCheck, x) end
	end)
end

-- Els Big Tags: like fastload, a tag on buyable brainrots whose generation exceeds
-- BigTagMin (name + generation), in Els colors. Tags live in the PlayerGui (the hub
-- destroys Workspace BillboardGuis). Display only: buying stays the game's.
if ElsConfig.BigTags ~= false then
	task.spawn(function()
		local CollectionService = game:GetService("CollectionService")
		local lp = Players.LocalPlayer
		while not lp do
			task.wait()
			lp = Players.LocalPlayer
		end
		if not game:IsLoaded() then game.Loaded:Wait() end
		local pg = lp:WaitForChild("PlayerGui", 30)
		if not pg then return end
		local okD, datas = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Datas", 30):WaitForChild("Animals", 30))
		end)
		if not okD or type(datas) ~= "table" then return end
		local minGen = tonumber(ElsConfig.BigTagMin) or 10e6

		local old = pg:FindFirstChild("ElsBigTags")
		if old then old:Destroy() end
		local elsTagGui = Instance.new("ScreenGui")
		elsTagGui.Name = "ElsBigTags"
		elsTagGui.ResetOnSpawn = false
		elsTagGui.Parent = pg

		local ELS_BG = Color3.fromRGB(6, 22, 44)
		local ELS_ACC = Color3.fromRGB(20, 84, 140)
		local ELS_ACC2 = Color3.fromRGB(120, 186, 228)
		local ELS_TXT = Color3.fromRGB(226, 238, 248)

		local function elsMoney(n)
			for _, u in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
				if n >= u[1] then return string.format("%.1f%s/s", n / u[1], u[2]) end
			end
			return string.format("%d/s", math.floor(n + 0.5))
		end

		local elsTags = {}
		local function elsUntag(prompt)
			local t = elsTags[prompt]
			if t then
				elsTags[prompt] = nil
				pcall(function() t:Destroy() end)
			end
		end
		local function elsTag(prompt)
			if elsTags[prompt] or not prompt:IsA("ProximityPrompt") then return end
			local adorn = prompt.Parent
			if not adorn or not (adorn:IsA("Attachment") or adorn:IsA("BasePart")) then return end
			local model = prompt:FindFirstAncestorWhichIsA("Model")
			local idx = model and model:GetAttribute("Index")
			local info = type(idx) == "string" and datas[idx]
			if type(info) ~= "table" or (tonumber(info.Generation) or 0) < minGen then return end

			local bb = Instance.new("BillboardGui")
			bb.Name = "ElsBigTag"
			bb.Adornee = adorn
			bb.Size = UDim2.fromOffset(220, 26)
			bb.StudsOffset = Vector3.new(0, 4, 0)
			bb.MaxDistance = 300
			bb.LightInfluence = 0
			bb.AlwaysOnTop = true
			local card = Instance.new("Frame")
			card.Size = UDim2.fromScale(1, 1)
			card.BackgroundColor3 = ELS_BG
			card.BackgroundTransparency = 0.1
			card.BorderSizePixel = 0
			card.Parent = bb
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = card
			local stroke = Instance.new("UIStroke")
			stroke.Color = ELS_ACC
			stroke.Thickness = 1.2
			stroke.Parent = card
			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 13
			lbl.TextColor3 = ELS_TXT
			lbl.RichText = true
			lbl.Text = string.format('%s  <font color="#%s">%s</font>',
				tostring(info.DisplayName or idx), ELS_ACC2:ToHex(), elsMoney(tonumber(info.Generation) or 0))
			lbl.Parent = card
			bb.Parent = elsTagGui
			elsTags[prompt] = bb
			prompt.AncestryChanged:Connect(function(_, parent)
				if parent == nil then elsUntag(prompt) end
			end)
		end

		local TAG = "AnimalPurchasePrompt"
		CollectionService:GetInstanceAddedSignal(TAG):Connect(function(p) task.defer(elsTag, p) end)
		CollectionService:GetInstanceRemovedSignal(TAG):Connect(elsUntag)
		for _, p in ipairs(CollectionService:GetTagged(TAG)) do pcall(elsTag, p) end
		ElsMark("tags")
	end)
end

-- Els Esc Menu: Esc opens a small Els menu (Leave / Reset), like OPTI. The Roblox
-- menu is closed when the executor can reach it.
if ElsConfig.EscMenu ~= false then
	task.spawn(function()
		local UserInputService = game:GetService("UserInputService")
		local GuiService = game:GetService("GuiService")
		local lp = Players.LocalPlayer
		while not lp do
			task.wait()
			lp = Players.LocalPlayer
		end

		-- re-close the Roblox menu (SettingsHub) if it opens; without access it just stays open
		local elsSettingsHub
		local function elsCloseRobloxMenu()
			pcall(function()
				if not elsSettingsHub then
					local cg = game:GetService("CoreGui")
					local mod = cg.RobloxGui.Modules.Settings.SettingsHub
					elsSettingsHub = require(mod)
				end
				elsSettingsHub:SetVisibility(false, true)
			end)
		end
		pcall(function()
			GuiService.MenuOpened:Connect(function()
				task.defer(elsCloseRobloxMenu)
			end)
		end)

		local ELS_BG = Color3.fromRGB(6, 22, 44)
		local ELS_ROW = Color3.fromRGB(10, 32, 60)
		local ELS_LINE = Color3.fromRGB(28, 70, 110)
		local ELS_TXT = Color3.fromRGB(226, 238, 248)
		local ELS_DIM = Color3.fromRGB(120, 156, 190)
		local ELS_BAD = Color3.fromRGB(240, 106, 106)
		local ELS_ACC = Color3.fromRGB(20, 84, 140)

		local function elsMake(class, props, parent)
			local x = Instance.new(class)
			for k, v in pairs(props) do x[k] = v end
			if parent then x.Parent = parent end
			return x
		end
		local function elsRound(x, r) elsMake("UICorner", { CornerRadius = UDim.new(0, r) }, x) end

		local elsMenuGui = elsMake("ScreenGui", {
			Name = "ElsEscMenu", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2147482000,
		})
		local elsWin = elsMake("Frame", {
			Name = "ElsWindow",
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(200, 124), BackgroundColor3 = ELS_BG,
			BackgroundTransparency = 0.03, BorderSizePixel = 0, Visible = false,
		}, elsMenuGui)
		elsRound(elsWin, 12)
		elsMake("UIStroke", { Color = ELS_ACC, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, elsWin)
		elsMake("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		}, elsWin)
		elsMake("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, elsWin)
		elsMake("TextLabel", {
			Name = "ElsTitle", LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = ELS_DIM,
			TextXAlignment = Enum.TextXAlignment.Left, Text = "ELS · MENU",
		}, elsWin)

		local elsActions = {}
		local function elsShow(v) elsWin.Visible = v end
		local function elsAdd(order, key, label, color, action)
			local b = elsMake("TextButton", {
				Name = "Els" .. label, LayoutOrder = order, Size = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = ELS_ROW, BorderSizePixel = 0, AutoButtonColor = false,
				Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Left, Text = label,
			}, elsWin)
			elsRound(b, 8)
			elsMake("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, b)
			elsMake("TextLabel", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
				TextSize = 12, TextColor3 = ELS_DIM, TextXAlignment = Enum.TextXAlignment.Right, Text = key.Name,
			}, b)
			b.MouseEnter:Connect(function() b.BackgroundColor3 = ELS_LINE end)
			b.MouseLeave:Connect(function() b.BackgroundColor3 = ELS_ROW end)
			b.Activated:Connect(function() elsShow(false) action() end)
			elsActions[key] = action
		end
		elsAdd(1, Enum.KeyCode.L, "Leave", ELS_BAD, function()
			game:Shutdown()
		end)
		elsAdd(2, Enum.KeyCode.R, "Reset", ELS_TXT, function()
			local c = lp.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if h then h.Health = 0 end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if UserInputService:GetFocusedTextBox() then return end
			local kc = input.KeyCode
			if kc == Enum.KeyCode.Escape then
				elsShow(not elsWin.Visible)
				task.defer(elsCloseRobloxMenu)
			elseif elsWin.Visible and elsActions[kc] then
				elsShow(false)
				elsActions[kc]()
			end
		end)

		elsMenuGui.Parent = lp:WaitForChild("PlayerGui")
		Els.EscMenu = elsMenuGui
	end)
end

-- Els Launch: start Els Hub, then measure the load
task.spawn(function()
	local lp = Players.LocalPlayer
	while not lp do
		task.wait()
		lp = Players.LocalPlayer
	end
	ElsMark("player")

	-- Els Hub sets _G.Els_CarpetAll on its first line: if present, it is already running (autoexec)
	if _G.Els_CarpetAll ~= nil or ElsEnv.__ElsHubRan then
		Els.HubSource = "autoexec"
		print(ELS_TAG .. " Els Hub already running, no double load")
	else
		if not elsHubFn and type(ElsConfig.HubUrl) == "string" and ElsConfig.HubUrl ~= "" then
			local okH, src = pcall(function() return game:HttpGet(ElsConfig.HubUrl) end)
			if okH and type(src) == "string" then
				local okL, fn, err = pcall(loadstring, src, "=ElsHub")
				if okL and fn then
					elsHubFn = fn
					Els.HubSource = ElsConfig.HubUrl
					ElsMark("hub-compiled")
				else
					warn(ELS_TAG .. " Els Hub (url) failed to compile: " .. tostring(err or fn))
				end
			else
				warn(ELS_TAG .. " could not download Els Hub: " .. tostring(src))
			end
		end
		if elsHubFn and _G.Els_CarpetAll == nil then
			ElsEnv.__ElsHubRan = true
			task.spawn(function()
				local ok, err = pcall(elsHubFn)
				if not ok then warn(ELS_TAG .. " Els Hub error: " .. tostring(err)) end
			end)
			ElsMark("hub")
		elseif not elsHubFn then
			warn(ELS_TAG .. " Els Hub not found (" .. tostring(ElsConfig.HubFile) .. ") — optimizations only")
		end
	end

	if not game:IsLoaded() then game.Loaded:Wait() end
	ElsMark("game")
	if not lp.Character then lp.CharacterAdded:Wait() end
	ElsMark("character")
	ElsEnv.LoadedIn = elsMarkT.character
	ElsEnv.LoadPending = nil
	Els.LoadedIn = elsMarkT.character
	elsTimerDone = true
	local plots = Workspace:WaitForChild("Plots", 30)
	if plots then
		local t = os.clock()
		while #plots:GetChildren() == 0 and os.clock() - t < 20 do task.wait() end
		ElsMark("bases")
	end
	-- data is ready once Els Hub reads the Synchronizer channels
	local t1 = os.clock()
	while os.clock() - t1 < 20 do
		local ok, reg = pcall(function() return _G.XenSyncAll and _G.XenSyncAll() end)
		if ok and type(reg) == "table" and next(reg) ~= nil then
			ElsMark("data")
			break
		end
		task.wait(0.05)
	end

	Els.Ready = true
	Els.DataIn = elsMarkT.data
	local line = os.date("%H:%M:%S") .. " " .. elsLoadTag .. " " .. table.concat(elsMarkList, " ")
	print(ELS_TAG .. " v" .. ELS_VERSION .. " " .. line)
	if ElsConfig.Timeline ~= false and writefile then
		pcall(function()
			local FILE = "Els_load_timeline.txt"
			local old = (isfile and isfile(FILE)) and readfile(FILE) or ""
			writefile(FILE, old .. line .. "\n")
		end)
	end
end)
