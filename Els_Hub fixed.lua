do
local fpsCap = (getgenv and getgenv().setfpscap) or setfpscap
if type(fpsCap) == "function" then pcall(fpsCap, 9999) end
end
do
local all = { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
local file = "Els_Carpet.json"
local choice
pcall(function()
if isfile and readfile and isfile(file) then
local d = game:GetService("HttpService"):JSONDecode(readfile(file))
if type(d) == "table" and type(d.tool) == "string" and table.find(all, d.tool) then choice = d.tool end
end
end)
_G.Els_CarpetAll = all
_G.Els_CarpetNames = nil
_G.Els_SetCarpet = function(name, save)
if not table.find(all, name) then return end
local list = _G.Els_CarpetNames or {}
table.clear(list)
list[1] = name
for _, n in ipairs(all) do
if n ~= name then list[#list + 1] = n end
end
_G.Els_CarpetNames = list
_G.Els_CarpetChoice = name
if save then
pcall(function() writefile(file, game:GetService("HttpService"):JSONEncode({ tool = name })) end)
end
end
_G.Els_SetCarpet(choice or all[1], false)
end
local function __elsSha256(message)
local band, bxor, bnot = bit32.band, bit32.bxor, bit32.bnot
local rrotate, rshift = bit32.rrotate, bit32.rshift
local U32 = 4294967296
local K = {
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}
local h0,h1,h2,h3 = 0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a
local h4,h5,h6,h7 = 0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
local function u32be(n)
return string.char(band(rshift(n,24),255), band(rshift(n,16),255), band(rshift(n,8),255), band(n,255))
end
local bitLen = #message * 8
message = message .. "\128"
while #message % 64 ~= 56 do message = message .. "\0" end
message = message .. u32be(math.floor(bitLen / U32)) .. u32be(bitLen % U32)
local w = {}
for chunk = 1, #message, 64 do
for i = 0, 15 do
local a,b,c,d = string.byte(message, chunk + i*4, chunk + i*4 + 3)
w[i+1] = ((a*256 + b)*256 + c)*256 + d
end
for i = 17, 64 do
local x, y = w[i-15], w[i-2]
local s0 = bxor(rrotate(x, 7), rrotate(x, 18), rshift(x, 3))
local s1 = bxor(rrotate(y, 17), rrotate(y, 19), rshift(y, 10))
w[i] = (w[i-16] + s0 + w[i-7] + s1) % U32
end
local a,b,c,d,e,f,g,h = h0,h1,h2,h3,h4,h5,h6,h7
for i = 1, 64 do
local S1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
local ch = bxor(band(e, f), band(bnot(e), g))
local t1 = (h + S1 + ch + K[i] + w[i]) % U32
local S0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
local maj = bxor(band(a, b), band(a, c), band(b, c))
local t2 = (S0 + maj) % U32
h, g, f, e = g, f, e, (d + t1) % U32
d, c, b, a = c, b, a, (t1 + t2) % U32
end
h0=(h0+a)%U32 h1=(h1+b)%U32 h2=(h2+c)%U32 h3=(h3+d)%U32
h4=(h4+e)%U32 h5=(h5+f)%U32 h6=(h6+g)%U32 h7=(h7+h)%U32
end
return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", h0,h1,h2,h3,h4,h5,h6,h7)
end
local __elsRemoteSecret = "2b857474-f9cc-4ddd-a4f1-28be8b6c1b38"
local function __elsCipher(name, jobId)
local out, pos = {}, 0
for i = 1, #name do
local c = string.byte(name, i)
if c == 47 then
out[i] = "/"
else
pos = pos + 1
local k = string.byte(jobId, (pos - 1) % #jobId + 1)
out[i] = string.char(((c - 32 + k) % 95) + 32)
end
end
return table.concat(out)
end
local __elsRemoteCache = {}
local __elsHashCache = {}
local function __elsHashFor(name)
local jobId = game.JobId
if type(jobId) ~= "string" or jobId == "" then return nil end
local key = name .. "|" .. __elsRemoteSecret .. "|" .. jobId
local h = __elsHashCache[key]
if not h then
h = __elsSha256(__elsCipher(name, jobId) .. __elsRemoteSecret .. jobId)
__elsHashCache[key] = h
end
return h
end
function _G.Els_GetRemoteByHash(name)
local hit = __elsRemoteCache[name]
if hit and hit.Parent then return hit end
local hash = __elsHashFor(name)
if not hash then return nil end
local pkgs = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
local Net = pkgs and pkgs:FindFirstChild("Net")
if not Net then return nil end
local r = Net:FindFirstChild("RE/" .. hash)
or Net:FindFirstChild("RF/" .. hash)
or Net:FindFirstChild("URE/" .. hash)
if r then __elsRemoteCache[name] = r end
return r
end
local __Els_GRAPPLE_ID = "75c9466d-e4c0-4b02-b26a-c3615fcc1e42"
function _G.Els_GrappleRemote()
return _G.Els_GetRemoteByHash(__Els_GRAPPLE_ID)
end
task.spawn(function()
local RunS = game:GetService("RunService")
local t0 = os.clock()
while os.clock() - t0 < 45 do
local jobId = game.JobId
if type(jobId) == "string" and jobId ~= "" then
pcall(__elsHashFor, __Els_GRAPPLE_ID)
local ok, r = pcall(_G.Els_GrappleRemote)
if ok and r then return end
end
RunS.Heartbeat:Wait()
end
end)
_G.__Els_GrappleFired = false
_G.__Els_KillQ = {}
do
local Players = game:GetService("Players")
local function pin(a)
if a and a.Name == "Animate" then
pcall(function() a.Disabled = true end)
end
end
local function hook(char)
if not char then return end
pin(char:FindFirstChild("Animate"))
char.ChildAdded:Connect(pin)
end
local function onLp(lp)
if not lp then return end
if lp.Character then hook(lp.Character) end
lp.CharacterAdded:Connect(hook)
end
local lp = Players.LocalPlayer
if lp then
onLp(lp)
else
Players.PlayerAdded:Connect(onLp)
end
end
do
local RS = game:GetService("ReplicatedStorage")
local KEEP = {
CustomProximityPromptController = true,
InteractController = true,
PlotController = true,
AnimalController = true,
PetController = true,
WorldBrainrotController = true,
EquipBrainrotsController = true,
EquipBrainrotsRenderController = true,
SelectBrainrotsController = true,
BrainrotPreloadingController = true,
AssetStreamController = true,
AdminPanelController = true,
NotificationController = true,
}
local function wrap(fn)
if newcclosure then
return newcclosure(fn)
end
return fn
end
local function isCtrlFolder(x)
return typeof(x) == "Instance" and x.Name == "Controllers" and x.Parent == RS
end
local function callerName()
if not getcallingscript then
return "?"
end
local ok, s = pcall(getcallingscript)
if not ok or s == nil then
return "nil"
end
return tostring(s.Name)
end
local function fromLoader()
return callerName() == "ClientLoader"
end
local function filt(kids)
if type(kids) ~= "table" then
return kids
end
local out = {}
for i = 1, #kids do
local k = kids[i]
if k and KEEP[k.Name] then
out[#out + 1] = k
end
end
return out
end
local oldNc
local undone = false
local function unhook()
if undone then return end
undone = true
pcall(function()
if oldNc then
hookmetamethod(game, "__namecall", oldNc)
end
end)
end
-- Els: the hook is only needed while ClientLoader lists its Controllers.
-- Before: for 6 s, every game method call went through getnamecallmethod +
-- string.lower + typeof. Now the cheapest check runs first (is it the
-- Controllers folder?) and the hook removes itself 1 s after the 1st filtering
-- (margin in case ClientLoader rereads the folder for init/start). 6 s is still the hard limit.
local ctrl = RS:FindFirstChild("Controllers")
RS.ChildAdded:Connect(function(c)
if c.Name == "Controllers" then ctrl = c end
end)
local filtered = false
pcall(function()
oldNc = hookmetamethod(game, "__namecall", wrap(function(self, ...)
if undone then
return oldNc(self, ...)
end
local c = ctrl
if c ~= nil then
if not rawequal(self, c) then
return oldNc(self, ...)
end
elseif not isCtrlFolder(self) then
return oldNc(self, ...)
end
local method = getnamecallmethod()
if type(method) ~= "string" or string.lower(method) ~= "getchildren" then
return oldNc(self, ...)
end
if not fromLoader() then
return oldNc(self, ...)
end
if not filtered then
filtered = true
task.delay(1, unhook)
end
return filt(oldNc(self, ...))
end))
end)
task.delay(6, unhook)
end
task.spawn(function()
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
if not lp then
lp = Players.PlayerAdded:Wait()
end
local rem
local function find(name)
local char = lp.Character
local bp = lp:FindFirstChild("Backpack")
return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end
local function remote()
if rem and rem.Parent then return rem end
local r = _G.Els_GrappleRemote and _G.Els_GrappleRemote()
if r then rem = r end
return r
end
local heldSince = nil
local watched = setmetatable({}, { __mode = "k" })
local function watchTool(g)
if not g or watched[g] then return end
watched[g] = true
pcall(function()
g.Equipped:Connect(function() heldSince = os.clock() end)
g.Unequipped:Connect(function() heldSince = nil end)
if g.Parent == lp.Character then heldSince = heldSince or os.clock() end
end)
end
local function tryEquipG()
local char = lp.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local g = find("Grapple Hook")
if g then watchTool(g) end
if g and hum and char and g.Parent ~= char then
pcall(function() hum:EquipTool(g) end)
return true
end
return char and char:FindFirstChild("Grapple Hook") ~= nil
end
local function hookBackpack(bp)
if not bp then return end
bp.ChildAdded:Connect(function(ch)
if _G.__Els_GrappleFired then return end
if ch and ch.Name == "Grapple Hook" then
tryEquipG()
end
end)
end
pcall(function()
lp.CharacterAdded:Connect(function()
if _G.__Els_GrappleFired then return end
tryEquipG()
end)
hookBackpack(lp:FindFirstChild("Backpack"))
lp.ChildAdded:Connect(function(ch)
if ch and ch.Name == "Backpack" then hookBackpack(ch) end
end)
if lp.Character then
tryEquipG()
end
end)
local held = 0
local t0 = os.clock()
while os.clock() - t0 < 15 do
if _G.__Els_GrappleFired then return end
local char = lp.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local g = find("Grapple Hook")
if g and hum and char then
if g.Parent ~= char then
pcall(function() hum:EquipTool(g) end)
held = 0
elseif char:FindFirstChild("Grapple Hook") then
held += 1
watchTool(g)
local r = remote()
local heldLong = heldSince ~= nil and (os.clock() - heldSince) >= 0.04
if (held >= 2 or heldLong) and r then
pcall(function() r:FireServer(0.33) end)
pcall(function() r:FireServer(0.33) end)
pcall(function() r:FireServer(0.33) end)
_G.__Els_GrappleFired = true
local tEq = os.clock() + 0.1
while os.clock() < tEq do
RunService.Heartbeat:Wait()
end
hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
local tw = os.clock()
local FLY = _G.Els_CarpetNames or { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
while os.clock() - tw < 0.4 do
char = lp.Character
hum = char and char:FindFirstChildOfClass("Humanoid") or hum
for _, fn in ipairs(FLY) do
local w = find(fn)
if w and hum and char then
if w.Parent ~= char then pcall(function() hum:EquipTool(w) end) end
if char:FindFirstChild(fn) then return end
end
end
RunService.Heartbeat:Wait()
end
return
end
else
held = 0
end
else
held = 0
end
RunService.Heartbeat:Wait()
end
end)
task.spawn(function()
local RS = game:GetService("ReplicatedStorage")
local KILL = {
RNGMachineVFX = true,
LuckIcons = true,
GlossaryBackground = true,
AnimationGraphEditor = true,
ML = true,
PlayWaveEvents = true,
}
local function yeet(ch)
if not ch then return end
pcall(function()
ch:Destroy()
end)
end
local function dropKill(ch)
if ch and KILL[ch.Name] then yeet(ch) end
end
local kids = RS:GetChildren()
for i = 1, #kids do dropKill(kids[i]) end
RS.ChildAdded:Connect(dropKill)
end)
task.wait()
local function _elsBusy()
return _G.__Els_VelFlying == true
end
local function __elsKeepVisual(inst)
while inst and inst~=workspace do
if inst:GetAttribute("ElsVisual")==true then return true end
inst=inst.Parent
end
return false
end
function _G.Els_Kill(inst)
if not inst or __elsKeepVisual(inst)then return end
if _elsBusy() then
local q = _G.__Els_KillQ
q[#q + 1] = inst
return
end
pcall(function() inst:Destroy() end)
end
local __elsFloorHolder
local function __elsIsFloor(p)
if not (p and p:IsA("BasePart")) or not p.CanCollide then return false end
local s = p.Size
local w = math.max(s.X, s.Z)
local l = math.min(s.X, s.Z)
return w >= 30 and l >= 30 and p.Position.Y < 30
end
_G.Els_IsFloor = __elsIsFloor
local FLOOR_KILL = { Part = true }
_G.Els_FloorKill = FLOOR_KILL
local function __elsKeepFloor(p)
return __elsIsFloor(p) and not FLOOR_KILL[p.Name]
end
function _G.Els_KillKeepFloor(inst)
if not inst or __elsKeepVisual(inst) then return end
if inst:IsA("BasePart") then
if __elsKeepFloor(inst) then return end
_G.Els_Kill(inst)
return
end
local floors = {}
pcall(function()
for _, d in ipairs(inst:GetDescendants()) do
if __elsKeepFloor(d) then floors[#floors + 1] = d end
end
end)
if #floors > 0 then
if not (__elsFloorHolder and __elsFloorHolder.Parent) then
__elsFloorHolder = Instance.new("Folder")
__elsFloorHolder.Name = "ElsFloorKeep"
__elsFloorHolder:SetAttribute("ElsVisual", true)
__elsFloorHolder.Parent = workspace
__elsFloorHolder.ChildAdded:Connect(function(ch)
if FLOOR_KILL[ch.Name] then pcall(function() ch:Destroy() end) end
end)
end
for i = 1, #floors do
pcall(function() floors[i].Parent = __elsFloorHolder end)
end
end
_G.Els_Kill(inst)
end
function _G.Els_FlushKills()
local q = _G.__Els_KillQ
_G.__Els_KillQ = {}
for i = 1, #q do
local x = q[i]
if x and x.Parent and not __elsKeepVisual(x)then pcall(function() x:Destroy() end) end
end
end
local function __elsStrip()
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local function kill(inst)
_G.Els_Kill(inst)
end
pcall(function() workspace.Terrain.Decoration = false end)
local WS_KILL = {
FriendPanel = true, Cash = true, Unlock = true, Purchases = true,
PlotSign = true, CashPad = true, InvisibleWalls = true, Multiplier = true,
Slope = true, IncubatorMachine = true, FuseMachine = true,
XzFusionMECircuit6zX = true, HalloweenFuseMachine = true, JumpLTMMachine = true,
RobuxShop = true,
AdminBoard = true, SoccerScoreBoard = true, CrystalSpinWheel = true, EclipseSpinWheel = true, EclipseWheel = true, RoueEclipse = true,
Beehive = true, CraftingMachine = true, Shop = true, Road = true,
EventBoard = true, TradePlazaPortal = true, LosTraders = true,
RNGMachine = true, Present = true, StPatricksPot = true,
ShopNPCRobuxIdle = true, RoadPanel = true, Honey = true,
Trap = true, Events = true, Sounds = true, rods = true,
Dev = true, ToolsAdds = true, __PROJECTILES = true, CrystalMap = true,
SpawnLocation = true, UFO = true, Interacts = true,
DiggingMachine = true,
}
local PLOT_KEEP = {
Skin = true, Laser = true, AnimalPodiums = true,
DeliveryHitbox = true, StealHitbox = true, AnimalTarget = true,
MainRoot = true, Floor = true, Spawn = true, Door = true, Hitbox = true,
Base = true, Wall = true, Roof = true, SecondFloor = true, ThirdFloor = true,
["structure base home"] = true, Unlock = true,
}
local PLOT_NUKE = {
FriendPanel = true, Cash = true, Purchases = true,
PlotSign = true, CashPad = true, InvisibleWalls = true, Multiplier = true,
LaserHitbox = true, Events = true, Sounds = true,
Slope = true,
}
local BODY_PART = {
HumanoidRootPart = true, Head = true, Torso = true,
UpperTorso = true, LowerTorso = true,
LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
RightUpperArm = true, RightLowerArm = true, RightHand = true,
LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
["Left Arm"] = true, ["Right Arm"] = true,
["Left Leg"] = true, ["Right Leg"] = true,
}
local CHAR_KEEP_CLASS = {
Humanoid = true, Animator = true, Attachment = true,
Motor6D = true, AnimationConstraint = true,
BallSocketConstraint = true, Weld = true, WeldConstraint = true,
}
local MAP_KEEP = { Ground = true, Ground_Left = true, Ground_Right = true }
local PART_CLASS = {
Part = true, MeshPart = true, UnionOperation = true,
WedgePart = true, CornerWedgePart = true, TrussPart = true,
SpawnLocation = true, Seat = true, VehicleSeat = true,
}
local function underUnlock(d)
local x = d
for _ = 1, 12 do
if not x then return false end
if x.Name == "Unlock" then return true end
if x == workspace then return false end
x = x.Parent
end
return false
end
local function isMine(inst)
if not (LP and inst) then return false end
if inst == LP.Character or inst.Name == LP.Name then return true end
return false
end
local function isVisualJunk(d)
local cn = d.ClassName
return cn == "Beam" or cn == "Trail" or cn == "ParticleEmitter"
or cn == "PointLight" or cn == "SpotLight" or cn == "SurfaceLight"
or cn == "Fire" or cn == "Smoke" or cn == "Sparkles"
or cn == "BillboardGui" or cn == "SurfaceGui" or cn == "Highlight"
or cn == "Decal" or cn == "Texture"
end
local function isSkinJunk(d)
if not d then return false end
if isVisualJunk(d) then return true end
return PART_CLASS[d.ClassName] == true and not d.CanCollide
end
local function isPet(inst)
if not inst or inst.ClassName ~= "Model" then return false end
return inst:FindFirstChild("FakeRootPart") ~= nil
or inst:FindFirstChild("RootPart") ~= nil
end
local function stripSkin(skin)
if not (skin and skin.Parent) then return end
local dd = skin:GetDescendants()
local dump = {}
for i = 1, #dd do
if isSkinJunk(dd[i]) then dump[#dump + 1] = dd[i] end
end
for i = 1, #dump do kill(dump[i]) end
end
local function skipLaserStrip(plot)
local keep = _G.__Els_KeepPlot
if not keep then
return true
end
return plot and tostring(plot.Name) == tostring(keep)
end
local function skipTimerStrip(plot)
return skipLaserStrip(plot)
end
local function plotOf(d)
local x = d
for _ = 1, 16 do
if not x then return nil end
local p = x.Parent
if p and p.Name == "Plots" then return x end
x = p
end
return nil
end
local function isRemainingTimeGui(d)
if not d then return false end
local x = d
for _ = 1, 16 do
if not x then break end
if x.Name == "RemainingTime" then return true end
x = x.Parent
end
local cn = d.ClassName
if cn == "BillboardGui" or cn == "SurfaceGui" then
local hit
pcall(function()
hit = d:FindFirstChild("RemainingTime", true)
end)
if hit then return true end
end
return false
end
local function stripPurchasesKeepTimer(purch)
if not (purch and purch.Parent) then return end
local kids = purch:GetChildren()
for i = 1, #kids do
local ch = kids[i]
if ch.Name ~= "PlotBlock" then
kill(ch)
else
local dd = ch:GetDescendants()
for j = 1, #dd do
local d = dd[j]
local cn = d.ClassName
if (cn == "BillboardGui" or cn == "SurfaceGui") and not isRemainingTimeGui(d) then
kill(d)
end
end
end
end
end
local laserPend = {}
local function stripLaser(laser)
if not (laser and laser.Parent) then return end
if skipLaserStrip(laser.Parent) then return end
local bars = {}
local beamPart = {}
local dd = laser:GetDescendants()
for i = 1, #dd do
local d = dd[i]
if d.ClassName == "Beam" then
local a0, a1 = d.Attachment0, d.Attachment1
local p0 = a0 and a0.Parent
local p1 = a1 and a1.Parent
if p0 and p0:IsA("BasePart") then beamPart[p0] = true end
if p1 and p1:IsA("BasePart") then beamPart[p1] = true end
elseif d:IsA("BasePart") then
bars[#bars + 1] = d
end
end
if #bars > 0 then
local chosen = {}
for i = 1, #bars do
if beamPart[bars[i]] then chosen[#chosen + 1] = bars[i] end
end
if #chosen == 0 then
for i = 1, #bars do
local d = bars[i]
local s = d.Size
local mx = math.max(s.X, s.Y, s.Z)
local mn = math.min(s.X, s.Y, s.Z)
local neon = false
pcall(function()
neon = d.Material == Enum.Material.Neon
or d.Material == Enum.Material.ForceField
end)
if neon or (mn <= 1.5 and mx >= 3) then
chosen[#chosen + 1] = d
end
end
end
if #chosen == 0 then chosen = bars end
local keep = chosen[1]
if keep then
for i = 1, #bars do
if bars[i] ~= keep then kill(bars[i]) end
end
pcall(function()
if PART_CLASS[laser.ClassName] then
laser.CanCollide = false
laser.CanTouch = false
end
keep.CanCollide = false
keep.CanTouch = false
end)
end
end
end
local function queueStripLaser(laser)
if not laser or laserPend[laser] then return end
laserPend[laser] = true
task.defer(function()
laserPend[laser] = nil
stripLaser(laser)
end)
end
local function stripPetVfx(pet)
if not pet then return end
local dd = pet:GetDescendants()
local dump = {}
for i = 1, #dd do
local d = dd[i]
local n = d.Name
local cn = d.ClassName
if n == "VfxInstance" or n == "_VfxInstance" or n == "AnimationController"
or cn == "ParticleEmitter" or cn == "Beam" or cn == "Trail"
or cn == "Fire" or cn == "Smoke" or cn == "Sparkles"
or cn == "Animator" or cn == "AnimationController"
or cn == "Bone"
or cn == "BillboardGui" or cn == "SurfaceGui" then
dump[#dump + 1] = d
end
end
for i = 1, #dump do kill(dump[i]) end
end
_G.Els_StripPetVfx = stripPetVfx
do
-- Els: the carried brainrot escaped cleanup (isMine ignores my character)
-- -> same strip as base brainrots, visual only
local carriedDone = setmetatable({}, { __mode = "k" })
local function petAncestor(x)
while x and x ~= workspace and x ~= game do
if isPet(x) then return x end
x = x.Parent
end
return nil
end
local function stripCarried(m)
if not m or carriedDone[m] then return end
carriedDone[m] = true
task.defer(function() pcall(stripPetVfx, m) end)
end
local function scanCarried()
local char = LP and LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local ok, parts = pcall(function() return hrp:GetConnectedParts(true) end)
if ok and type(parts) == "table" then
for i = 1, #parts do
local p = parts[i]
if not p:IsDescendantOf(char) then stripCarried(petAncestor(p)) end
end
end
for _, d in ipairs(char:GetDescendants()) do
if d.ClassName == "Model" then stripCarried(petAncestor(d)) end
end
-- the game can also show the carried brainrot as a separate model
-- (Workspace, a Workspace folder, or the camera) that follows the character:
-- take any brainrot outside Plots within 20 studs of me
local plots = workspace:FindFirstChild("Plots")
local function near(m)
local ok, piv = pcall(function() return m:GetPivot() end)
return ok and (piv.Position - hrp.Position).Magnitude < 20
end
local function check(x)
if x.ClassName ~= "Model" or x == char or x:FindFirstChildOfClass("Humanoid") then return end
if isPet(x) or x:FindFirstChildWhichIsA("AnimationController", true) then
if near(x) then stripCarried(x) end
end
end
for _, root in ipairs({ workspace, workspace.CurrentCamera }) do
if root then
for _, x in ipairs(root:GetChildren()) do
if x ~= plots and x ~= char then
if x.ClassName == "Folder" or (x.ClassName == "Model" and not isPet(x) and not x:FindFirstChildOfClass("Humanoid")) then
for _, y in ipairs(x:GetChildren()) do check(y) end
else
check(x)
end
end
end
end
end
end
local function isStealing()
if LP and LP:GetAttribute("Stealing") == true then return true end
local c = LP and LP.Character
return c ~= nil and c:GetAttribute("Stealing") == true
end
local scanning = false
local function onSteal()
if not isStealing() or scanning then return end
-- during the whole steal: one scan right away, then every 0.5 s
-- (the carried model can appear or be recreated late)
scanning = true
task.spawn(function()
task.wait(0.05)
while isStealing() do
pcall(scanCarried)
task.wait(0.5)
end
scanning = false
end)
end
local function hookMyChar(char)
if not char then return end
char.DescendantAdded:Connect(function(d)
if d.ClassName == "Model" then task.defer(function() stripCarried(petAncestor(d)) end) end
end)
char:GetAttributeChangedSignal("Stealing"):Connect(onSteal)
end
if LP then
if LP.Character then hookMyChar(LP.Character) end
LP.CharacterAdded:Connect(hookMyChar)
LP:GetAttributeChangedSignal("Stealing"):Connect(onSteal)
onSteal()
end
end
do
-- Els: base brainrots = just their name
-- The 3D model is destroyed (Els_Kill, like sweepNonPrio).
-- The name comes from the data (AnimalList.Index) and is shown above the podium:
-- Els Hub already targets by data + podium position, not by models.
-- Disable: _G.Els_PetNamesOnly = false before the hub
if _G.Els_PetNamesOnly ~= false then
task.spawn(function()
local plots = workspace:WaitForChild("Plots", 60)
if not plots or not LP then return end
local pg = LP:WaitForChild("PlayerGui", 30)
if not pg then return end
local holder = pg:FindFirstChild("ElsPetNames")
if holder then holder:Destroy() end
holder = Instance.new("ScreenGui")
holder.Name = "ElsPetNames"
holder.ResetOnSpawn = false
holder.Parent = pg
local function isPetModel(x)
return x:IsA("Model") and (x:FindFirstChild("RootPart") ~= nil or x:FindFirstChild("FakeRootPart") ~= nil
or x:FindFirstChildWhichIsA("AnimationController", true) ~= nil)
end
-- same technique as fastload (Unrender): task.defer(x.Destroy, x) on arrival,
-- on each base's ChildAdded (brainrots are direct children of the plot)
local function killPet(x)
if x and x.Parent and x.Parent.Parent == plots and isPetModel(x) then
task.defer(pcall, x.Destroy, x)
return true
end
return false
end
local waiting = setmetatable({}, { __mode = "k" })
local function onPlotChild(x)
if not x:IsA("Model") or killPet(x) or waiting[x] then return end
-- model still empty: wait for its RootPart / FakeRootPart / AnimationController
waiting[x] = true
local con
con = x.DescendantAdded:Connect(function(d)
if d.Name == "RootPart" or d.Name == "FakeRootPart" or d.ClassName == "AnimationController" then
con:Disconnect()
waiting[x] = nil
task.defer(killPet, x)
end
end)
task.delay(10, function()
if con.Connected then con:Disconnect() end
waiting[x] = nil
end)
end
local function hookPlot(plot)
plot.ChildAdded:Connect(onPlotChild)
for _, ch in ipairs(plot:GetChildren()) do onPlotChild(ch) end
end
plots.ChildAdded:Connect(hookPlot)
for _, plot in ipairs(plots:GetChildren()) do hookPlot(plot) end
local labels = {}
local function anchorOf(plot, slot)
local pods = plot:FindFirstChild("AnimalPodiums")
local pod = pods and pods:FindFirstChild(tostring(slot))
if not pod then return nil end
local base = pod:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
if spawn and spawn:IsA("BasePart") then return spawn end
if base and base:IsA("BasePart") then return base end
return pod:FindFirstChildWhichIsA("BasePart", true)
end
local function setLabel(key, anchor, name)
local l = labels[key]
if l and l.bb.Parent and l.anchor == anchor then
if l.name ~= name then l.name = name; l.lbl.Text = name end
return
end
if l then pcall(function() l.bb:Destroy() end) end
local bb = Instance.new("BillboardGui")
bb.Name = "ElsName"
bb.Adornee = anchor
bb.Size = UDim2.fromOffset(180, 22)
bb.StudsOffset = Vector3.new(0, 3, 0)
bb.MaxDistance = 250
bb.LightInfluence = 0
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.fromScale(1, 1)
lbl.BackgroundTransparency = 1
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 14
lbl.TextColor3 = Color3.fromRGB(226,238,248)
lbl.TextStrokeTransparency = 0.35
lbl.Text = name
lbl.Parent = bb
bb.Parent = holder
labels[key] = { bb = bb, lbl = lbl, anchor = anchor, name = name }
end
while holder.Parent do
local seen = {}
for _, plot in ipairs(plots:GetChildren()) do
local ch
pcall(function() ch = _G.XenSyncGet and _G.XenSyncGet(plot.Name) end)
local list = ch and _G.sProp and _G.sProp(ch, "AnimalList")
if type(list) == "table" then
for slot, ad in pairs(list) do
if type(ad) == "table" and type(ad.Index) == "string" then
local anchor = anchorOf(plot, slot)
if anchor then
local key = plot.Name .. "|" .. tostring(slot)
seen[key] = true
setLabel(key, anchor, ad.Index)
end
end
end
end
end
-- brainrot gone (stolen, sold) or podium removed by Els Hub: remove the name
for key, l in pairs(labels) do
if not seen[key] or not l.anchor.Parent then
pcall(function() l.bb:Destroy() end)
labels[key] = nil
end
end
task.wait(1)
end
end)
end
end
local function isCharJunk(d)
if not d then return false end
local cn = d.ClassName
if cn == "PathfindingModifier" then return false end
if cn == "WrapTarget" or cn == "WrapLayer" then return true end
if cn == "Shirt" or cn == "ShirtGraphic" then return true end
if cn == "NoCollisionConstraint" then return true end
local nm = d.Name
if nm == "__HITBOX" or nm == "OriginalPosition" or nm == "OriginalSize" then return true end
if CHAR_KEEP_CLASS[cn] then return false end
if BODY_PART[nm] then return false end
return true
end
local function isUuidName(n)
return type(n) == "string" and #n == 36
and string.match(n, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end
local function isOtherAvatar(char)
if not (char and char.ClassName == "Model") then return false end
if isMine(char) then return false end
if isPet(char) then return false end
local n = char.Name
if type(n) == "string" and string.sub(n, -6) == "_Clone" then return false end
if Players:GetPlayerFromCharacter(char) then return true end
if Players:FindFirstChild(n) then return true end
return char:FindFirstChildOfClass("Humanoid") ~= nil
end
local hookedChars = {}
local function stripOtherChar(char)
if _G.__Els_VelFlying then return end
if not (char and char.Parent) or isMine(char) or not isOtherAvatar(char) then return end
local function sweep()
local dd = char:GetDescendants()
local dump = {}
for i = 1, #dd do
if isCharJunk(dd[i]) then dump[#dump + 1] = dd[i] end
end
for i = 1, #dump do kill(dump[i]) end
end
sweep()
if hookedChars[char] then return end
hookedChars[char] = true
char.DescendantAdded:Connect(function(d)
if _G.__Els_VelFlying then return end
if d and d.Parent and not isMine(char) and isCharJunk(d) then kill(d) end
end)
end
local strippedPlots = {}
_G.__Els_StrippedPlots = strippedPlots
local function near(a, b)
return math.abs(a - b) < 0.2
end
local function isPlotPadPart(d)
if not d or PART_CLASS[d.ClassName] ~= true then return false end
if d.Name == "structure base home" or d.Name == "Spawn" then return false end
local s = d.Size
if near(s.X, 4) and near(s.Y, 1) and near(s.Z, 4) then return true end
if near(s.X, 2) and near(s.Y, 0.5) and near(s.Z, 2) then return true end
return false
end
local function isPodiumPlate(d)
if not d or PART_CLASS[d.ClassName] ~= true then return false end
if d.Name == "Spawn" then return false end
local s = d.Size
if near(s.X, 6) and near(s.Y, 0.2) and near(s.Z, 6) then return true end
if near(s.X, 4) and near(s.Y, 0.2) and near(s.Z, 4) then return true end
return false
end
local function stripPlotDecor(dec)
if not (dec and dec.Parent) then return end
local dump = {}
local function walk(x)
local kids = x:GetChildren()
for i = 1, #kids do
local d = kids[i]
local cn = d.ClassName
local nm = d.Name
if nm == "Spawn" or nm == "PromptAttachment" or cn == "ProximityPrompt" then
elseif cn == "Model" and isPet(d) then
elseif cn == "Beam" or cn == "PointLight" then
dump[#dump + 1] = d
elseif isPlotPadPart(d) then
dump[#dump + 1] = d
else
walk(d)
end
end
end
walk(dec)
for i = 1, #dump do kill(dump[i]) end
end
local function stripPodiumPlates(pods)
if not (pods and pods.Parent) then return end
local dump = {}
local function scan(folder)
if not folder then return end
local dd = folder:GetDescendants()
for i = 1, #dd do
local d = dd[i]
if d.Name ~= "Spawn" and d.Name ~= "PromptAttachment"
and d.ClassName ~= "ProximityPrompt" and isPodiumPlate(d) then
dump[#dump + 1] = d
end
end
end
local slots = pods:GetChildren()
for i = 1, #slots do
local slot = slots[i]
local base = slot:FindFirstChild("Base")
if base then scan(base:FindFirstChild("Decorations")) end
scan(slot:FindFirstChild("Decorations"))
end
for i = 1, #dump do kill(dump[i]) end
end
local function handlePlotChild(plot, ch)
if not (ch and ch.Parent) then return end
local n = ch.Name
if n == "Skin" then stripSkin(ch); return end
if n == "Laser" then
if not skipLaserStrip(plot) then stripLaser(ch) end
return
end
if n == "AnimalPodiums" then stripPodiumPlates(ch); return end
if n == "Decorations" then stripPlotDecor(ch); return end
if n == "Purchases" then
if skipTimerStrip(plot) then
stripPurchasesKeepTimer(ch)
else
kill(ch)
end
return
end
if PLOT_KEEP[n] then return end
if PLOT_NUKE[n] then kill(ch); return end
if isPet(ch) then
local set = _G.Els_PrioSet
if type(set) == "table" and set[string.lower(n)] ~= true then
kill(ch)
else
stripPetVfx(ch)
end
return
end
end
local function stripPlotInteriorFast(plot)
if not (plot and plot.Parent) then return end
if _G.__Els_MyPlot and plot.Name == _G.__Els_MyPlot then return end
strippedPlots[plot.Name] = true
local kids = plot:GetChildren()
for i = 1, #kids do
local ch = kids[i]
if ch and ch.Parent then
local n = ch.Name
if n == "Skin" or n == "Laser" or n == "AnimalPodiums" or n == "Decorations" then
elseif n == "Purchases" and skipTimerStrip(plot) then
stripPurchasesKeepTimer(ch)
elseif PLOT_KEEP[n] then
elseif PLOT_NUKE[n] then
kill(ch)
elseif isPet(ch) then
local set = _G.Els_PrioSet
if type(set) == "table" and set[string.lower(n)] ~= true then
kill(ch)
end
end
end
end
end
local function stripPlotVisual(plot)
if not (plot and plot.Parent) then return end
if _G.__Els_MyPlot and plot.Name == _G.__Els_MyPlot then return end
local skin = plot:FindFirstChild("Skin")
if skin then stripSkin(skin) end
local laser = plot:FindFirstChild("Laser")
if laser and not skipLaserStrip(plot) then stripLaser(laser) end
local pods = plot:FindFirstChild("AnimalPodiums")
if pods then stripPodiumPlates(pods) end
local dec = plot:FindFirstChild("Decorations")
if dec then stripPlotDecor(dec) end
local kids = plot:GetChildren()
for i = 1, #kids do
local ch = kids[i]
if isPet(ch) then stripPetVfx(ch) end
end
end
local function stripPlotInterior(plot)
stripPlotInteriorFast(plot)
stripPlotVisual(plot)
end
local function connectPlot(plot)
if not (plot and plot.Parent) then return end
plot.ChildAdded:Connect(function(ch)
if _G.__Els_VelFlying then return end
handlePlotChild(plot, ch)
end)
plot.DescendantAdded:Connect(function(d)
if _G.__Els_VelFlying then return end
if not d then return end
if underUnlock(d) then return end
local cn = d.ClassName
if cn == "BillboardGui" or cn == "SurfaceGui" then
if skipTimerStrip(plot) and isRemainingTimeGui(d) then return end
kill(d)
return
end
if d.Name == "Spawn" or d.Name == "PromptAttachment" or cn == "ProximityPrompt" then
return
end
if d.Name == "Decorations" and d.Parent == plot then
stripPlotDecor(d)
return
end
local p = d.Parent
if not p then return end
if p.Name == "LaserHitbox" then kill(d); return end
if PART_CLASS[d.ClassName] then
if isPlotPadPart(d) then
local x = p
local inPlotDec, skip = false, false
while x and x ~= plot do
if isPet(x) or x.Name == "Spawn" or x.Name == "AnimalPodiums" then
skip = true; break
end
if x.Name == "Decorations" and x.Parent == plot then inPlotDec = true end
x = x.Parent
end
if inPlotDec and not skip then kill(d); return end
elseif isPodiumPlate(d) then
local x = p
local inDec, skip = false, false
while x and x ~= plot do
if x.Name == "Spawn" then skip = true; break end
if x.Name == "Decorations" then inDec = true end
if x.Name == "AnimalPodiums" then
if inDec and not skip then kill(d) end
return
end
x = x.Parent
end
end
end
local sk = p
while sk and sk ~= plot do
if sk.Name == "Skin" then
if isSkinJunk(d) then kill(d) end
return
end
sk = sk.Parent
end
local las = p
while las and las ~= plot do
if las.Name == "Laser" then
if skipLaserStrip(plot) then return end
if PART_CLASS[d.ClassName] then
pcall(function()
d.CanCollide = false
d.CanTouch = false
end)
end
queueStripLaser(las)
return
end
las = las.Parent
end
end)
end
local function plotIsMine(plot)
if not plot then return false end
if _G.__Els_MyPlot and plot.Name == _G.__Els_MyPlot then return true end
local ch
pcall(function()
if _G.XenSyncGet then ch = _G.XenSyncGet(plot.Name) end
end)
if ch and _G.Els_IsMyPlot and _G.Els_IsMyPlot(ch) then
_G.__Els_MyPlot = plot.Name
return true
end
return false
end
local function canDestroyPlot(plot)
if not plot then return false end
if plotIsMine(plot) then return false end
local keep = _G.__Els_KeepPlot
if keep and plot.Name == keep then return false end
if not _G.__Els_MyPlot then return false end
return plot.Name ~= _G.__Els_MyPlot
end
local hookedPlots
local function hookPlot(plot)
if plotIsMine(plot) then return end
stripPlotInterior(plot)
connectPlot(plot)
end
local function hookPlots(folder)
if not folder or hookedPlots == folder then return end
hookedPlots = folder
local kids = folder:GetChildren()
for i = 1, #kids do
if not plotIsMine(kids[i]) then
stripPlotInterior(kids[i])
connectPlot(kids[i])
end
end
folder.ChildAdded:Connect(function(plot)
hookPlot(plot)
if canDestroyPlot(plot) then
kill(plot)
end
end)
end
do
-- Els: my base is cleaned too (before: plotIsMine skipped it entirely)
-- destroyed: Cash, CashPad, PlotSign, FriendPanel, Multiplier, InvisibleWalls, LaserHitbox,
--            decor, useless skin, billboards/surfaces
-- kept: delivery/steal hitbox, floors, walls, roof, doors, Slope (ramp),
--       the lock pad (Purchases.PlotBlock) and its timer
local MY_KEEP = { Slope = true }
local myHooked
local function myGui(d)
if not d.Parent then return end
local cn = d.ClassName
if cn == "BillboardGui" or cn == "SurfaceGui" then
if isRemainingTimeGui(d) then return end
kill(d)
end
end
local function myChild(ch)
if not (ch and ch.Parent) then return end
local n = ch.Name
if n == "Skin" then stripSkin(ch) return end
if n == "Decorations" then stripPlotDecor(ch) return end
if n == "Purchases" then stripPurchasesKeepTimer(ch) return end
if PLOT_KEEP[n] or MY_KEEP[n] then return end
if PLOT_NUKE[n] then kill(ch) end
end
local function stripMyPlot(plot)
if not plot or myHooked == plot then return end
myHooked = plot
for _, ch in ipairs(plot:GetChildren()) do myChild(ch) end
for _, d in ipairs(plot:GetDescendants()) do
if not underUnlock(d) then myGui(d) end
end
plot.ChildAdded:Connect(function(ch) task.defer(myChild, ch) end)
plot.DescendantAdded:Connect(function(d)
if underUnlock(d) then return end
task.defer(myGui, d)
end)
end
_G.Els_StripMyPlot = stripMyPlot
task.spawn(function()
local t0 = os.clock()
while os.clock() - t0 < 120 do
local plots = workspace:FindFirstChild("Plots")
local name = _G.__Els_MyPlot
local mine = plots and name and plots:FindFirstChild(tostring(name))
if mine then stripMyPlot(mine) return end
task.wait(0.5)
end
end)
end
_G.Els_LockPrioPlot = function(plotName)
if not plotName then return end
_G.__Els_KeepPlot = tostring(plotName)
local plots = workspace:FindFirstChild("Plots")
if not plots then return end
local kids = plots:GetChildren()
for i = 1, #kids do
local plot = kids[i]
if canDestroyPlot(plot) then
kill(plot)
end
end
local mine = _G.__Els_MyPlot and plots:FindFirstChild(_G.__Els_MyPlot)
if mine and _G.Els_NukePlotPodiums then
pcall(_G.Els_NukePlotPodiums, mine)
end
local keepPlot = _G.__Els_KeepPlot and plots:FindFirstChild(_G.__Els_KeepPlot)
if keepPlot and _G.Els_StripNonPrioPodiums then
pcall(_G.Els_StripNonPrioPodiums, keepPlot)
end
end
local function stripMap(map)
local function handle(x)
if _G.__Els_VelFlying then return end
if x and not MAP_KEEP[x.Name] then _G.Els_KillKeepFloor(x) end
end
map.ChildAdded:Connect(handle)
local kids = map:GetChildren()
task.spawn(function()
local t0 = os.clock()
for i = 1, #kids do
handle(kids[i])
if os.clock() - t0 > 0.005 then
task.wait()
t0 = os.clock()
end
end
end)
end
local hookedRma
local rmaBoxDone = false
local function hookRma(rma)
if not rma then return end
if rmaBoxDone then
kill(rma)
return
end
if hookedRma == rma then return end
hookedRma = rma
local function nuke()
if _G.__Els_VelFlying then return end
if rmaBoxDone then return end
rmaBoxDone = true
kill(rma)
end
if #rma:GetChildren() > 0 then
nuke()
else
rma.ChildAdded:Connect(nuke)
end
end
local function onWsChild(ch)
if not ch then return end
if _G.__Els_VelFlying then return end
local n = ch.Name
if ch.ClassName == "Camera" or ch.ClassName == "Terrain" then return end
if n == "Plots" then hookPlots(ch); return end
if n == "RenderedMovingAnimals" then hookRma(ch); return end
if n == "Map" then stripMap(ch); return end
if isMine(ch) then return end
if isUuidName(n) then _G.Els_KillKeepFloor(ch); return end
if isOtherAvatar(ch) then stripOtherChar(ch); return end
if ch.ClassName == "Model" then
ch.ChildAdded:Connect(function()
if isOtherAvatar(ch) then stripOtherChar(ch) end
end)
end
if string.sub(n, 1, 7) == "BeeHive" or string.sub(n, 1, 7) == "Sentry_" then
kill(ch)
return
end
if WS_KILL[n] or ch.ClassName == "Highlight" then _G.Els_KillKeepFloor(ch); return end
if ch.ClassName == "Model" and string.find(n, "'s Rainbow", 1, true) then
kill(ch)
end
end
local wsch = workspace:GetChildren()
local plotsFolder, mapFolder, rmaFolder
local rest = {}
for i = 1, #wsch do
local ch = wsch[i]
local n = ch.Name
if n == "Plots" then plotsFolder = ch
elseif n == "Map" then mapFolder = ch
elseif n == "RenderedMovingAnimals" then rmaFolder = ch
else rest[#rest + 1] = ch end
end
if mapFolder then stripMap(mapFolder) end
if rmaFolder then hookRma(rmaFolder) end
for i = 1, #rest do onWsChild(rest[i]) end
if plotsFolder then hookPlots(plotsFolder) end
workspace.ChildAdded:Connect(onWsChild)
local function hookPlrChar(plr)
if not plr or plr == LP then return end
if plr.Character then stripOtherChar(plr.Character) end
plr.CharacterAdded:Connect(stripOtherChar)
end
local plrs = Players:GetPlayers()
for i = 1, #plrs do hookPlrChar(plrs[i]) end
Players.PlayerAdded:Connect(hookPlrChar)
local function onLit(x)
if _G.__Els_VelFlying then return end
if not x then return end
local cn = x.ClassName
if cn == "Sky" or cn == "Atmosphere" or cn == "Clouds"
or cn == "SunRaysEffect" or cn == "ColorCorrectionEffect" then
kill(x)
end
end
local lit = Lighting:GetChildren()
for i = 1, #lit do onLit(lit[i]) end
Lighting.ChildAdded:Connect(onLit)
local function stripCamFx(x)
if not x then return end
local cn = x.ClassName
if cn == "ColorCorrectionEffect" or cn == "BlurEffect" then kill(x) end
end
local hookedCam
local function hookCam(cam)
if not cam or hookedCam == cam then return end
hookedCam = cam
local ck = cam:GetChildren()
for i = 1, #ck do stripCamFx(ck[i]) end
cam.ChildAdded:Connect(stripCamFx)
end
hookCam(workspace.CurrentCamera)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
hookCam(workspace.CurrentCamera)
end)
workspace.DescendantAdded:Connect(function(d)
if not d then return end
if _G.__Els_VelFlying then return end
local cn = d.ClassName
if cn == "BillboardGui" or cn == "SurfaceGui" or cn == "Decal" or cn == "Texture" then
if underUnlock(d) then return end
if (cn == "BillboardGui" or cn == "SurfaceGui")
and skipTimerStrip(plotOf(d)) and isRemainingTimeGui(d) then
return
end
kill(d)
end
end)
if mapFolder and mapFolder.Parent then
local md = mapFolder:GetDescendants()
for i = 1, #md do
local cn = md[i].ClassName
if cn == "Decal" or cn == "Texture" then kill(md[i]) end
end
end
do
local ter = workspace.Terrain
pcall(function() ter.Decoration = false end)
if _G.Els_ClearTerrain == true then pcall(function() ter:Clear() end) end
local kids = ter:GetChildren()
for i = 1, #kids do kill(kids[i]) end
ter.ChildAdded:Connect(function(ch)
if _G.__Els_VelFlying then return end
kill(ch)
end)
ter.DescendantAdded:Connect(function(d)
if _G.__Els_VelFlying then return end
if d then kill(d) end
end)
end
_G.__Els_StripDone = true
end
task.wait()
local SRC = [=[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
RunService = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
do
local okPre = pcall(function()
RunService.PreSimulation:Connect(function(dt)
local f = _G.__Els_FlyPre
if f then
f(dt)
end
end)
end)
if not okPre then
RunService.Stepped:Connect(function(_, dt)
local f = _G.__Els_FlyPre
if f then
f(dt)
end
end)
end
pcall(function()
RunService.Heartbeat:Connect(function(dt)
local f = _G.__Els_FlyHb
if f then
f(dt)
end
end)
end)
end
do
local function hookChar(char)
if not char then return end
task.defer(function()
local h = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 8)
if not (h and h:IsA("BasePart")) then return end
pcall(function()
h.Anchored = false
LocalPlayer.ReplicationFocus = h
end)
end)
end
if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)
end
do
local function unwalk(char)
local a = char and char:FindFirstChild("Animate")
if a then
pcall(function() a.Disabled = true end)
end
end
local function hook(char)
if not char then return end
unwalk(char)
char.ChildAdded:Connect(function(ch)
if ch.Name == "Animate" then
pcall(function() ch.Disabled = true end)
end
end)
end
if LocalPlayer.Character then hook(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hook)
end
priorityList = {
"Headless Horseman","Signore Carapace","Strawberry Elephant","Elefanto Frigo","John Pork",
"Plant Bros","Meowl","Arca Bros","Orchidox","Skibidi Toilet",
"Arcadragon","Griffin","Dragon Gingerini","Dragon Aquanini","Love Love Bear",
"Grabatron","Antonio","Moby Bros","Jelly Moby","La Supreme Combinasion",
"Ginger Gerat","Digi Narwhal","Dragon Skeletonini","Kalika Bros","Fishino Clownino",
"Kraken","Hydra Bunny","Bunny and Eggy","Pancake and Syrup","Hydra Dragon Cannelloni",
"Cola Cat","Dragon Cannelloni","Sammyni Cakini","Tirilikalika Tirilikalako","Draculino",
"Draculino Egg","Ketupat Bros","Cobra Gelato","Bumbatron","La Casa Boo",
"Venuspino","Los Secret Combinasionas","Dug dug dug","Duggy Bros","Sammyni Truckini",
"Rosey and Teddy","Foxini Lanternini","Sammyni Spookyni","Skelly and Coffy","La Breakfast Combinasion",
"Gold and Diamond","Rico Dinero","Capitano Americano","Fortunu and Cashuru","Los Sekolahs",
"Los Hackers","Flying Dutchman","Slushki Huski","Los Admins","Los Chillis",
"Gorillo Subwoofero","Rubrikiko","Los Amigos","Cooki and Milki","Spooky and Pumpky",
"Fragrama and Chocrama","Guest 666","Reinito Sleighito","Popcuru and Fizzuru","La Fuse Machine",
"La Craft Machine","Celestial Pegasus","Rubiko and Kubiko","Gym Bros","Celularcini Viciosini",
"Globa Steppa","Quackini Snackini","Examen Bros","Pretzo Robo","Fragola La La La",
"Cloverat Clapat","La Food Combinasion","Tralaledon","Bearito Cabinito","Cerberus",
"Capitano Moby","Burguro And Fryuro","Garama and Madundung","Jolly Jolly Sahur","Abyssaloco",
"Pizza and Ranch","Cash or Card","La Secret Combinasion",
}
_G.Els_PrioSet = {}
for _, n in ipairs(priorityList) do
if type(n) == "string" and n ~= "" then
_G.Els_PrioSet[string.lower(n)] = true
end
end
do
local vfxDone = setmetatable({}, { __mode = "k" })
local notPet = setmetatable({}, { __mode = "k" })
local function sweepNonPrio()
local plots = workspace:FindFirstChild("Plots")
if not plots then return end
local set = _G.Els_PrioSet
if type(set) ~= "table" then return end
local now = os.clock()
for _, plot in ipairs(plots:GetChildren()) do
for _, ch in ipairs(plot:GetChildren()) do
if not ch:IsA("Model") or vfxDone[ch] then continue end
local again = notPet[ch]
if again and now < again then continue end
if not (ch:FindFirstChild("RootPart") or ch:FindFirstChild("FakeRootPart")
or ch:FindFirstChildWhichIsA("AnimationController", true)) then
notPet[ch] = now + 8
continue
end
notPet[ch] = nil
if not set[string.lower(ch.Name)] then
_G.Els_Kill(ch)
elseif not vfxDone[ch] then
vfxDone[ch] = true
pcall(_G.Els_StripPetVfx, ch)
end
end
end
end
_G.Els_SweepNonPrio = sweepNonPrio
task.defer(function() pcall(sweepNonPrio) end)
task.delay(3, function() pcall(sweepNonPrio) end)
task.spawn(function()
task.wait(3)
while true do
task.wait(2)
if not _G.__Els_VelFlying then pcall(sweepNonPrio) end
end
end)
end
Config = {
AutoStealEnabled = true,
AutoGrabRadius = 110,
AutoTPPriority = true,
StealNearest = false,
StealMode = "Priority",
PriorityList = priorityList,
KickToPS = false,
InfiniteJump = true,
WaveriderSpeedEnabled = false,
WaveriderSpeed = 140,
WaveriderSpeedKey = "Q",
AutoClone = true,
InvSteal = true,
InvStealAngle = 220,
InvStealDepth = 10,
TpSettings = {
Tool = "Flying Bee",
CloneDelayVal = 0.27,
GrabbleTPSpeed = 480,
ElsSkipSettle = true,
ElsMaxTries = 3,
ElsWatchTime = 4,
JumpTP = true,
JumpFarDist = 170,
HopTime = 0.25,
HopHeight = 6,
MiniTPSpeed = 100,
},
}
local Els_CFG_FILE = "Els_Hub_Settings.json"
local function elsSaveSettings()
return (pcall(function()
if not writefile then error("no writefile") end
local data = {
AutoClone = Config.AutoClone,
InvSteal = Config.InvSteal,
KickToPS = Config.KickToPS,
InfiniteJump = Config.InfiniteJump,
WaveriderSpeedEnabled = Config.WaveriderSpeedEnabled,
WaveriderSpeed = Config.WaveriderSpeed,
StealNearest = Config.StealNearest,
}
writefile(Els_CFG_FILE, game:GetService("HttpService"):JSONEncode(data))
end))
end
_G.Els_SaveSettings = elsSaveSettings
local _elsSaveQueued = false
function _G.Els_AutoSave()
if _elsSaveQueued then return end
_elsSaveQueued = true
task.delay(0.5, function()
_elsSaveQueued = false
pcall(elsSaveSettings)
end)
end
pcall(function()
if isfile and readfile and isfile(Els_CFG_FILE) then
local saved = game:GetService("HttpService"):JSONDecode(readfile(Els_CFG_FILE))
if type(saved) == "table" then
for k, v in pairs(saved) do
if Config[k] ~= nil then Config[k] = v end
end
end
end
end)
Config.WaveriderSpeedEnabled = false
function instantClone()
local c = LocalPlayer.Character
if not c then return end
local h = c:FindFirstChildOfClass("Humanoid")
if not h then return end
local cl = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or c:FindFirstChild("Quantum Cloner")
if not cl then return end
pcall(function() h:UnequipTools() end)
task.wait()
if cl.Parent ~= c then h:EquipTool(cl); task.wait() end
_G.isCloning = true
cl:Activate()
task.wait(0.05)
-- Els bypass: fire the teleport remote directly so clone works even when the
-- game's TeleportToClone GUI script is disabled (full KillScripts). The GUI click
-- is the fallback when the remote cannot be resolved.
local r = _G.Els_GetRemoteByHash and (_G.Els_GetRemoteByHash("QuantumCloner/OnTeleport") or _G.Els_GetRemoteByHash("ItemUse/QuantumClonerTeleport"))
if r then
pcall(function() r:FireServer() end)
else
local pg = LocalPlayer:FindFirstChild("PlayerGui")
local tf = pg and pg:FindFirstChild("ToolsFrames")
local qc = tf and tf:FindFirstChild("QuantumCloner")
local tb = qc and qc:FindFirstChild("TeleportToClone")
if tb then
tb.Visible = true
pcall(function() firesignal(tb.MouseButton1Click) end)
pcall(function() firesignal(tb.MouseButton1Up) end)
pcall(function() firesignal(tb.Activated) end)
end
end
task.delay(0.55, function() _G.isCloning = false end)
end
do
local LP = LocalPlayer
local RS = ReplicatedStorage
local CARPET_NAMES = _G.Els_CarpetNames or { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
local function findTool(name)
local char = LP.Character
local bp = LP:FindFirstChild("Backpack")
return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end
local _eqCarpetName
local function _carpetInChar(char)
if not char then return nil end
if _eqCarpetName then
local t = char:FindFirstChild(_eqCarpetName)
if t then return _eqCarpetName end
_eqCarpetName = nil
end
for _, n in ipairs(CARPET_NAMES) do
local t = char:FindFirstChild(n)
if t then _eqCarpetName = n; return n end
end
return nil
end
local function equipCarpet()
if _G.isCloning then return nil end
local char = LP.Character
if not _G.__Els_GrappleFired then return _carpetInChar(char) end
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then return nil end
local held = _carpetInChar(char)
local preferred = _G.Els_CarpetChoice or (Config and Config.TpSettings and Config.TpSettings.Tool)
if held and (held == preferred or not preferred or not findTool(preferred)) then return held end
if preferred then
local pt = findTool(preferred)
if pt and pt:IsA("Tool") then
if pt.Parent ~= char then pcall(function() hum:EquipTool(pt) end) end
_eqCarpetName = preferred
return preferred
end
end
for _, n in ipairs(CARPET_NAMES) do
local t = findTool(n)
if t and t:IsA("Tool") then
if t.Parent ~= char then pcall(function() hum:EquipTool(t) end) end
_eqCarpetName = n
return n
end
end
return nil
end
_G.Els_EquipCarpet = equipCarpet
_G.Els_CarpetNames = CARPET_NAMES
end
do
function _G.D3GovClamp(v)
local cap = 480
local n = tonumber(v) or (Config and Config.TpSettings and tonumber(Config.TpSettings.GrabbleTPSpeed)) or cap
if n > cap then n = cap end
return n
end
end
if not _G.__Els_SyncBoot then
do
local _xchan
local _synInst, _syncMod
local function _synNow()
if _synInst and _synInst.Parent then return _synInst end
local p = ReplicatedStorage:FindFirstChild("Packages")
_synInst = p and p:FindFirstChild("Synchronizer")
return _synInst
end
local function _trySenv()
if _xchan then return true end
local syn = _synNow()
if not syn then return false end
if type(_syncMod) ~= "table" then
local req = (getrenv and getrenv().require) or require
local ok, mod = pcall(req, syn)
if ok and type(mod) == "table" then _syncMod = mod end
end
local getFn = type(_syncMod) == "table" and rawget(_syncMod, "Get")
local gf = getfenv or (debug and debug.getfenv)
if type(getFn) ~= "function" or type(gf) ~= "function" then return false end
local ok, env = pcall(gf, getFn)
if not ok or type(env) ~= "table" then return false end
local ch = rawget(env, "Channels")
if type(ch) ~= "table" then return false end
_xchan = ch
return true
end
local function _chans()
if _xchan then return _xchan end
_trySenv()
return _xchan
end
_G.XenSyncAll = function() return _chans() end
_G.XenSyncGet = function(idx)
local t = _chans()
if not t or idx == nil then return nil end
local ok, cd = pcall(rawget, t, idx)
if ok and type(cd) == "table" then return cd end
local ok2, cd2 = pcall(function() return t[idx] end)
if ok2 and type(cd2) == "table" then return cd2 end
return nil
end
_G.Els_IsPlotChanKey = function(k)
return type(k) == "string" and #k >= 32 and string.find(k, "-", 1, true) ~= nil
end
_G.sProp = function(ch, key)
if type(ch) ~= "table" or key == nil then return nil end
local ct = rawget(ch, "CacheTable")
if type(ct) ~= "table" then
local okC, c2 = pcall(function() return ch.CacheTable end)
if okC and type(c2) == "table" then ct = c2 end
end
if type(ct) ~= "table" then return nil end
local v = rawget(ct, key)
if v ~= nil then return v end
local okV, v2 = pcall(function() return ct[key] end)
if okV then return v2 end
return nil
end
end
end
do
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local ANGVELSSpeed = { CARPET = 480 }
if Config and Config.TpSettings then
if tonumber(Config.TpSettings.GrabbleTPSpeed) then
ANGVELSSpeed.CARPET = math.min(480, tonumber(Config.TpSettings.GrabbleTPSpeed))
end
end
local _routeVia = "ligne"
do
pcall(function()
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
settings().Physics.ThrottleAdjustTime = 0
end)
pcall(function()
game:GetService("NetworkClient"):SetOutgoingKBPSLimit(100000)
end)
end
local function getPlotChannel(plotName)
local channel
pcall(function() channel = _G.XenSyncGet(plotName) end)
return channel
end
local function channelGet(channel, key)
return _G.sProp(channel, key)
end
local _myPlotYes = setmetatable({}, { __mode = "k" })
local function isMyPlot(channel)
if not channel then return false end
if _myPlotYes[channel] then return true end
local owner = channelGet(channel, "Owner")
if not owner then return false end
local result = false
pcall(function()
if typeof(owner) == "Instance" and owner:IsA("Player") then
result = owner.UserId == LP.UserId
elseif type(owner) == "table" and owner.UserId then
result = owner.UserId == LP.UserId
elseif typeof(owner) == "Instance" then
result = owner == LP
end
end)
if result then _myPlotYes[channel] = true end
return result
end
_G.Els_IsMyPlot = isMyPlot
local function isPlotUnlocked(plotName)
local ok, res = pcall(function()
local channel = getPlotChannel(plotName)
if not channel then return false end
return channelGet(channel, "BlockEndTimeFirstFloor") == nil
end)
return ok and (res == true)
end
local _podiumPos = setmetatable({}, { __mode = "k" })
local _slotStr = {}
local function _slotKey(slot)
local s = _slotStr[slot]
if s == nil then s = tostring(slot); _slotStr[slot] = s end
return s
end
local function _cheapPos(inst)
if not inst then return nil end
if inst:IsA("BasePart") then return inst.Position end
local pp = inst.PrimaryPart
if pp then return pp.Position end
local p = inst:FindFirstChildWhichIsA("BasePart")
return p and p.Position or nil
end
local function _plotWorldPos(plot)
local p = _cheapPos(plot)
if p then return p end
for _, n in ipairs({ "PlotSign", "MainRoot", "Base", "Floor", "Spawn" }) do
p = _cheapPos(plot:FindFirstChild(n))
if p then return p end
end
return nil
end
local function getPetPosition(plot, slot)
if not plot then return nil end
slot = _slotKey(slot)
local sub = _podiumPos[plot]
if sub == nil then sub = {}; _podiumPos[plot] = sub end
local hit = sub[slot]
if hit then return hit end
local podiums = plot:FindFirstChild("AnimalPodiums")
if not podiums then return nil end
local podium = podiums:FindFirstChild(slot)
if not podium then
for _, ch in ipairs(podiums:GetChildren()) do
if tostring(ch.Name) == slot then podium = ch; break end
end
end
if not podium then return nil end
local base = podium:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
local pos = _cheapPos(spawn) or _cheapPos(base) or _cheapPos(podium)
if pos then
sub[slot] = pos
return pos
end
return nil
end
local function _findPlot(plotName)
local Plots = workspace:FindFirstChild("Plots")
if not Plots or plotName == nil then return nil end
local name = tostring(plotName)
local plot = Plots:FindFirstChild(name)
if plot then return plot end
for _, pl in ipairs(Plots:GetChildren()) do
if pl.Name == name or tostring(pl.Name) == name then return pl end
end
return nil
end
local function _ensurePetPos(p)
if not p then return nil end
if p.position then return p.position end
local plot = _findPlot(p.plot)
if not plot then return nil end
local pos = getPetPosition(plot, p.slot)
if pos then
p.position = pos
return pos
end
local hint = _plotWorldPos(plot)
if hint then p.plotHint = hint end
return nil
end
local _BLOCKING_MACHINE_TYPES = { Fuse=true, Duel=true, Trade=true, Crafting=true }
local function _ANGVELSIsFusing(animalData)
if type(animalData) ~= "table" then return false end
local m = animalData.Machine
if type(m) ~= "table" then return false end
return _BLOCKING_MACHINE_TYPES[m.Type] == true and m.Active == true
end
local _prioRank = {}
do
local list = (Config and Config.PriorityList) or priorityList
if type(list) == "table" then
for i, n in ipairs(list) do
if type(n) == "string" then _prioRank[string.lower(n)] = i end
end
end
end
local _MUT_RANK = {
eclipse = 1,
crystal = 2,
phantom = 3,
bloodrot = 4,
cyber = 5,
divine = 6,
divin = 6,
cursed = 7,
yinyang = 8,
yingyang = 8,
radioactive = 9,
galaxy = 10,
lava = 11,
candy = 12,
rainbow = 13,
[""] = 14,
none = 14,
normal = 14,
base = 14,
default = 14,
diamond = 14,
gold = 14,
}
local function _adGen(index, mut, traits)
local f = _G._mynxxGen
if type(f) ~= "function" then return 0 end
local ok, v = pcall(f, index, mut, traits)
v = ok and tonumber(v) or 0
if v ~= v or v == math.huge then return 0 end
return v
end
local function _adMut(ad)
if type(ad) ~= "table" then return "" end
local m = ad.Mutation or ad.mutation or ad.Mut
if type(m) == "table" then
m = m.Name or m.Index or m.Type or m[1]
end
if type(m) ~= "string" then return "" end
return m
end
local function _mutRank(m)
local k = tostring(m or ""):lower():gsub("[%s%-_]", "")
return _MUT_RANK[k] or 99
end
local function _bestPrioOnBase(plotName, animalList)
local best, bestRank, bestMut, bestGen = nil, math.huge, 99, -1
if type(animalList) ~= "table" then return nil end
for slot, animalData in pairs(animalList) do
if type(animalData) ~= "table" then continue end
local animalName = animalData.Index
if not animalName then continue end
local rank = _prioRank[string.lower(animalName)]
if not rank then continue end
if _ANGVELSIsFusing(animalData) then continue end
local mut = _adMut(animalData)
local mutRank = _mutRank(mut)
local gen = _adGen(animalName, mut, animalData.Traits)
local same = best and string.lower(animalName) == string.lower(best.index)
local take = false
if not best then
take = true
elseif rank < bestRank then
take = true
elseif same and mutRank < bestMut then
take = true
elseif same and mutRank == bestMut and gen > bestGen then
take = true
end
if take then
bestRank = rank
bestMut = mutRank
bestGen = gen
best = {
name = animalName, index = animalName, position = nil,
plotHint = nil, mutation = mut, gen = gen,
plot = tostring(plotName), slot = tostring(slot),
}
end
end
return best
end
local _noPrioN, _noPrioSt = {}, {}
local _prioSlots, _podHook, _myPodNuke = {}, {}, {}
local function nukePlotPodiums(plot)
if not (plot and plot.Parent) then return end
if _myPodNuke[plot] then
local pods = plot:FindFirstChild("AnimalPodiums")
if pods then
local kids = pods:GetChildren()
for i = 1, #kids do _G.Els_Kill(kids[i]) end
end
return
end
_myPodNuke[plot] = true
local function wipe(folder)
if not folder then return end
local kids = folder:GetChildren()
for i = 1, #kids do _G.Els_Kill(kids[i]) end
folder.ChildAdded:Connect(function(ch)
_G.Els_Kill(ch)
end)
end
wipe(plot:FindFirstChild("AnimalPodiums"))
plot.ChildAdded:Connect(function(ch)
if ch and ch.Name == "AnimalPodiums" then wipe(ch) end
end)
end
local function stripNonPrioPodiums(plot)
if not (plot and plot.Parent) then return end
if _G.__Els_MyPlot and plot.Name == _G.__Els_MyPlot then
nukePlotPodiums(plot)
return
end
local set = _G.Els_PrioSet
if type(set) ~= "table" then return end
local ch
pcall(function() ch = _G.XenSyncGet(plot.Name) end)
if ch and isMyPlot(ch) then
_G.__Els_MyPlot = plot.Name
nukePlotPodiums(plot)
return
end
local list = ch and channelGet(ch, "AnimalList")
if type(list) ~= "table" then return end
local keepSlots = {}
for slot, ad in pairs(list) do
if type(ad) == "table" and type(ad.Index) == "string"
and set[string.lower(ad.Index)] then
keepSlots[tostring(slot)] = true
end
end
if not next(keepSlots) then return end
_prioSlots[plot.Name] = keepSlots
local pods = plot:FindFirstChild("AnimalPodiums")
if not pods then return end
local kids = pods:GetChildren()
for i = 1, #kids do
local slotInst = kids[i]
if not keepSlots[tostring(slotInst.Name)] then
_G.Els_Kill(slotInst)
end
end
if not _podHook[plot] then
_podHook[plot] = true
pods.ChildAdded:Connect(function(slotInst)
local ks = _prioSlots[plot.Name]
if slotInst and ks and not ks[tostring(slotInst.Name)] then
_G.Els_Kill(slotInst)
end
end)
end
end
_G.Els_NukePlotPodiums = nukePlotPodiums
_G.Els_StripNonPrioPodiums = stripNonPrioPodiums
local function stripNoPrioPlots()
local plots = workspace:FindFirstChild("Plots")
if not plots then return end
local keep = _G.__Els_KeepPlot
local set = _G.Els_PrioSet
for _, plot in ipairs(plots:GetChildren()) do
if plot.Name == _G.__Els_MyPlot then
pcall(nukePlotPodiums, plot)
continue
end
if keep and plot.Name == keep then
pcall(stripNonPrioPodiums, plot)
continue
end
local ch
pcall(function() ch = _G.XenSyncGet(plot.Name) end)
if ch and isMyPlot(ch) then
_G.__Els_MyPlot = plot.Name
pcall(nukePlotPodiums, plot)
continue
end
local list = ch and channelGet(ch, "AnimalList")
if type(list) ~= "table" then continue end
local n, hasPrio = 0, false
for _, ad in pairs(list) do
n += 1
if type(ad) == "table" and type(ad.Index) == "string"
and set and set[string.lower(ad.Index)] then
hasPrio = true
end
end
if not hasPrio then
for _, c in ipairs(plot:GetChildren()) do
if c:IsA("Model") and (c:FindFirstChild("RootPart") or c:FindFirstChild("FakeRootPart"))
and set and set[string.lower(c.Name)] then
hasPrio = true
break
end
end
end
if hasPrio then
_noPrioN[plot.Name] = nil
_noPrioSt[plot.Name] = nil
if _G.__Els_StrippedPlots then _G.__Els_StrippedPlots[plot.Name] = nil end
pcall(stripNonPrioPodiums, plot)
continue
end
local key = plot.Name
if n == (_noPrioN[key] or -1) then
_noPrioSt[key] = (_noPrioSt[key] or 0) + 1
else
_noPrioN[key] = n
_noPrioSt[key] = 0
end
if (_noPrioSt[key] or 0) >= 1 then
if _G.__Els_MyPlot and plot.Name ~= _G.__Els_MyPlot
and not (keep and plot.Name == keep) then
_G.Els_Kill(plot)
end
end
end
end
local function scanAllPets()
local pets = {}
local isKey = _G.Els_IsPlotChanKey
local best, bestPlot
local reg = _G.XenSyncAll and _G.XenSyncAll()
if type(reg) == "table" then
for name, ch in next, reg do
if not (isKey and isKey(name)) then continue end
if not ch then continue end
if isMyPlot(ch) then
_G.__Els_MyPlot = tostring(name)
local plots = workspace:FindFirstChild("Plots")
local mine = plots and plots:FindFirstChild(tostring(name))
if mine then pcall(nukePlotPodiums, mine) end
continue
end
local cand = _bestPrioOnBase(name, channelGet(ch, "AnimalList"))
if cand then
local take = not best
if best then
local ra = _prioRank[string.lower(cand.index)] or math.huge
local rb = _prioRank[string.lower(best.index)] or math.huge
local ma, mb = _mutRank(cand.mutation), _mutRank(best.mutation)
take = ra < rb or (ra == rb and (ma < mb
or (ma == mb and (tonumber(cand.gen) or 0) > (tonumber(best.gen) or 0))))
end
if take then best, bestPlot = cand, tostring(name) end
end
end
end
if _G.__Els_StripDone and not _G.__Els_VelFlying then
pcall(stripNoPrioPlots)
end
if best then
pets[1] = best
pcall(_G.Els_LockPrioPlot, bestPlot)
end
return pets
end
_G.Els_ScanPets = scanAllPets
task.spawn(function()
local t0 = os.clock()
while os.clock() - t0 < 20 do
local plots = workspace:FindFirstChild("Plots")
if plots then
for _, plot in ipairs(plots:GetChildren()) do
local ch
pcall(function() ch = _G.XenSyncGet(plot.Name) end)
if ch and isMyPlot(ch) then
_G.__Els_MyPlot = plot.Name
pcall(nukePlotPodiums, plot)
if _G.__Els_KeepPlot then
pcall(_G.Els_LockPrioPlot, _G.__Els_KeepPlot)
end
return
end
end
end
task.wait()
end
end)
local UPPER = {
B = {{coord=Vector3.new(-487.921448,16.850713,-75.768013),facing="NORTH"},{coord=Vector3.new(-332.379730,16.850722,-75.762100),facing="NORTH"},{coord=Vector3.new(-487.134918,16.850713,-18.094154),facing="SOUTH"},{coord=Vector3.new(-316.300171,16.850713,-17.845898),facing="SOUTH"}},
C = {{coord=Vector3.new(-330.765381,16.850713,31.424425),facing="NORTH"},{coord=Vector3.new(-502.989349,16.850713,31.172430),facing="NORTH"},{coord=Vector3.new(-489.077087,16.850713,89.010147),facing="SOUTH"},{coord=Vector3.new(-330.908936,16.850713,88.930145),facing="SOUTH"}},
D = {{coord=Vector3.new(-331.264893,16.850713,138.209167),facing="NORTH"},{coord=Vector3.new(-487.935181,16.850713,138.026321),facing="NORTH"},{coord=Vector3.new(-487.774933,16.850713,195.882538),facing="SOUTH"},{coord=Vector3.new(-330.799133,16.850575,196.022354),facing="SOUTH"}},
}
local LOWER = {
B = {{coord=Vector3.new(-335.725586,-3.048217,-74.984589),facing="NORTH"},{coord=Vector3.new(-503.214233,-3.048217,-75.043137),facing="NORTH"},{coord=Vector3.new(-483.619385,-3.718430,-18.844337),facing="SOUTH"},{coord=Vector3.new(-316.147095,-3.048218,-18.818844),facing="SOUTH"}},
C = {{coord=Vector3.new(-335.985413,-3.048218,32.051426),facing="NORTH"},{coord=Vector3.new(-503.277008,-3.048217,31.956175),facing="NORTH"},{coord=Vector3.new(-483.749390,-3.048218,88.147003),facing="SOUTH"},{coord=Vector3.new(-315.793823,-3.048217,88.163979),facing="SOUTH"}},
D = {{coord=Vector3.new(-335.476654,-3.048218,139.001083),facing="NORTH"},{coord=Vector3.new(-503.710083,-3.048218,138.989883),facing="NORTH"},{coord=Vector3.new(-315.654938,-3.048218,195.302444),facing="SOUTH"},{coord=Vector3.new(-483.859253,-3.048218,195.269043),facing="SOUTH"}},
}
local UPPER_Y_THRESHOLD = 7
local TALL_PETS = { ["La Secret Combinasion"]=true, ["La Jolly Grande"]=true }
local TALL_OFFSET = 3
local BASES_LOW = {
[1]=Vector3.new(-476.52,-2,220.94),[2]=Vector3.new(-476.52,-2,113.77),
[3]=Vector3.new(-476.52,-2,6.18),[4]=Vector3.new(-476.52,-2,-101.07),
[5]=Vector3.new(-342.66,-2,221.45),[6]=Vector3.new(-342.66,-2,113.41),
[7]=Vector3.new(-342.66,-2,6.25),[8]=Vector3.new(-342.66,-2,-99.73),
}
local BASES_HIGH = {
[1]=Vector3.new(-479.51,18,220.94),[2]=Vector3.new(-479.51,18,113.77),
[3]=Vector3.new(-479.51,18,6.18),[4]=Vector3.new(-479.51,18,-101.07),
[5]=Vector3.new(-339.48,18,221.45),[6]=Vector3.new(-339.48,18,113.41),
[7]=Vector3.new(-339.48,18,6.25),[8]=Vector3.new(-339.48,18,-99.73),
}
local _PLOT_BOXES = {
[1] = { minX = -525.25, maxX = -479.75, minY = -10.10, maxY = 43.90, minZ = 196.61, maxZ = 242.11 },
[2] = { minX = -525.25, maxX = -479.75, minY = -10.10, maxY = 43.90, minZ = 89.61, maxZ = 135.11 },
[3] = { minX = -525.25, maxX = -479.75, minY = -10.10, maxY = 43.90, minZ = -17.39, maxZ = 28.11 },
[4] = { minX = -525.25, maxX = -479.75, minY = -10.10, maxY = 43.90, minZ = -124.39, maxZ = -78.89 },
[5] = { minX = -339.44, maxX = -293.94, minY = -10.10, maxY = 43.90, minZ = 199.11, maxZ = 244.61 },
[6] = { minX = -339.44, maxX = -293.94, minY = -10.10, maxY = 43.90, minZ = 92.11, maxZ = 137.61 },
[7] = { minX = -339.44, maxX = -293.94, minY = -10.10, maxY = 43.90, minZ = -14.89, maxZ = 30.61 },
[8] = { minX = -339.44, maxX = -293.94, minY = -10.10, maxY = 43.90, minZ = -121.89, maxZ = -76.39 },
}
local _PLOT_PAD = 8
local _SHOP_PAD = 4
local function _segHitsPlotPad(a, b, k)
local box = _PLOT_BOXES[k]
local minX, maxX = box.minX - _PLOT_PAD, box.maxX + _PLOT_PAD
local minZ, maxZ = box.minZ - _PLOT_PAD, box.maxZ + _PLOT_PAD
local dx, dz = b.X - a.X, b.Z - a.Z
local t0, t1 = 0, 1
local function clip(p, q)
if p > -1e-12 and p < 1e-12 then
return q >= 0
end
local r = q / p
if p < 0 then
if r > t1 then return false end
if r > t0 then t0 = r end
else
if r < t0 then return false end
if r < t1 then t1 = r end
end
return true
end
if not clip(-dx, a.X - minX) then return false end
if not clip(dx, maxX - a.X) then return false end
if not clip(-dz, a.Z - minZ) then return false end
if not clip(dz, maxZ - a.Z) then return false end
return true
end
local FRONT_Y_LOW = -3.048217
local FRONT_Y_HIGH = 16.850713
local COLUMN_SPLIT_X = -410
local FRONT_Z_CLAMP = 8
local SIDE_NEAR_Z = 45
local function getClosestBaseIdx(pos)
local closest, dist = 1, math.huge
for i = 1, 8 do
local b = BASES_LOW[i]
local d = (pos.X - b.X)^2 + (pos.Z - b.Z)^2
if d < dist then dist = d; closest = i end
end
return closest
end
do
local function initializeEliteGround()
_G.EliteRedLines=true
do
local boxes={}
local holder
local SKIP={InvisibleWalls=true,LaserHitbox=true,DeliveryHitbox=true,StealHitbox=true,Hitbox=true,AnimalTarget=true,Multiplier=true}
local function lineColor()
local c=_G.EliteRedLineColor
if typeof(c)=="Color3"then return c end
return Color3.fromRGB(255,35,35)
end
local function getHolder()
if holder and holder.Parent then return holder end
holder=Instance.new("Folder")
holder.Name="ElsEliteGround"
holder:SetAttribute("ElsVisual",true)
holder.Parent=workspace
return holder
end
function _G.Els_AABB(root)
local minx,miny,minz=math.huge,math.huge,math.huge
local maxx,maxy,maxz=-math.huge,-math.huge,-math.huge
local found=0
local list=root:GetDescendants()
if root:IsA("BasePart")then list[#list+1]=root end
local t0=os.clock()
for i=1,#list do
local d=list[i]
if d:IsA("BasePart")and not SKIP[d.Name]then
local par=d.Parent
if not(par and SKIP[par.Name])then
local c,s=d.CFrame,d.Size
local r,u,l=c.RightVector,c.UpVector,c.LookVector
local ex=0.5*(math.abs(r.X)*s.X+math.abs(u.X)*s.Y+math.abs(l.X)*s.Z)
local ey=0.5*(math.abs(r.Y)*s.X+math.abs(u.Y)*s.Y+math.abs(l.Y)*s.Z)
local ez=0.5*(math.abs(r.Z)*s.X+math.abs(u.Z)*s.Y+math.abs(l.Z)*s.Z)
local p=c.Position
if p.X-ex<minx then minx=p.X-ex end
if p.Y-ey<miny then miny=p.Y-ey end
if p.Z-ez<minz then minz=p.Z-ez end
if p.X+ex>maxx then maxx=p.X+ex end
if p.Y+ey>maxy then maxy=p.Y+ey end
if p.Z+ez>maxz then maxz=p.Z+ez end
found=found+1
end
end
if os.clock()-t0>0.004 then
task.wait()
t0=os.clock()
end
end
if found==0 then return nil end
return minx,miny,minz,maxx,maxy,maxz,found
end
local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater=true
local function groundY(minx,miny,minz,maxx,maxy,maxz)
rayParams.FilterDescendantsInstances={getHolder()}
local off=3
local xs={minx-off,(minx+maxx)/2,maxx+off}
local zs={minz-off,(minz+maxz)/2,maxz+off}
local ys={}
for xi=1,3 do
for zi=1,3 do
if not(xi==2 and zi==2)then
local r=workspace:Raycast(Vector3.new(xs[xi],maxy+10,zs[zi]),Vector3.new(0,-(maxy-miny)-400,0),rayParams)
if r then ys[#ys+1]=r.Position.Y end
end
end
end
if#ys==0 then return nil end
table.sort(ys)
return ys[math.max(1,math.floor(#ys/3)+1)]
end
function _G.Els_DrawBox(key,minx,miny,minz,maxx,maxy,maxz,gyFallback)
local sx,sz=maxx-minx,maxz-minz
if sx<2 or sz<2 then return end
local t=tonumber(_G.EliteRedLineWidth)or 0.2
local e=boxes[key]
local sig=string.format("%d|%.1f|%.1f|%.1f|%.1f|%.2f",math.floor(os.clock()/20),minx,minz,maxx,maxz,t)
if e and e.folder and e.folder.Parent and e.sig==sig then return end
local gy=groundY(minx,miny,minz,maxx,maxy,maxz)or gyFallback
if not gy or gy>maxy or gy<miny-80 then gy=miny end
if not(e and e.folder and e.folder.Parent)then
local count=0
for _ in pairs(boxes)do count=count+1 end
if not e and count>=14 then return end
if e then pcall(function()e.folder:Destroy()end)end
local folder=Instance.new("Folder")
folder.Name="L"..tostring(key)
folder.Parent=getHolder()
local parts={}
for i=1,4 do
local p=Instance.new("Part")
p.Anchored=true
p.CanCollide=false
p.CanQuery=false
p.CanTouch=false
p.CastShadow=false
p.Material=Enum.Material.SmoothPlastic
p.Reflectance=0
p.TopSurface=Enum.SurfaceType.Smooth
p.BottomSurface=Enum.SurfaceType.Smooth
p.Parent=folder
parts[i]=p
end
e={folder=folder,parts=parts}
boxes[key]=e
end
e.sig=sig
local h=0.06
local off=t/2+0.6
local x0,x1,z0,z1=minx-off,maxx+off,minz-off,maxz+off
local y=gy+h/2+0.02
local col=lineColor()
local ps=e.parts
ps[1].Size=Vector3.new(x1-x0+t,h,t)
ps[1].CFrame=CFrame.new((x0+x1)/2,y,z0)
ps[2].Size=Vector3.new(x1-x0+t,h,t)
ps[2].CFrame=CFrame.new((x0+x1)/2,y,z1)
ps[3].Size=Vector3.new(t,h,z1-z0-t)
ps[3].CFrame=CFrame.new(x0,y,(z0+z1)/2)
ps[4].Size=Vector3.new(t,h,z1-z0-t)
ps[4].CFrame=CFrame.new(x1,y,(z0+z1)/2)
for i=1,4 do ps[i].Color=col end
end
function _G.Els_HasBox(key)return boxes[key]~=nil end
function _G.Els_PruneBoxes(prefix,keep)
for k,e in pairs(boxes)do
if string.sub(k,1,#prefix)==prefix and not keep[k]then
pcall(function()e.folder:Destroy()end)
boxes[k]=nil
end
end
end
function _G.EliteClearRedLines()
for k,e in pairs(boxes)do
pcall(function()e.folder:Destroy()end)
boxes[k]=nil
end
end
task.spawn(function()
if _G.EliteRedLines==false then return end
if not game:IsLoaded()then game.Loaded:Wait()end
local plots=workspace:FindFirstChild("Plots")or workspace:WaitForChild("Plots",60)
if not plots then return end
local measured={}
local learned={}
local seen=setmetatable({},{__mode="k"})
local function col(i)return i<=4 and"w"or"e"end
for _,s in pairs((_G.Els_EliteGroundSnapshot or {}).plots or {})do
if s[7] and s[7]>=60 and s[4]-s[1]<=400 and s[6]-s[3]<=400 then
local cx,cz=(s[1]+s[4])/2,(s[3]+s[6])/2
local idx=getClosestBaseIdx(Vector3.new(cx,0,cz))
local B=BASES_LOW[idx]
if B then
measured[idx]={minx=s[1],miny=s[2],minz=s[3],maxx=s[4],maxy=s[5],maxz=s[6]}
learned[col(idx)]={dx=cx-B.X,dz=cz-B.Z,sx=s[4]-s[1],sz=s[6]-s[3],lo=s[2]-B.Y,hi=s[5]-B.Y}
end
end
end
local function record(plot)
if type(BASES_LOW)~="table"or type(getClosestBaseIdx)~="function"then return false end
local snap=_G.Els_EliteGroundSnapshot and _G.Els_EliteGroundSnapshot.plots[plot.Name]
local minx,miny,minz,maxx,maxy,maxz,n
if snap then minx,miny,minz,maxx,maxy,maxz,n=table.unpack(snap)
else minx,miny,minz,maxx,maxy,maxz,n=_G.Els_AABB(plot)end
if not minx or n<60 then return false end
if(maxx-minx)>400 or(maxz-minz)>400 then return false end
local cx,cz=(minx+maxx)/2,(minz+maxz)/2
local idx=getClosestBaseIdx(Vector3.new(cx,0,cz))
local B=BASES_LOW[idx]
if not B then return false end
local m={minx=minx,miny=miny,minz=minz,maxx=maxx,maxy=maxy,maxz=maxz}
measured[idx]=m
learned[col(idx)]={dx=cx-B.X,dz=cz-B.Z,sx=maxx-minx,sz=maxz-minz,lo=miny-B.Y,hi=maxy-B.Y}
return true
end
local function synth(i)
local B=BASES_LOW[i]
local L=learned[col(i)]
local mirror=false
if not L then
L=learned[i<=4 and"e"or"w"]
mirror=true
end
if not B or not L then return nil end
local cx=B.X+(mirror and-L.dx or L.dx)
local cz=B.Z+L.dz
return cx-L.sx/2,B.Y+L.lo,cz-L.sz/2,cx+L.sx/2,B.Y+L.hi,cz+L.sz/2
end
while true do
if _G.EliteRedLines~=false and type(BASES_LOW)=="table"then
local now=os.clock()
local count=0
for _,plot in ipairs(plots:GetChildren())do
if count<8 and(plot:IsA("Model")or plot:IsA("Folder"))and plot:FindFirstChild("AnimalPodiums")then
count=count+1
local rec=seen[plot]
if not rec then
rec={n=0}
seen[plot]=rec
end
local age=rec.t0 and now-rec.t0 or 0
if rec.n==0 or(rec.n==1 and age>=8)or(rec.n==2 and age>=25)then
local ok,done=pcall(record,plot)
if ok and done then
rec.n=rec.n+1
rec.t0=rec.t0 or now
end
end
end
end
for i=1,8 do
local m=measured[i]
if m then
pcall(_G.Els_DrawBox,"base_"..i,m.minx,m.miny,m.minz,m.maxx,m.maxy,m.maxz)
else
local a,b,c,d,e,f=synth(i)
if a then pcall(_G.Els_DrawBox,"base_"..i,a,b,c,d,e,f)end
end
end
end
task.wait(1)
end
end)
local SHOPNAMES={shop=true,itemshop=true,itemsshop=true}
if type(_G.EliteRemoveNames)=="table"then
for _,n in ipairs(_G.EliteRemoveNames)do
if type(n)=="string"then SHOPNAMES[(string.lower(n):gsub("[%s_%-]",""))]=true end
end
end
local SKIP_ROOT={Plots=true,RenderedMovingAnimals=true,Camera=true,Terrain=true}
local function notWheel(low)
return not(string.find(low,"wheel",1,true)or string.find(low,"spin",1,true)or string.find(low,"eclipse",1,true))
end
local function rootOk(inst)
local top=inst
while top.Parent and top.Parent~=workspace do top=top.Parent end
return top.Parent==workspace and not SKIP_ROOT[top.Name]
end
local function shopCandidate(inst)
local cn=inst.ClassName
if cn~="Model"and cn~="Folder"then return false end
local low=string.lower(inst.Name)
if not notWheel(low)then return false end
local nm=(low:gsub("[%s_%-]",""))
if not(SHOPNAMES[nm]or string.find(nm,"itemshop",1,true))then return false end
return rootOk(inst)
end
local function drawShop(inst,slice)
local minx,miny,minz,maxx,maxy,maxz=_G.Els_AABB(inst)
if not minx then return false end
local sx,sz=maxx-minx,maxz-minz
if sx<8 or sz<8 or sx>250 or sz>250 then return false end
local total,anch=0,0
for _,d in ipairs(inst:GetDescendants())do
if d:IsA("BasePart")then
total=total+1
if d.Anchored then anch=anch+1 end
end
end
if total<5 or anch<total*0.6 then return false end
_G.Els_DrawBox("shop_"..inst.Name,minx,miny,minz,maxx,maxy,maxz)
return true
end
local shopDrawn=false
local function noteShop(inst)
if _G.EliteRedLines==false then return end
if not shopCandidate(inst)then return end
local okD,resD=pcall(drawShop,inst)
if okD and resD then shopDrawn=true end
for _,dt in ipairs({1.5,6,15})do
task.delay(dt,function()pcall(drawShop,inst)end)
end
end
local origPark=_G.Els_Park
if type(origPark)=="function"then
_G.Els_Park=function(inst,...)
if typeof(inst)=="Instance"then pcall(noteShop,inst)end
return origPark(inst,...)
end
end
local function allModels()
local ok,r=pcall(function()return workspace:QueryDescendants("Model, Folder")end)
if ok and type(r)=="table"then return r end
return workspace:GetDescendants()
end
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
workspace.DescendantAdded:Connect(function(d)
local cn=d.ClassName
if cn=="Model"or cn=="Folder"then task.defer(noteShop,d)end
end)
local all=allModels()
local t0=os.clock()
for i=1,#all do
local d=all[i]
local cn=d.ClassName
if cn=="Model"or cn=="Folder"then noteShop(d)end
if os.clock()-t0>0.004 then
task.wait()
t0=os.clock()
end
end
task.wait(20)
if shopDrawn or _G.EliteRedLines==false then return end
local best,bestArea
local names={}
t0=os.clock()
for _,d in ipairs(allModels())do
if os.clock()-t0>0.004 then
task.wait()
t0=os.clock()
end
local cn=d.ClassName
if(cn=="Model"or cn=="Folder")then
local low=string.lower(d.Name)
if string.find(low,"shop",1,true)and notWheel(low)and not string.find(low,"robux",1,true)and rootOk(d)then
names[#names+1]=d.Name
local ok,minx,_,minz,maxx,_,maxz=pcall(_G.Els_AABB,d)
if ok and minx then
local area=(maxx-minx)*(maxz-minz)
if area>=64 and area<=62500 and(not bestArea or area>bestArea)then best,bestArea=d,area end
end
end
end
end
pcall(print,"[LINES] objects with 'shop' in the name: "..(#names>0 and table.concat(names,", ")or"none found"))
local okB,resB
if best then okB,resB=pcall(drawShop,best)end
if best and okB and resB then
shopDrawn=true
pcall(print,"[LINES] guessed the item shop is '"..best.Name.."' - if that is wrong, run with _G.EliteRemoveNames={\"RealName\"}")
end
end)
end
task.defer(function()
for name,b in pairs((_G.Els_EliteGroundSnapshot or {}).shops or {})do
pcall(_G.Els_DrawBox,"shop_"..name,table.unpack(b,1,6))
end
end)
end
task.spawn(function()
task.wait(5)
pcall(initializeEliteGround)
end)
end
local function buildFrontCandidate(idx, isUpper, playerZ)
local base = isUpper and BASES_HIGH[idx] or BASES_LOW[idx]
local frontY = isUpper and FRONT_Y_HIGH or FRONT_Y_LOW
local frontZ = math.clamp(playerZ - base.Z, -FRONT_Z_CLAMP, FRONT_Z_CLAMP) + base.Z
local coord = Vector3.new(base.X, frontY, frontZ)
local faceDir = (idx <= 4) and Vector3.new(-1, 0, 0) or Vector3.new(1, 0, 0)
return coord, faceDir
end
local function plotSides(coordTable, idx)
local base = BASES_LOW[idx]
local isWest = idx <= 4
local out = {}
for _, coords in pairs(coordTable) do
for _, data in ipairs(coords) do
if ((data.coord.X < COLUMN_SPLIT_X) == isWest)
and math.abs(data.coord.Z - base.Z) < SIDE_NEAR_Z then
out[#out + 1] = data
end
end
end
return out
end
local function cloneDestCandidates(hrpPos, petPos, petName)
local adjY = petPos.Y
if TALL_PETS[petName] then adjY = petPos.Y - TALL_OFFSET end
local coordTable = adjY > UPPER_Y_THRESHOLD and UPPER or LOWER
local isUpper = (coordTable == UPPER)
local idx = getClosestBaseIdx(petPos)
local frontCoord, frontFace = buildFrontCandidate(idx, isUpper, hrpPos.Z)
local list = { { coord = frontCoord, face = frontFace } }
for _, d in ipairs(plotSides(coordTable, idx)) do
local face = d.facing == "NORTH" and Vector3.new(0, 0, -1) or Vector3.new(0, 0, 1)
list[#list + 1] = { coord = d.coord, face = face }
end
return list
end
local function resolveCloneDest(hrpPos, petPos, petName)
local list = cloneDestCandidates(hrpPos, petPos, petName)
local bestCoord, bestFace = list[1].coord, list[1].face
local bestDist = (hrpPos - bestCoord).Magnitude
for i = 2, #list do
local dd = (hrpPos - list[i].coord).Magnitude
if dd < bestDist then
bestDist = dd
bestCoord = list[i].coord
bestFace = list[i].face
end
end
return bestCoord, bestFace
end
local _PUSH_SKIP = {
Floor = true, Spawn = true, MainRoot = true, AnimalTarget = true,
Multiplier = true, DeliveryHitbox = true, StealHitbox = true,
SecondFloor = true, ThirdFloor = true, Slope = true, Roof = true,
XenHubLandPlatform = true,
__HITBOX = true,
}
local _wallLat = { 0, 5, -5, 14, -14 }
local _wallRp = RaycastParams.new()
_wallRp.IgnoreWater = true
_wallRp.FilterType = Enum.RaycastFilterType.Exclude
local function wallFrontPos(destPos, facingDir)
if not destPos or not facingDir or facingDir.Magnitude < 0.1 then return destPos, "dest" end
local axis = facingDir.Unit
local perp = Vector3.new(-axis.Z, 0, axis.X)
_wallRp.FilterDescendantsInstances = { LP.Character }
local bestAlong, bestName = nil, "dest"
local function considerAlong(along, off, name, maxOff)
if off > (maxOff or 16) or along < -2 or along > 28 then return end
if bestAlong == nil or along < bestAlong then
bestAlong = along
bestName = name
end
end
local function considerHit(res)
if not res then return end
local n = res.Instance and res.Instance.Name or ""
if _PUSH_SKIP[n] then return end
if math.abs(res.Normal.Y) >= 0.5 then return end
local along = (res.Position - destPos):Dot(axis)
local off = (res.Position - destPos - axis * along).Magnitude
considerAlong(along, off, n, 14)
end
for _, lat in ipairs(_wallLat) do
local origin = destPos - axis * 12 + perp * lat + Vector3.new(0, 2, 0)
considerHit(workspace:Raycast(origin, axis * 40, _wallRp))
end
if bestAlong == nil then return destPos, "dest" end
local stick = destPos + axis * bestAlong
stick = Vector3.new(stick.X, destPos.Y, stick.Z)
return stick, bestName
end
local function _antiFall(hrp, destPos)
local char = hrp and hrp.Parent
local hum = char and char:FindFirstChildOfClass("Humanoid")
local plat
local stopped = false
local conn
plat = Instance.new("Part")
plat.Name = "XenHubLandPlatform"
plat.Size = Vector3.new(14, 1, 14)
plat.Position = Vector3.new(destPos.X, destPos.Y - 3.15, destPos.Z)
plat.Anchored = true
plat.CanCollide = true
plat.Transparency = 1
plat.Parent = workspace
if hum then
pcall(function()
hum.Sit = false
hum.PlatformStand = false
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
hum:ChangeState(Enum.HumanoidStateType.Running)
end)
end
local tEnd = os.clock() + 1.1
local function stop(killPlatNow)
if stopped then return end
stopped = true
if conn then conn:Disconnect(); conn = nil end
if hum and hum.Parent then
pcall(function()
hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
end)
end
if killPlatNow then
if plat and plat.Parent then plat:Destroy() end
else
task.delay(5, function()
if plat and plat.Parent then plat:Destroy() end
end)
end
end
conn = RunService.Heartbeat:Connect(function()
if stopped then return end
if os.clock() > tEnd then
stop(false)
return
end
local h = (hrp and hrp.Parent) and hrp or nil
if h then
local v = h.AssemblyLinearVelocity
if v.Y < -2 then
h.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
end
h.AssemblyAngularVelocity = Vector3.zero
end
if hum and hum.Parent then
pcall(function()
hum.Sit = false
local st = hum:GetState()
if st == Enum.HumanoidStateType.FallingDown
or st == Enum.HumanoidStateType.Ragdoll
or st == Enum.HumanoidStateType.GettingUp then
hum:ChangeState(Enum.HumanoidStateType.Running)
end
end)
end
end)
return stop
end
local function vZero(hrp)
if not hrp then return end
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
pcall(function()
hrp.Velocity = Vector3.zero
end)
end
local function velMoveThrough(hrp, waypoints, speedOverride, precise)
if not hrp or not hrp.Parent or #waypoints == 0 then
return
end
local finishR = precise and 0.75 or 8
local landAt = waypoints[#waypoints]
_G.__Els_VelFlying = true
_G.__Els_FlyHrp = hrp
local _runSpeed = _G.D3GovClamp(speedOverride or ANGVELSSpeed.CARPET)
hrp.Anchored = false
local names = _G.Els_CarpetNames or { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
local function carpetHeld()
local c = hrp.Parent
if not c then return false end
for i = 1, #names do
if c:FindFirstChild(names[i]) then return true end
end
return false
end
pcall(function()
if _G.Els_EquipCarpet then _G.Els_EquipCarpet() end
end)
local char = hrp.Parent
local hum = char and char:FindFirstChildOfClass("Humanoid")
pcall(function()
local a = char and char:FindFirstChild("Animate")
if a then a.Disabled = true end
end)
local function releaseFall()
if not (hum and hum.Parent) then return end
pcall(function()
hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end)
end
if hum then
pcall(function()
hum.PlatformStand = false
hum.Sit = false
hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
hum:ChangeState(Enum.HumanoidStateType.Jumping)
hum.Jump = true
end)
end
local pts = { hrp.Position }
for i = 1, #waypoints do
local p = waypoints[i]
if (p - pts[#pts]).Magnitude > 0.25 then
pts[#pts + 1] = p
end
end
local n = #pts
if n < 2 then
vZero(hrp)
releaseFall()
_G.__Els_VelFlying = false
_G.__Els_FlyHrp = nil
return
end
local wpIdx = 2
local done = false
local lastVel = Vector3.zero
local lastClock = 0
local function finish()
if done then return end
done = true
_G.__Els_FlyPre = nil
_G.__Els_FlyHb = nil
releaseFall()
if hrp and hrp.Parent then
pcall(function() hrp.CanCollide = true end)
local dest = landAt or pts[n]
if not precise and dest and (hrp.Position - dest).Magnitude <= 12 then
hrp.CFrame = CFrame.new(dest)
end
vZero(hrp)
end
end
pcall(function()
hrp.CanCollide = false
end)
local function setALV(dir, dtHint, remain)
if not (hrp and hrp.Parent) or dir.Magnitude < 0.1 then return end
local now = os.clock()
local step = tonumber(dtHint)
if not (step and step > 0) then
if lastClock > 0 then
step = now - lastClock
else
step = 0.016
end
end
lastClock = now
local spd = _runSpeed
if remain then
local cap2 = remain / math.max(step, 1 / 60)
if spd > cap2 then spd = cap2 end
end
lastVel = dir.Unit * spd
hrp.AssemblyLinearVelocity = lastVel
hrp.AssemblyAngularVelocity = Vector3.zero
end
local function stepLine(dtHint)
if wpIdx > n then
finish()
return
end
local dest = landAt or pts[n]
if dest then
local toDest = dest - hrp.Position
if toDest.Magnitude < finishR then
finish()
return
end
if wpIdx >= n and lastVel.Magnitude > 10 and lastVel.Unit:Dot(toDest) <= 0 then
finish()
return
end
end
local A = pts[wpIdx - 1] or hrp.Position
local B = pts[wpIdx]
if not B then
finish()
return
end
local AB = B - A
local len = AB.Magnitude
if len < 0.05 then
if wpIdx >= n then
finish()
return
end
wpIdx += 1
B = pts[wpIdx]
if not B then
finish()
return
end
AB = B - hrp.Position
len = AB.Magnitude
if len < 0.05 then return end
end
local dir = AB.Unit
local along = (hrp.Position - A):Dot(dir)
local toB = B - hrp.Position
if wpIdx >= n then
if toB.Magnitude < finishR or dir:Dot(toB) <= 0 then
finish()
return
end
dir = toB.Magnitude > 0.1 and toB.Unit or dir
elseif along >= len or dir:Dot(toB) <= 0 then
wpIdx += 1
if wpIdx > n then
finish()
return
end
local nxt = pts[wpIdx]
if not nxt then
finish()
return
end
local toN = nxt - hrp.Position
if toN.Magnitude > 0.05 then
dir = toN.Unit
end
end
local rem = nil
if precise and wpIdx >= n then
rem = ((landAt or pts[n]) - hrp.Position).Magnitude
end
setALV(dir, dtHint, rem)
end
_G.__Els_FlyPre = function(dt)
if done or not hrp or not hrp.Parent then
_G.__Els_FlyPre = nil
return
end
local ok = pcall(stepLine, dt)
if not ok then
finish()
end
end
_G.__Els_FlyHb = function()
if done or not hrp or not hrp.Parent then
_G.__Els_FlyHb = nil
return
end
if not carpetHeld() then
pcall(function()
if _G.Els_EquipCarpet then _G.Els_EquipCarpet() end
end)
end
end
local total = 0
for i = 2, n do
total = total + (pts[i] - pts[i - 1]).Magnitude
end
local timeout = total / math.max(_runSpeed, 1) + (precise and 3 or 2)
local tVel = os.clock()
while not done and (os.clock() - tVel) < timeout do
RunService.Heartbeat:Wait()
end
finish()
if hrp and hrp.Parent then
pcall(function() hrp.CanCollide = true end)
local dest = landAt or pts[n]
if not precise and dest and (hrp.Position - dest).Magnitude <= 12 then
hrp.CFrame = CFrame.new(dest)
end
vZero(hrp)
end
_G.__Els_VelFlying = false
_G.__Els_FlyHrp = nil
_G.__Els_FlyPre = nil
_G.__Els_FlyHb = nil
end
local _MID_BOXES = {
{ minX = -450.30, maxX = -435.20, minY = -11.40, maxY = 2.70, minZ = 29.05, maxZ = 51.30 },
{ minX = -445.66, maxX = -434.56, minY = -10.12, maxY = 3.80, minZ = 54.67, maxZ = 67.69 },
{ minX = -385.76, maxX = -367.76, minY = -10.00, maxY = 5.84, minZ = 56.26, maxZ = 81.26 },
{ minX = -443.55, maxX = -434.52, minY = -11.40, maxY = 6.42, minZ = 70.83, maxZ = 87.11 },
{ minX = -440.83, maxX = -438.98, minY = -9.50, maxY = -1.98, minZ = 36.37, maxZ = 43.65 },
{ minX = -386.35, maxX = -371.25, minY = -11.40, maxY = 2.70, minZ = 29.10, maxZ = 51.35 },
}
local function _segmentHitsShop(a, b)
local function inside(p)
for i = 1, #_MID_BOXES do
local box = _MID_BOXES[i]
if p.X >= box.minX - _SHOP_PAD and p.X <= box.maxX + _SHOP_PAD
and p.Y >= box.minY and p.Y <= box.maxY
and p.Z >= box.minZ - _SHOP_PAD and p.Z <= box.maxZ + _SHOP_PAD then
return true
end
end
return false
end
local mag = (b - a).Magnitude
if mag < 0.05 then return inside(a) end
local n = math.max(6, math.floor(mag / 3))
for i = 0, n do
if inside(a + (b - a) * (i / n)) then return true end
end
return false
end
local function _clearWide(a, b, ignA, ignB)
if _segmentHitsShop(a, b) then return false end
for k = 1, 8 do
if k ~= ignA and k ~= ignB and _segHitsPlotPad(a, b, k) then return false end
end
return true
end
local function _len(pts)
local s, prev = 0, pts[1]
for k = 2, #pts do s = s + (pts[k] - prev).Magnitude; prev = pts[k] end
return s
end
local function _nearestBase(p)
for i = 1, 8 do
local box = _PLOT_BOXES[i]
if p.X >= box.minX and p.X <= box.maxX and p.Z >= box.minZ and p.Z <= box.maxZ then
return i
end
end
local bi, bd = nil, math.huge
for i = 1, 8 do
local b = BASES_LOW[i]
local d = (p.X - b.X) ^ 2 + (p.Z - b.Z) ^ 2
if d < bd then bd = d; bi = i end
end
if bd > 90 * 90 then return nil end
return bi
end
local function _ptHitsBase(px, pz, k, ignB)
if k == ignB then return false end
local box = _PLOT_BOXES[k]
return px >= (box.minX - _PLOT_PAD) and px <= (box.maxX + _PLOT_PAD)
and pz >= (box.minZ - _PLOT_PAD) and pz <= (box.maxZ + _PLOT_PAD)
end
local function _segmentHitsOtherBase(a, b, ignA, ignB)
for k = 1, 8 do
if k ~= ignA and k ~= ignB and _segHitsPlotPad(a, b, k) then return true end
end
return false
end
local function _canSeeSide(p, dest, iTo)
if not iTo then iTo = getClosestBaseIdx(dest) end
if (dest - p).Magnitude < 6 then return true end
if iTo and _ptHitsBase(p.X, p.Z, iTo, nil) then return false end
if _segmentHitsOtherBase(p, dest, nil, iTo) then return false end
if (dest - p).Magnitude >= 6 and _segmentHitsShop(p, dest) then return false end
return true
end
local _GCELL = 4
local _GX0, _GZ0 = -540, -150
local _GNX = 67
local _GNZ = 105
local _GSHOP = table.create(_GNX * _GNZ, false)
local _GPLOT = {}
for k = 1, 8 do
_GPLOT[k] = table.create(_GNX * _GNZ, false)
end
do
local shopPad = _SHOP_PAD
for iz = 0, _GNZ - 1 do
local z0 = _GZ0 + iz * _GCELL
local z1 = z0 + _GCELL
for ix = 0, _GNX - 1 do
local x0 = _GX0 + ix * _GCELL
local x1 = x0 + _GCELL
local idx = iz * _GNX + ix + 1
for s = 1, #_MID_BOXES do
local b = _MID_BOXES[s]
if x1 > (b.minX - shopPad) and x0 < (b.maxX + shopPad)
and z1 > (b.minZ - shopPad) and z0 < (b.maxZ + shopPad) then
_GSHOP[idx] = true
break
end
end
for k = 1, 8 do
local b = _PLOT_BOXES[k]
local p = _PLOT_PAD
if x1 > (b.minX - p) and x0 < (b.maxX + p)
and z1 > (b.minZ - p) and z0 < (b.maxZ + p) then
_GPLOT[k][idx] = true
end
end
end
end
end
local function _gWalk(ix, iz, ignA, ignB)
if ix < 0 or iz < 0 or ix >= _GNX or iz >= _GNZ then return false end
local idx = iz * _GNX + ix + 1
if _GSHOP[idx] then return false end
for k = 1, 8 do
if k ~= ignA and k ~= ignB and _GPLOT[k][idx] then return false end
end
return true
end
local function _gNear(ix, iz, ignA, ignB)
if _gWalk(ix, iz, ignA, ignB) then return ix, iz end
for r = 1, 12 do
for dz = -r, r do
for dx = -r, r do
if math.abs(dx) == r or math.abs(dz) == r then
local x, z = ix + dx, iz + dz
if _gWalk(x, z, ignA, ignB) then return x, z end
end
end
end
end
return nil
end
local function _routeLen(pts)
if not pts or #pts < 2 then return math.huge end
return _len(pts)
end
local function _pullPath(pts, y, iFrom, iTo)
if not pts or #pts < 3 then return pts end
local out = { pts[1] }
local i = 1
while i < #pts do
local far = i + 1
for j = i + 2, #pts do
local a = Vector3.new(pts[i].X, y, pts[i].Z)
local b = Vector3.new(pts[j].X, y, pts[j].Z)
if _clearWide(a, b, iFrom, iTo) then
far = j
end
end
out[#out + 1] = pts[far]
i = far
end
if #out >= 3 then
local simp = { out[1] }
for k = 2, #out - 1 do
local a, b, c = out[k - 1], out[k], out[k + 1]
local v1, v2 = b - a, c - b
if not (v1.Magnitude > 0.5 and v2.Magnitude > 0.5
and v1.Unit:Dot(v2.Unit) >= 0.995) then
if (b - simp[#simp]).Magnitude > 0.5 then
simp[#simp + 1] = b
end
end
end
local last = out[#out]
if (last - simp[#simp]).Magnitude > 0.5 then
simp[#simp + 1] = last
end
out = simp
end
return out
end
local function _astarXZ(fromPos, toPos, y, ignA, ignB)
local sx = math.floor((fromPos.X - _GX0) / _GCELL)
local sz = math.floor((fromPos.Z - _GZ0) / _GCELL)
local gx = math.floor((toPos.X - _GX0) / _GCELL)
local gz = math.floor((toPos.Z - _GZ0) / _GCELL)
sx, sz = _gNear(sx, sz, ignA, ignB)
gx, gz = _gNear(gx, gz, ignA, ignB)
if not sx or not gx then return nil end
local start = sz * _GNX + sx + 1
local goal = gz * _GNX + gx + 1
local function h(ix, iz)
local dx, dz = math.abs(ix - gx), math.abs(iz - gz)
local m = dx < dz and dx or dz
return (dx + dz - m) + m * 1.41421356
end
local gScore = {}
local came = {}
local closed = {}
local hf, hi = {}, {}
local function push(f, idx)
local i = #hf + 1
hf[i], hi[i] = f, idx
while i > 1 do
local p = math.floor(i * 0.5)
if hf[p] <= hf[i] then break end
hf[p], hf[i] = hf[i], hf[p]
hi[p], hi[i] = hi[i], hi[p]
i = p
end
end
local function pop()
local n = #hf
if n == 0 then return nil end
local idx = hi[1]
hf[1], hi[1] = hf[n], hi[n]
hf[n], hi[n] = nil, nil
local i = 1
n = n - 1
while true do
local l, r, s = i * 2, i * 2 + 1, i
if l <= n and hf[l] < hf[s] then s = l end
if r <= n and hf[r] < hf[s] then s = r end
if s == i then break end
hf[i], hf[s] = hf[s], hf[i]
hi[i], hi[s] = hi[s], hi[i]
i = s
end
return idx
end
gScore[start] = 0
push(h(sx, sz), start)
local found = false
local nVisit = 0
while #hf > 0 do
local cur = pop()
if closed[cur] then continue end
closed[cur] = true
if cur == goal then found = true; break end
nVisit += 1
if nVisit > 8000 then break end
local c0 = cur - 1
local cx, cz = c0 % _GNX, math.floor(c0 / _GNX)
for dz = -1, 1 do
for dx = -1, 1 do
if dx == 0 and dz == 0 then continue end
local nx, nz = cx + dx, cz + dz
if not _gWalk(nx, nz, ignA, ignB) then continue end
if dx ~= 0 and dz ~= 0 then
if not _gWalk(cx + dx, cz, ignA, ignB) then continue end
if not _gWalk(cx, cz + dz, ignA, ignB) then continue end
end
local nidx = nz * _GNX + nx + 1
if closed[nidx] then continue end
local step = (dx ~= 0 and dz ~= 0) and 1.41421356 or 1
local ng = (gScore[cur] or 1e9) + step
if ng < (gScore[nidx] or 1e9) then
gScore[nidx] = ng
came[nidx] = cur
push(ng + h(nx, nz), nidx)
end
end
end
end
if not found then return nil end
local chain = {}
local c = goal
while c do
chain[#chain + 1] = c
c = came[c]
end
local pts = {}
for i = #chain, 1, -1 do
local id = chain[i] - 1
local ix, iz = id % _GNX, math.floor(id / _GNX)
pts[#pts + 1] = Vector3.new(
_GX0 + (ix + 0.5) * _GCELL,
y,
_GZ0 + (iz + 0.5) * _GCELL)
end
if #pts == 0 then return nil end
pts[1] = Vector3.new(fromPos.X, y, fromPos.Z)
pts[#pts] = Vector3.new(toPos.X, y, toPos.Z)
return _pullPath(pts, y, ignA, ignB)
end
local function _visShort(fromPos, toPos, y, ignA, ignB)
local a0 = Vector3.new(fromPos.X, y, fromPos.Z)
local b0 = Vector3.new(toPos.X, y, toPos.Z)
if (a0 - b0).Magnitude < 0.5 then
return { a0, b0 }
end
if _clearWide(a0, b0, ignA, ignB) then
return { a0, b0 }
end
local boxes = {}
local pad = _PLOT_PAD
for k = 1, 8 do
if k ~= ignA and k ~= ignB then
local b = _PLOT_BOXES[k]
boxes[#boxes + 1] = {
minX = b.minX - pad, maxX = b.maxX + pad,
minZ = b.minZ - pad, maxZ = b.maxZ + pad,
}
end
end
local sp = _SHOP_PAD
for s = 1, #_MID_BOXES do
local b = _MID_BOXES[s]
boxes[#boxes + 1] = {
minX = b.minX - sp, maxX = b.maxX + sp,
minZ = b.minZ - sp, maxZ = b.maxZ + sp,
}
end
local function inBox(x, z)
for i = 1, #boxes do
local b = boxes[i]
if x >= b.minX and x <= b.maxX and z >= b.minZ and z <= b.maxZ then
return true
end
end
return false
end
local nx = { fromPos.X, toPos.X }
local nz = { fromPos.Z, toPos.Z }
local eps = 0.45
for i = 1, #boxes do
local b = boxes[i]
local cx = { b.minX - eps, b.maxX + eps, b.maxX + eps, b.minX - eps }
local cz = { b.minZ - eps, b.minZ - eps, b.maxZ + eps, b.maxZ + eps }
for c = 1, 4 do
if not inBox(cx[c], cz[c]) then
nx[#nx + 1] = cx[c]
nz[#nz + 1] = cz[c]
end
end
end
local n = #nx
if n < 2 then return nil end
local inf = 1e18
local g = table.create(n, inf)
local prv = table.create(n, 0)
local used = table.create(n, false)
g[1] = 0
for _ = 1, n do
local u, best = 0, inf
for i = 1, n do
if not used[i] and g[i] < best then
best = g[i]
u = i
end
end
if u == 0 then break end
used[u] = true
if u == 2 then break end
local pa = Vector3.new(nx[u], y, nz[u])
for v = 1, n do
if used[v] or v == u then continue end
local dx, dz = nx[v] - nx[u], nz[v] - nz[u]
local dist = math.sqrt(dx * dx + dz * dz)
if dist < 0.05 or g[u] + dist >= g[v] then continue end
local pb = Vector3.new(nx[v], y, nz[v])
if _clearWide(pa, pb, ignA, ignB) then
g[v] = g[u] + dist
prv[v] = u
end
end
end
if g[2] >= inf * 0.5 or prv[2] == 0 then return nil end
local chain = { 2 }
local c = 2
local guard = 0
while c ~= 1 do
c = prv[c]
if c == 0 then return nil end
chain[#chain + 1] = c
guard += 1
if guard > n then return nil end
end
local pts = {}
for i = #chain, 1, -1 do
local id = chain[i]
pts[#pts + 1] = Vector3.new(nx[id], y, nz[id])
end
pts[1] = a0
pts[#pts] = b0
return _pullPath(pts, y, ignA, ignB)
end
local function computeRoute(fromPos, toPos, facingDir)
local y = fromPos.Y
local iFrom, iTo = _nearestBase(fromPos), _nearestBase(toPos)
if not iTo then iTo = getClosestBaseIdx(toPos) end
local route
local hitsShop = _segmentHitsShop(fromPos, toPos)
if _canSeeSide(fromPos, toPos, iTo) and not hitsShop then
route = { toPos }
_routeVia = "ligne"
else
local best, bestL = nil, math.huge
local function take(pts, via)
if not pts or #pts < 1 then return end
local copy = {}
for i = 1, #pts do
copy[i] = pts[i]
end
if (copy[#copy] - toPos).Magnitude > 0.5 then
copy[#copy + 1] = toPos
end
local L = _routeLen(copy)
if L < bestL then
best, bestL = copy, L
_routeVia = via
end
end
take(_visShort(fromPos, toPos, y, iFrom, iTo), "short")
if not best then
take(_astarXZ(fromPos, toPos, y, iFrom, iTo), "astar")
end
if best then
route = best
else
route = { toPos }
_routeVia = "short"
end
end
return route
end
local function _jumpPath(fromPos, toPos, facingDir)
if Config and Config.TpSettings and Config.TpSettings.JumpTP == false then return nil end
local ok, route = pcall(computeRoute, fromPos, toPos, facingDir)
if not ok or type(route) ~= "table" or #route == 0 then route = { toPos } end
local function inBox(p, list, pad)
for k = 1, #list do
local b = list[k]
if p.X >= b.minX - pad and p.X <= b.maxX + pad and p.Z >= b.minZ - pad and p.Z <= b.maxZ + pad then return true end
end
return false
end
local samples, segOf = {}, {}
local prev = Vector3.new(fromPos.X, 0, fromPos.Z)
samples[1], segOf[1] = prev, 1
for i, wp in ipairs(route) do
local cur = Vector3.new(wp.X, 0, wp.Z)
local n = math.max(1, math.ceil((cur - prev).Magnitude / 2))
for s = 1, n do
samples[#samples + 1] = prev:Lerp(cur, s / n)
segOf[#samples] = i
end
prev = cur
end
local ie = 1
while ie <= #samples and inBox(samples[ie], _PLOT_BOXES, _PLOT_PAD) do ie += 1 end
local ia = #samples
while ia >= 1 and inBox(samples[ia], _PLOT_BOXES, _PLOT_PAD) do ia -= 1 end
if ie >= ia then return nil end
local E, N = samples[ie], samples[ia]
local D = (N - E).Magnitude
if D < 20 then return nil end
local need = 0
local fine = math.ceil(D / 2)
for s = 1, fine - 1 do
local t = s / fine
local xz = E:Lerp(N, t)
local clear = (inBox(xz, _PLOT_BOXES, _PLOT_PAD) and 50) or (inBox(xz, _MID_BOXES, _SHOP_PAD) and 12) or nil
if clear then
local h = (clear - (fromPos.Y + (toPos.Y - fromPos.Y) * t)) / (4 * t * (1 - t))
if h > need then need = h end
end
end
local H = math.max(need, math.min(D * 0.15, 25), 6)
if H > 100 then return nil end
local out = {}
for i = 1, segOf[ie] - 1 do
out[#out + 1] = Vector3.new(route[i].X, fromPos.Y, route[i].Z)
end
local steps = math.max(8, math.ceil(D / 10))
for s = 1, steps do
local t = s / steps
local xz = E:Lerp(N, t)
out[#out + 1] = Vector3.new(xz.X, fromPos.Y + (toPos.Y - fromPos.Y) * t + 4 * H * t * (1 - t), xz.Z)
end
for i = segOf[ia], #route do
out[#out + 1] = (i == #route) and toPos or Vector3.new(route[i].X, toPos.Y, route[i].Z)
end
if (out[#out] - toPos).Magnitude > 0.5 then out[#out + 1] = toPos end
return out
end
local function _pickJump(fromPos, toPos, facingDir, normal)
local ts = Config and Config.TpSettings
local farD = tonumber(ts and ts.JumpFarDist) or 170
local d = Vector3.new(toPos.X - fromPos.X, 0, toPos.Z - fromPos.Z).Magnitude
local jump = (d >= farD) and _jumpPath(fromPos, toPos, facingDir) or nil
print(string.format("[TP] %d studs : %s", math.floor(d + 0.5), jump and "saut" or "normal"))
return jump or normal
end
local function doClone()
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not char or not hum then return false end
pcall(instantClone)
return true
end
local _belsLandConn, _belsLandPlat
local function _belsLand(hrp, to, minY, platOff)
if not (hrp and to) then return end
if _belsLandConn then pcall(function() _belsLandConn:Disconnect() end); _belsLandConn = nil end
if _belsLandPlat and _belsLandPlat.Parent then pcall(function() _belsLandPlat:Destroy() end) end
local plat = Instance.new("Part")
plat.Name = "XenHubLandPlatform"
plat:SetAttribute("ElsVisual", true)
plat.Size = Vector3.new(14, 1, 14)
plat.Position = Vector3.new(to.X, to.Y - (platOff or 3.15), to.Z)
plat.Anchored = true
plat.CanCollide = true
plat.CanTouch = false
plat.CanQuery = false
plat.CastShadow = false
plat.Transparency = 1
plat.Parent = workspace
_belsLandPlat = plat
local tEnd = os.clock() + 2.2
local char = hrp.Parent
local conn
conn = RunService.Heartbeat:Connect(function()
local gone = not hrp.Parent or LP.Character ~= char
if LP:GetAttribute("Stealing") == true or gone then
if conn then conn:Disconnect() end
if _belsLandConn == conn then _belsLandConn = nil end
conn = nil
if plat and plat.Parent then plat:Destroy() end
return
end
if os.clock() > tEnd then return end
local rh = hrp
local v = rh.AssemblyLinearVelocity
if v.Y < -2 then
rh.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
end
if rh.Position.Y < minY then
rh.CFrame = CFrame.new(rh.Position.X, to.Y, rh.Position.Z)
rh.AssemblyLinearVelocity = Vector3.zero
rh.AssemblyAngularVelocity = Vector3.zero
end
end)
_belsLandConn = conn
end
local function _floorLandMinY(h, to)
if h > 23.15 then return 18 end
return to.Y - 3
end
local function _miniTPSpeed()
local ts = Config and Config.TpSettings
return tonumber(ts and ts.MiniTPSpeed) or 100
end
local function _hopTo(hrp, dest, shouldStop, speed)
local ts = Config and Config.TpSettings
local maxTime = tonumber(ts and ts.HopTime) or 0.25
local height = tonumber(ts and ts.HopHeight) or 6
local from = hrp.Position
local dist = (dest - from).Magnitude
if dist < 0.5 then return true end
local dur
if speed then
dur = math.max(dist / math.max(speed, 1), 0.05)
else
if maxTime <= 0 then return true end
dur = math.clamp(dist / 800, 0.1, math.max(maxTime, 0.1))
end
local ctrl
if speed and math.abs(dest.Y - from.Y) > 3 then
ctrl = Vector3.new((from.X + dest.X) / 2, math.max(from.Y, dest.Y), (from.Z + dest.Z) / 2)
else
local peak = math.max(from.Y, dest.Y) + height
ctrl = Vector3.new((from.X + dest.X) / 2, 2 * peak - (from.Y + dest.Y) / 2, (from.Z + dest.Z) / 2)
end
local rot = hrp.CFrame - hrp.CFrame.Position
pcall(function() hrp.Anchored = true end)
local t0 = os.clock()
while true do
RunService.Heartbeat:Wait()
if not hrp.Parent or (shouldStop and shouldStop()) then return false end
local a = math.min((os.clock() - t0) / dur, 1)
hrp.CFrame = CFrame.new(from:Lerp(ctrl, a):Lerp(ctrl:Lerp(dest, a), a)) * rot
if a >= 1 then return true end
end
end
local function goToBrainrot(petPos, fast, hopSpeed)
if not petPos then return end
local char, hrp, hum
local _t0 = os.clock()
repeat
char = LP.Character
hrp = char and char:FindFirstChild("HumanoidRootPart")
hum = char and char:FindFirstChildOfClass("Humanoid")
if hrp and hum then break end
RunService.Heartbeat:Wait()
until os.clock() - _t0 > 3
if not hrp or not hum then return end
hrp.Anchored = false
local _equipped, _already, _first = false, false, true
do
local _e0 = os.clock()
repeat
char = LP.Character
for _, _cn in ipairs(_G.Els_CarpetNames or {}) do
if char and char:FindFirstChild(_cn) then _equipped = true; break end
end
if _equipped then _already = _first; break end
_first = false
_G.Els_EquipCarpet()
RunService.Heartbeat:Wait()
until _equipped or os.clock() - _e0 > 1.5
if _equipped and not (fast and _already) then
task.wait(0.2)
end
end
char = LP.Character
hrp = char and char:FindFirstChild("HumanoidRootPart")
hum = char and char:FindFirstChildOfClass("Humanoid")
if not hrp then return end
hrp.Anchored = false
do
local _t0b = os.clock()
repeat
local p = hrp.Position
local inRad = false
for i = 1, 8 do
local box = _PLOT_BOXES[i]
if p.X >= box.minX and p.X <= box.maxX and p.Z >= box.minZ and p.Z <= box.maxZ then
inRad = true
break
end
end
if inRad then break end
RunService.Heartbeat:Wait()
until os.clock() - _t0b > 1.5
end
local h = petPos.Y
local targetY = hrp.Position.Y
if h > 23.15 then targetY = 21
elseif h >= 11 and h <= 23.15 then targetY = h - 4
elseif h >= -6.9 and h <= 8.9 then targetY = -4 end
local _to = Vector3.new(petPos.X, targetY, petPos.Z)
_hopTo(hrp, _to, function() return LP.Character ~= char end, hopSpeed)
pcall(function() hrp.Anchored = false end)
if LP.Character ~= char or not hrp.Parent then return end
if _G.Els_UnderBrainrotPlatformStop then pcall(_G.Els_UnderBrainrotPlatformStop) end
if h < 11 then
local plat=Instance.new("Part")
plat.Name="XenHubLandPlatform"
plat:SetAttribute("ElsVisual",true)
plat.Size=Vector3.new(10,1,10)
local foot=(hum and hum.HipHeight or 2)+hrp.Size.Y*0.5
if hum and hum.RigType==Enum.HumanoidRigType.R6 then foot+=2 end
plat.Position=Vector3.new(_to.X,_to.Y-foot-0.5,_to.Z)
plat.Anchored=true;plat.CanCollide=true;plat.CanTouch=false;plat.CanQuery=false
plat.Transparency=1;plat.CastShadow=false;plat.Parent=workspace
local active=true
local function stop()
if not active then return end
active=false;plat:Destroy()
if _G.Els_UnderBrainrotPlatformStop==stop then _G.Els_UnderBrainrotPlatformStop=nil end
end
_G.Els_UnderBrainrotPlatformStop=stop
task.spawn(function()
while active do
task.wait(0.25)
if not active then break end
if not plat.Parent or LP.Character~=char or not hrp.Parent or not hum or hum.Health<=0 then stop();break end
local delta=hrp.Position-_to
if delta.X*delta.X+delta.Z*delta.Z>36 or math.abs(delta.Y)>8 then stop();break end
end
end)
end
if hrp and hrp.Parent then
hrp.CFrame = CFrame.new(_to)
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
end
if h >= 11 then
_belsLand(hrp, _to, _floorLandMinY(h, _to), (h <= 23.15) and 6 or 3.15)
end
end
local _stealTarget
local manualTarget
local selectionVersion=0
local isTeleporting,_tpStartedAt=false,0
local _nearestOn,_nearestCache,_nearestAt=false,nil,nil
local function nearestPaint()end
local function _petUid(p)return p and (tostring(p.plot).."_"..tostring(p.slot))end
local function readTargetSlot(plot,slot,index)
local ch=getPlotChannel(tostring(plot))
if not ch or isMyPlot(ch)then return nil end
local list=channelGet(ch,"AnimalList")
if type(list)~="table"then return nil end
local a=list[slot] or list[tonumber(slot)] or list[tostring(slot)]
if type(a)~="table" or type(a.Index)~="string" or (index and a.Index~=index)
or not _prioRank[a.Index:lower()] or _ANGVELSIsFusing(a)then return nil end
return {name=a.Index,index=a.Index,mutation=_adMut(a),plot=tostring(plot),slot=tostring(slot)}
end
local function _pickByMode(pets)return pets and pets[1]end
local function armSteal(pet)
if not pet then return end
if _petUid(pet)~=_petUid(_stealTarget) or (_stealTarget and pet.index~=_stealTarget.index)then selectionVersion+=1 end
_stealTarget=pet;_G.Els_LastPet=pet
_G.EliteStealTargetUID=_petUid(pet)
if _G.EliteArmSteal then _G.EliteArmSteal(pet)end
end
local function disarmSteal()
_stealTarget=nil;_G.Els_LastPet=nil;_G.EliteStealTargetUID=nil
selectionVersion+=1
if _G.EliteDisarmSteal then _G.EliteDisarmSteal()end
end
local function preferredPet(refresh)
if manualTarget then
if readTargetSlot(manualTarget.plot,manualTarget.slot,manualTarget.index)then return manualTarget end
manualTarget=nil;selectionVersion+=1
end
local held=_stealTarget
if held and readTargetSlot(held.plot,held.slot,held.index)then
if not refresh or isTeleporting or _G.__Els_TPStarted or _G.__Els_VelFlying then return held end
end
if _G.__Els_VelFlying or _G.isCloning or LP:GetAttribute("Stealing")==true then return nil end
local best,bestRank,bestMutation,bestGen=nil,math.huge,math.huge,-1
local reg=_G.XenSyncAll and _G.XenSyncAll()
for name,ch in pairs(type(reg)=="table" and reg or {})do
if not (_G.Els_IsPlotChanKey and _G.Els_IsPlotChanKey(name)) or not ch or isMyPlot(ch)then continue end
local p=_bestPrioOnBase(name,channelGet(ch,"AnimalList"))
if p then
local rank=_prioRank[string.lower(p.index)] or math.huge
local mutation=_mutRank(p.mutation)
local gen=tonumber(p.gen) or 0
if rank<bestRank or (rank==bestRank and mutation<bestMutation)
or (rank==bestRank and mutation==bestMutation and gen>bestGen)then
best,bestRank,bestMutation,bestGen=p,rank,mutation,gen
end
end
end
if held and best and _petUid(held)==_petUid(best) and held.index==best.index then return held end
if _petUid(best)~=_petUid(held)then selectionVersion+=1 end
_stealTarget=best
return best
end
local function scanAllPetsCached(_,refresh)
local p=preferredPet(refresh)
if not p then return {}end
pcall(_ensurePetPos,p)
p._pri=_prioRank[(p.index or p.name):lower()];p.mps=p.gen or 0
return {p}
end
local function selectedPetMatches(p,refresh)
if not p or _G.EliteClickMoving then return false end
local wanted=preferredPet(refresh)
return wanted and _petUid(wanted)==_petUid(p) and wanted.index==(p.index or p.name)
and readTargetSlot(p.plot,p.slot,p.index or p.name)~=nil
end
local function selectedSlotMatches(plot,slot)
local p=preferredPet()
return p and p.plot==tostring(plot) and p.slot==tostring(slot) and selectedPetMatches(p)
end
local function EN(n)return "Els_"..n end
local function eliteSay(s)warn(s)end
local function _pingMs()
local ok,v=pcall(LP.GetNetworkPing,LP)
return ok and type(v)=="number" and v*1000 or 100
end
_G.EliteStealMode="priority";_G.ElitePriorityOnly=true;_G.EliteNearGrab=false
_G.EliteIdleHud=false;_G.EliteClickMoving=false;_G.EliteStealQuick=false
_G.ElitePrioOk=function(p)return type(p)=="table" and _prioRank[(p.index or p.name or ""):lower()]~=nil end
local function preFlyStrip(plotName)
if plotName then
pcall(_G.Els_LockPrioPlot, plotName)
end
end
local function _elsTPImpl(pre)
if isTeleporting and (os.clock() - _tpStartedAt) < 30 then return end
isTeleporting = true
_G.__Els_TPStarted = true
_tpStartedAt = os.clock()
local T0 = os.clock()
local ts = Config and Config.TpSettings
local skipSettle = not (ts and ts.ElsSkipSettle == false)
local maxTries = math.max(1, tonumber(ts and ts.ElsMaxTries) or 3)
local try = (type(pre) == "table" and tonumber(pre._elsTry)) or 1
local steps, label = {}, "?"
local function mark(k) steps[#steps + 1] = string.format("%s %.2fs", k, os.clock() - T0) end
local function report(status)
print("[ELS] " .. tostring(label) .. " | try " .. try .. " | " .. table.concat(steps, " | ") .. " | " .. status)
end
local function lagPad()
local ok, v = pcall(LP.GetNetworkPing, LP)
local p = (ok and type(v) == "number") and v or 0.1
return math.clamp((p - 0.12) * 0.5, 0, 0.15)
end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then
isTeleporting = false
_G.__Els_TPStarted = nil
return
end
local function alive()
return LP.Character == char and hrp.Parent ~= nil and hum.Health > 0
end
pcall(_G.Els_EquipCarpet)
local allPets
if type(pre) == "table" and (pre.plot or pre.name or pre.index) then
allPets = { pre }
elseif type(pre) == "table" and #pre > 0 then
allPets = pre
else
allPets = scanAllPets()
local _t0 = os.clock()
while #allPets == 0 and (os.clock() - _t0) < 2 do
task.wait(0.05)
allPets = scanAllPets()
end
end
if #allPets == 0 then
isTeleporting = false
report("no target")
return
end
local pet
for _, cand in ipairs(allPets) do
local taken = false
if _G.EliteDropTaken then
local ok, v = pcall(_G.EliteDropTaken, cand)
taken = ok and v == true
end
if not taken then pet = cand break end
end
pet = pet or allPets[1]
label = pet.name or pet.index or "?"
armSteal(pet)
pcall(_ensurePetPos, pet)
local petPos = pet.position or pet.plotHint
if not petPos then
local _t0 = os.clock()
repeat
RunService.Heartbeat:Wait()
pcall(_ensurePetPos, pet)
petPos = pet.position or pet.plotHint
until petPos or (os.clock() - _t0) > 2
end
if not petPos then
isTeleporting = false
_G.__Els_TPStarted = nil
report("position introuvable")
return
end
mark("target")
local baseIdx = getClosestBaseIdx(petPos)
local function insideBase(p)
local box = _PLOT_BOXES[baseIdx]
return box ~= nil and p.X >= box.minX + 3 and p.X <= box.maxX - 3 and p.Z >= box.minZ + 3 and p.Z <= box.maxZ - 3
end
local function targetHere()
if _G.EliteDropTaken then
local ok, v = pcall(_G.EliteDropTaken, pet)
if ok and v == true then return false end
end
local ok, r = pcall(readTargetSlot, pet.plot, pet.slot, pet.index or pet.name)
return not ok or r ~= nil
end
local function retry()
if try < maxTries then
return function() doVelocityTP({ pet, _elsTry = try + 1 }) end
end
end
local function stealing()
local v = LP:GetAttribute("Stealing")
if v == nil or v == false then
local c = LP.Character
v = c and c:GetAttribute("Stealing")
end
return v ~= nil and v ~= false
end
local function watch()
local tEnd = os.clock() + (tonumber(ts and ts.ElsWatchTime) or 4)
local far, hops = nil, 0
while os.clock() < tEnd do
task.wait(0.1)
if not alive() or _G.BelsResetting then return end
if stealing() then
mark("grab")
report("STEAL OK")
return
end
if isTeleporting or _G.__Els_VelFlying or _petUid(_stealTarget) ~= _petUid(pet) then return end
local busy = _G.EliteIsGrabBusy and _G.EliteIsGrabBusy() == true
if busy then tEnd = math.max(tEnd, os.clock() + 1) end
local p = hrp.Position
local dx, dz = p.X - petPos.X, p.Z - petPos.Z
if busy or dx * dx + dz * dz <= 144 then
far = nil
else
far = far or os.clock()
if os.clock() - far > 0.35 then
if not targetHere() then
report("target lost")
return
end
if insideBase(p) and hops < 2 then
hops += 1
far = nil
goToBrainrot(petPos, true)
mark("replace")
tEnd = math.max(tEnd, os.clock() + 2.5)
elseif try < maxTries then
mark("pushback")
report("retry")
doVelocityTP({ pet, _elsTry = try + 1 })
return
else
report("echec")
return
end
end
end
end
if not stealing() and alive() then report("no grab") end
end
local _tpSpd = _G.D3GovClamp(ts and ts.GrabbleTPSpeed)
local function fly(dest, face)
if not hrp.Parent then return end
local route = computeRoute(hrp.Position, dest, face)
if not route or #route == 0 then route = { dest } end
route = _pickJump(hrp.Position, dest, face, route)
_G.__Els_VelFlying = true
velMoveThrough(hrp, route, _tpSpd)
end
local function flyChecked(dest, face)
fly(dest, face)
if hrp.Parent and (hrp.Position - dest).Magnitude > 15 then
mark("steal")
fly(dest, face)
mark("revol")
else
mark("steal")
end
end
if petPos.Y <= 8.9 and isPlotUnlocked(pet.plot) then
local _to = Vector3.new(petPos.X, FRONT_Y_LOW, petPos.Z)
local _, _faceDir = buildFrontCandidate(baseIdx, false, hrp.Position.Z)
preFlyStrip(pet.plot)
-- grab synced with the TP: the hold runs during the flight and ends on landing
if _G.Els_SyncGrab then
local eta = (hrp.Position - _to).Magnitude / math.max(tonumber(_tpSpd) or 100, 1)
pcall(_G.Els_SyncGrab, pet, os.clock() + eta)
end
flyChecked(_to, _faceDir)
if hrp.Parent then vZero(hrp) end
isTeleporting = false
report("en place")
return watch
end
local _petPosForDest = petPos
if petPos.Y >= 11 and petPos.Y <= 23.15 then
_petPosForDest = Vector3.new(petPos.X, FRONT_Y_LOW - 1, petPos.Z)
end
local flyDest, facingDir = resolveCloneDest(hrp.Position, _petPosForDest, pet.name)
if facingDir and facingDir.Magnitude > 0.1 then
flyDest = wallFrontPos(flyDest, facingDir)
end
preFlyStrip(pet.plot)
flyChecked(flyDest, facingDir)
if not alive() then report("mort") return end
local look = Vector3.new(0, 0, -1)
if facingDir and facingDir.Magnitude > 0.1 then
look = Vector3.new(facingDir.X, 0, facingDir.Z)
if look.Magnitude < 0.1 then look = Vector3.new(0, 0, -1) else look = look.Unit end
end
local destPos, hitName = wallFrontPos(flyDest, facingDir)
if not string.find(string.lower(hitName or ""), "laser", 1, true) then
destPos = destPos + look * 0.45
end
local function settle()
hrp.Anchored = false
hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
vZero(hrp)
end
settle()
local _stopFall = _antiFall(hrp, destPos)
armSteal(pet)
local cloneDelay = (tonumber(ts and ts.CloneDelayVal) or 0.27) + lagPad()
for pass = 1, 2 do
local t1 = os.clock()
local pushed = false
repeat
RunService.Heartbeat:Wait()
pushed = not hrp.Parent or (hrp.Position - flyDest).Magnitude > 6
until pushed or os.clock() - t1 >= cloneDelay
if not pushed then break end
if _stopFall then pcall(_stopFall, true) end
if not alive() then report("mort") return end
if pass == 2 then
report("pushback before clone")
return retry()
end
mark("pushback")
flyChecked(flyDest, facingDir)
settle()
_stopFall = _antiFall(hrp, destPos)
end
local _cloneOk = doClone()
if _stopFall then pcall(_stopFall, false) end
mark("clone")
if not _cloneOk then
report("no clone")
return
end
_G.isCloning = false
task.wait(0.3 + lagPad())
if not alive() then report("mort") return end
-- grab synced with the TP: start the hold now, it commits as soon as we land
if _G.Els_SyncGrab then
local mini = math.max(tonumber(ts and ts.MiniTPSpeed) or 100, 1)
pcall(_G.Els_SyncGrab, pet, os.clock() + (hrp.Position - petPos).Magnitude / mini)
end
goToBrainrot(petPos, skipSettle)
if not alive() then report("mort") return end
local hp = hrp.Position
if Vector3.new(hp.X - petPos.X, 0, hp.Z - petPos.Z).Magnitude > 10 then
mark("placement")
goToBrainrot(petPos, skipSettle)
mark("replacement")
else
mark("placement")
end
report("en place")
return watch
end
function doVelocityTP(pre)
local nextStep
local ok, r = pcall(_elsTPImpl, pre)
if ok and type(r) == "function" then
nextStep = r
elseif not ok then
print("[ELS] error: " .. tostring(r))
end
isTeleporting = false
_G.__Els_TPStarted = nil
_G.__Els_VelFlying = false
_G.__Els_FlyPre = nil
_G.__Els_FlyHb = nil
local char = LP.Character
local h = char and char:FindFirstChild("HumanoidRootPart")
if h then
h.AssemblyLinearVelocity = Vector3.zero
h.AssemblyAngularVelocity = Vector3.zero
end
task.delay(1.2, function()
if not (_G.__Els_VelFlying or _G.__Els_TPStarted) then
pcall(_G.Els_FlushKills)
end
end)
if nextStep then task.spawn(nextStep) end
end
_G.Els_DoVelocityTP = doVelocityTP
local function stealTargetBest()
if LP:GetAttribute("Stealing")==true or isTeleporting or _G.__Els_VelFlying or _G.isCloning then return end
local pet=preferredPet()
if pet then armSteal(pet);pcall(_G.Els_LockPrioPlot,pet.plot)else disarmSteal()end
return pet
end
local function stealNearestPrio()
local char=LP.Character
local root=char and char:FindFirstChild("HumanoidRootPart")
if not root or not _G.Els_StealTargetList then return false end
local best,distance=nil,math.huge
for _,pet in ipairs(_G.Els_StealTargetList())do
pcall(_ensurePetPos,pet)
if pet.position then
local delta=pet.position-root.Position
local d=delta:Dot(delta)
if d<distance then best,distance=pet,d end
end
end
if not best then return false end
return _G.Els_StealTargetPick(best.plot,best.slot,best.index)
end
_G.Els_StealTargetBest=stealTargetBest
local function stealTargetList()
local out = {}
local isKey = _G.Els_IsPlotChanKey
local reg = _G.XenSyncAll and _G.XenSyncAll()
if type(reg) ~= "table" then return out end
for name, ch in next, reg do
if not (isKey and isKey(name)) or not ch or isMyPlot(ch) then continue end
local list = channelGet(ch, "AnimalList")
if type(list) ~= "table" then continue end
for slot, ad in pairs(list) do
if type(ad) ~= "table" or type(ad.Index) ~= "string" then continue end
local prio = _prioRank[string.lower(ad.Index)]
if not prio then continue end
if _ANGVELSIsFusing(ad) then continue end
local mut = _adMut(ad)
local okG, gen = pcall(function() return _G._mynxxGen and _G._mynxxGen(ad.Index, mut, ad.Traits) end)
gen = (okG and tonumber(gen)) or 0
local tr = {}
local raw = ad.Traits or ad.traits or ad.TraitList or ad.traitList
if type(raw) == "table" then
for k, v in pairs(raw) do
local n = (type(v) == "string" and v) or (type(v) == "table" and (v.Name or v.name or v.Trait or v.Id)) or (type(k) == "string" and v and k) or nil
if type(n) == "string" then tr[#tr + 1] = n end
end
end
out[#out + 1] = { name = ad.Index, index = ad.Index, mutation = mut, plot = tostring(name), slot = tostring(slot), rank = prio, gen = gen, traits = tr }
end
end
table.sort(out, function(a, b)
if a.rank ~= b.rank then return a.rank < b.rank end
local ma, mb = _mutRank(a.mutation), _mutRank(b.mutation)
if ma ~= mb then return ma < mb end
return (a.gen or 0) > (b.gen or 0)
end)
return out
end
_G.Els_StealTargetList = stealTargetList
local _switchGen, _switchTw, _switchHold = 0, nil, nil
local function _stopSwitchMove()
if _switchHold then
pcall(function() _switchHold:Disconnect() end)
_switchHold = nil
end
if _switchTw then
pcall(function() _switchTw:Cancel() end)
_switchTw = nil
end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp then
pcall(function()
hrp.Anchored = false
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
end)
end
end
_G.Els_CancelMovement = function()
_switchGen += 1
_stopSwitchMove()
end
local function manualSwitchMove(petPos)
if not petPos then return end
_switchGen += 1
local gen = _switchGen
_stopSwitchMove()
pcall(_G.Els_EquipCarpet)
if gen ~= _switchGen then return end
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
_switchHold = RunService.Heartbeat:Connect(function()
if gen ~= _switchGen then return end
pcall(_G.Els_EquipCarpet)
end)
local h = petPos.Y
local targetY = hrp.Position.Y
if h > 23.15 then targetY = 21
elseif h >= 11 and h <= 23.15 then targetY = h - 4
elseif h >= -6.9 and h <= 8.9 then targetY = -4 end
local dest = Vector3.new(petPos.X, targetY, petPos.Z)
local dist = (hrp.Position - dest).Magnitude
if dist < 0.5 then
hrp.CFrame = CFrame.new(dest)
_stopSwitchMove()
return
end
_hopTo(hrp, dest, function() return gen ~= _switchGen end, _miniTPSpeed())
if gen ~= _switchGen then return end
if hrp and hrp.Parent then
if h >= 11 then
if _G.Els_UnderBrainrotPlatformStop then pcall(_G.Els_UnderBrainrotPlatformStop) end
pcall(_belsLand, hrp, dest, _floorLandMinY(h, dest), (h <= 23.15) and 6 or 3.15)
end
pcall(function()
hrp.CFrame = CFrame.new(dest)
hrp.Anchored = false
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
end)
end
if gen == _switchGen then
_stopSwitchMove()
end
end
local function stealTargetPick(plotName, slot, useVel)
if LP:GetAttribute("Stealing") == true then return false end
local reg = _G.XenSyncAll and _G.XenSyncAll()
local ch = type(reg) == "table" and reg[plotName]
local list = ch and channelGet(ch, "AnimalList")
local ad
if type(list) == "table" then
for k, v in pairs(list) do if tostring(k) == tostring(slot) then ad = v; break end end
end
if type(ad) ~= "table" or type(ad.Index) ~= "string" then return false end
_nearestOn = false
Config.StealNearest = false
pcall(function() nearestPaint(false) end)
local pet = { name = ad.Index, index = ad.Index, mutation = _adMut(ad), plot = tostring(plotName), slot = tostring(slot) }
_G.Els_LastPet = pet
pcall(_G.Els_LockPrioPlot, pet.plot)
manualTarget=pet;selectionVersion+=1
armSteal(pet)
task.spawn(function()
local tw = os.clock()
while (_G.__Els_TPStarted or _G.__Els_VelFlying) and os.clock() - tw < 10 do
if _stealTarget ~= pet then return end
task.wait(0.05)
end
local pos, t0 = nil, os.clock()
repeat pcall(_ensurePetPos, pet); pos = pet.position; if not pos then task.wait() end until pos or os.clock() - t0 > 2
if not pos or _stealTarget ~= pet then return end
if useVel == true then
pcall(manualSwitchMove, pos)
else
pcall(goToBrainrot, pos, nil, _miniTPSpeed())
end
end)
return true
end
_G.Els_GetManualTarget=function()return manualTarget end
do
local pending,running=nil,false
_G.Els_CancelPendingPick=function()pending=nil;_G.Els_PendingTarget=nil end
_G.Els_StealTargetPick=function(plot,slot,index,useVel)
local fresh=readTargetSlot(plot,slot,index)
if not fresh then return false end
fresh.useVel=useVel==true
pending=fresh;_G.Els_PendingTarget=fresh
if running then return true end
running=true
task.spawn(function()
while pending do
if LP:GetAttribute("Stealing")~=true and not _G.__Els_TPStarted and not _G.__Els_VelFlying
and not _G.isCloning then
local pet=pending
if readTargetSlot(pet.plot,pet.slot,pet.index)then
local ok,accepted=pcall(stealTargetPick,pet.plot,pet.slot,pet.useVel)
if not ok or not accepted then warn("[Els] Selection unavailable.")end
end
if pending==pet then pending=nil;_G.Els_PendingTarget=nil end
end
if pending then task.wait(0.05)end
end
running=false
end)
return true
end
end
_G.Els_StealTargetClear = function() if _G.Els_CancelPendingPick then _G.Els_CancelPendingPick()end;manualTarget=nil;pcall(disarmSteal);return stealTargetBest() end
_G.Els_GoBackToTarget = function()
local pet = _G.Els_LastPet
if type(pet) ~= "table" or not pet.plot or not pet.slot then
if _G.Els_StealTargetBest then return pcall(stealTargetBest) end
return false
end
local reg = _G.XenSyncAll and _G.XenSyncAll()
local ch = type(reg) == "table" and reg[pet.plot]
local list = ch and channelGet(ch, "AnimalList")
local still = false
if type(list) == "table" then
for k, v in pairs(list) do
if tostring(k) == tostring(pet.slot) and type(v) == "table" and tostring(v.Index) == tostring(pet.index) then still = true; break end
end
end
if still then return stealTargetPick(pet.plot, pet.slot) end
return pcall(stealTargetBest)
end
do
local RS=game:GetService("ReplicatedStorage")
local RUN=game:GetService("RunService")
local _netFolder
local function _netDir()
if _netFolder then return _netFolder end
local pk=RS:FindFirstChild("Packages")or RS:WaitForChild("Packages",10)
if not pk then return nil end
_netFolder=pk:FindFirstChild("Net")or pk:WaitForChild("Net",10)
return _netFolder
end
local _net
local function _getNet()
if _net then return _net end
local dir=_netDir()
if not dir then return nil end
local ok,m=pcall(require,dir)
if ok and type(m)=="table"then _net=m end
return _net
end
local _queue,_hooked,_original={},false,nil
local function _host()
for _,sig in ipairs({RUN.Heartbeat,RUN.RenderStepped,RUN.PostSimulation})do
local ok,conns=pcall(getconnections,sig)
if ok then
for _,c in ipairs(conns)do
local f=c.Function
if f and f~=_G.__mkSyncHost and islclosure(f)and not isexecutorclosure(f)then
local s=select(2,pcall(debug.info,f,"s"))
if type(s)=="string"and s:find("^ReplicatedStorage%.")and not s:find("ReplicatedFirst")then
return f
end
end
end
end
end
end
local function _install()
if _hooked then return true end
if not _getNet()then return false end
local h=_host()
if not h then return false end
_G.__mkNetHost=h
local w=function(...)
local job=table.remove(_queue,1)
if job then
local ok,r=pcall(_net[job.kind],_net,job.name)
job.result=(ok and typeof(r)=="Instance")and r or nil
job.done=true
end
return _original(...)
end
local ok,env=pcall(getfenv,h)
if ok and type(env)=="table"then pcall(setfenv,w,env)end
_original=hookfunction(h,w)
_hooked=true
return true
end
local _cache={}
local function _get(name,kind)
kind=(kind=="RemoteFunction"and"RemoteFunction")
or(kind=="UnreliableRemoteEvent"and"UnreliableRemoteEvent")
or"RemoteEvent"
if type(name)~="string"or name==""then return nil end
local logical=name:match("^R[EF]/(.+)$")or name:match("^URE/(.+)$")or name
local ck=kind.."|"..logical
local hit=_cache[ck]
if hit and hit.Parent then return hit end
_cache[ck]=nil
if not _getNet()then return nil end
if not _install()then return nil end
local job={kind=kind,name=logical}
table.insert(_queue,job)
local t=os.clock()+(tonumber(_G.EliteNetTimeout)or 5)
while not job.done and os.clock()<t do RUN.Heartbeat:Wait()end
if job.result and job.result.Parent then
_cache[ck]=job.result
return job.result
end
return nil
end
_G.EliteGetRemote=function(method,name)
local fast=_G.Els_GetRemoteByHash and _G.Els_GetRemoteByHash(name)
if fast then return fast end
return _get(name,method)
end
_G.__secureGetRemote=function(method,name)return _get(name,method)end
do
local _dummy=Instance.new("RemoteEvent")
local _rawFire=(clonefunction and clonefunction(_dummy.FireServer))or _dummy.FireServer
_dummy:Destroy()
end
end
do
local pg = LP:FindFirstChild("PlayerGui")
if pg then
local old = pg:FindFirstChild("ElsStealBar")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "ElsStealBar", false, true
gui.DisplayOrder, gui.Enabled = 20, false
local T = _G.Els_Theme
local C = T and T.C or {
bg = Color3.fromRGB(6,22,44), bg2 = Color3.fromRGB(10,32,60), line = Color3.fromRGB(28,70,110),
txt = Color3.fromRGB(226,238,248), dim = Color3.fromRGB(120,156,190),
acc = Color3.fromRGB(20,84,140), acc2 = Color3.fromRGB(120,186,228), green = Color3.fromRGB(140,220,255),
}
local accSeq = ColorSequence.new(C.acc, C.acc2)
local doneSeq = ColorSequence.new(C.green, Color3.fromRGB(64,136,196))
local function label(parent, x, w, color, size, align)
local t = Instance.new("TextLabel")
t.BackgroundTransparency, t.BorderSizePixel = 1, 0
t.Position, t.Size = UDim2.new(0, x, 0, 7), w
t.Font, t.TextSize, t.TextColor3 = Enum.Font.GothamBold, size, color
t.TextXAlignment = align or Enum.TextXAlignment.Left
t.TextTruncate = Enum.TextTruncate.AtEnd
t.Parent = parent
return t
end
local wrap = Instance.new("Frame")
wrap.AnchorPoint = Vector2.new(0.5, 1)
wrap.Position = UDim2.new(0.5, 0, 1, -110)
wrap.Size = UDim2.fromOffset(310, 44)
wrap.Parent = gui
do local sc = Instance.new("UIScale"); sc.Name = "ElsGrabScale"; sc.Scale = 1.25; sc.Parent = wrap end -- bigger grab bar
-- grab bar sits right above the inventory (hotbar, bag button, open bag panel)
local function placeBar()
pcall(function()
local hb = pg:FindFirstChild("ElsHotbar")
local top
if hb and hb.Enabled then
for _, n in ipairs({ "ElsBar", "ElsBag", "ElsBagPanel" }) do
local o = hb:FindFirstChild(n, true)
if o and o:IsA("GuiObject") and o.Visible and o.AbsoluteSize.Y > 0 then
local y = o.AbsolutePosition.Y
if not top or y < top then top = y end
end
end
end
if top then
wrap.Position = UDim2.new(0.5, 0, 0, top - 2)
else
wrap.Position = UDim2.new(0.5, 0, 1, -110)
end
end)
end
if T then
T.window(wrap)
T.accent(wrap, UDim2.fromOffset(12, 0), UDim2.new(1, -24, 0, 2))
else
wrap.BackgroundColor3, wrap.BorderSizePixel = C.bg, 0
Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", wrap).Color = C.line
end
local dot = Instance.new("Frame")
dot.Size, dot.Position = UDim2.fromOffset(8, 8), UDim2.fromOffset(14, 11)
dot.BackgroundColor3, dot.BorderSizePixel = C.acc, 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 4)
dot.Parent = wrap
local tag = label(wrap, 28, UDim2.fromOffset(40, 16), C.acc, 11)
tag.Text = "GRAB"
local nameL = label(wrap, 70, UDim2.new(1, -140, 0, 16), C.txt, 12)
nameL.Text = ""
local pct = label(wrap, 0, UDim2.fromOffset(56, 16), C.txt, 12, Enum.TextXAlignment.Right)
pct.AnchorPoint, pct.Position = Vector2.new(1, 0), UDim2.new(1, -14, 0, 7)
pct.Text = "0%"
local track = Instance.new("Frame")
track.BorderSizePixel, track.BackgroundColor3 = 0, C.bg2
track.Position, track.Size = UDim2.fromOffset(14, 30), UDim2.new(1, -28, 0, 6)
track.Parent = wrap
Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)
local fill = Instance.new("Frame")
fill.BorderSizePixel, fill.BackgroundColor3 = 0, Color3.new(1, 1, 1)
fill.Size, fill.Parent = UDim2.fromScale(0, 1), track
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
local fgr = Instance.new("UIGradient")
fgr.Color = accSeq
fgr.Parent = fill
gui.Parent = pg
local wasDone = false
_G.EliteTargetsSteal = function(name, text, fraction)
if name == "" then gui.Enabled = false; return end
if name ~= nil then nameL.Text = tostring(name) end
if fraction ~= nil then
placeBar()
gui.Enabled = true
local f = math.clamp(tonumber(fraction) or 0, 0, 1)
fill.Size = UDim2.fromScale(f, 1)
local done = f >= 1
if done ~= wasDone then
wasDone = done
fgr.Color = done and doneSeq or accSeq
dot.BackgroundColor3 = done and C.green or C.acc
end
end
if text ~= nil then pct.Text = tostring(text) end
end
end
end
do
local function initializeDonorGrab()
do
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local LP=Players.LocalPlayer
local PG=LP:FindFirstChild("PlayerGui")
local GUIHOST=(gethui and gethui())or game:GetService("CoreGui")
local _fspOverlap=OverlapParams.new()
_fspOverlap.FilterType=Enum.RaycastFilterType.Exclude
local function _promptWorldPos(p)
local pp=p and p.Parent
if not pp then
return nil
end
if pp:IsA("Attachment")then
return pp.WorldPosition
end
if pp:IsA("BasePart")then
return pp.Position
end
return nil
end
local function findStealPrompt(pet)
if not pet then
return nil
end
local podPrompt
if pet.plot and pet.slot then
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(pet.plot)
local podiums=plot and plot:FindFirstChild("AnimalPodiums")
local podium=podiums and podiums:FindFirstChild(tostring(pet.slot))
if podium then
local base=podium:FindFirstChild("Base")
local spawn=base and base:FindFirstChild("Spawn")
local attach=spawn and spawn:FindFirstChild("PromptAttachment")
if attach then
for _,p in ipairs(attach:GetChildren())do
if p:IsA("ProximityPrompt")then
podPrompt=p
break
end
end
end
if not podPrompt then
podPrompt=podium:FindFirstChildWhichIsA("ProximityPrompt",true)
end
end
end
if pet.position then
local pp=podPrompt and _promptWorldPos(podPrompt)
if(not podPrompt)or(pp and(pp-pet.position).Magnitude>15)then
_fspOverlap.FilterDescendantsInstances=LP.Character and{LP.Character}or{}
local okB,parts=pcall(workspace.GetPartBoundsInRadius,workspace,pet.position,14,_fspOverlap)
if okB and parts then
local best,bestD
for _,part in ipairs(parts)do
local pr=part:FindFirstChildOfClass("ProximityPrompt")
if not pr then
for _,ch in ipairs(part:GetChildren())do
if ch:IsA("Attachment")then
pr=ch:FindFirstChildOfClass("ProximityPrompt")
if pr then
break
end
end
end
end
if pr then
local pos=_promptWorldPos(pr)
local d=pos and(pos-pet.position).Magnitude or math.huge
if not best or d<bestD then
best,bestD=pr,d
end
end
end
if best then
return best
end
end
end
end
return podPrompt
end
local InternalStealCache=setmetatable({},{__mode="k"})
local STEAL_HOLD_DURATION=tonumber(_G.EliteStealHold)or 1.35
local STEAL_PROXIMITY=tonumber(_G.EliteStealProximity)or 60
local _stealHoldStart,_stealHoldActive=0,false
local _stealTarget,_stealArmedAt=nil,0
local _lastTargetPick,_lastPickUid,_currentTargetName=0,nil,nil
local _stealLastScan,_autoLastScan=0,0
local _inRangeLast=0
local _armCheckAt=0
local _petsCache,_petsCacheAt,_petsVersion=nil,0,nil
_G.ElitePrioFilter=function(pets)
local out={}
for _,p in ipairs(type(pets)=="table" and pets or {})do
if _G.ElitePrioOk(p)then out[#out+1]=p end
end
return out
end
local function _scanCached(now,maxAge)
if _petsCache and _petsVersion==selectionVersion and(now-_petsCacheAt)<=(maxAge or 0.1)then
return _petsCache
end
local pets=scanAllPetsCached(0.08)
local ok=pets~=nil
if ok and type(pets)=="table"then
if _G.ElitePrioFilter then
pets=_G.ElitePrioFilter(pets)
end
_petsCache,_petsCacheAt,_petsVersion=pets,now,selectionVersion
return pets
end
return nil
end
local function _petListed(plot,slot)
local ch=getPlotChannel(plot)
local al=ch and channelGet(ch,"AnimalList")
if type(al)~="table"then
return true,false
end
local e=al[slot]
if e==nil then
e=al[tonumber(slot)or-1]
end
if e==nil then
e=al[tostring(slot)]
end
return e~=nil,true
end
local function _prox()
return tonumber(_G.EliteStealProximity)or STEAL_PROXIMITY
end
local STEAL_HOLD_MAX=2.95
local function _holdDur()
if _G.EliteStealHoldFull==true then
return STEAL_HOLD_MAX
end
local h=tonumber(_G.EliteStealHoldDuration)or STEAL_HOLD_DURATION
if h<STEAL_HOLD_DURATION then
h=STEAL_HOLD_DURATION
elseif h>STEAL_HOLD_MAX then
h=STEAL_HOLD_MAX
end
return h
end
local _cooldownUntil=0
local function _verifyFire(pet,path,judge)
task.delay(tonumber(_G.EliteVerifyDelay)or 0.35,function()
if not(pet and pet.plot and pet.slot~=nil)then
return
end
local listed,known=true,false
pcall(function()
listed,known=_petListed(pet.plot,pet.slot)
end)
if not known then
return
end
if not listed then
_G.EliteStealFails=0
_cooldownUntil=0
return
end
if not judge then
_cooldownUntil=0
return
end
end)
end
local function _holdBusy()
return _stealHoldActive
end
_G.EliteIsGrabBusy=_holdBusy
local _armedPet,_armLostSince=nil,0
local function _armLivePos(p)
if not(p and p.plot and p.slot~=nil)then
return nil
end
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(p.plot)
if not plot then
return nil
end
local ok,pos=pcall(getPetPosition,plot,p.slot)
if ok then
return pos
end
return nil
end
_G.EliteArmSteal=function(pet)
if type(pet)~="table"or type(pet.plot)~="string"or pet.slot==nil then
return
end
_armedPet={
name=pet.name,
index=pet.index,
mps=pet.mps,
_pri=pet._pri,
plot=pet.plot,
slot=tostring(pet.slot),
position=pet.position,
}
_armLostSince=0
_stealTarget=_armedPet
_stealArmedAt=os.clock()
if type(pet.name)=="string"and pet.name~=""then
_currentTargetName=pet.name
end
end
_G.EliteDisarmSteal=function()
_armedPet,_armLostSince=nil,0
_stealTarget=nil
_petsCache=nil
end
_G.EliteArmedName=function()
return _armedPet and _armedPet.name or nil
end
_G.EliteAnimBorder=function(frame,thick,color)
local st=Instance.new("UIStroke")
st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
st.Thickness=thick or 1.4
st.Color=color or Color3.new(1,1,1)
st.Transparency=0.2
st.Parent=frame
return st
end
local UIC={
bg=Color3.fromRGB(5,18,38),
bg2=Color3.fromRGB(8,27,52),
card=Color3.fromRGB(13,38,72),
hover=Color3.fromRGB(19,50,90),
track=Color3.fromRGB(34,78,124),
line=Color3.fromRGB(26,62,100),
acc=Color3.fromRGB(120,186,228),
acc2=Color3.fromRGB(20,84,140),
txt=Color3.fromRGB(228,240,250),
dim=Color3.fromRGB(122,158,192),
input=Color3.fromRGB(6,20,40),
green=Color3.fromRGB(140,220,255),
red=Color3.fromRGB(56,84,116),
edge=Color3.fromRGB(160,210,240),
}
local UIFB=(function()
for _,n in ipairs({"GothamBold"})do
local ok,f=pcall(function()
return Enum.Font[n]
end)
if ok and f then
return f
end
end
return Enum.Font.GothamBold
end)()
local UIF=Enum.Font.GothamMedium
local function mk(class,parent,props)
local o=Instance.new(class)
for k,v in pairs(props or{})do
o[k]=v
end
o.Parent=parent
return o
end
local function corner(o,r)
mk("UICorner",o,{CornerRadius=UDim.new(0,math.min(r or 6,6))})
return o
end
local function stroke(o,col)
mk("UIStroke",o,{Color=col or UIC.line,Thickness=1})
return o
end
pcall(function()
local _oldDbg=LP:FindFirstChild("PlayerGui")
_oldDbg=_oldDbg and _oldDbg:FindFirstChild(EN("EliteStealDbg"))
if _oldDbg then
_oldDbg:Destroy()
end
end)
local function _mirror(name,txt,frac)
local f=_G.EliteTargetsSteal
if type(f)=="function"then
pcall(f,name,txt,frac)
end
end
local function showStealBar(name,pct)
pct=math.clamp(tonumber(pct)or 0,0,1)
_mirror(name,math.floor(pct*100+0.5).."%",pct)
end
local function setStealBarPct(pct)
pct=math.clamp(tonumber(pct)or 0,0,1)
_mirror(nil,math.floor(pct*100+0.5).."%",pct)
end
local function hideStealBar()
_G.__EliteHudName=nil
_mirror("","0%",0)
end
task.defer(hideStealBar)
local function buildStealCallbacks(prompt)
if InternalStealCache[prompt]then
return
end
if not prompt or not prompt.Parent then
return
end
local data={holdCallbacks={},triggerCallbacks={},holdEndCallbacks={},ready=true}
local function grab(sig,into)
local ok,conns=pcall(getconnections,sig)
if ok and type(conns)=="table"then
for _,c in ipairs(conns)do
if type(c.Function)=="function"then
table.insert(into,c.Function)
end
end
end
end
grab(prompt.PromptButtonHoldBegan,data.holdCallbacks)
grab(prompt.Triggered,data.triggerCallbacks)
grab(prompt.PromptButtonHoldEnded,data.holdEndCallbacks)
-- Els: always cache (the caller already picked a real steal prompt). Under full
-- script-kill the game callbacks are gone, so without this the cache stays empty
-- and auto-steal finds no target; executeStealAsync then drives the grab via the
-- direct remotes (begin -> hold -> commit).
InternalStealCache[prompt]=data
end
local _rawFireServer=Instance.new("RemoteEvent").FireServer
local _reBegin,_reCommit=nil,nil
local _reState,_reRetryAt={},{}
local function _re(cache,hash)
if cache and cache.Parent then
return cache
end
local st=_reState[hash]
if typeof(st)=="Instance"then
if st.Parent then
return st
end
_reState[hash]=nil
st=nil
end
if st=="pending"then
return nil
end
if st=="failed"and os.clock()<(_reRetryAt[hash]or 0)then
return nil
end
_reState[hash]="pending"
task.spawn(function()
local got
pcall(function()
if _G.EliteGetRemote then
got=_G.EliteGetRemote("RemoteEvent",hash)
end
end)
if typeof(got)=="Instance"then
_reState[hash]=got
else
_reState[hash]="failed"
_reRetryAt[hash]=os.clock()+(tonumber(_G.EliteRemoteRetry)or 5)
end
end)
task.delay(tonumber(_G.EliteRemoteResolveWait)or 3,function()
if _reState[hash]=="pending"then
_reState[hash]="failed"
_reRetryAt[hash]=os.clock()+(tonumber(_G.EliteRemoteRetry)or 5)
end
end)
return nil
end
-- Els: steal remotes = the game's CURRENT build (from the message hub). Two builds;
-- use the first whose begin + grab both resolve. Each arg is {timeOffset, token};
-- grab also sends plot + slot. Fired only when the game's prompt callbacks are gone.
local _ELS_GRAB_BUILDS = {
{Begin="b77dde61-dd74-4f18-b329-2ac7f7e48f0b",Grab="0c1792e6-3df9-46fd-8b46-be6e4e6df08f",
BeginArgs={{79,"94fa9dee-cfa2-4cc2-ac2a-0659e5169fac"},{79,"173cd914-bfdd-4c77-80bc-86864bd1ecb4"}},
GrabArgs={{141,"859270da-f6e7-4110-af2e-4c58fa259c75"},{141,"b231811b-fa22-4265-81fe-424ea71ddb92"}}},
{Begin="f1a4d3a5-b97a-4622-8fd6-232663ff697e",Grab="f5f26af9-cb1b-4588-bcc9-12fd78f64599",
BeginArgs={{50,"ba10cc43-8b93-4b7d-93b8-e1935730ebe3"},{50,"ed327974-0c39-423a-b9c7-467b8fdac46d"}},
GrabArgs={{16,"7aae3e74-d52e-433a-83b1-9d5a507d2e80"},{16,"c3eb316e-a4cc-4dc9-8b0e-1a770a7d99fd"}}},
}
local _elsGrabBuild
local function _elsResolveBuild()
if _elsGrabBuild and _reBegin and _reBegin.Parent and _reCommit and _reCommit.Parent then return true end
for _,b in ipairs(_ELS_GRAB_BUILDS)do
local br=_re(nil,b.Begin)
local gr=_re(nil,b.Grab)
if br and gr then _elsGrabBuild,_reBegin,_reCommit=b,br,gr return true end
end
return false
end
local function _stealBegin()
if not _elsResolveBuild()then return false end
local now=workspace:GetServerTimeNow()
for _,a in ipairs(_elsGrabBuild.BeginArgs)do
pcall(_rawFireServer,_reBegin,now+a[1],a[2])
end
return true
end
local function _stealCommit(plot,slot)
if not selectedSlotMatches(plot,slot)then return false end
if not _elsResolveBuild()then return false end
if type(plot)~="string"or slot==nil then return false end
local sl=tonumber(slot)or slot
local now=workspace:GetServerTimeNow()
for _,a in ipairs(_elsGrabBuild.GrabArgs)do
pcall(_rawFireServer,_reCommit,now+a[1],a[2],plot,sl)
end
return true
end
_G.EliteStealBegin,_G.EliteStealCommit=_stealBegin,_stealCommit
local function _stealMargin()
return tonumber(_G.EliteStealMargin)or 0.08
end
-- Els: grab synced with the TP. It does NOT send its own steal remotes anymore:
-- it just starts Els' normal grab (EliteFireSteal -> executeStealAsync, which uses
-- the GAME's own steal-prompt callbacks, like the old working build) at the right
-- moment during the flight, so the hold ends when the TP lands. executeStealAsync
-- then waits until you are <= 12 studs from the prompt (+0.22 s) before the grab,
-- and its bar is the real one.
-- Before: own remotes with tokens the server ignored -> bar full, no grab, and the
-- grab only happened on the next steal loop.
-- arriveAt = os.clock() time the TP should land (nil = start now).
-- _G.Els_TPGrabSync = false turns it off (old steal loop only).
local function _syncHoldNeed(pet)
local need=STEAL_HOLD_DURATION
if type(findStealPrompt)=="function"then
local ok,pr=pcall(findStealPrompt,pet)
if ok and pr then
local hd=pr.HoldDuration
if type(hd)=="number"and hd>0 then need=math.max(need,hd+_stealMargin())end
end
end
return need
end
_G.Els_SyncGrab=function(pet,arriveAt)
if _G.Els_TPGrabSync==false then return false end
if not(pet and type(pet.plot)=="string" and pet.slot~=nil)then return false end
if _stealHoldActive or LP:GetAttribute("Stealing")==true then return false end
task.spawn(function()
-- start before landing: the fast grab needs 0.55 s, the normal grab its hold time
if arriveAt then
local lead=(_G.Els_FastGrab~=false)and 0.55 or _syncHoldNeed(pet)
local startAt=arriveAt-lead
while os.clock()<startAt do
if LP:GetAttribute("Stealing")==true or _stealHoldActive then return end
RunService.Heartbeat:Wait()
end
end
if LP:GetAttribute("Stealing")==true or _stealHoldActive then return end
if _G.EliteFireSteal then pcall(_G.EliteFireSteal,pet)end
end)
return true
end
-- Els FAST GRAB (0.55 s, Twilight's FireSteal timing):
--  begin is back-dated 1.6 s, the grab is dated begin + 2.1 s, so it can be sent
--  0.55 s after begin. Sent only when you are <= 10 studs from the steal prompt
--  AND inside the base's StealHitbox, re-sent every 0.25 s for up to 3 s.
--  If it fails twice in a row, the normal grab is used for 30 s (safety).
--  _G.Els_FastGrab = false -> always the normal grab.
local FG_MIN,FG_WIN,FG_BACK,FG_AHEAD,FG_DIST=0.55,3,1.6,2.1,10
local _fgFails,_fgOffUntil=0,0
local function _fgPromptPos(pet)
if type(findStealPrompt)=="function"then
local ok,pr=pcall(findStealPrompt,pet)
if ok and pr and pr.Parent then
local p=pr.Parent
if p:IsA("Attachment")then return p.WorldPosition end
if p:IsA("BasePart")then return p.Position end
end
end
return _armLivePos(pet)or pet.position
end
local function _fgInHitbox(pet,pos)
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(pet.plot)
local hb=plot and plot:FindFirstChild("StealHitbox")
if not(hb and hb:IsA("BasePart"))then return true end
local o=hb.CFrame:PointToObjectSpace(pos)
local s=hb.Size*0.5
return math.abs(o.X)<=s.X and math.abs(o.Y)<=s.Y and math.abs(o.Z)<=s.Z
end
local function _fgReady(pet)
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local pp=_fgPromptPos(pet)
if not(h and pp)then return false end
if(h.Position-pp).Magnitude>FG_DIST then return false end
return _fgInHitbox(pet,h.Position)
end
_G.Els_FastGrabTry=function(pet)
if _G.Els_FastGrab==false or os.clock()<_fgOffUntil then return false end
if not(pet and type(pet.plot)=="string" and pet.slot~=nil)then return false end
if _stealHoldActive or LP:GetAttribute("Stealing")==true then return false end
if not _elsResolveBuild()then return false end
_stealHoldActive=true
showStealBar(pet.name,0)
task.spawn(function()
local base=workspace:GetServerTimeNow()-FG_BACK
for _,a in ipairs(_elsGrabBuild.BeginArgs)do pcall(_rawFireServer,_reBegin,base+a[1],a[2])end
local t0=os.clock()
local sl=tonumber(pet.slot)or pet.slot
while os.clock()-t0<FG_WIN and LP:GetAttribute("Stealing")~=true do
local el=os.clock()-t0
pcall(setStealBarPct,math.min(el/FG_MIN,1))
if el>=FG_MIN and _fgReady(pet)then
if not selectedSlotMatches(pet.plot,pet.slot)then break end
for _,a in ipairs(_elsGrabBuild.GrabArgs)do pcall(_rawFireServer,_reCommit,base+FG_AHEAD+a[1],a[2],pet.plot,sl)end
local t1=os.clock()
while os.clock()-t1<0.25 and LP:GetAttribute("Stealing")~=true do RunService.Heartbeat:Wait()end
else
RunService.Heartbeat:Wait()
end
end
local ok=LP:GetAttribute("Stealing")==true
if ok then
_fgFails=0
else
_fgFails=_fgFails+1
if _fgFails>=2 then
_fgFails=0
_fgOffUntil=os.clock()+30
warn("[ELS] fast grab failed twice, normal grab for 30 s")
end
end
_stealHoldActive=false
hideStealBar()
end)
return true
end
local function _confirmGrab(prompt,data,pet)
if not selectedPetMatches(pet)then return end
if _G.EliteStealConfirm==false then
return
end
-- Els: no game prompt callbacks (full script-kill) -> the hold already elapsed,
-- so commit the grab now via the direct remote. Begin was fired at hold start.
if (not data.triggerCallbacks or #data.triggerCallbacks==0) and pet and type(pet.plot)=="string" and pet.slot~=nil then
pcall(_stealCommit,pet.plot,pet.slot)
end
local ping=0.1
pcall(function()
ping=(_pingMs()or 100)/1000
end)
local gap=math.clamp(ping*1.2+0.05,0.15,0.4)
local tries=tonumber(_G.EliteStealRetries)or 2
local t0,n=os.clock(),0
while os.clock()-t0<gap*(tries+1)do
RunService.Heartbeat:Wait()
if LP:GetAttribute("Stealing") or not selectedPetMatches(pet)then
return
end
if n<tries and os.clock()-t0>=gap*(n+1)then
n=n+1
if prompt and prompt.Parent and prompt.Enabled~=false then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
end
if n==tries and pet and pet.plot and pet.slot~=nil then
pcall(_stealCommit,pet.plot,pet.slot)
end
end
end
end
local _apCache=setmetatable({},{__mode="k"})
local function _apOf(prompt,data)
local ap=_apCache[prompt]
if ap~=nil then
return ap or nil
end
if debug and debug.getupvalues then
for _,fn in ipairs(data.holdCallbacks)do
local ok,ups=pcall(debug.getupvalues,fn)
if ok and type(ups)=="table"then
for _,v in pairs(ups)do
if type(v)=="table"and rawget(v,"State")~=nil and rawget(v,"ProximityPrompt")~=nil then
_apCache[prompt]=v
return v
end
end
end
end
end
_apCache[prompt]=false
return nil
end
local function _fireHold(prompt,data)
if _G.EliteForceHold~=false then
local ap=_apOf(prompt,data)
if ap and ap.State~="Steal"then
local old=ap.State
ap.State="Steal"
for _,fn in ipairs(data.holdCallbacks)do
pcall(fn)
end
ap.State=old
return
end
end
for _,fn in ipairs(data.holdCallbacks)do
task.spawn(fn)
end
end
do
local function hookHum(ch)
local hum=ch and ch:WaitForChild("Humanoid",5)
if hum then
hum.StateChanged:Connect(function(_,new)
if new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.FallingDown then
_G.__EliteRagPhysT=tick()
end
end)
end
end
LP.CharacterAdded:Connect(hookHum)
if LP.Character then
task.spawn(hookHum,LP.Character)
end
LP:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
local et=tonumber(LP:GetAttribute("RagdollEndTime"))or 0
if et>workspace:GetServerTimeNow()then
_G.__EliteRagUntil=et
end
end)
end
local function _ragEnd()
local now=workspace:GetServerTimeNow()
local a=tonumber(LP:GetAttribute("RagdollEndTime"))or 0
if a>now then
return a
end
local c=tonumber(_G.__EliteRagUntil)or 0
if c>now then
return c
end
return 0
end
local function _ragBlocked()
if _G.EliteRagdollHold==false then
return false
end
return(_ragEnd()-workspace:GetServerTimeNow()+(tonumber(_G.EliteRagdollPad)or 0.1))>0
end
local function executeStealAsync(prompt,petName,restoreMax,pet)
if _holdBusy()then
return false
end
local data=InternalStealCache[prompt]
if not data or not data.ready then
return false
end
data.ready=false
_stealHoldStart=tick()
_stealHoldActive=true
-- Els: no game prompt callbacks (full script-kill) -> fire BEGIN ourselves at the
-- start of the hold; _confirmGrab fires COMMIT once the hold has elapsed.
if not data.holdCallbacks or #data.holdCallbacks==0 then pcall(_stealBegin) end
do
local _tok={}
_G.__EliteHoldTok=_tok
task.delay(tonumber(_G.EliteStealFailsafe)or 12,function()
if _G.__EliteHoldTok==_tok and _stealHoldActive then
_stealHoldActive=false
data.ready=true
pcall(hideStealBar)
pcall(eliteSay,"[STEAL] a steal got stuck - reset it, auto steal continues")
end
end)
end
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
showStealBar(petName,0)
if _G.EliteStealQuick==true then
task.spawn(function()
_fireHold(prompt,data)
local _beginT=os.clock()
pcall(function()
local st=prompt:GetAttribute("State")
if st~=nil and st~="Steal"then
_stealBegin()
end
end)
local _qd=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
_qd=math.max(_qd,hd+_stealMargin())
end
end)
_G.EliteStealSrvEnd=workspace:GetServerTimeNow()+_qd
local _barConn
pcall(function()
_barConn=RunService.RenderStepped:Connect(function()
local rem=_G.EliteStealSrvEnd and(_G.EliteStealSrvEnd-workspace:GetServerTimeNow())
or 0
if rem<=0 then
setStealBarPct(1)
else
setStealBarPct(1-rem/_qd)
end
end)
end)
local remaining=_G.EliteStealSrvEnd-workspace:GetServerTimeNow()
if remaining>0 then
task.wait(remaining)
end
if _ragBlocked()then
pcall(showStealBar,"RAGDOLL HOLD: "..tostring(petName),1)
local r0=os.clock()
local stale=tonumber(_G.EliteStealSrvHoldMax)or 2.4
while _ragBlocked()and os.clock()-r0<8 do
local remain=_ragEnd()-workspace:GetServerTimeNow()
if remain>0 and remain<=_qd+0.05 and(os.clock()-_beginT)+remain>stale and prompt and prompt.Parent then
_fireHold(prompt,data)
_beginT=os.clock()
end
RunService.Heartbeat:Wait()
end
pcall(showStealBar,petName,1)
local age=os.clock()-_beginT
if age>stale+0.1 and prompt and prompt.Parent and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
age=0
end
if age<_qd then
task.wait(_qd-age)
end
end
if _barConn then
pcall(function()
_barConn:Disconnect()
end)
end
if selectedPetMatches(pet) and prompt and prompt.Parent then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
_confirmGrab(prompt,data,pet)
else
_armedPet,_armLostSince=nil,0
end
for _,fn in ipairs(data.holdEndCallbacks)do
task.spawn(fn)
end
task.wait(0.05)
_stealHoldActive=false
_G.EliteStealSrvEnd=nil
if restoreMax~=nil then
pcall(function()
if prompt and prompt.Parent then
prompt.MaxActivationDistance=restoreMax
end
end)
end
data.ready=true
hideStealBar()
end)
return true
end
task.spawn(function()
_fireHold(prompt,data)
local _beginT,_holdAbs,_ragShown=os.clock(),tick(),false
local GRAB_MIN=STEAL_HOLD_DURATION
local GRAB_MAX=tonumber(_G.EliteStealHoldMax)or STEAL_HOLD_MAX
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 and hd+0.1>GRAB_MIN then
GRAB_MIN=hd+0.1
end
end)
local _flashSteal=false
local landed=_G.__EliteTPLandedAt
local _fAt=_G.__EliteFlashTPAt
if _fAt and(os.clock()-_fAt)<(tonumber(_G.EliteFlashStealWindow)or 15)then
local fh=tonumber(_G.EliteFlashStealHold)or 1.37
GRAB_MIN=fh
_flashSteal=true
if landed then
_G.__EliteTPLandedAt=nil
end
elseif landed and(os.clock()-landed)<(tonumber(_G.EliteTPStealWindow)or 5)then
_G.__EliteTPLandedAt=nil
local post=(_G.__EliteLastTPTween==true)and(tonumber(_G.EliteTweenStealHold)or 2.15)
or(tonumber(_G.EliteTPStealHold)or 2.55)
if post>GRAB_MIN then
GRAB_MIN=post
end
end
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 and GRAB_MIN<hd+_stealMargin()and not _flashSteal then
GRAB_MIN=hd+_stealMargin()
end
end)
if GRAB_MAX<GRAB_MIN then
GRAB_MAX=GRAB_MIN
end
local _ppSeen,_ppKind,_charSeen,_hrpSeen=nil,0,nil,nil
local function _grabRange()
local char=LP.Character
if not char then
return true
end
if char~=_charSeen then
_charSeen=char
_hrpSeen=char:FindFirstChild("HumanoidRootPart")
end
local hrp=_hrpSeen
if not hrp or hrp.Parent~=char then
hrp=char:FindFirstChild("HumanoidRootPart")
_hrpSeen=hrp
if not hrp then
return true
end
end
local pp=prompt.Parent
if not pp then
return true
end
if pp~=_ppSeen then
_ppSeen=pp
_ppKind=(pp:IsA("Attachment")and 1)or(pp:IsA("BasePart")and 2)or 0
end
local pos
if _ppKind==1 then
pos=pp.WorldPosition
elseif _ppKind==2 then
pos=pp.Position
else
return true
end
return(hrp.Position-pos).Magnitude<=(tonumber(_G.EliteStealGrabDist)or 12)
end
local DWELL=tonumber(_G.EliteStealDwell)or 0.22
local readyAt=nil
local _gone=false
local _barConn
pcall(function()
_barConn=RunService.RenderStepped:Connect(function()
local el=tick()-_stealHoldStart
if not(prompt and prompt.Parent and prompt:IsDescendantOf(workspace))then
return
end
if el<GRAB_MIN then
setStealBarPct(el/GRAB_MIN)
else
setStealBarPct(1)
end
end)
end)
while true do
local el=tick()-_stealHoldStart
if not selectedPetMatches(pet) or not(prompt and prompt.Parent and prompt:IsDescendantOf(workspace))then
_gone=true
break
end
local _rb=_ragBlocked()
if _rb then
if not _ragShown then
_ragShown=true
pcall(showStealBar,"RAGDOLL HOLD: "..tostring(petName),1)
end
if el>=GRAB_MAX then
GRAB_MAX=el+0.1
end
do
local remain=_ragEnd()-workspace:GetServerTimeNow()
local need=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
need=math.max(need,hd+_stealMargin())
end
end)
if remain>0 and remain<=need+0.05 and(os.clock()-_beginT)+remain>(tonumber(_G.EliteStealSrvHoldMax)or 2.4)and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
_stealHoldStart=tick()+remain-GRAB_MIN
GRAB_MAX=math.max(GRAB_MAX,GRAB_MIN+0.6)
end
end
elseif _ragShown then
_ragShown=false
pcall(showStealBar,petName,1)
end
if tick()-_holdAbs>(tonumber(_G.EliteStealHoldCap)or 8)then
break
end
if not _rb and os.clock()-_beginT>math.max(tonumber(_G.EliteStealSrvHoldMax)or 2.5,GRAB_MIN+0.6)
and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
local _needSrv=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
_needSrv=math.max(_needSrv,hd+_stealMargin())
end
end)
_stealHoldStart=tick()-math.max(0,GRAB_MIN-_needSrv)
GRAB_MAX=math.max(GRAB_MAX,GRAB_MIN+0.6)
readyAt=nil
el=tick()-_stealHoldStart
end
if el>=GRAB_MAX and not _rb then
break
end
if _grabRange()then
if not readyAt then
readyAt=tick()
end
if el>=GRAB_MIN and(tick()-readyAt)>=DWELL and not _rb then
break
end
else
readyAt=nil
end
RunService.Heartbeat:Wait()
end
if _barConn then
pcall(function()
_barConn:Disconnect()
end)
end
setStealBarPct(0)
if not _gone and selectedPetMatches(pet) and prompt and prompt.Parent then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
_confirmGrab(prompt,data,pet)
elseif _gone then
_armedPet,_armLostSince=nil,0
end
for _,fn in ipairs(data.holdEndCallbacks)do
task.spawn(fn)
end
task.wait(0.05)
_stealHoldActive=false
if restoreMax~=nil then
pcall(function()
if prompt and prompt.Parent then
prompt.MaxActivationDistance=restoreMax
end
end)
end
data.ready=true
hideStealBar()
end)
return true
end
local function timeUntilCanSteal()
if
LP:GetAttribute("Stealing")
or LP:GetAttribute("IsTrading")
or LP:GetAttribute("IsDuelSelecting")
or LP:GetAttribute("Web")
then
return-1
end
local ragdoll=LP:GetAttribute("RagdollEndTime")
if ragdoll then
local r=ragdoll-workspace:GetServerTimeNow()
if r>0 then
return r
end
end
return 0
end
local stealOn=(_G.EliteStealMode~=nil)
local _emptyScans=0
local function _fireSteal(pet)
if not selectedPetMatches(pet,not _holdBusy())then return false end
if not pet then
return false
end
if _holdBusy()then
_G.__EliteFireWhy="busy"
return false
end
if _G.EliteDropCatch~=false and _G.EliteDropTaken and _G.EliteDropTaken(pet)then
_G.__EliteFireWhy="someone is carrying it"
return false
end
_G.__EliteDropBeginAt=nil
local _fhrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _fd=(_fhrp and pet.position)and(pet.position-_fhrp.Position).Magnitude or nil
local _judge=(_fd~=nil)and(_fd<=_prox()+2)or false
local _cd=_holdDur()+(tonumber(_G.EliteStealCycleGap)or 0)
-- Els: 0.55 s fast grab first (falls back to the normal grab below if unavailable)
if _G.Els_FastGrabTry and _G.Els_FastGrabTry(pet)then
_G.EliteLastFire=os.clock()
_G.__EliteFireWhy=nil
return true
end
local prompt=findStealPrompt(pet)
if not prompt or not prompt.Parent then
-- Els: no prompt (full script-kill removes the game's prompt layer) -> grab purely
-- via the direct remotes, like the message hub: begin, hold STEAL_HOLD_DURATION,
-- then commit with plot + slot. plot/slot come from the Synchronizer, still live.
if pet and type(pet.plot)=="string" and pet.slot~=nil and not _holdBusy() and LP:GetAttribute("Stealing")~=true then
_stealHoldActive=true
showStealBar(pet.name,0)
task.spawn(function()
local okBegin=_stealBegin()
local need=STEAL_HOLD_DURATION
pcall(function() local hd=prompt and prompt.HoldDuration if type(hd)=="number" and hd>0 then need=math.max(need,hd+_stealMargin()) end end)
local t0=os.clock()
while os.clock()-t0<need do
pcall(setStealBarPct,(os.clock()-t0)/need)
RunService.Heartbeat:Wait()
end
if okBegin then _stealCommit(pet.plot,pet.slot) end
task.wait(0.3)
_stealHoldActive=false
hideStealBar()
end)
_G.EliteLastFire=os.clock()
_G.__EliteFireWhy="direct remote (no prompt)"
_verifyFire(pet,"direct",_judge)
return true
end
_G.__EliteFireWhy="no steal prompt"
local k=tostring(pet.plot).."_"..tostring(pet.slot)
_G.__EliteNoPromptAt=_G.__EliteNoPromptAt or{}
if os.clock()-(_G.__EliteNoPromptAt[k]or 0)>2 then
_G.__EliteNoPromptAt[k]=os.clock()
eliteSay("[STEAL] can't find the steal prompt for "..tostring(pet.name).." ("..k..")")
end
return false
end
local oldMax
pcall(function()
oldMax=prompt.MaxActivationDistance
end)
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
buildStealCallbacks(prompt)
if InternalStealCache[prompt]then
_G.__EliteFireWhy="prompt not ready"
if executeStealAsync(prompt,pet.name,oldMax,pet)then
_G.EliteLastFire=os.clock()
_verifyFire(pet,"prompt",_judge)
return true
end
if oldMax~=nil then
pcall(function()
prompt.MaxActivationDistance=oldMax
end)
end
return false
else
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
showStealBar(pet.name,0)
_stealHoldActive=true
task.spawn(function()
local need=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
need=math.max(need,hd+0.1)
end
end)
local okB=pcall(function()
prompt:InputHoldBegin()
end)
local t0=os.clock()
while os.clock()-t0<need do
pcall(setStealBarPct,(os.clock()-t0)/need)
RunService.Heartbeat:Wait()
end
if okB then
pcall(function()
prompt:InputHoldEnd()
end)
end
task.wait(0.15)
if selectedPetMatches(pet) and fireproximityprompt and not LP:GetAttribute("Stealing")then
pcall(function()
fireproximityprompt(prompt)
end)
end
pcall(function()
if oldMax~=nil and prompt and prompt.Parent then
prompt.MaxActivationDistance=oldMax
end
end)
hideStealBar()
_stealHoldActive=false
end)
_G.EliteLastFire=os.clock()
_verifyFire(pet,"prompt",_judge)
return true
end
end
_G.EliteFireSteal=_fireSteal
local _dropWatch,_seenOnPod,_missSince={},{},{}
local function _dropUid(p)
return tostring(p.plot).."_"..tostring(p.slot)
end
local function _dropNear(p)
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
return h~=nil and p~=nil and p.position~=nil and(h.Position-p.position).Magnitude<=(_prox()+6)
end
local function _onPodium(pet)
if not(pet and pet.plot and pet.slot~=nil)then
return nil
end
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(tostring(pet.plot))
local pods=plot and plot:FindFirstChild("AnimalPodiums")
local pod=pods and pods:FindFirstChild(tostring(pet.slot))
local b=pod and pod:FindFirstChild("Base")
local sp=b and b:FindFirstChild("Spawn")
if not sp then
return nil
end
for _,d in ipairs(sp:GetDescendants())do
if d:IsA("Model")then
return true
end
end
return false
end
_G.EliteDropTaken=function(pet)
if not(pet and pet.plot and pet.slot~=nil)or pet.conveyor then
return false
end
local uid=_dropUid(pet)
local on=_onPodium(pet)
if on==true then
_seenOnPod[uid]=true
_missSince[uid]=nil
_dropWatch[uid]=nil
return false
end
local function _someoneStealing()
for _,pl in ipairs(Players:GetPlayers())do
if pl~=LP and pl:GetAttribute("Stealing")==true then
return true
end
end
return false
end
if on==false and _seenOnPod[uid]and not _someoneStealing()then
_missSince[uid]=nil
_dropWatch[uid]=nil
return false
end
if on==false and _seenOnPod[uid]then
local ms=_missSince[uid]
if not ms then
_missSince[uid]=os.clock()
return false
end
if os.clock()-ms<0.4 then
return false
end
if not _dropWatch[uid]then
_dropWatch[uid]={pet=pet,at=os.clock(),since=_missSince[uid]or os.clock()}
eliteSay("[STEAL] "..tostring(pet.name).." is being carried by someone - grabbing it when it's dropped")
end
if not _dropNear(pet)then
if _armedPet and _armedPet.plot==pet.plot and tostring(_armedPet.slot)==tostring(pet.slot)then
_armedPet,_armLostSince=nil,0
end
if _stealTarget and _stealTarget.plot==pet.plot and tostring(_stealTarget.slot)==tostring(pet.slot)then
_stealTarget=nil
end
end
return true
end
return false
end
do
local _rawScan=_scanCached
_scanCached=function(now,maxAge)
local pets=_rawScan(now,maxAge)
if type(pets)~="table"or next(_dropWatch)==nil then
return pets
end
local out={}
for _,p in ipairs(pets)do
if not(p.plot and _dropWatch[_dropUid(p)])or _dropNear(p)then
out[#out+1]=p
end
end
return out
end
local _hudOn,_hudAt=false,0
local _holderCache={}
local function _holderName(pet)
local key=_dropUid(pet)
local c=_holderCache[key]
if c and os.clock()-c.t<0.5 then
return c.n
end
local best,bd
for _,pl in ipairs(Players:GetPlayers())do
if pl~=LP and pl:GetAttribute("Stealing")==true and pl.Character then
local ch=pl.Character
local d=math.huge
for _,m in ipairs(ch:GetChildren())do
if m:IsA("Model")and(m.Name==pet.index or m.Name==pet.name)then
d=-1
break
end
end
if d~=-1 then
local h=ch:FindFirstChild("HumanoidRootPart")
d=(h and pet.position)and(h.Position-pet.position).Magnitude or math.huge
end
if not bd or d<bd then
best,bd=pl,d
end
end
end
local n=best and best.DisplayName or"SOMEONE"
_holderCache[key]={n=n,t=os.clock()}
return n
end
local _lastSweep=0
RunService.Heartbeat:Connect(function()
if next(_dropWatch)==nil or _G.EliteDropCatch==false then
if _hudOn and not _holdBusy()then
_hudOn=false
pcall(_mirror,"","0%",0)
end
return
end
local now=os.clock()
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local carrying=LP:GetAttribute("Stealing")==true
local busy=_holdBusy()
if now-_lastSweep>=0.5 then
_lastSweep=now
local live={}
local ok,pets=pcall(_rawScan,now,0.5)
if ok and type(pets)=="table"then
for _,p in ipairs(pets)do
if p.plot then
live[_dropUid(p)]=true
end
end
for uid,w in pairs(_dropWatch)do
if(not live[uid]and next(live)~=nil)or now-w.at>(tonumber(_G.EliteDropWait)or 60)then
_dropWatch[uid]=nil
end
end
end
end
for uid,w in pairs(_dropWatch)do
local pet=w.pet
if not selectedPetMatches(pet)then _dropWatch[uid]=nil; continue end
local near=hrp and pet.position and(hrp.Position-pet.position).Magnitude<=(_prox()+2)
if _onPodium(pet)==true then
_dropWatch[uid]=nil
if near and not carrying and not busy then
local pre=_G.__EliteDropBeginAt
local _stale=tonumber(_G.EliteStealSrvHoldMax)or 2.4
local age=pre and now-pre or nil
_G.__EliteDropBeginAt=nil
if _G.EliteDropInstant~=false and age and age<=_stale then
task.delay(math.max(0,STEAL_HOLD_DURATION-age+0.03),function()
if LP:GetAttribute("Stealing")or _holdBusy()then
return
end
if _stealCommit(pet.plot,pet.slot)then
task.delay(0.35,function()
if not LP:GetAttribute("Stealing")and not _holdBusy()then
pcall(_fireSteal,pet)
end
end)
else
pcall(_fireSteal,pet)
end
end)
else
pcall(_fireSteal,pet)
end
end
elseif near and not carrying and not busy and _G.EliteDropInstant~=false then
local pre=_G.__EliteDropBeginAt
if not pre or now-pre>=(tonumber(_G.EliteStealSrvHoldMax)or 2.4)-0.1 then
pcall(function()
local pr=findStealPrompt(pet)
local dt=pr and InternalStealCache[pr]
if dt and dt.ready and type(dt.holdCallbacks)=="table"then
_fireHold(pr,dt)
end
end)
if _stealBegin()then
_G.__EliteDropBeginAt=now
end
end
end
end
local show,showD=nil,nil
if hrp then
for _,w in pairs(_dropWatch)do
if w.pet and w.pet.position then
local dd=(hrp.Position-w.pet.position).Magnitude
if not showD or dd<showD then
show,showD=w,dd
end
end
end
end
if show and not _holdBusy()and not LP:GetAttribute("Stealing")and _G.EliteDropHud~=false then
if now-_hudAt>=0.1 then
_hudAt=now
_hudOn=true
pcall(_mirror,(_dropNear(show.pet)and("DROP HOLD: "..tostring(show.pet.name))or("HELD BY ".._holderName(show.pet)..": "..tostring(show.pet.name))),string.format("%.1fs",now-(show.since or show.at)),1)
end
elseif _hudOn and not _holdBusy()then
_hudOn=false
pcall(_mirror,"","0%",0)
end
end)
task.spawn(function()
local idleOn=false
while true do
task.wait(0.25)
pcall(function()
if _G.EliteStealMode==nil or _G.EliteIdleHud==false or _holdBusy()or LP:GetAttribute("Stealing")or _hudOn then
return
end
local t=_armedPet or _stealTarget
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if t and t.position and h then
idleOn=true
_mirror("TARGET: "..tostring(t.name)..(_G.__EliteStealWhy and("  -  ".._G.__EliteStealWhy)or""),string.format("%dm",math.floor((t.position-h.Position).Magnitude)),0)
elseif idleOn then
idleOn=false
_mirror("","0%",0)
end
end)
end
end)
end
local function _stealTick()
if _G.EliteClickMoving then return end
_G.EliteTickN=(_G.EliteTickN or 0)+1
stealOn=(_G.EliteStealMode~=nil)
if not stealOn then
return
end
local now=os.clock()
if not _holdBusy() and (not _stealTarget or _petsVersion~=selectionVersion or now-_lastTargetPick>=0.1)then
_lastTargetPick=now
local pets=_scanCached(now,0.08)
local best=type(pets)=="table" and pets[1] or nil
_stealTarget,_armedPet=best,best
_lastPickUid=best and _petUid(best) or nil
_G.EliteStealTargetUID=_lastPickUid
if best then
_currentTargetName=best.name
_G.Els_LastPet=best
else
_G.Els_LastPet=nil
end
end
if _stealTarget then
local pos=_armLivePos(_stealTarget)
if pos then _stealTarget.position=pos end
end
local pet=_stealTarget
if not pet then
return
end
if type(pet.name)=="string"and pet.name~=""and pet.name~=_G.__EliteHudName and not LP:GetAttribute("Stealing")then
_G.__EliteHudName=pet.name
_mirror(pet.name,nil,nil)
end
if now-_stealLastScan<0.02 then
_G.EliteThrN=(_G.EliteThrN or 0)+1
return
end
_stealLastScan=now
local t=timeUntilCanSteal()
if t==-1 then
_G.__EliteStealWhy="can't steal right now"
if LP:GetAttribute("Stealing")then
_stealTarget=nil
_armedPet,_armLostSince=nil,0
end
return
end
if t>0 and t>_holdDur()then
_G.__EliteStealWhy="ragdolled"
return
end
_G.__EliteStealWhy="too far"
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if not hrp then
return
end
if pet.position then
local toPet=pet.position-hrp.Position
local dist=toPet.Magnitude
if(now-(_G.__eliteTgtAt or 0))>=0.15 then
_G.__eliteTgtAt=now
_G.EliteStealTgt=tostring(pet.name)
.." ["
..tostring(pet.plot)
.."/"
..tostring(pet.slot)
.."] d="
..math.floor(dist)
end
local hold=_holdDur()
local lead=tonumber(_G.EliteStealLead)or 0.6
local closing=dist>0.001 and(hrp.AssemblyLinearVelocity:Dot(toPet)/dist)or 0
local _nearBase=false
do
local _bi=getClosestBaseIdx(pet.position)
local _b=_bi and BASES_LOW[_bi]
if _b then
local _bx,_bz=hrp.Position.X-_b.X,hrp.Position.Z-_b.Z
if math.sqrt(_bx*_bx+_bz*_bz)<=(tonumber(_G.EliteCloseBaseRange)or 100)then
_nearBase=true
end
end
end
local _armed=_G.EliteStealQuick~=true
local _mul=_armed and 1.5 or 1
if _nearBase then
if dist>(tonumber(_G.EliteNearBaseStealStart)or 80)*_mul then
return
end
elseif closing>(tonumber(_G.EliteFastApproach)or 150)then
if dist>(tonumber(_G.EliteStealLeadMax)or 420)*_mul then
return
end
if(dist/closing)>hold*lead+(tonumber(_G.EliteStealEarly)or 0.35)*_mul then
return
end
elseif closing>5 then
if dist>(tonumber(_G.EliteCloseProximity)or 40)*_mul then
return
end
else
if dist>_prox()*_mul then
return
end
end
end
_G.__EliteFireWhy=nil
if _fireSteal(pet)then
_G.__EliteStealWhy=nil
else
_G.__EliteStealWhy=_G.__EliteFireWhy or"waiting"
end
end
local _stealThrottle=0
RunService.Heartbeat:Connect(function()
local __t0=os.clock()
_stealThrottle=_stealThrottle+1
if _stealThrottle<(tonumber(_G.EliteStealTickEvery)or 1)then
return
end
_stealThrottle=0
if _G.EliteProf and _G.EliteProf.mark then _G.EliteProf.mark("steal tick",__t0)end
pcall(_stealTick)
end)
task.spawn(function()
while true do
task.wait(tonumber(_G.EliteWatchdogTick)or 0.1)
if
_G.EliteStealMode~=nil
and _G.EliteStealWatchdog~=false
and not LP:GetAttribute("Stealing")
and not _holdBusy()
and(os.clock()-(_G.EliteLastFire or 0))>(tonumber(_G.EliteWatchdogGap)or 0.35)
then
local c=LP.Character
local h=c and c:FindFirstChild("HumanoidRootPart")
if h then
local pets=_scanCached(os.clock(),0.15)
local ok=pets~=nil
if ok and type(pets)=="table"then
local near,nd=nil,math.huge
local mp=h.Position
if _G.EliteStealMode=="nearest"then
for _,p in ipairs(pets)do
if not p.conveyor and p.position then
local d=(p.position-mp).Magnitude
if d<nd then
nd,near=d,p
end
end
end
else
local want=_armedPet or _stealTarget
local wuid=want and _petUid(want)
if wuid then
for _,p in ipairs(pets)do
if not p.conveyor and p.position and _petUid(p)==wuid then
near,nd=p,(p.position-mp).Magnitude
break
end
end
end
end
if near and nd<=_prox()then
pcall(_fireSteal,near)
end
end
end
end
end
end)
end
end
initializeDonorGrab()
end
task.spawn(function()
while task.wait(1.5) do
if _G.__Els_VelFlying or _G.__Els_TPStarted or _G.isCloning or _G.MeerkoInvisActive then
continue
end
pcall(stealTargetBest)
end
end)
_G.Els_StealNearestPrio = stealNearestPrio
end
do
local UIS = game:GetService("UserInputService")
local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 8)
if not pg then
return
end
local old = pg:FindFirstChild("ElsNearest")
if old then old:Destroy() end
local g = Instance.new("ScreenGui")
g.Name = "ElsNearest"
g.ResetOnSpawn = false
g.IgnoreGuiInset = true
g.Parent = pg
g.Enabled = false
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(168, 82)
panel.Position = UDim2.new(1, -180, 0, 72)
panel.BackgroundColor3 = Color3.fromRGB(8,28,54)
panel.BackgroundTransparency = 0
panel.BorderSizePixel = 1
panel.BorderColor3 = Color3.fromRGB(40,100,156)
panel.Parent = g
local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 0)
pc.Parent = panel
local lay = Instance.new("UIListLayout")
lay.Padding = UDim.new(0, 6)
lay.Parent = panel
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = panel
local OFF = Color3.fromRGB(13,36,68)
local ON = Color3.fromRGB(30,96,156)
local function mkBtn(text, y)
local b = Instance.new("TextButton")
b.Size = UDim2.new(1, 0, 0, 30)
b.BackgroundColor3 = OFF
b.TextColor3 = Color3.fromRGB(236,244,252)
b.Text = text
b.Font = Enum.Font.GothamBold
b.TextSize = 11
b.AutoButtonColor = true
b.BorderSizePixel = 1
b.BorderColor3 = Color3.fromRGB(28,70,110)
b.Parent = panel
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 0)
c.Parent = b
return b
end
local function paint(b, label, on)
b.BackgroundColor3 = on and ON or OFF
b.Text = label .. "  " .. (on and "ON" or "OFF")
end
local bSteal = mkBtn("STEAL NEAREST")
bSteal.Text = "STEAL NEAREST"
_G.Els_NearestBtn = bSteal
do
local last,token=-math.huge,0
local color=bSteal.BackgroundColor3
bSteal.Activated:Connect(function()
local now=os.clock()
if now-last<0.2 then return end
last=now;token+=1
local stamp=token
local fn=_G.Els_StealNearestPrio
local ok,accepted=false,false
if type(fn)=="function"then ok,accepted=pcall(fn)end
if ok and accepted then
bSteal.Text=_G.Els_PendingTarget and "TARGET PENDING" or "TARGET OK"
bSteal.BackgroundColor3=Color3.fromRGB(40,120,186)
else
bSteal.Text=type(fn)=="function" and "NO PRIORITY" or "LOADING..."
bSteal.BackgroundColor3=Color3.fromRGB(125,45,45)
if not ok and accepted then warn("[Els] Steal Nearest: "..tostring(accepted))end
end
task.delay(1.2,function()
if bSteal.Parent and stamp==token then bSteal.Text="STEAL NEAREST";bSteal.BackgroundColor3=color end
end)
end)
end
local bJoinPS = mkBtn("JOIN PS")
bJoinPS.Visible = false
bJoinPS.Text = "JOIN PS"
bJoinPS.MouseButton1Click:Connect(function()
if _G.Els_JoinPS then pcall(_G.Els_JoinPS) end
end)
local bJump = mkBtn("INFINITE JUMP")
bJump.Visible = false
local bWave = mkBtn("WAVERIDER SPEED")
bWave.Visible = false
local bClone = mkBtn("AUTO CLONE (V)")
bClone.Visible = false
local bInv = mkBtn("INV STEAL")
local function mkSlide(label, minV, maxV, get, set, fmt)
local hold = Instance.new("Frame")
hold.Size = UDim2.new(1, 0, 0, 36)
hold.BackgroundTransparency = 1
hold.Visible = false
hold.Parent = panel
local lab = Instance.new("TextLabel")
lab.Size = UDim2.new(1, 0, 0, 14)
lab.BackgroundTransparency = 1
lab.TextColor3 = Color3.fromRGB(212,226,240)
lab.Font = Enum.Font.GothamMedium
lab.TextSize = 10
lab.TextXAlignment = Enum.TextXAlignment.Left
lab.Parent = hold
local sbar = Instance.new("Frame")
sbar.Size = UDim2.new(1, 0, 0, 8)
sbar.Position = UDim2.fromOffset(0, 20)
sbar.BackgroundColor3 = Color3.fromRGB(26,62,100)
sbar.BorderSizePixel = 0
sbar.Parent = hold
local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 0)
sbc.Parent = sbar
local sfill = Instance.new("Frame")
sfill.Size = UDim2.new(0.5, 0, 1, 0)
sfill.BackgroundColor3 = Color3.fromRGB(96,170,224)
sfill.BorderSizePixel = 0
sfill.Parent = sbar
local sfc = Instance.new("UICorner")
sfc.CornerRadius = UDim.new(0, 0)
sfc.Parent = sfill
local dragging = false
local function apply(v)
v = math.clamp(tonumber(v) or minV, minV, maxV)
set(v)
sfill.Size = UDim2.new((v - minV) / math.max(0.001, maxV - minV), 0, 1, 0)
lab.Text = label .. ": " .. fmt(v)
end
apply(get())
sbar.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dragging = true
local rel = math.clamp((i.Position.X - sbar.AbsolutePosition.X) / math.max(1, sbar.AbsoluteSize.X), 0, 1)
apply(minV + (maxV - minV) * rel)
end
end)
return {
apply = apply,
bar = sbar,
isDrag = function() return dragging end,
setDrag = function(v) dragging = v end,
minV = minV,
maxV = maxV,
}
end
local rotSlide = mkSlide("Rotation", 0, 360, function()
return tonumber(_G.MeerkoInvisAngle) or Config.InvStealAngle or 220
end, function(v)
Config.InvStealAngle = v
pcall(_G.Els_AutoSave)
_G.MeerkoInvisAngle = v
end, function(v)
return tostring(math.floor(v + 0.5))
end)
local depSlide = mkSlide("Depth", 0, 10, function()
return tonumber(_G.MeerkoInvisDepth) or Config.InvStealDepth or 10
end, function(v)
Config.InvStealDepth = v
pcall(_G.Els_AutoSave)
_G.MeerkoInvisDepth = v
end, function(v)
return string.format("%.1f", v)
end)
local angRow = Instance.new("Frame")
angRow.Size = UDim2.new(1, 0, 0, 24)
angRow.BackgroundTransparency = 1
angRow.Visible = false
angRow.Parent = panel
local function mkAng(x, deg, txt)
local b = Instance.new("TextButton")
b.Size = UDim2.fromOffset(72, 24)
b.Position = UDim2.fromOffset(x, 0)
b.BackgroundColor3 = OFF
b.TextColor3 = Color3.fromRGB(236,244,252)
b.Text = txt
b.Font = Enum.Font.GothamBold
b.TextSize = 10
b.Parent = angRow
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 0)
c.Parent = b
b.MouseButton1Click:Connect(function()
rotSlide.apply(deg)
end)
return b
end
mkAng(0, 180, "180")
mkAng(80, 220, "220")
local spdHold = Instance.new("Frame")
spdHold.Size = UDim2.new(1, 0, 0, 36)
spdHold.BackgroundTransparency = 1
spdHold.Visible = false
spdHold.Parent = panel
local spdLab = Instance.new("TextLabel")
spdLab.Size = UDim2.new(1, 0, 0, 14)
spdLab.BackgroundTransparency = 1
spdLab.TextColor3 = Color3.fromRGB(212,226,240)
spdLab.Font = Enum.Font.GothamMedium
spdLab.TextSize = 10
spdLab.TextXAlignment = Enum.TextXAlignment.Left
spdLab.Parent = spdHold
local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 8)
bar.Position = UDim2.fromOffset(0, 20)
bar.BackgroundColor3 = Color3.fromRGB(26,62,100)
bar.BorderSizePixel = 0
bar.Parent = spdHold
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 0)
bc.Parent = bar
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(96,170,224)
fill.BorderSizePixel = 0
fill.Parent = bar
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 0)
fc.Parent = fill
local SPD_MIN, SPD_MAX = 60, 250
local function setSpdUi(v)
v = math.clamp(tonumber(v) or 140, SPD_MIN, SPD_MAX)
Config.WaveriderSpeed = v
pcall(_G.Els_AutoSave)
local rel = (v - SPD_MIN) / (SPD_MAX - SPD_MIN)
fill.Size = UDim2.new(rel, 0, 1, 0)
spdLab.Text = "Wave speed: " .. tostring(math.floor(v + 0.5))
end
setSpdUi(Config.WaveriderSpeed)
local drag = false
local function fromX(x)
local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
setSpdUi(SPD_MIN + (SPD_MAX - SPD_MIN) * rel)
end
bar.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
drag = true
fromX(i.Position.X)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
drag = false
rotSlide.setDrag(false)
depSlide.setDrag(false)
end
end)
UIS.InputChanged:Connect(function(i)
if not (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
return
end
if drag then
fromX(i.Position.X)
end
if rotSlide.isDrag() then
local rel = math.clamp((i.Position.X - rotSlide.bar.AbsolutePosition.X) / math.max(1, rotSlide.bar.AbsoluteSize.X), 0, 1)
rotSlide.apply(rotSlide.minV + (rotSlide.maxV - rotSlide.minV) * rel)
end
if depSlide.isDrag() then
local rel = math.clamp((i.Position.X - depSlide.bar.AbsolutePosition.X) / math.max(1, depSlide.bar.AbsoluteSize.X), 0, 1)
depSlide.apply(depSlide.minV + (depSlide.maxV - depSlide.minV) * rel)
end
end)
paint(bJump, "INFINITE JUMP", Config.InfiniteJump == true)
paint(bWave, "WAVERIDER SPEED (A)", Config.WaveriderSpeedEnabled == true)
paint(bClone, "AUTO CLONE (V)", Config.AutoClone ~= false)
paint(bInv, "INV STEAL", Config.InvSteal ~= false)
local PS_PLACE_ID = 109983668079237
local PS_LINK_CODE = "57963013835087486111896053246959"
local autoKickFired = false
local function doAutoKick()
if autoKickFired then return end
autoKickFired = true
if not pcall(function()
game:GetService("ExperienceService"):LaunchExperience({ placeId = PS_PLACE_ID, linkCode = PS_LINK_CODE })
end) then
pcall(function() LocalPlayer:Kick("") end)
end
end
local function startAutoKick()
local pgui = LocalPlayer:FindFirstChild("PlayerGui")
if not pgui then return end
if _G.__Els_PsKickConn then
pcall(function() _G.__Els_PsKickConn:Disconnect() end)
_G.__Els_PsKickConn = nil
end
_G.__Els_PsKickConn = pgui.DescendantAdded:Connect(function(gui)
if not Config.KickToPS or autoKickFired then return end
local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
if txt and string.find(txt, "You stole") then
doAutoKick()
end
end)
end
local function stopAutoKick()
if _G.__Els_PsKickConn then
pcall(function() _G.__Els_PsKickConn:Disconnect() end)
_G.__Els_PsKickConn = nil
end
end
local waveConn
local function setWaveriderSpeed(enabled)
Config.WaveriderSpeedEnabled = enabled
if waveConn then
waveConn:Disconnect()
waveConn = nil
end
if not enabled then return end
local lastTick = 0
waveConn = RunService.Heartbeat:Connect(function()
if _G.__Els_VelFlying or _G.__Els_TPStarted or _G.isCloning or _G.MeerkoInvisActive then return end
local now = tick()
if now - lastTick < 0.066 then return end
lastTick = now
local c = LocalPlayer.Character
if not c then return end
local hum = c:FindFirstChildOfClass("Humanoid")
local hrp = c:FindFirstChild("HumanoidRootPart")
if not hum or not hrp then return end
local FLY = _G.Els_CarpetNames or { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
local held
for _, fn in ipairs(FLY) do if c:FindFirstChild(fn) then held = fn break end end
if not held then
for _, fn in ipairs(FLY) do
local tb = LocalPlayer.Backpack:FindFirstChild(fn)
if tb and _G.__Els_GrappleFired then pcall(function() hum:EquipTool(tb) end); held = fn break end
end
end
if not held then return end
local spd = tonumber(Config.WaveriderSpeed) or 140
local md = hum.MoveDirection
if md.Magnitude > 0 then
hrp.AssemblyLinearVelocity = Vector3.new(md.X * spd, hrp.AssemblyLinearVelocity.Y, md.Z * spd)
else
hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
end
end)
end
local infJumpConn, lastJump = nil, 0
local function setInfiniteJump(enabled)
Config.InfiniteJump = enabled
if infJumpConn then
infJumpConn:Disconnect()
infJumpConn = nil
end
if not enabled then return end
infJumpConn = RunService.Heartbeat:Connect(function()
if _G.__Els_VelFlying or _G.__Els_TPStarted then return end
local now = tick()
if now - lastJump < 0.1 then return end
local c = LocalPlayer.Character
if not c then return end
local hrp = c:FindFirstChild("HumanoidRootPart")
local hum = c:FindFirstChildOfClass("Humanoid")
if not hrp or not hum or hum.Health <= 0 then return end
if not (UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump) then return end
lastJump = now
hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
end)
end
bJump.MouseButton1Click:Connect(function()
Config.InfiniteJump = not Config.InfiniteJump
paint(bJump, "INFINITE JUMP", Config.InfiniteJump)
setInfiniteJump(Config.InfiniteJump)
pcall(_G.Els_AutoSave)
end)
local function toggleWave()
Config.WaveriderSpeedEnabled = not Config.WaveriderSpeedEnabled
paint(bWave, "WAVERIDER SPEED (A)", Config.WaveriderSpeedEnabled)
setWaveriderSpeed(Config.WaveriderSpeedEnabled)
pcall(_G.Els_AutoSave)
end
bWave.MouseButton1Click:Connect(toggleWave)
bClone.MouseButton1Click:Connect(function()
Config.AutoClone = not (Config.AutoClone ~= false)
paint(bClone, "AUTO CLONE (V)", Config.AutoClone)
pcall(_G.Els_AutoSave)
end)
bInv.MouseButton1Click:Connect(function()
Config.InvSteal = not (Config.InvSteal ~= false)
paint(bInv, "INV STEAL", Config.InvSteal)
if _G.Els_InvStealSet then
pcall(_G.Els_InvStealSet, Config.InvSteal)
end
pcall(_G.Els_AutoSave)
end)
local function doInstantReset()
pcall(function()
local c = LocalPlayer.Character
local hum = c and c:FindFirstChildOfClass("Humanoid")
if hum then
hum.Health = 0
elseif c then
c:BreakJoints()
end
end)
end
_G.Els_InstantReset = doInstantReset
Config.KickToPS = false
Config.InfiniteJump = true
paint(bJump, "INFINITE JUMP", true)
setInfiniteJump(true)
if Config.WaveriderSpeedEnabled then setWaveriderSpeed(true) end
UIS.InputBegan:Connect(function(input, processed)
if processed or _G.Els_KeyCapturing then return end
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
local is = _G.Els_KeyIs
if type(is) ~= "function" then return end
local kc = input.KeyCode
if is("Clone", kc) and Config.AutoClone ~= false then
task.spawn(instantClone)
elseif is("Kick", kc) then
task.spawn(function() if _G.Els_KickError then _G.Els_KickError() else doAutoKick() end end)
elseif is("CarpetSpeed", kc) then
toggleWave()
end
end)
end
task.spawn(function()
local t0 = os.clock()
while os.clock() - t0 < 12 do
if _G.__Els_TPStarted or _G.__Els_VelFlying then return end
local ok, pets = pcall(_G.Els_ScanPets)
if ok and type(pets) == "table" and #pets > 0 then
local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if hrp and _G.Els_DoVelocityTP then
local tw = os.clock()
local FLY = _G.Els_CarpetNames or { "Flying Bee", "Witch's Broom", "Waverider", "Flying Carpet", "Santa's Sleigh", "Cupid's Wings" }
while os.clock() - tw < 1.5 do
local c = LocalPlayer.Character
local held = false
if c then for _, fn in ipairs(FLY) do if c:FindFirstChild(fn) then held = true break end end end
if _G.__Els_GrappleFired and held then
break
end
RunService.Heartbeat:Wait()
end
pcall(_G.Els_DoVelocityTP, pets)
return
end
end
RunService.Heartbeat:Wait()
end
end)
do
local LP = LocalPlayer
local hard = false
local humRef = nil
local n = 0
local stealing = LP:GetAttribute("Stealing") == true
LP:GetAttributeChangedSignal("Stealing"):Connect(function()
stealing = LP:GetAttribute("Stealing") == true
end)
local function want()
return _G.__Els_VelFlying or _G.__Els_TPStarted or _G.isCloning or stealing
end
local function protect()
if not want() then
if hard then
hard = false
local hum = humRef
if hum and hum.Parent then
pcall(function()
hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
end)
end
humRef = nil
end
return
end
n += 1
local hum = humRef
if not (hum and hum.Parent) then
local char = LP.Character
hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then return end
humRef = hum
end
if not hard then
hard = true
pcall(function()
hum.BreakJointsOnDeath = false
hum.RequiresNeck = false
hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
end)
end
if n % 3 ~= 0 then return end
if hum.Health < hum.MaxHealth then
hum.Health = hum.MaxHealth
end
end
RunService.PreSimulation:Connect(protect)
LP.CharacterAdded:Connect(function()
hard = false
humRef = nil
end)
end
task.delay(10, function()
local XWorkspace = Workspace
local on = false
local orig = setmetatable({}, { __mode = "k" })
local conns = {}
local loopId = 0
local ALPHA = 0.5
local FOLDERS = { "Base", "PlotSign", "FriendPanel", "Cash", "Laser", "Decorations", "Skin", "Unlock", "Purchases" }
local function setTransparency(instance, alpha, id)
if not instance then return end
if id ~= loopId then return end
local function apply(obj)
if obj:IsA("BasePart") then
if orig[obj] == nil then
if obj.Transparency == alpha then orig[obj] = 0
else orig[obj] = obj.Transparency end
end
local o = orig[obj]
if o < 1 then
local target = o + (1 - o) * alpha
if math.abs(obj.Transparency - target) > 0.01 then obj.Transparency = target end
end
end
end
apply(instance)
for i, child in ipairs(instance:GetDescendants()) do
apply(child)
if i % 20 == 0 then
task.wait()
if id ~= loopId then return end
end
end
end
local function trackSubtree(root, alpha, id)
if not root or id ~= loopId then return end
setTransparency(root, alpha, id)
if id ~= loopId then return end
conns[#conns + 1] = root.DescendantAdded:Connect(function(obj)
if id ~= loopId then return end
setTransparency(obj, alpha, id)
end)
end
local function processPlot(plot, alpha, id)
if not plot or id ~= loopId then return end
for _, fname in ipairs(FOLDERS) do
if id ~= loopId then return end
trackSubtree(plot:FindFirstChild(fname), alpha, id)
end
if id ~= loopId then return end
conns[#conns + 1] = plot.ChildAdded:Connect(function(child)
if id ~= loopId then return end
for _, fname in ipairs(FOLDERS) do
if child.Name == fname then trackSubtree(child, alpha, id); break end
end
end)
local podiums = plot:FindFirstChild("AnimalPodiums")
if podiums then
local function processPodium(podium)
for _, child in ipairs(podium:GetChildren()) do
if child.Name == "Claim" then
trackSubtree(child, alpha, id)
elseif child.Name == "Base" then
trackSubtree(child:FindFirstChild("Decorations"), alpha, id)
elseif child:IsA("Model") and child.Name ~= "Decorations" then
trackSubtree(child, alpha, id)
end
end
end
for _, podium in ipairs(podiums:GetChildren()) do processPodium(podium) end
conns[#conns + 1] = podiums.ChildAdded:Connect(function(podium)
if id ~= loopId then return end
task.wait(0.1)
if id ~= loopId then return end
processPodium(podium)
end)
end
end
local function applyAllPlots(alpha, id)
local plotsFolder = XWorkspace:FindFirstChild("Plots")
if not plotsFolder then return end
for _, plot in ipairs(plotsFolder:GetChildren()) do
if id ~= loopId then return end
processPlot(plot, alpha, id)
task.wait()
end
conns[#conns + 1] = plotsFolder.ChildAdded:Connect(function(plot)
if id ~= loopId then return end
task.wait(0.2)
processPlot(plot, alpha, id)
end)
end
local function enable()
for _, c in ipairs(conns) do
if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
end
conns = {}
loopId = loopId + 1
local id = loopId
on = true
task.spawn(function()
while id == loopId and not XWorkspace:FindFirstChild("Plots") do task.wait(0.2) end
if id ~= loopId then return end
pcall(applyAllPlots, ALPHA, id)
end)
end
enable()
end)
_G.MeerkoInvisDepth = tonumber(Config.InvStealDepth) or 10
_G.MeerkoInvisAngle = tonumber(Config.InvStealAngle) or 220
_G.MeerkoInvisAutoDelay = 0.5
if _G.MeerkoInvisRestartDist == nil then _G.MeerkoInvisRestartDist = 2.25 end
if _G.MeerkoInvisRestartWait == nil then _G.MeerkoInvisRestartWait = 0.5 end
if _G.MeerkoInvisAutoRecover == nil then _G.MeerkoInvisAutoRecover = true end
_G.MeerkoInvisActive = false
_G.MeerkoInvisAuto = Config.InvSteal ~= false
do
local LP = LocalPlayer
local active, conns = false, {}
local realHRP, cloneHRP, track, hip, origT
local stuck, restarting = false, false
local start, stop
local function depth()
return 0.01 + (math.clamp(tonumber(_G.MeerkoInvisDepth) or 4.2, 0, 10) / 10) * 0.19
end
local function angle()
return math.clamp(tonumber(_G.MeerkoInvisAngle) or 180, 0, 360)
end
local function add(c) conns[#conns + 1] = c end
local function rewire(char, from, to)
for _, v in ipairs(char:GetDescendants()) do
if v:IsA("Weld") or v:IsA("Motor6D") then
if v.Part0 == from then v.Part0 = to end
if v.Part1 == from then v.Part1 = to end
end
end
end
stop = function()
active, stuck = false, false
for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
conns = {}
if origT then
for p, v in pairs(origT) do
if p and p.Parent then pcall(function() p.LocalTransparencyModifier = v end) end
end
origT = nil
end
if track then
pcall(function() track:AdjustSpeed(1) track:Stop(0) track:Destroy() end)
track = nil
end
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if realHRP and realHRP:IsDescendantOf(game) and hum then
local tmp = Instance.new("Model")
tmp.Parent = game
char.Parent = tmp
realHRP.Parent = char
char.PrimaryPart = realHRP
char.Parent = workspace
realHRP.CanCollide = true
rewire(char, cloneHRP, realHRP)
if cloneHRP then
local at = cloneHRP.CFrame
cloneHRP:Destroy()
cloneHRP = nil
realHRP.CFrame = at
end
hum.HipHeight = hip or 0
tmp:Destroy()
end
realHRP, cloneHRP = nil, nil
_G.MeerkoInvisActive = false
end
local function animTrick(char, hum)
if not (char and hum and hum.Health > 0) then return end
local a = Instance.new("Animation")
a.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
track = animator:LoadAnimation(a)
track.Priority = Enum.AnimationPriority.Action4
track.Looped = true
track:Play(0, 1, 0)
a:Destroy()
add(track.Stopped:Connect(function()
if active then animTrick(char, hum) end
end))
task.defer(function()
if not track then return end
track.TimePosition = 0.7
task.delay(0.1, function() if track then track:AdjustSpeed(math.huge) end end)
end)
end
start = function()
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum or active then return false end
local folder = workspace:FindFirstChild(LP.Name)
if folder then
for _, n in ipairs({ "DoubleRig", "Constraints" }) do
local x = folder:FindFirstChild(n)
if x then x:Destroy() end
end
add(folder.ChildAdded:Connect(function(c)
if c.Name == "DoubleRig" or c.Name == "Constraints" then c:Destroy() end
end))
end
for _, s in ipairs({ "Dead", "FallingDown", "Ragdoll" }) do
hum:SetStateEnabled(Enum.HumanoidStateType[s], false)
end
hip = hum.HipHeight
realHRP = char:FindFirstChild("HumanoidRootPart")
if not (realHRP and realHRP.Parent) then return false end
local tmp = Instance.new("Model")
tmp.Parent = game
char.Parent = tmp
cloneHRP = realHRP:Clone()
cloneHRP.Parent = char
realHRP.Parent = workspace.CurrentCamera
cloneHRP.CFrame = realHRP.CFrame
char.PrimaryPart = cloneHRP
char.Parent = workspace
rewire(char, realHRP, cloneHRP)
tmp:Destroy()
active = true
animTrick(char, hum)
origT = {}
for _, p in ipairs(char:GetDescendants()) do
if p:IsA("BasePart") then
origT[p] = p.LocalTransparencyModifier
p.LocalTransparencyModifier = 1
end
end
add(char.DescendantAdded:Connect(function(d)
if not (active and d:IsA("BasePart")) then return end
if origT and origT[d] == nil then origT[d] = d.LocalTransparencyModifier end
pcall(function() d.LocalTransparencyModifier = 1 end)
end))
add(RunService.Heartbeat:Connect(function()
if not active or not hum.Parent then return end
if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
if hum:GetStateEnabled(Enum.HumanoidStateType.Dead) then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end
local st = hum:GetState()
if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.FallingDown
or st == Enum.HumanoidStateType.Ragdoll then
hum:ChangeState(Enum.HumanoidStateType.Running)
end
end))
local lastTarget, grace = nil, 60
add(RunService.PreSimulation:Connect(function()
if not (active and realHRP and hum.Health > 0) then return end
local base = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
if not base then return end
if grace > 0 then
grace = grace - 1
elseif _G.MeerkoInvisAutoRecover ~= false and not stuck and lastTarget
and (realHRP.Position - lastTarget).Magnitude
> (tonumber(_G.MeerkoInvisRestartDist) or 2.25) then
stuck = true
if not restarting then
task.spawn(function()
restarting = true
stop()
task.wait(tonumber(_G.MeerkoInvisRestartWait) or 0.5)
restarting = false
start()
end)
end
end
local cf = base.CFrame
- Vector3.new(0, hum.HipHeight + (base.Size.Y / 2) - 1 + depth(), 0)
realHRP.CFrame = cf * CFrame.Angles(math.rad(angle()), 0, 0)
realHRP.AssemblyLinearVelocity = base.AssemblyLinearVelocity
realHRP.CanCollide = false
if realHRP.Parent ~= workspace.CurrentCamera then
realHRP.Parent = workspace.CurrentCamera
end
lastTarget = cf.Position
end))
add(LP.CharacterAdded:Connect(function() if active then stop() end end))
_G.MeerkoInvisActive = true
return true
end
local armed, autoOn = false, false
local function syncAuto()
local want = (_G.MeerkoInvisAuto == true) and (LP:GetAttribute("Stealing") == true)
if not want then
armed = false
if active and autoOn then autoOn = false pcall(stop) end
return
end
if active or armed then return end
armed = true
task.delay(tonumber(_G.MeerkoInvisAutoDelay) or 1.5, function()
armed = false
if _G.MeerkoInvisAuto == true and not active
and LP:GetAttribute("Stealing") == true
and os.clock() >= (_G.Els_InvisSuppressUntil or 0) then
autoOn = true
pcall(start)
end
end)
end
_G.MeerkoInvisSync = syncAuto
-- full stop used by Drop Brainrot (R): invis off now, and no auto re-start
-- for 2 s so it can't come back in the middle of the drop
_G.Els_InvisOff = function()
_G.Els_InvisSuppressUntil = os.clock() + 2
local was = active or realHRP ~= nil
armed, autoOn = false, false
if was then pcall(stop) end
return was
end
LP:GetAttributeChangedSignal("Stealing"):Connect(syncAuto)
end
_G.Els_InvStealSet = function(on)
Config.InvSteal = on and true or false
_G.MeerkoInvisAuto = Config.InvSteal == true
if _G.MeerkoInvisSync then pcall(_G.MeerkoInvisSync) end
end
]=]
local __elsCoreFn = nil
pcall(function() __elsCoreFn = loadstring(SRC) end)
if not game:IsLoaded() then
game.Loaded:Wait()
end
do
local Players = game:GetService("Players")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
if not lp.Character then
lp.CharacterAdded:Wait()
end
if not workspace:FindFirstChild("Plots") then
workspace:WaitForChild("Plots", 10)
end
end
do
local TS = game:GetService("TweenService")
local T = {}
local C = {
bg=Color3.fromRGB(6,22,44), bg2=Color3.fromRGB(10,32,60),
row=Color3.fromRGB(13,38,72), rowHover=Color3.fromRGB(19,50,90), rowSel=Color3.fromRGB(28,70,118),
line=Color3.fromRGB(28,70,110), txt=Color3.fromRGB(226,238,248), dim=Color3.fromRGB(120,156,190),
acc=Color3.fromRGB(20,84,140), acc2=Color3.fromRGB(120,186,228), green=Color3.fromRGB(140,220,255),
red=Color3.fromRGB(235,85,95),
}
T.C = C
local WHITE = Color3.new(1,1,1)
function T.hex(c) return string.format("#%02X%02X%02X",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)) end
function T.tween(o,t,props)
pcall(function() TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play() end)
end
function T.corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o; return c end
function T.stroke(o,color,thick,trans)
local s=Instance.new("UIStroke"); s.Color=color or C.line; s.Thickness=thick or 1; s.Transparency=trans or 0
s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s
end
function T.label(parent,props)
local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.BorderSizePixel=0
t.Font=Enum.Font.GothamBold; t.TextSize=12; t.TextColor3=C.txt; t.TextXAlignment=Enum.TextXAlignment.Left
for k,v in pairs(props or {}) do t[k]=v end
t.Parent=parent; return t
end
function T.window(f)
f.BackgroundColor3=C.bg; f.BorderSizePixel=0
T.corner(f,12); T.stroke(f,C.acc,1.2,0.25)
local gr=Instance.new("UIGradient"); gr.Rotation=90
gr.Color=ColorSequence.new(WHITE,Color3.fromRGB(172,194,220)); gr.Parent=f
return f
end
function T.accent(parent,pos,size)
local b=Instance.new("Frame"); b.Name="Accent"; b.BorderSizePixel=0; b.BackgroundColor3=WHITE
b.Position=pos; b.Size=size; T.corner(b,1)
local gr=Instance.new("UIGradient"); gr.Color=ColorSequence.new(C.acc,C.acc2); gr.Parent=b
b.Parent=parent; return b
end
function T.title(parent,text,x,y,h)
local dot=Instance.new("Frame"); dot.Name="Dot"; dot.Size=UDim2.fromOffset(8,8)
dot.Position=UDim2.fromOffset(x,y+math.floor(h/2)-4); dot.BackgroundColor3=C.acc; dot.BorderSizePixel=0
T.corner(dot,4); dot.Parent=parent
return T.label(parent,{Name="Title",Position=UDim2.fromOffset(x+14,y),Size=UDim2.new(1,-(x+14)-40,0,h),Text=text,TextSize=13})
end
local base, hov = setmetatable({},{__mode="k"}), setmetatable({},{__mode="k"})
local function lit(c) return c:Lerp(WHITE,0.06) end
function T.setBase(b,col)
base[b]=col
T.tween(b,0.12,{BackgroundColor3=hov[b] and lit(col) or col})
end
function T.button(b,variant)
b.AutoButtonColor=false; b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; b.TextSize=12
b.TextColor3=(variant=="danger") and C.red or C.txt
T.corner(b,8)
local s=T.stroke(b,(variant=="primary") and C.acc or C.line,1,(variant=="primary") and 0.2 or 0); s.Name="ThemeStroke"
local col=(variant=="primary") and C.rowSel or C.row
base[b]=col; b.BackgroundColor3=col
b.MouseEnter:Connect(function() hov[b]=true; T.tween(b,0.12,{BackgroundColor3=lit(base[b] or col)}) end)
b.MouseLeave:Connect(function() hov[b]=false; T.tween(b,0.12,{BackgroundColor3=base[b] or col}) end)
return b
end
function T.toggle(b,on,text)
T.setBase(b,on and C.rowSel or C.row)
local s=b:FindFirstChild("ThemeStroke")
if s then s.Color=on and C.acc or C.line; s.Transparency=on and 0.15 or 0 end
if text then
b.RichText=true
b.Text=text.."   <font color=\""..T.hex(on and C.green or C.dim).."\">"..(on and "ON" or "OFF").."</font>"
end
end
function T.input(tb)
tb.BackgroundColor3=C.bg2; tb.BorderSizePixel=0; tb.TextColor3=C.txt; tb.PlaceholderColor3=C.dim
T.corner(tb,8); T.stroke(tb,C.line,1)
local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8)
p.PaddingTop=UDim.new(0,4); p.PaddingBottom=UDim.new(0,4); p.Parent=tb
return tb
end
_G.Els_Theme = T
end
do
-- ===================================================================
-- Els UI: hotbar + prompts in Els Hub colors (replace the Roblox backpack
-- and the ProximityPrompt display, like fastload)
-- Disable: _G.Els_Hotbar = false / _G.Els_PromptUI = false before the hub
-- ===================================================================
local T = _G.Els_Theme
local C = T and T.C
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
if T and LP and _G.Els_Hotbar ~= false then
task.spawn(function()
local HS = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local pg = LP:WaitForChild("PlayerGui", 10)
if not pg then return end
task.spawn(function()
for _ = 1, 100 do
if pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false)
and not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then break end
task.wait(0.2)
end
end)
local old = pg:FindFirstChild("ElsHotbar")
if old then old:Destroy() end
local SLOTS, CELL, PAD = 9, 54, 6
local KEYS = {
[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3,
[Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5, [Enum.KeyCode.Six] = 6,
[Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8, [Enum.KeyCode.Nine] = 9,
}
local SAVE_FILE = "Els_Hotbar.json"
local gui = Instance.new("ScreenGui")
gui.Name = "ElsHotbar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
local barW = SLOTS * CELL + (SLOTS - 1) * PAD + 16
local bar = Instance.new("Frame")
bar.Name = "ElsBar"
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, -12)
bar.Size = UDim2.fromOffset(barW, CELL + 16)
T.window(bar)
bar.BackgroundTransparency = 0.08
bar.Parent = gui
T.accent(bar, UDim2.new(0, 14, 0, 0), UDim2.new(1, -28, 0, 2))
local row = Instance.new("Frame")
row.Name = "ElsSlots"
row.BackgroundTransparency = 1
row.Position = UDim2.fromOffset(8, 8)
row.Size = UDim2.new(1, -16, 1, -16)
row.Parent = bar
local rl = Instance.new("UIListLayout")
rl.FillDirection = Enum.FillDirection.Horizontal
rl.SortOrder = Enum.SortOrder.LayoutOrder
rl.Padding = UDim.new(0, PAD)
rl.Parent = row
local bagBtn = Instance.new("TextButton")
bagBtn.Name = "ElsBag"
bagBtn.AnchorPoint = Vector2.new(0.5, 1)
bagBtn.Position = UDim2.new(0.5, 0, 1, -(CELL + 16 + 18))
bagBtn.Size = UDim2.fromOffset(110, 24)
T.button(bagBtn)
bagBtn.RichText = true
bagBtn.Text = "BAG"
bagBtn.Parent = gui
local panelH = 3 * CELL + 2 * PAD + 20
local panel = Instance.new("Frame")
panel.Name = "ElsBagPanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -(CELL + 16 + 18 + 24 + 8))
panel.Size = UDim2.fromOffset(barW, panelH)
T.window(panel)
panel.BackgroundTransparency = 0.05
panel.Visible = false
panel.Parent = gui
T.title(panel, "BAG  ·  drag = store  ·  click = equip  ·  right click = hotbar", 12, 6, 16)
local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.fromOffset(8, 26)
scroll.Size = UDim2.new(1, -12, 1, -32)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.acc
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromOffset(CELL, CELL)
grid.CellPadding = UDim2.fromOffset(PAD, PAD)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = scroll
local function newCell(parent, idx)
local b = Instance.new("TextButton")
b.Name = "ElsSlot"
b.Size = UDim2.fromOffset(CELL, CELL)
b.Text = ""
b.LayoutOrder = idx or 0
T.button(b)
local icon = Instance.new("ImageLabel")
icon.BackgroundTransparency = 1
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.fromScale(0.5, 0.5)
icon.Size = UDim2.fromOffset(34, 34)
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = b
local name = T.label(b, {
Position = UDim2.fromOffset(4, 14), Size = UDim2.new(1, -8, 1, -18), TextSize = 10,
TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Text = "",
})
local shade = Instance.new("Frame")
shade.AnchorPoint = Vector2.new(0, 1)
shade.Position = UDim2.fromScale(0, 1)
shade.Size = UDim2.fromScale(1, 0)
shade.BackgroundColor3 = Color3.new(0, 0, 0)
shade.BackgroundTransparency = 0.45
shade.BorderSizePixel = 0
shade.Visible = false
shade.ZIndex = 3
T.corner(shade, 8)
shade.Parent = b
local timer = T.label(b, {
Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 15,
TextStrokeTransparency = 0.5, Visible = false, ZIndex = 4, Text = "",
})
if idx then
T.label(b, { Position = UDim2.fromOffset(5, 3), Size = UDim2.fromOffset(12, 12), TextSize = 10, TextColor3 = C.dim, Text = tostring(idx), ZIndex = 2 })
end
local under = Instance.new("Frame")
under.AnchorPoint = Vector2.new(0.5, 1)
under.Position = UDim2.new(0.5, 0, 1, -3)
under.Size = UDim2.new(0.5, 0, 0, 2)
under.BackgroundColor3 = C.acc
under.BorderSizePixel = 0
under.Visible = false
under.ZIndex = 3
T.corner(under, 1)
under.Parent = b
b.Parent = parent
return { btn = b, icon = icon, name = name, shade = shade, timer = timer, under = under, tool = nil, total = 0, worn = nil, idx = idx }
end
local slotNames = {}
-- bagOrder = backpack order + list of tools already seen (a tool removed from the bar doesn't come back on its own)
local bagOrder, orderIdx = {}, {}
pcall(function()
if isfile and isfile(SAVE_FILE) then
local d = HS:JSONDecode(readfile(SAVE_FILE))
if type(d) == "table" and type(d.slots) == "table" then
for i = 1, SLOTS do
if type(d.slots[i]) == "string" and d.slots[i] ~= "" then slotNames[i] = d.slots[i] end
end
end
if type(d) == "table" and type(d.order) == "table" then
for _, n in ipairs(d.order) do
if type(n) == "string" and not orderIdx[n] then
bagOrder[#bagOrder + 1] = n
orderIdx[n] = #bagOrder
end
end
end
end
end)
local function reindex()
table.clear(orderIdx)
for i, n in ipairs(bagOrder) do orderIdx[n] = i end
end
local dirty = false
local function save()
if not dirty or not writefile then return end
dirty = false
local out = {}
for i = 1, SLOTS do out[i] = slotNames[i] or "" end
pcall(function() writefile(SAVE_FILE, HS:JSONEncode({ slots = out, order = bagOrder })) end)
end
local function hum()
local c = LP.Character
return c and c:FindFirstChildOfClass("Humanoid")
end
local function use(tool)
local h = hum()
if not (tool and h) then return end
if tool.Parent == LP.Character then h:UnequipTools() else h:EquipTool(tool) end
end
local function cooldown(tool)
if not tool then return 0 end
local a = tool:GetAttribute("CooldownTime")
if type(a) == "number" and a > 0 then return a end
local u = tool:GetAttribute("CooldownUntil")
if type(u) == "number" then return math.max(u - workspace:GetServerTimeNow(), 0) end
return 0
end
local function show(cell, tool)
if cell.tool ~= tool then cell.total = 0 end
cell.tool = tool
local id = tool and tool.TextureId or ""
cell.icon.Image = id
cell.icon.Visible = id ~= ""
cell.name.Text = (tool and id == "") and tool.Name or ""
cell.btn.BackgroundTransparency = tool and 0 or 0.5
end
local function paint(cell)
local tool = cell.tool
local worn = tool ~= nil and tool.Parent == LP.Character
if cell.worn ~= worn then
cell.worn = worn
T.toggle(cell.btn, worn)
cell.under.Visible = worn
end
local cd = cooldown(tool)
if cd <= 0 then
cell.total = 0
cell.shade.Visible = false
cell.timer.Visible = false
else
cell.total = math.max(cell.total, cd)
cell.shade.Size = UDim2.fromScale(1, cd / cell.total)
cell.shade.Visible = true
cell.timer.Text = cd < 10 and string.format("%.1f", cd) or tostring(math.ceil(cd))
cell.timer.Visible = true
end
end
local RunService = game:GetService("RunService")
local slots = {}
local bagCells = {}
local byName = {}
local tools = {}
local function firstEmpty()
for i = 1, SLOTS do if not slotNames[i] then return i end end
return nil
end
local function inBar(n)
for i = 1, SLOTS do if slotNames[i] == n then return i end end
return nil
end
-- ---------- drag and drop (bar <-> bar, bag -> bar, bar -> bag/outside, bag <-> bag)
local ghost = Instance.new("Frame")
ghost.Name = "ElsDrag"
ghost.AnchorPoint = Vector2.new(0.5, 0.5)
ghost.Size = UDim2.fromOffset(CELL, CELL)
ghost.BackgroundColor3 = C.rowSel
ghost.BorderSizePixel = 0
ghost.Visible = false
ghost.ZIndex = 20
T.corner(ghost, 8)
T.stroke(ghost, C.acc, 1.6)
local gIcon = Instance.new("ImageLabel")
gIcon.BackgroundTransparency = 1
gIcon.AnchorPoint = Vector2.new(0.5, 0.5)
gIcon.Position = UDim2.fromScale(0.5, 0.5)
gIcon.Size = UDim2.fromOffset(36, 36)
gIcon.ScaleType = Enum.ScaleType.Fit
gIcon.ZIndex = 21
gIcon.Parent = ghost
local gName = T.label(ghost, {
Position = UDim2.fromOffset(4, 12), Size = UDim2.new(1, -8, 1, -16), TextSize = 10, TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", ZIndex = 21,
})
ghost.Parent = gui
local press, dragName, dragFrom = nil, nil, nil
local gPos, gTilt = Vector2.zero, 0
local function mouse() return UIS:GetMouseLocation() end
-- GetMouseLocation counts from the top of the screen, AbsolutePosition may count
-- below the Roblox top bar: bring the mouse into AbsolutePosition space
local function ptr() return UIS:GetMouseLocation() + gui.AbsolutePosition end
local function over(pos, obj, pad)
pad = pad or 0
local p, s = obj.AbsolutePosition, obj.AbsoluteSize
return pos.X >= p.X - pad and pos.Y >= p.Y - pad and pos.X <= p.X + s.X + pad and pos.Y <= p.Y + s.Y + pad
end
local function slotAt(pos)
for i, c in ipairs(slots) do
if over(pos, c.btn, PAD / 2) then return i end
end
return nil
end
local function bagAt(pos)
if not panel.Visible then return nil end
for _, c in ipairs(bagCells) do
if c.btn.Visible and c.tool and over(pos, c.btn, PAD / 2) then return c end
end
return nil
end
local function resetStrokes()
for _, c in ipairs(slots) do
local s = c.btn:FindFirstChild("ThemeStroke")
if s then
s.Color = c.worn and C.acc or C.line
s.Transparency = c.worn and 0.15 or 0
end
end
end
local function moveInOrder(name, beforeName)
local from = orderIdx[name]
if from then table.remove(bagOrder, from) end
reindex()
local to = beforeName and orderIdx[beforeName] or (#bagOrder + 1)
table.insert(bagOrder, to, name)
reindex()
end
local function drop(pos)
local name, from = dragName, dragFrom
local target = slotAt(pos)
if target then
if from.kind == "slot" then
slotNames[from.idx], slotNames[target] = slotNames[target], slotNames[from.idx]
else
local j = inBar(name)
if j then slotNames[j] = slotNames[target] end
slotNames[target] = name
end
dirty = true
return
end
local bc = bagAt(pos)
if bc and bc.tool.Name ~= name then
moveInOrder(name, bc.tool.Name)
if from.kind == "slot" then slotNames[from.idx] = nil end
dirty = true
return
end
-- bar slot dropped into the open bag: removed from the bar
-- dropped elsewhere (empty space): nothing changes, the move is cancelled
if from.kind == "slot" and panel.Visible and over(pos, panel) then
slotNames[from.idx] = nil
dirty = true
end
end
local function bindDrag(cell, kind, idx)
cell.btn.InputBegan:Connect(function(input)
local t = input.UserInputType
if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
press = { cell = cell, kind = kind, idx = idx, at = mouse(), touch = t == Enum.UserInputType.Touch }
end
end)
end
UIS.InputChanged:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
if press and not dragName and press.cell.tool and (mouse() - press.at).Magnitude > 4 then
dragName = press.cell.tool.Name
dragFrom = press
local id = press.cell.tool.TextureId
gIcon.Image = id
gIcon.Visible = id ~= ""
gName.Text = id == "" and dragName or ""
gPos = mouse()
gTilt = 0
ghost.Position = UDim2.fromOffset(gPos.X, gPos.Y)
ghost.Visible = true
end
end)
UIS.InputEnded:Connect(function(input)
local t = input.UserInputType
if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
local p = press
press = nil
if dragName then
pcall(drop, ptr())
dragName, dragFrom = nil, nil
ghost.Visible = false
resetStrokes()
elseif p and p.cell.tool then
-- single click: equip / unequip (released on the same slot)
if p.touch or over(ptr(), p.cell.btn) then use(p.cell.tool) end
end
end)
RunService.RenderStepped:Connect(function(dt)
if not dragName then return end
local m = mouse()
local prev = gPos
gPos = gPos:Lerp(m, 1 - math.exp(-35 * dt))
local vx = dt > 0 and (gPos.X - prev.X) / dt or 0
gTilt = gTilt + (math.clamp(vx * 0.015, -10, 10) - gTilt) * (1 - math.exp(-16 * dt))
ghost.Position = UDim2.fromOffset(gPos.X, gPos.Y)
ghost.Rotation = gTilt
local tgt = slotAt(ptr())
for i, c in ipairs(slots) do
local s = c.btn:FindFirstChild("ThemeStroke")
if s then
if i == tgt then
s.Color = C.acc2
s.Transparency = 0
else
s.Color = c.worn and C.acc or C.line
s.Transparency = c.worn and 0.15 or 0
end
end
end
end)
for i = 1, SLOTS do
local cell = newCell(row, i)
slots[i] = cell
bindDrag(cell, "slot", i)
cell.btn.MouseButton2Click:Connect(function()
if slotNames[i] then slotNames[i] = nil; dirty = true end
end)
end
local function sync()
table.clear(byName)
table.clear(tools)
for _, cont in ipairs({ LP:FindFirstChildOfClass("Backpack"), LP.Character }) do
if cont then
for _, t in ipairs(cont:GetChildren()) do
if t:IsA("Tool") then
tools[#tools + 1] = t
if not byName[t.Name] then byName[t.Name] = t end
end
end
end
end
-- new, never-seen tool: end of the bag + 1st empty bar slot
for _, t in ipairs(tools) do
if not orderIdx[t.Name] then
bagOrder[#bagOrder + 1] = t.Name
orderIdx[t.Name] = #bagOrder
dirty = true
if not inBar(t.Name) then
local e = firstEmpty()
if e then slotNames[e] = t.Name end
end
end
end
table.sort(tools, function(a, b)
local ia, ib = orderIdx[a.Name] or math.huge, orderIdx[b.Name] or math.huge
if ia ~= ib then return ia < ib end
return a.Name < b.Name
end)
for i = 1, SLOTS do
local t = slotNames[i] and byName[slotNames[i]] or nil
if slots[i].tool ~= t then show(slots[i], t) end
end
for i, t in ipairs(tools) do
local cell = bagCells[i]
if not cell then
cell = newCell(scroll, nil)
bagCells[i] = cell
bindDrag(cell, "bag", nil)
cell.btn.MouseButton2Click:Connect(function()
local tl = cell.tool
if not tl or inBar(tl.Name) then return end
local e = firstEmpty() or SLOTS
slotNames[e] = tl.Name
dirty = true
end)
end
cell.btn.LayoutOrder = i
cell.btn.Visible = true
if cell.tool ~= t then show(cell, t) end
end
for i = #tools + 1, #bagCells do
bagCells[i].btn.Visible = false
show(bagCells[i], nil)
end
bagBtn.Text = string.format('BAG  <font color="%s">%d</font>', T.hex(C.acc2), #tools)
save()
end
local function setPanel(v)
panel.Visible = v
T.toggle(bagBtn, v)
end
bagBtn.Activated:Connect(function() setPanel(not panel.Visible) end)
UIS.InputBegan:Connect(function(input, gp)
if gp or UIS:GetFocusedTextBox() or _G.Els_KeyCapturing then return end
local k = KEYS[input.KeyCode]
if k then
use(slots[k].tool)
elseif input.KeyCode == Enum.KeyCode.Backquote then
setPanel(not panel.Visible)
end
end)
gui.Parent = pg
local syncDirty, syncAt = true, 0
local function markSync() syncDirty = true end
local function watchBag(c)
if c then
c.ChildAdded:Connect(markSync)
c.ChildRemoved:Connect(markSync)
end
end
watchBag(LP:FindFirstChildOfClass("Backpack"))
watchBag(LP.Character)
LP.ChildAdded:Connect(function(c)
if c:IsA("Backpack") then watchBag(c) markSync() end
end)
LP.CharacterAdded:Connect(function(c) watchBag(c) markSync() end)
while gui.Parent do
local tnow = os.clock()
if syncDirty or dirty or tnow - syncAt >= 1 then
syncDirty, syncAt = false, tnow
pcall(sync)
end
for i = 1, SLOTS do pcall(paint, slots[i]) end
if panel.Visible then
for _, cell in ipairs(bagCells) do
if cell.btn.Visible then pcall(paint, cell) end
end
end
task.wait(0.1)
end
end)
end
if T and LP and _G.Els_PromptUI ~= false then
task.spawn(function()
local PPS = game:GetService("ProximityPromptService")
local TS = game:GetService("TweenService")
local pg = LP:WaitForChild("PlayerGui", 10)
if not pg then return end
local old = pg:FindFirstChild("ElsPrompts")
if old then old:Destroy() end
local holder = Instance.new("ScreenGui")
holder.Name = "ElsPrompts"
holder.ResetOnSpawn = false
holder.Parent = pg
local boards = {}
local function keyName(p)
local n = p.KeyboardKeyCode.Name
return #n > 3 and string.sub(n, 1, 3) or n
end
-- if the game also draws its own prompt (BillboardGui on the same attachment), turn it off
local function hideGame(prompt)
local adorn = prompt.Parent
if not adorn then return end
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("BillboardGui") and d.Adornee == adorn and not d:IsDescendantOf(holder) then
pcall(function() d.Enabled = false end)
end
end
end
local function hide(prompt)
local b = boards[prompt]
if not b then return end
boards[prompt] = nil
for _, c in ipairs(b.cons) do c:Disconnect() end
pcall(function() b.gui:Destroy() end)
end
local function fillTo(b, full, dur)
if b.tw then b.tw:Cancel() end
b.tw = TS:Create(b.fill, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = full and UDim2.fromScale(1, 1) or UDim2.fromScale(0, 1) })
b.tw:Play()
end
local function show(prompt)
hide(prompt)
local adorn = prompt.Parent
if not adorn or not (adorn:IsA("Attachment") or adorn:IsA("BasePart")) then return end
if prompt.Style == Enum.ProximityPromptStyle.Default then
pcall(function() prompt.Style = Enum.ProximityPromptStyle.Custom end)
end
local bb = Instance.new("BillboardGui")
bb.Name = "ElsPrompt"
bb.Adornee = adorn
bb.Size = UDim2.fromOffset(180, 46)
bb.SizeOffset = Vector2.new(0, 0.6)
bb.AlwaysOnTop = true
bb.Active = true
bb.LightInfluence = 0
local card = Instance.new("TextButton")
card.Size = UDim2.fromScale(1, 1)
card.Text = ""
card.AutoButtonColor = false
T.window(card)
card.BackgroundTransparency = 0.05
card.Parent = bb
local cardStroke = card:FindFirstChildOfClass("UIStroke")
local key = Instance.new("Frame")
key.Position = UDim2.fromOffset(7, 7)
key.Size = UDim2.fromOffset(32, 32)
key.BackgroundColor3 = C.rowSel
key.BorderSizePixel = 0
T.corner(key, 8)
T.stroke(key, C.acc, 1, 0.2)
key.Parent = card
T.label(key, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 14, TextColor3 = C.acc2, Text = keyName(prompt) })
local act = T.label(card, { Position = UDim2.fromOffset(46, 6), Size = UDim2.new(1, -54, 0, 17), TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, Text = prompt.ActionText })
local obj = T.label(card, { Position = UDim2.fromOffset(46, 23), Size = UDim2.new(1, -54, 0, 14), TextSize = 11, TextColor3 = C.dim, TextTruncate = Enum.TextTruncate.AtEnd, Text = prompt.ObjectText })
local track = Instance.new("Frame")
track.Position = UDim2.new(0, 8, 1, -5)
track.Size = UDim2.new(1, -16, 0, 2)
track.BackgroundColor3 = C.line
track.BorderSizePixel = 0
T.corner(track, 1)
track.Parent = card
local fill = T.accent(track, UDim2.new(0, 0, 0, 0), UDim2.fromScale(0, 1))
local b = { gui = bb, fill = fill, stroke = cardStroke, cons = {} }
b.cons[#b.cons + 1] = prompt:GetPropertyChangedSignal("ActionText"):Connect(function() act.Text = prompt.ActionText end)
b.cons[#b.cons + 1] = prompt:GetPropertyChangedSignal("ObjectText"):Connect(function() obj.Text = prompt.ObjectText end)
card.MouseButton1Down:Connect(function() pcall(function() prompt:InputHoldBegin() end) end)
card.MouseButton1Up:Connect(function() pcall(function() prompt:InputHoldEnd() end) end)
card.MouseLeave:Connect(function() pcall(function() prompt:InputHoldEnd() end) end)
bb.Parent = holder
boards[prompt] = b
end
PPS.PromptShown:Connect(function(prompt)
show(prompt)
task.defer(hideGame, prompt)
task.delay(0.1, hideGame, prompt)
end)
PPS.PromptHidden:Connect(hide)
PPS.PromptButtonHoldBegan:Connect(function(prompt)
local b = boards[prompt]
if b then fillTo(b, true, math.max(prompt.HoldDuration, 0.05)) end
end)
PPS.PromptButtonHoldEnded:Connect(function(prompt)
local b = boards[prompt]
if b then fillTo(b, false, 0.15) end
end)
PPS.PromptTriggered:Connect(function(prompt)
local b = boards[prompt]
if not b then return end
if b.stroke then
b.stroke.Color = C.green
task.delay(0.35, function() if b.stroke and b.stroke.Parent then b.stroke.Color = C.line end end)
end
fillTo(b, false, 0.2)
end)
end)
end
end
do
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")
local FILE = "Els_Keybinds.json"
local function letterKey(ch)
for _, kc in ipairs(Enum.KeyCode:GetEnumItems()) do
if #kc.Name == 1 and kc.Name:match("%u") then
local ok, s = pcall(UIS.GetStringForKeyCode, UIS, kc)
if ok and type(s) == "string" and s:upper() == ch then return kc.Name end
end
end
return ch
end
local DEFS = {
{ id = "Clone",       label = "Auto Clone",     key = "V" },
{ id = "CarpetSpeed", label = "Carpet Speed",   key = letterKey("Q") },
{ id = "InstaReset",  label = "Insta Reset",    key = "X" },
{ id = "Drop",        label = "Drop Brainrot",  key = "R" },
{ id = "Kick",        label = "Kick",           key = "Y" },
{ id = "Rejoin",      label = "Rejoin",         key = "Slash" },
{ id = "Exec",        label = "AJ (script)",    key = "J" },
}
local binds = {}
for _, d in ipairs(DEFS) do binds[d.id] = d.key end
local function validKey(name)
if name == "None" then return true end
if type(name) ~= "string" then return false end
local ok, kc = pcall(function() return Enum.KeyCode[name] end)
return ok and kc ~= nil
end
pcall(function()
if isfile and readfile and isfile(FILE) then
local d = HS:JSONDecode(readfile(FILE))
if type(d) == "table" then
for id, k in pairs(d) do
if binds[id] ~= nil and validKey(k) then binds[id] = k end
end
end
end
end)
local function save()
pcall(function() if writefile then writefile(FILE, HS:JSONEncode(binds)) end end)
end
local listeners = {}
local function changed() for _, f in ipairs(listeners) do pcall(f) end end
_G.Els_KeyCapturing = false
_G.Els_KeybindDefs = DEFS
_G.Els_Keybinds = binds
_G.Els_KeyIs = function(id, kc)
local k = binds[id]
return k ~= nil and k ~= "None" and kc ~= nil and kc.Name == k
end
_G.Els_KeyText = function(id)
local k = binds[id]
if not k or k == "None" then return "-" end
local ok, kc = pcall(function() return Enum.KeyCode[k] end)
if ok and kc then
local ok2, s = pcall(UIS.GetStringForKeyCode, UIS, kc)
if ok2 and type(s) == "string" and s:match("%S") then return s:upper() end
end
return k
end
_G.Els_SetKeybind = function(id, k)
if binds[id] == nil or not validKey(k) then return end
if k ~= "None" then
for other, v in pairs(binds) do
if other ~= id and v == k then binds[other] = "None" end
end
end
binds[id] = k
save(); changed()
end
_G.Els_ResetKeybinds = function()
for _, d in ipairs(DEFS) do binds[d.id] = d.key end
save(); changed()
end
_G.Els_OnKeybindChanged = function(f) listeners[#listeners + 1] = f end
end
do
local _AD,_MD,_TD
local function _data()
if _AD then return true end
local ok=pcall(function()
local d=game:GetService("ReplicatedStorage"):WaitForChild("Datas")
_AD=require(d:WaitForChild("Animals")); _MD=require(d:WaitForChild("Mutations")); _TD=require(d:WaitForChild("Traits"))
end)
return ok and _AD~=nil
end
_G._mynxxGen=function(index,mutation,traits)
if not _data() then return 0 end
local info=_AD[index]; if not info or not info.Generation then return 0 end
local mult=1
if mutation and mutation~="None" and mutation~="" then local m=_MD[mutation]; if m and m.Modifier then mult=mult+m.Modifier end end
if type(traits)=="table" then for _,tr in ipairs(traits)do local t=_TD[tr]; if t and t.MultiplierModifier then mult=mult+t.MultiplierModifier end end end
return info.Generation*mult
end
end
pcall(__elsStrip)
task.spawn(function()
local hooked = setmetatable({}, { __mode = "k" })
local function nuke(ch)
if ch and ch.Parent and _G.Els_KillKeepFloor then _G.Els_KillKeepFloor(ch) end
end
local function hookEvents(ev)
if hooked[ev] then return end
hooked[ev] = true
ev.ChildAdded:Connect(function(ch) task.defer(nuke, ch) end)
end
local LATE_KILL = {
"DiggingMachine",
{ "1x1x1x1Map", "Lab" },
{ "1x1x1x1Map", "ConveyorSystem" },
{ "1x1x1x1Map", "Computer Desk" },
{ "1x1x1x1Map", "WallExtension" },
{ "1x1x1x1Map", "TeleportHitbox" },
"Steps",
{ "SammyBase", "Lab" },
{ "SammyBase", "ConveyorSystem" },
{ "SammyBase", "Computer Desk" },
{ "SammyBase", "WallExtension" },
{ "SammyBase", "TeleportHitbox" },
}
local function killPath(folder, path, i)
for _, ch in ipairs(folder:GetChildren()) do
if ch.Name == path[i] then
if i == #path then nuke(ch) else killPath(ch, path, i + 1) end
end
end
end
while true do
if not _G.__Els_VelFlying then
local top = {}
local wk = workspace:GetChildren()
for i = 1, #wk do top[wk[i].Name] = true end
for _, entry in ipairs(LATE_KILL) do
local path = type(entry) == "table" and entry or { entry }
if top[path[1]] then pcall(killPath, workspace, path, 1) end
end
end
local ev = workspace:FindFirstChild("Events")
if ev then
hookEvents(ev)
if not _G.__Els_VelFlying then
for _, ch in ipairs(ev:GetChildren()) do nuke(ch) end
end
end
task.wait(2)
end
end)
do
local fn = __elsCoreFn or loadstring(SRC)
if fn then
local okCore, errCore = pcall(fn)
if not okCore then warn("[Els] core error: " .. tostring(errCore)) end
end
end
task.spawn(function()
task.wait(3)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TS = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer
local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 8)
if not pg then return end
local PS_PLACE_ID = 109983668079237
local PS_CODE_FILE   = "Els_PSCode.json"
local KICK_STATE_FILE = "Els_KickState.json"
local UTIL_POS_FILE  = "Els_UtilPos.json"
local PS_LINK_CODE = "57963013835087486111896053246959"
pcall(function()
if isfile and readfile and isfile(PS_CODE_FILE) then
local d = HS:JSONDecode(readfile(PS_CODE_FILE))
if type(d)=="table" and type(d.code)=="string" and #d.code>0 then PS_LINK_CODE=d.code end
end
end)
local autoKickOn = false
-- Els: auto kick mode, "ps" = join the private server, "instant" = direct Kick
local kickMode = "ps"
pcall(function()
if isfile and readfile and isfile(KICK_STATE_FILE) then
local d = HS:JSONDecode(readfile(KICK_STATE_FILE))
if type(d)=="table" and d.on==true then autoKickOn=true end
if type(d)=="table" and d.mode=="instant" then kickMode="instant" end
end
end)
local function saveKickState() pcall(function() writefile(KICK_STATE_FILE, HS:JSONEncode({on=autoKickOn, mode=kickMode})) end) end
local autoKickFired, kickConn = false, nil
local function joinPS()
if not pcall(function() game:GetService("ExperienceService"):LaunchExperience({ placeId = PS_PLACE_ID, linkCode = PS_LINK_CODE }) end) then
pcall(function() LP:Kick("") end)
end
end
-- Els fast auto kick: 3 triggers, the first one to fire wins (the 3rd is further down: delivery)
--  1) data: during a steal, as soon as my base (AnimalList) gains a brainrot -> kick
--     (fires before the message, which waits for its animation)
--  2) message: "You stole" / "Vous avez volé" (French game text), checked on creation AND one frame later
local kickConns = {}
local function kickLeave()
if kickMode == "instant" then
pcall(function() LP:Kick("") end)
else
joinPS()
end
end
local function kickFire()
if not autoKickOn or autoKickFired then return end
autoKickFired = true
-- in its own thread: leaving doesn't block the frame that triggered it
task.spawn(kickLeave)
end
-- 3) delivery: Stealing goes back to false while I'm in MY delivery zone
--    = steal delivered, often before AnimalList is updated
local CollectionService = game:GetService("CollectionService")
local function inMyDelivery()
local name = _G.__Els_MyPlot
local plots = workspace:FindFirstChild("Plots")
local plot = plots and name and plots:FindFirstChild(tostring(name))
local char = LP.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
if not (plot and hrp) then return false end
local boxes = {}
for _, b in ipairs(CollectionService:GetTagged("PlotDeliveryHitbox")) do
if b:IsA("BasePart") and b:IsDescendantOf(plot) then boxes[#boxes + 1] = b end
end
if #boxes == 0 then
local b = plot:FindFirstChild("DeliveryHitbox", true)
if b and b:IsA("BasePart") then boxes[1] = b end
end
for _, b in ipairs(boxes) do
local rel = b.CFrame:PointToObjectSpace(hrp.Position)
local half = b.Size / 2 + Vector3.new(4, 6, 4)
if math.abs(rel.X) <= half.X and math.abs(rel.Y) <= half.Y and math.abs(rel.Z) <= half.Z then
return true
end
end
return false
end
local function stealText(t)
if type(t) ~= "string" or t == "" then return false end
local l = string.lower(t)
return string.find(l, "you stole", 1, true) ~= nil or string.find(l, "vous avez vol", 1, true) ~= nil
end
local function checkGui(gui)
if autoKickFired or not gui.Parent then return end
if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and stealText(gui.Text) then kickFire() end
end
local function myCount()
local name = _G.__Els_MyPlot
if not name or not _G.XenSyncGet or not _G.sProp then return nil end
local ch = _G.XenSyncGet(tostring(name))
local list = ch and _G.sProp(ch, "AnimalList")
if type(list) ~= "table" then return nil end
local n = 0
for _, ad in pairs(list) do
if type(ad) == "table" then n = n + 1 end
end
return n
end
local function isStealing()
if LP:GetAttribute("Stealing") == true then return true end
local c = LP.Character
return c ~= nil and c:GetAttribute("Stealing") == true
end
local stealBase, armUntil = nil, 0
local function onStealChanged()
if isStealing() then
local ok, n = pcall(myCount)
stealBase = ok and n or nil
armUntil = math.huge
else
-- delivery sets Stealing back to false: keep watching for 2 more s
if armUntil == math.huge then
armUntil = os.clock() + 2
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
local alive = hum ~= nil and hum.Health > 0
if alive and autoKickOn and not autoKickFired then
local ok, inside = pcall(inMyDelivery)
if ok and inside then kickFire() end
end
end
end
end
local function hookCharSteal(c)
if c then kickConns[#kickConns + 1] = c:GetAttributeChangedSignal("Stealing"):Connect(onStealChanged) end
end
local function startAutoKick()
if kickConn then return end
autoKickFired = false
local pgui = LP:FindFirstChild("PlayerGui"); if not pgui then return end
kickConn = pgui.DescendantAdded:Connect(function(gui)
if not autoKickOn or autoKickFired then return end
checkGui(gui)
task.defer(checkGui, gui)
end)
kickConns[#kickConns + 1] = LP:GetAttributeChangedSignal("Stealing"):Connect(onStealChanged)
kickConns[#kickConns + 1] = LP.CharacterAdded:Connect(hookCharSteal)
hookCharSteal(LP.Character)
onStealChanged()
kickConns[#kickConns + 1] = RunService.Heartbeat:Connect(function()
if autoKickFired or not autoKickOn or os.clock() > armUntil then return end
local ok, n = pcall(myCount)
if not (ok and n) then return end
if stealBase == nil then stealBase = n return end
if n > stealBase then kickFire() end
end)
end
local function stopAutoKick()
if kickConn then pcall(function() kickConn:Disconnect() end); kickConn = nil end
for _, c in ipairs(kickConns) do pcall(function() c:Disconnect() end) end
kickConns = {}
stealBase, armUntil = nil, 0
end
local function kickError() pcall(function() LP:Kick("") end) end
_G.Els_KickError = kickError
_G.Els_JoinPS = joinPS
local wfConns, wfActive = {}, false
local function stopWF() wfActive=false; for _,c in ipairs(wfConns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end; wfConns={} end
local function doDrop()
if wfActive then return end
-- Els: holding a brainrot while invis -> turn the invis off first, then drop
-- (like Twilight: invis off, wait 0.1 s so the real root is back, then fling)
-- R = 1) invis off  2) wait until your real root is back in your character
-- 3) drop. Done whenever the invis is on (no Stealing check: the game can put
-- that attribute on the character instead of the player).
if _G.MeerkoInvisActive then
local stopped = false
if _G.Els_InvisOff then
stopped = select(2, pcall(_G.Els_InvisOff)) == true
elseif _G.Bels_StopInvisSteal then
pcall(_G.Bels_StopInvisSteal)
stopped = true
end
local t0 = os.clock()
while os.clock() - t0 < 0.6 do
local c = LP.Character
local inCam = false
for _, o in ipairs(workspace.CurrentCamera:GetChildren()) do
if o.Name == "HumanoidRootPart" and o:IsA("BasePart") then inCam = true break end
end
if not _G.MeerkoInvisActive and not inCam and c and c:FindFirstChild("HumanoidRootPart") then break end
RunService.Heartbeat:Wait()
end
-- a few physics frames so the server sees your real root before the drop
for _ = 1, 3 do RunService.Heartbeat:Wait() end
task.wait(0.1)
if wfActive then return end
end
wfActive = true
local ch = LP.Character; if not ch then wfActive=false; return end
local rr = ch:FindFirstChild("HumanoidRootPart")
for _,o in pairs(workspace.CurrentCamera:GetChildren()) do if o.Name=="HumanoidRootPart" then rr=o; break end end
if not rr then wfActive=false; return end
table.insert(wfConns, RunService.Stepped:Connect(function()
if not wfActive then return end
for _,p in ipairs(Players:GetPlayers()) do
if p ~= LP and p.Character then for _,pt in ipairs(p.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide=false end end end
end
end))
task.spawn(function()
while wfActive do
RunService.Heartbeat:Wait(); if not rr or not rr.Parent then break end
local v=rr.Velocity; rr.Velocity=v*10000+Vector3.new(0,10000,0)
RunService.RenderStepped:Wait(); if rr then rr.Velocity=v end
RunService.Stepped:Wait(); if rr then rr.Velocity=v+Vector3.new(0,0.1,0) end
end
end)
task.delay(0.4, stopWF)
end
_G.Els_DropBrainrot = doDrop
local function rejoin() pcall(function() TS:Teleport(game.PlaceId, LP) end) end
local resetBusy = false
local function doInstantReset()
if resetBusy then return end
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = hum and (hum.RootPart or char:FindFirstChild("HumanoidRootPart"))
if not char or not hum or hum.Health <= 0 or not root then return end
if _G.BelsResetEpoch then _G.BelsResetEpoch = _G.BelsResetEpoch + 1 end
_G.BelsResetting = true
if _G.Bels_CancelPendingPick then pcall(_G.Bels_CancelPendingPick) end
if _G.Bels_InvStealSet then pcall(_G.Bels_InvStealSet, false) end
if _G.Bels_StopInvisSteal then pcall(_G.Bels_StopInvisSteal) end
hum = char:FindFirstChildOfClass("Humanoid")
root = char:FindFirstChild("HumanoidRootPart") or (hum and hum.RootPart)
if not hum or not root then _G.BelsResetting = nil; return end
resetBusy = true
local antiDieBefore = _G.AntiDieDisabled; _G.AntiDieDisabled = true
local hipBefore, positionBefore = hum.HipHeight, root.CFrame
local hidden = {}
pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
task.spawn(function()
local camera = workspace.CurrentCamera
local frozen = camera and camera.CFrame
local oldType = camera and camera.CameraType
local bindName = "ElsInstantResetCamera"
local newCharacter
local addedConn
local spawnConn = LP.CharacterAdded:Connect(function(c) newCharacter = c end)
local function hide(obj)
if obj:IsA("BasePart") then hidden[obj] = obj.LocalTransparencyModifier; obj.LocalTransparencyModifier = 1
elseif obj:IsA("Decal") then hidden[obj] = obj.Transparency; obj.Transparency = 1 end
end
pcall(function()
camera.CameraType = Enum.CameraType.Scriptable
RunService:BindToRenderStep(bindName, Enum.RenderPriority.Camera.Value + 1, function()
if camera and frozen then camera.CFrame = frozen end
end)
for _, obj in ipairs(char:GetDescendants()) do hide(obj) end
addedConn = char.DescendantAdded:Connect(hide)
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("BasePart") then obj.Anchored = false; obj.CanCollide = false
elseif obj.Name == "SeatWeld" then obj:Destroy() end
end
end)
local started = os.clock()
while not newCharacter and os.clock() - started < 0.4 and hum.Parent do
pcall(function()
hum.PlatformStand = false; hum.Sit = false; hum.AutoRotate = true
hum.HipHeight = 1e30; root.Anchored = false
root.Velocity = Vector3.new(0, 50000, 0)
end)
RunService.Heartbeat:Wait()
end
if not newCharacter then
local floor = workspace.FallenPartsDestroyHeight
local voidStarted = os.clock()
while not newCharacter and os.clock() - voidStarted < 0.6 and root.Parent do
pcall(function() root.CFrame = CFrame.new(0, floor - 500, 0); root.Velocity = Vector3.new(0, -50000, 0) end)
RunService.Heartbeat:Wait()
end
end
while not newCharacter and os.clock() - started < 6 do
pcall(function() hum.Health = 0; hum:ChangeState(Enum.HumanoidStateType.Dead) end)
pcall(function() char:BreakJoints() end)
task.wait(0.1)
end
pcall(function() spawnConn:Disconnect() end)
if addedConn then pcall(function() addedConn:Disconnect() end) end
pcall(function() RunService:UnbindFromRenderStep(bindName) end)
pcall(function()
camera.CameraType = oldType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or oldType
local newHum = newCharacter and (newCharacter:FindFirstChildOfClass("Humanoid") or newCharacter:WaitForChild("Humanoid", 5))
if newHum then camera.CameraSubject = newHum end
end)
if not newCharacter and LP.Character == char and hum.Parent and hum.Health > 0 then
pcall(function() hum.HipHeight = hipBefore; root.CFrame = positionBefore; root.AssemblyLinearVelocity = Vector3.zero end)
for obj, value in pairs(hidden) do
pcall(function() if obj:IsA("BasePart") then obj.LocalTransparencyModifier = value else obj.Transparency = value end end)
end
end
_G.AntiDieDisabled = antiDieBefore
_G.BelsResetting = nil
resetBusy = false
end)
end
_G.Els_InstaReset = doInstantReset
local EXEC_FILE = "Els_Exec.lua"
local function execLoad()
if type(_G.Els_ExecScript)=="string" then return _G.Els_ExecScript end
local ok, src = pcall(function() return readfile(EXEC_FILE) end)
if ok and type(src)=="string" then _G.Els_ExecScript=src; return src end
return ""
end
local function doExec()
local src = execLoad()
if type(src)=="string" and #src>0 then
task.spawn(function() local fn,err=loadstring(src); if fn then pcall(fn) else warn("[AJ] "..tostring(err)) end end)
end
end
local T = _G.Els_Theme
local C = T.C
local old = pg:FindFirstChild("ElsUtilSquare"); if old then old:Destroy() end
local g = Instance.new("ScreenGui"); g.Name="ElsUtilSquare"; g.ResetOnSpawn=false; g.IgnoreGuiInset=true; g.Parent=pg
local UTIL_POS_FILE2 = "Els_UtilPos2.json"
local _posAll = {}
pcall(function()
if isfile and readfile and isfile(UTIL_POS_FILE2) then
local d = HS:JSONDecode(readfile(UTIL_POS_FILE2))
if type(d)=="table" then _posAll = d end
end
end)
local _saveQ = false
local function savePos()
if _saveQ then return end
_saveQ = true
task.delay(0.6, function()
_saveQ = false
pcall(function() writefile(UTIL_POS_FILE2, HS:JSONEncode(_posAll)) end)
end)
end
-- Els: each block is its own small window (draggable, position saved)
local function makeWin(id, text, w, y)
local f = Instance.new("Frame"); f.Name = "Els_"..id
f.Size = UDim2.fromOffset(w,0); f.AutomaticSize = Enum.AutomaticSize.Y
local p = _posAll[id]
if type(p)=="table" and tonumber(p.x) and tonumber(p.y) then
f.Position = UDim2.fromOffset(tonumber(p.x), tonumber(p.y))
else
f.Position = UDim2.new(0,16,0.5,y)
end
T.window(f); f.Active=true; f.Draggable=true; f.Parent=g
f:GetPropertyChangedSignal("Position"):Connect(function()
local ap = f.AbsolutePosition
_posAll[id] = { x = math.floor(ap.X), y = math.floor(ap.Y) }
savePos()
end)
local lay=Instance.new("UIListLayout", f); lay.Padding=UDim.new(0,6); lay.SortOrder=Enum.SortOrder.LayoutOrder
local pad=Instance.new("UIPadding", f); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10)
local tf=Instance.new("Frame", f); tf.Size=UDim2.new(1,0,0,20); tf.BackgroundTransparency=1; tf.LayoutOrder=0
T.accent(tf, UDim2.new(0,2,0,-8), UDim2.new(1,-4,0,2))
T.title(tf, text, 2, 0, 20)
return f, tf
end
local wAuto, title = makeWin("AutoKick", "AUTO KICK", 230, -225)
local wAJ      = makeWin("AJ",       "AJ",          200, -107)
local wRejoin  = makeWin("Rejoin",   "REJOIN / KICK", 200,  -23)
local panel = wAuto
local function style(b) return T.button(b) end
local row1=Instance.new("Frame", wAuto); row1.Size=UDim2.new(1,0,0,32); row1.BackgroundTransparency=1; row1.LayoutOrder=1
local bAuto=style(Instance.new("TextButton", row1)); bAuto.Size=UDim2.new(1,-40,1,0); bAuto.Position=UDim2.fromOffset(0,0)
local bEye=style(Instance.new("TextButton", row1)); bEye.Size=UDim2.fromOffset(32,32); bEye.Position=UDim2.new(1,-32,0,0); bEye.Text="👁"; bEye.TextColor3=C.dim
local function paintAuto() T.toggle(bAuto, autoKickOn, "Auto kick") end
local function toggleKick() autoKickOn=not autoKickOn; if autoKickOn then startAutoKick() else stopAutoKick() end; saveKickState(); paintAuto() end
paintAuto()
if autoKickOn then startAutoKick() end
bAuto.MouseButton1Click:Connect(toggleKick)
bAuto.MouseButton2Click:Connect(toggleKick)
-- Els: auto kick mode choice (PS / Instant)
local rowMode=Instance.new("Frame", wAuto); rowMode.Size=UDim2.new(1,0,0,28); rowMode.BackgroundTransparency=1; rowMode.LayoutOrder=2
local bModePS=style(Instance.new("TextButton", rowMode)); bModePS.Size=UDim2.new(0.5,-3,1,0); bModePS.Position=UDim2.fromOffset(0,0)
local bModeInst=style(Instance.new("TextButton", rowMode)); bModeInst.Size=UDim2.new(0.5,-3,1,0); bModeInst.Position=UDim2.new(0.5,3,0,0)
local function paintMode()
T.toggle(bModePS, kickMode=="ps"); bModePS.Text="Kick : PS"
T.toggle(bModeInst, kickMode=="instant"); bModeInst.Text="Kick : Instant"
bModePS.TextColor3 = kickMode=="ps" and C.txt or C.dim
bModeInst.TextColor3 = kickMode=="instant" and C.txt or C.dim
end
local function setMode(m) kickMode=m; saveKickState(); paintMode() end
bModePS.MouseButton1Click:Connect(function() setMode("ps") end)
bModeInst.MouseButton1Click:Connect(function() setMode("instant") end)
paintMode()
local edPS=Instance.new("Frame"); edPS.Size=UDim2.fromOffset(320,118); edPS.Position=UDim2.new(0,276,0.5,-59)
T.window(edPS); edPS.Visible=false; edPS.Active=true; edPS.Draggable=true; edPS.Parent=g
T.accent(edPS, UDim2.fromOffset(12,0), UDim2.new(1,-24,0,2))
T.title(edPS, "PS LINK CODE", 12, 8, 20)
local boxPS=Instance.new("TextBox", edPS); boxPS.Size=UDim2.new(1,-20,0,30); boxPS.Position=UDim2.fromOffset(10,36)
T.input(boxPS); boxPS.Font=Enum.Font.Code; boxPS.TextSize=11
boxPS.TextXAlignment=Enum.TextXAlignment.Left; boxPS.ClearTextOnFocus=false; boxPS.PlaceholderText="Private server link code"; boxPS.Text=PS_LINK_CODE
local bSavePS=T.button(Instance.new("TextButton", edPS),"primary"); bSavePS.Size=UDim2.new(0.5,-14,0,30); bSavePS.Position=UDim2.new(0,10,1,-40); bSavePS.Text="Save"
local bClosePS=T.button(Instance.new("TextButton", edPS)); bClosePS.Size=UDim2.new(0.5,-14,0,30); bClosePS.Position=UDim2.new(0.5,4,1,-40); bClosePS.Text="Close"
bSavePS.MouseButton1Click:Connect(function()
local code = boxPS.Text
if type(code)=="string" and #code>0 then
PS_LINK_CODE = code
pcall(function() writefile(PS_CODE_FILE, HS:JSONEncode({code=code})) end)
bSavePS.Text="✓ Saved"; task.delay(1.5, function() bSavePS.Text="Save" end)
end
end)
bClosePS.MouseButton1Click:Connect(function() edPS.Visible=false end)
bEye.MouseButton1Click:Connect(function() boxPS.Text=PS_LINK_CODE; edPS.Visible=not edPS.Visible end)
local bRejoin=style(Instance.new("TextButton", wRejoin)); bRejoin.Size=UDim2.new(1,0,0,32); bRejoin.Text="Rejoin"; bRejoin.LayoutOrder=1
bRejoin.MouseButton1Click:Connect(rejoin)
local bKick=T.button(Instance.new("TextButton", wRejoin),"danger"); bKick.Size=UDim2.new(1,0,0,32); bKick.Text="KICK"; bKick.LayoutOrder=2
bKick.MouseButton1Click:Connect(kickError)
local row4=Instance.new("Frame", wAJ); row4.Size=UDim2.new(1,0,0,32); row4.BackgroundTransparency=1; row4.LayoutOrder=1
local bAJ=style(Instance.new("TextButton", row4)); bAJ.Size=UDim2.new(1,-40,1,0); bAJ.Position=UDim2.fromOffset(0,0); bAJ.Text="AJ"
bAJ.MouseButton1Click:Connect(doExec)
local bGear=style(Instance.new("TextButton", row4)); bGear.Size=UDim2.fromOffset(32,32); bGear.Position=UDim2.new(1,-32,0,0); bGear.Text="SET"; bGear.TextSize=10; bGear.TextColor3=C.dim
local ed=Instance.new("Frame"); ed.Size=UDim2.fromOffset(360,260); ed.Position=UDim2.new(0,276,0.5,-130)
T.window(ed); ed.Visible=false; ed.Active=true; ed.Draggable=true; ed.Parent=g
T.accent(ed, UDim2.fromOffset(12,0), UDim2.new(1,-24,0,2))
T.title(ed, "AJ SCRIPT", 12, 8, 20)
local box=Instance.new("TextBox", ed); box.Size=UDim2.new(1,-20,1,-86); box.Position=UDim2.fromOffset(10,36)
T.input(box); box.Font=Enum.Font.Code; box.TextSize=11
box.TextXAlignment=Enum.TextXAlignment.Left; box.TextYAlignment=Enum.TextYAlignment.Top; box.ClearTextOnFocus=false; box.MultiLine=true; box.TextWrapped=true
box.PlaceholderText="-- paste your script (AJ button / J key runs it)"; box.Text=""
local bSave=T.button(Instance.new("TextButton", ed),"primary"); bSave.Size=UDim2.new(0.5,-14,0,32); bSave.Position=UDim2.new(0,10,1,-42); bSave.Text="Save"
local bClose=T.button(Instance.new("TextButton", ed)); bClose.Size=UDim2.new(0.5,-14,0,32); bClose.Position=UDim2.new(0.5,4,1,-42); bClose.Text="Close"
bSave.MouseButton1Click:Connect(function()
_G.Els_ExecScript=box.Text; pcall(function() writefile(EXEC_FILE, box.Text) end)
bSave.Text="✓ Saved"; task.delay(1.5, function() bSave.Text="Save" end)
end)
bClose.MouseButton1Click:Connect(function() ed.Visible=false end)
bGear.MouseButton1Click:Connect(function() box.Text=execLoad(); ed.Visible=not ed.Visible end)
local bKeys=T.button(Instance.new("TextButton", title))
bKeys.Size=UDim2.fromOffset(20,20); bKeys.Position=UDim2.new(1,-20,0,0)
bKeys.Text="⚙"; bKeys.TextSize=14; bKeys.TextColor3=C.dim
local DEFS = _G.Els_KeybindDefs or {}
local KB_W, KB_TOP, KB_GAP = 250, 52, 34
local footY = KB_TOP + (#DEFS + 1)*KB_GAP + 2
local kb=Instance.new("Frame"); kb.Size=UDim2.fromOffset(KB_W, footY + 30 + 12)
T.window(kb); kb.Visible=false; kb.Active=true; kb.Draggable=true; kb.Parent=g
T.accent(kb, UDim2.fromOffset(12,0), UDim2.new(1,-24,0,2))
T.title(kb, "KEYBINDS", 12, 8, 20)
T.label(kb,{Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,14),Font=Enum.Font.GothamMedium,TextSize=10,TextColor3=C.dim,
Text="Click + key  •  Esc: cancel  •  Backspace: none"})
local keyBtns, listening = {}, nil
local function paintKeys()
local txt = _G.Els_KeyText
for id, b in pairs(keyBtns) do
if listening == id then
b.Text="..."; T.toggle(b, true)
else
b.Text=txt and txt(id) or "?"; T.toggle(b, false)
end
end
end
local function stopListen()
listening=nil
task.delay(0.05, function() if not listening then _G.Els_KeyCapturing=false end end)
paintKeys()
end
for i, d in ipairs(DEFS) do
local row=Instance.new("Frame", kb); row.Size=UDim2.new(1,-24,0,28); row.Position=UDim2.fromOffset(12, KB_TOP+(i-1)*KB_GAP)
row.BackgroundTransparency=1
T.label(row,{Size=UDim2.new(1,-90,1,0),Text=d.label,Font=Enum.Font.GothamMedium,TextSize=12})
local kbtn=T.button(Instance.new("TextButton", row)); kbtn.Size=UDim2.fromOffset(80,28); kbtn.Position=UDim2.new(1,-80,0,0)
keyBtns[d.id]=kbtn
kbtn.MouseButton1Click:Connect(function()
if listening==d.id then stopListen(); return end
listening=d.id; _G.Els_KeyCapturing=true; paintKeys()
end)
end
do
local row=Instance.new("Frame", kb); row.Size=UDim2.new(1,-24,0,28); row.Position=UDim2.fromOffset(12, KB_TOP+#DEFS*KB_GAP)
row.BackgroundTransparency=1
T.label(row,{Size=UDim2.new(1,-150,1,0),Text="Carpet",Font=Enum.Font.GothamMedium,TextSize=12})
local cb=T.button(Instance.new("TextButton", row)); cb.Size=UDim2.fromOffset(140,28); cb.Position=UDim2.new(1,-140,0,0)
cb.TextSize=11; cb.TextTruncate=Enum.TextTruncate.AtEnd
local function owned(n)
local ch, bp = LP.Character, LP:FindFirstChild("Backpack")
return (ch and ch:FindFirstChild(n)) or (bp and bp:FindFirstChild(n))
end
local function paintCarpet()
local n=_G.Els_CarpetChoice or "?"
cb.Text=n
cb.TextColor3=owned(n) and C.txt or C.dim
end
local function step(dir)
local all=_G.Els_CarpetAll or {}
if #all==0 or not _G.Els_SetCarpet then return end
local i=table.find(all,_G.Els_CarpetChoice) or 1
i=((i-1+dir)%#all)+1
_G.Els_SetCarpet(all[i], true)
paintCarpet()
end
cb.MouseButton1Click:Connect(function() step(1) end)
cb.MouseButton2Click:Connect(function() step(-1) end)
kb:GetPropertyChangedSignal("Visible"):Connect(function() if kb.Visible then paintCarpet() end end)
paintCarpet()
end
local bDef=T.button(Instance.new("TextButton", kb)); bDef.Size=UDim2.new(0.5,-16,0,30); bDef.Position=UDim2.fromOffset(12, footY); bDef.Text="Defaults"
local bKbClose=T.button(Instance.new("TextButton", kb)); bKbClose.Size=UDim2.new(0.5,-16,0,30); bKbClose.Position=UDim2.new(0.5,4,0,footY); bKbClose.Text="Close"
bDef.MouseButton1Click:Connect(function()
if listening then stopListen() end
if _G.Els_ResetKeybinds then _G.Els_ResetKeybinds() end
end)
bKbClose.MouseButton1Click:Connect(function() if listening then stopListen() end; kb.Visible=false end)
bKeys.MouseButton1Click:Connect(function()
if kb.Visible then
if listening then stopListen() end
kb.Visible=false
return
end
local ap, as = panel.AbsolutePosition, panel.AbsoluteSize
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
local x = ap.X + as.X + 10
if x + KB_W > vp.X then x = math.max(0, ap.X - KB_W - 10) end
kb.Position=UDim2.fromOffset(x, ap.Y)
paintKeys()
kb.Visible=true
end)
UIS.InputBegan:Connect(function(input)
if not listening then return end
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
local kc, id = input.KeyCode, listening
if kc == Enum.KeyCode.Escape or kc == Enum.KeyCode.Unknown then
elseif kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
if _G.Els_SetKeybind then _G.Els_SetKeybind(id, "None") end
else
if _G.Els_SetKeybind then _G.Els_SetKeybind(id, kc.Name) end
end
stopListen()
end)
if _G.Els_OnKeybindChanged then _G.Els_OnKeybindChanged(paintKeys) end
paintKeys()
UIS.InputBegan:Connect(function(input, gpe)
if gpe or _G.Els_KeyCapturing then return end
if UIS:GetFocusedTextBox() then return end
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
local is = _G.Els_KeyIs
if type(is) ~= "function" then return end
local kc = input.KeyCode
if is("Drop", kc) then task.spawn(doDrop)
elseif is("Rejoin", kc) then task.spawn(rejoin)
elseif is("Exec", kc) then task.spawn(doExec)
elseif is("InstaReset", kc) then task.spawn(doInstantReset) end
end)
end)
do
local function appliquer()
local fn = (getgenv and getgenv().setfflag) or setfflag or setfastflag
if type(fn)~="function" then return end
-- Els: no more gray/beige sky at load (it stays set for the whole Roblox session, so force it off)
if not pcall(fn,"FFlagDebugSkyGray","False") then pcall(fn,"DebugSkyGray","False") end
end
appliquer()
for _,t in ipairs({1,3,8}) do task.delay(t, appliquer) end
task.spawn(function() if not game:IsLoaded() then game.Loaded:Wait() end appliquer() end)
end
task.spawn(function()
local LP=game:GetService("Players").LocalPlayer
local HS=game:GetService("HttpService")
local pg=LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui",8); if not pg then return end
local old=pg:FindFirstChild("ElsStealTargetWin"); if old then old:Destroy() end
local g=Instance.new("ScreenGui"); g.Name="ElsStealTargetWin"; g.ResetOnSpawn=false; g.IgnoreGuiInset=true; g.Parent=pg
local T=_G.Els_Theme; local C=T.C; local label, corner, stroke, hex = T.label, T.corner, T.stroke, T.hex
local MUT={eclipse={255,170,90},crystal={150,230,255},phantom={200,200,255},bloodrot={225,70,70},cyber={90,190,255},
divine={255,240,180},cursed={175,90,255},yinyang={255,150,40},radioactive={130,255,90},galaxy={160,130,255},
lava={255,95,40},candy={255,120,200},rainbow={255,120,200},diamond={90,220,255},gold={255,210,60}}
local RANK={Color3.fromRGB(255,200,70),Color3.fromRGB(205,210,222),Color3.fromRGB(215,140,85)}
local function mutName(m) m=tostring(m or ""); local l=m:lower(); return (l=="normal" or l=="none") and "" or m end
local function mutColor(m) local c=MUT[(m:lower():gsub("[%s%-_]",""))]; return c and Color3.fromRGB(c[1],c[2],c[3]) or Color3.fromRGB(192,208,224) end
local function money(n)
n=tonumber(n); if not n or n~=n or n<0 or n==math.huge then return "--/s" end
for _,u in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do if n>=u[1] then return string.format("%.1f%s/s",n/u[1],u[2]) end end
return string.format("%d/s",math.floor(n+0.5))
end
local TRA_IC,TRA_ICL={},{}
task.spawn(function()
pcall(function()
local d=require(game:GetService("ReplicatedStorage"):WaitForChild("Datas",15):WaitForChild("Traits",15))
if type(d)~="table" then return end
for n,v in pairs(d) do
if type(v)=="table" and v.Icon then
local s=tostring(v.Icon); s=s:match("^%d+$") and ("rbxassetid://"..s) or s
TRA_IC[n]=s; TRA_ICL[string.lower(tostring(n))]=s
end
end
end)
end)
local TR_SZ,TR_GAP,TR_MAX=15,2,4
local function traitIcons(p)
local out={}
if type(p.traits)=="table" then
for _,tv in ipairs(p.traits) do
local tn=(type(tv)=="string" and tv) or (type(tv)=="table" and (tv.Name or tv.name or tv.Trait or tv.Id)) or nil
local ic=type(tn)=="string" and (TRA_IC[tn] or TRA_ICL[string.lower(tn)]) or nil
if ic then out[#out+1]=ic end
end
end
return out
end
local function mkTraits(parent,props)
local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.BorderSizePixel=0
f.Size=UDim2.fromOffset(TR_MAX*TR_SZ+(TR_MAX-1)*TR_GAP,16)
for k,v in pairs(props) do f[k]=v end
local l=Instance.new("UIListLayout",f); l.FillDirection=Enum.FillDirection.Horizontal; l.SortOrder=Enum.SortOrder.LayoutOrder
l.HorizontalAlignment=Enum.HorizontalAlignment.Right; l.VerticalAlignment=Enum.VerticalAlignment.Center; l.Padding=UDim.new(0,TR_GAP)
for k=1,TR_MAX do
local im=Instance.new("ImageLabel",f); im.Name="T"..k; im.LayoutOrder=k; im.Size=UDim2.fromOffset(TR_SZ,TR_SZ)
im.BackgroundTransparency=1; im.BorderSizePixel=0; im.Visible=false
end
f.Parent=parent
return f
end
local function setTraits(f,icons)
for k=1,TR_MAX do
local im=f:FindFirstChild("T"..k)
if im then im.Image=icons[k] or ""; im.Visible=icons[k]~=nil end
end
local n=math.min(#icons,TR_MAX)
return n>0 and (n*TR_SZ+(n-1)*TR_GAP+6) or 0
end
local floorCache={}
local function floorOf(plot,slot)
local key=tostring(plot).."|"..tostring(slot)
if floorCache[key] then return floorCache[key] end
local ok,y=pcall(function()
local pod=workspace.Plots[tostring(plot)].AnimalPodiums[tostring(slot)]
local sp=pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
return ((sp and sp:IsA("BasePart") and sp) or pod:FindFirstChildWhichIsA("BasePart",true)).Position.Y
end)
if not ok or not y then return nil end
floorCache[key]=(y>23.15 and 3) or (y>=11 and 2) or 1
return floorCache[key]
end
local function details(p, withMut)
local t={}
local m=mutName(p.mutation)
if withMut and m~="" then t[#t+1]="<font color=\""..hex(mutColor(m)).."\">"..m.."</font>" end
local f=floorOf(p.plot,p.slot); if f then t[#t+1]="Floor "..f end
if p.slot~=nil then t[#t+1]="Slot "..tostring(p.slot) end
return table.concat(t,"  ·  ")
end
local function plainBtn(parent,props)
local b=Instance.new("TextButton"); b.AutoButtonColor=false; b.BorderSizePixel=0; b.Text=""
b.Font=Enum.Font.GothamBold; b.TextSize=12; b.TextColor3=C.txt
for k,v in pairs(props) do b[k]=v end
b.Parent=parent; return b
end
local ST_SCALE=1.3 -- steal target window scale (button keeps 1.15)
local btn=plainBtn(g,{Size=UDim2.fromOffset(140,28),Position=UDim2.new(1,-180,0,18),BackgroundColor3=C.bg,Active=true,Draggable=true})
do local s=Instance.new("UIScale"); s.Scale=1.15; s.Parent=btn end
corner(btn,14); stroke(btn,C.acc,1.2,0.2)
local bDot=Instance.new("Frame",btn); bDot.Size=UDim2.fromOffset(8,8); bDot.Position=UDim2.fromOffset(14,10); bDot.BackgroundColor3=C.acc; bDot.BorderSizePixel=0; corner(bDot,4)
label(btn,{Size=UDim2.new(1,-34,1,0),Position=UDim2.fromOffset(28,0),Text="STEAL TARGET"})
local W_W, W_H, HEAD = 280, 410, 40
local stW=Instance.new("Frame"); stW.Size=UDim2.fromOffset(W_W,W_H); stW.Position=UDim2.new(1,-470,0,56)
T.window(stW); stW.Active=true; stW.Draggable=true; stW.ClipsDescendants=true; stW.Parent=g
-- steal target background image
-- works with an Image id OR a Decal id (a Decal id is converted to its image id)
do
local BG_ID = 102090190918246
g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- children always draw above the window background
local bgImg=Instance.new("ImageLabel"); bgImg.Name="ElsBgImage"
bgImg.Size=UDim2.fromScale(1,1); bgImg.Position=UDim2.fromOffset(0,0)
bgImg.BackgroundTransparency=1; bgImg.BorderSizePixel=0
bgImg.ScaleType=Enum.ScaleType.Crop; bgImg.ImageTransparency=0.45
bgImg.ZIndex=0; corner(bgImg,12); bgImg.Parent=stW
task.spawn(function()
local CP = game:GetService("ContentProvider")
local function loads(url)
local done, okStatus = false, false
task.spawn(function()
pcall(function()
CP:PreloadAsync({ url }, function(_, status) okStatus = (status == Enum.AssetFetchStatus.Success) end)
end)
done = true
end)
local t0 = os.clock()
while not done and os.clock() - t0 < 6 do task.wait(0.1) end
return okStatus
end
-- 1) local file in the executor workspace folder (no Roblox upload / moderation needed)
local gca = getcustomasset or (getsynasset)
if type(gca) == "function" and isfile then
for _, f in ipairs({ "Els_StealBg.png", "Els_StealBg.jpg", "Els_StealBg.jpeg" }) do
local okF, has = pcall(isfile, f)
if okF and has then
local okA, url = pcall(gca, f)
if okA and type(url) == "string" then
bgImg.Image = url
print("[ELS] steal target background: using local file " .. f)
return
end
end
end
end
-- 2) Roblox asset: Decal id -> its image id, then the id itself and the usual offsets
local cands = {}
pcall(function()
local objs = game:GetObjects("rbxassetid://" .. BG_ID)
local d = objs and objs[1]
if d and (d:IsA("Decal") or d:IsA("Texture")) and d.Texture ~= "" then cands[#cands+1] = d.Texture end
end)
for k = 0, 4 do cands[#cands+1] = "rbxassetid://" .. (BG_ID - k) end
for _, url in ipairs(cands) do
if loads(url) then
bgImg.Image = url
print("[ELS] steal target background: loaded " .. url)
return
end
end
bgImg.Image = "rbxassetid://" .. BG_ID
warn("[ELS] steal target background: image " .. BG_ID .. " did not load (not approved yet, or not an image/decal id). Put Els_StealBg.png in the executor workspace folder instead.")
end)
end
do local s=Instance.new("UIScale"); s.Scale=ST_SCALE; s.Parent=stW end
do
local file="Els_StealTargetPos.json"
pcall(function()
if not (isfile and readfile and isfile(file)) then return end
local d=HS:JSONDecode(readfile(file))
local x,y=tonumber(d.x),tonumber(d.y)
if x and y and math.abs(x)<=10000 and math.abs(y)<=10000 then stW.Position=UDim2.new(tonumber(d.xs) or 0,x,tonumber(d.ys) or 0,y) end
end)
local queued=false
local function save() return pcall(function() local p=stW.Position; writefile(file,HS:JSONEncode({xs=p.X.Scale,x=p.X.Offset,ys=p.Y.Scale,y=p.Y.Offset})) end) end
_G.Els_SaveStealTargetPosition=save
stW:GetPropertyChangedSignal("Position"):Connect(function()
if queued then return end; queued=true
task.delay(0.3,function() queued=false; save() end)
end)
end
T.accent(stW,UDim2.fromOffset(12,0),UDim2.new(1,-24,0,2))
T.title(stW,"STEAL TARGET",14,0,HEAD)
local count=label(stW,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-40,0,10),Size=UDim2.fromOffset(0,20),AutomaticSize=Enum.AutomaticSize.X,
BackgroundTransparency=0,BackgroundColor3=C.bg2,TextSize=11,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center,Text="0"})
corner(count,10)
do local p=Instance.new("UIPadding",count); p.PaddingLeft=UDim.new(0,9); p.PaddingRight=UDim.new(0,9) end
local bMin=plainBtn(stW,{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-32,0,9),BackgroundColor3=C.bg2,TextSize=14,TextColor3=C.dim,Text="–"})
corner(bMin,6)
local card=Instance.new("Frame",stW); card.Size=UDim2.new(1,-20,0,50); card.Position=UDim2.fromOffset(10,HEAD)
card.BackgroundColor3=C.bg2; card.BorderSizePixel=0; corner(card,9)
local cStroke=stroke(card,C.line,1)
local tag=label(card,{Position=UDim2.fromOffset(10,7),Size=UDim2.fromOffset(0,16),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=0,
BackgroundColor3=C.acc2,TextSize=9,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center,Text="AUTO"})
corner(tag,8)
do local p=Instance.new("UIPadding",tag); p.PaddingLeft=UDim.new(0,7); p.PaddingRight=UDim.new(0,7) end
local cName=label(card,{Position=UDim2.fromOffset(10,26),Size=UDim2.new(1,-100,0,18),TextSize=13,TextTruncate=Enum.TextTruncate.AtEnd,Text="—"})
local cInfo=label(card,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,7),Size=UDim2.fromOffset(180,16),TextSize=10,
TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right,RichText=true})
local cGen=label(card,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,26),Size=UDim2.fromOffset(90,18),TextSize=13,
TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Right})
local cTraits=mkTraits(card,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-104,0,27)})
local LIST_Y=HEAD+58
local sc=Instance.new("ScrollingFrame",stW); sc.Size=UDim2.new(1,-14,1,-(LIST_Y+54)); sc.Position=UDim2.fromOffset(10,LIST_Y)
sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.ScrollBarThickness=3; sc.ScrollBarImageColor3=C.acc
sc.CanvasSize=UDim2.new(); sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; sc.ScrollingDirection=Enum.ScrollingDirection.Y
local scl=Instance.new("UIListLayout",sc); scl.SortOrder=Enum.SortOrder.LayoutOrder; scl.Padding=UDim.new(0,5)
do local p=Instance.new("UIPadding",sc); p.PaddingRight=UDim.new(0,6); p.PaddingTop=UDim.new(0,1) end
local empty=label(stW,{Position=UDim2.fromOffset(10,LIST_Y+30),Size=UDim2.new(1,-20,0,40),TextColor3=C.dim,TextSize=11,Font=Enum.Font.GothamMedium,
TextXAlignment=Enum.TextXAlignment.Center,Text="No priority brainrots in this server",Visible=false})
local bNear=plainBtn(stW,{Size=UDim2.new(1,-20,0,34),Position=UDim2.new(0,10,1,-44),BackgroundColor3=C.rowSel,Text="STEAL NEAREST"})
corner(bNear,8); stroke(bNear,C.acc,1,0.2)
_G.Els_NearestBtn=bNear
local collapsed=false
bMin.MouseButton1Click:Connect(function()
collapsed=not collapsed
bMin.Text=collapsed and "+" or "–"
stW.Size=UDim2.fromOffset(W_W,collapsed and HEAD or W_H)
card.Visible, sc.Visible, bNear.Visible = not collapsed, not collapsed, not collapsed
if collapsed then empty.Visible=false end
end)
local selKey, rows, rowPets, refresh = nil, {}, {}, nil
local function makeRow(key)
local row=plainBtn(sc,{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.row}); corner(row,9)
local st=stroke(row,C.acc,1.2,1); st.Name="Stroke"
local bar=Instance.new("Frame",row); bar.Name="Bar"; bar.Size=UDim2.fromOffset(3,22); bar.Position=UDim2.new(0,0,0.5,-11)
bar.BackgroundColor3=C.acc; bar.BorderSizePixel=0; bar.Visible=false; corner(bar,2)
local badge=Instance.new("Frame",row); badge.Name="Badge"; badge.Size=UDim2.fromOffset(26,26); badge.Position=UDim2.new(0,9,0.5,-13)
badge.BackgroundColor3=C.bg2; badge.BorderSizePixel=0; corner(badge,7); stroke(badge,C.line,1).Name="Stroke"
label(badge,{Name="Num",Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center,TextSize=11,TextColor3=C.dim})
label(row,{Name="PetName",Position=UDim2.fromOffset(44,6),Size=UDim2.new(1,-54,0,18),TextTruncate=Enum.TextTruncate.AtEnd})
label(row,{Name="Sub",Position=UDim2.fromOffset(44,23),Size=UDim2.new(1,-54,0,15),TextSize=11,RichText=true})
mkTraits(row,{Name="Traits",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-9,0,7)})
local pill=label(row,{Name="Mut",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-9,0,7),Size=UDim2.fromOffset(0,16),
AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=0.82,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center})
corner(pill,8)
do local p=Instance.new("UIPadding",pill); p.PaddingLeft=UDim.new(0,7); p.PaddingRight=UDim.new(0,7) end
row.Activated:Connect(function()
local pet=rowPets[key]; if not pet then return end
if selKey==key then
if _G.Els_StealTargetClear then pcall(_G.Els_StealTargetClear) end
else
local ok,accepted=pcall(_G.Els_StealTargetPick,pet.plot,pet.slot,pet.index,true)
if not ok or not accepted then warn("[Els] This target is no longer available.") end
end
refresh()
end)
return row
end
refresh=function()
local ok,pets=pcall(_G.Els_StealTargetList)
if not ok or type(pets)~="table" then return end
local manual=_G.Els_PendingTarget or (_G.Els_GetManualTarget and _G.Els_GetManualTarget())
selKey=manual and (tostring(manual.plot).."|"..tostring(manual.slot)) or nil
count.Text=#pets..(#pets==1 and " target" or " targets")
empty.Visible=(#pets==0) and not collapsed
local cur=manual or _G.Els_LastPet
if cur then
local curKey, full = tostring(cur.plot).."|"..tostring(cur.slot), nil
for _,p in ipairs(pets) do if tostring(p.plot).."|"..tostring(p.slot)==curKey then full=p break end end
tag.Text=manual and "LOCKED" or "AUTO"; tag.BackgroundColor3=manual and C.acc or C.acc2
cStroke.Color=manual and C.acc or C.line
cName.Text=tostring(cur.name or cur.index or "?")
cGen.Text=(full or cur).gen and money((full or cur).gen) or ""
cInfo.Text=details(full or cur,true)
local tw=setTraits(cTraits,traitIcons(full or cur))
cName.Size=UDim2.new(1,-(100+tw),0,18)
else
tag.Text="IDLE"; tag.BackgroundColor3=C.line; cStroke.Color=C.line
cName.Text="No target"; cGen.Text=""; cInfo.Text=""
setTraits(cTraits,{}); cName.Size=UDim2.new(1,-100,0,18)
end
local seen={}
for i,pet in ipairs(pets) do
local key=tostring(pet.plot).."|"..tostring(pet.slot)
seen[key]=true; rowPets[key]=pet
local row=rows[key] or makeRow(key); rows[key]=row
local sel=(key==selKey)
row.LayoutOrder=i
row.BackgroundColor3=sel and C.rowSel or C.row
row.Bar.Visible=sel; row.Stroke.Transparency=sel and 0.15 or 1
row.Badge.Num.Text=tostring(i); row.Badge.Num.TextColor3=RANK[i] or C.dim
row.Badge.Stroke.Color=RANK[i] or C.line
row.PetName.Text=tostring(pet.name or pet.index or "")
local d=details(pet,false)
row.Sub.Text="<font color=\""..hex(C.green).."\">"..money(pet.gen).."</font>"..(d~="" and ("  <font color=\""..hex(C.dim).."\">·  "..d.."</font>") or "")
local m=mutName(pet.mutation)
row.Mut.Visible=(m~="")
if m~="" then local mc=mutColor(m); row.Mut.Text=m:upper(); row.Mut.TextColor3=mc; row.Mut.BackgroundColor3=mc end
local mw=(m=="") and 0 or (row.Mut.AbsoluteSize.X/ST_SCALE)
local tw=setTraits(row.Traits,traitIcons(pet))
row.Traits.Position=UDim2.new(1,-(9+(mw>0 and mw+4 or 0)),0,7)
row.PetName.Size=UDim2.new(1,-(54+(mw>0 and mw+8 or 0)+tw),0,18)
end
for key,row in pairs(rows) do if not seen[key] then rowPets[key]=nil; rows[key]=nil; row:Destroy() end end
end
do
local last,token=-math.huge,0
bNear.Activated:Connect(function()
if os.clock()-last<0.2 then return end
last=os.clock(); token+=1; local stamp=token
local fn=_G.Els_StealNearestPrio
local ok,accepted=false,false
if type(fn)=="function" then ok,accepted=pcall(fn) end
if ok and accepted then
bNear.Text=_G.Els_PendingTarget and "TARGET PENDING" or "TARGET OK"; bNear.TextColor3=C.green
else
bNear.Text=type(fn)=="function" and "NO PRIORITY" or "LOADING..."; bNear.TextColor3=C.red
end
pcall(refresh)
task.delay(1.2,function() if stamp==token then bNear.Text="STEAL NEAREST"; bNear.TextColor3=C.txt end end)
end)
end
pcall(refresh)
btn.MouseButton1Click:Connect(function() stW.Visible=not stW.Visible; if stW.Visible then pcall(refresh) end end)
while g.Parent do task.wait(1); if stW.Visible then pcall(refresh) end end
end)
task.spawn(function()
task.wait(3)
local Players=game:GetService("Players"); local RunService=game:GetService("RunService"); local HS=game:GetService("HttpService")
local LP=Players.LocalPlayer
local W={on=false, v=27}
pcall(function() if isfile and readfile and isfile("Els_Walk.json") then local d=HS:JSONDecode(readfile("Els_Walk.json")); if type(d)=="table" then if type(d.on)=="boolean" then W.on=d.on end if tonumber(d.v) then W.v=math.clamp(math.floor(tonumber(d.v)+0.5),16,27) end end end end)
local function save() pcall(function() writefile("Els_Walk.json", HS:JSONEncode(W)) end) end
local LOOSE={[Enum.HumanoidStateType.Physics]=true,[Enum.HumanoidStateType.Ragdoll]=true,[Enum.HumanoidStateType.FallingDown]=true,[Enum.HumanoidStateType.Freefall]=true,[Enum.HumanoidStateType.Jumping]=true}
local function stealing() local v=LP:GetAttribute("Stealing"); if v==nil or v==false then local c=LP.Character; v=c and c:GetAttribute("Stealing") end return v~=nil and v~=false end
local wasMoving,resumeAt,persoVu=false,0,nil
task.spawn(function()
while true do
task.wait(W.on and 0.03 or 0.25)
if W.on then pcall(function()
local char=LP.Character
if char~=persoVu then persoVu=char; wasMoving,resumeAt=false,0 end
if typeof(getgenv)=="function" and getgenv().__AuroraSpeed then return end
if not W.on or not stealing() then return end
if _G.__Els_VelFlying or _G.__Els_TPStarted then return end
local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
if not(hrp and hum) or hum.Health<=0 then return end
local now=os.clock(); local md=hum.MoveDirection; local moving=md.Magnitude>=0.05
if wasMoving and not moving then resumeAt=now+0.08 end
wasMoving=moving
local vy=hrp.AssemblyLinearVelocity.Y
if now<resumeAt then hrp.AssemblyLinearVelocity=Vector3.new(0,vy,0); return end
local st=hum:GetState()
if not moving then
if st~=Enum.HumanoidStateType.Freefall and st~=Enum.HumanoidStateType.Jumping and not LOOSE[st] then hrp.AssemblyLinearVelocity=Vector3.new(0,vy,0) end
return
end
local u=md.Unit; local v=math.clamp(W.v,16,27)
hrp.AssemblyLinearVelocity=Vector3.new(u.X*v,vy,u.Z*v)
end) end
end
end)
task.spawn(function()
local pg=LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui",8); if not pg then return end
local old=pg:FindFirstChild("ElsWalk"); if old then old:Destroy() end
local gg=Instance.new("ScreenGui"); gg.Name="ElsWalk"; gg.ResetOnSpawn=false; gg.IgnoreGuiInset=true; gg.Parent=pg
local T=_G.Els_Theme
local C=T.C
local box=Instance.new("Frame"); box.Size=UDim2.fromOffset(180,124)
local WPOS_FILE = "Els_WalkPos.json"
local _wp
pcall(function() if isfile and readfile and isfile(WPOS_FILE) then local d=HS:JSONDecode(readfile(WPOS_FILE)); if type(d)=="table" and tonumber(d.x) and tonumber(d.y) then _wp=UDim2.fromOffset(tonumber(d.x),tonumber(d.y)) end end end)
box.Position = _wp or UDim2.new(0,16,0,16)
T.window(box); box.Active=true; box.Draggable=true; box.Parent=gg
do
local q=false
box:GetPropertyChangedSignal("Position"):Connect(function()
if q then return end
q=true
task.delay(0.6, function() q=false; pcall(function() local ap=box.AbsolutePosition; writefile(WPOS_FILE, HS:JSONEncode({x=math.floor(ap.X),y=math.floor(ap.Y)})) end) end)
end)
end
T.accent(box, UDim2.fromOffset(12,0), UDim2.new(1,-24,0,2))
local inv=T.button(Instance.new("TextButton",box)); inv.Size=UDim2.new(1,-20,0,30); inv.Position=UDim2.fromOffset(10,10)
local function paintInv() T.toggle(inv, _G.MeerkoInvisAuto==true, "INV STEAL") end
paintInv()
inv.MouseButton1Click:Connect(function()
local on = not (_G.MeerkoInvisAuto==true)
if _G.Els_InvStealSet then pcall(_G.Els_InvStealSet, on) else _G.MeerkoInvisAuto=on end
pcall(function() if _G.Els_AutoSave then _G.Els_AutoSave() end end)
paintInv()
end)
local tog=T.button(Instance.new("TextButton",box)); tog.Size=UDim2.new(1,-20,0,30); tog.Position=UDim2.fromOffset(10,46)
local function paintT() T.toggle(tog, W.on, "WALKSPEED") end
paintT(); tog.MouseButton1Click:Connect(function() W.on=not W.on; paintT(); save() end)
local UIS=game:GetService("UserInputService")
local W_MIN, W_MAX = 16, 27
T.label(box,{Position=UDim2.fromOffset(12,84),Size=UDim2.new(0.5,-12,0,14),Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=C.dim,Text="Speed"})
local lab=T.label(box,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,84),Size=UDim2.new(0.5,-12,0,14),TextSize=11,
TextXAlignment=Enum.TextXAlignment.Right})
local bar=Instance.new("TextButton",box); bar.Size=UDim2.new(1,-24,0,6); bar.Position=UDim2.fromOffset(12,106)
bar.Text=""; bar.AutoButtonColor=false; bar.BackgroundColor3=C.bg2; bar.BorderSizePixel=0
T.corner(bar,3); T.stroke(bar,C.line,1)
local fill=Instance.new("Frame",bar); fill.BackgroundColor3=Color3.new(1,1,1); fill.BorderSizePixel=0
T.corner(fill,3)
do local gr=Instance.new("UIGradient"); gr.Color=ColorSequence.new(C.acc,C.acc2); gr.Parent=fill end
local knob=Instance.new("Frame",bar); knob.Size=UDim2.fromOffset(12,12); knob.AnchorPoint=Vector2.new(0.5,0.5)
knob.BackgroundColor3=C.txt; knob.BorderSizePixel=0; knob.ZIndex=2; T.corner(knob,6); T.stroke(knob,C.acc,1.5)
local function paintV()
W.v=math.clamp(math.floor((tonumber(W.v) or W_MAX)+0.5),W_MIN,W_MAX)
local rel=(W.v-W_MIN)/(W_MAX-W_MIN)
fill.Size=UDim2.new(rel,0,1,0)
knob.Position=UDim2.new(rel,0,0.5,0)
lab.Text=tostring(W.v)
end
paintV()
local dragging=false
local function fromX(x)
local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)
W.v=W_MIN+(W_MAX-W_MIN)*rel
paintV()
end
bar.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=true; fromX(i.Position.X)
end
end)
UIS.InputChanged:Connect(function(i)
if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
fromX(i.Position.X)
end
end)
UIS.InputEnded:Connect(function(i)
if dragging and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
dragging=false; save()
end
end)
end)
end)
_G.MeerkoAntiRagdollAncien = true
_G.MeerkoAntiRagdollEnabled = true
_G.MeerkoAntiKnockbackEnabled = true
if _G.AntiDieDisabled == nil then _G.AntiDieDisabled = false end
task.spawn(function()
local __P = game:GetService("Players")
while not __P.LocalPlayer do task.wait() end
local okAD, errAD = pcall(function()
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local LP         = Players.LocalPlayer
local antiRagdollConnections = {}
local antiRagdollCharacter, antiRagdollHumanoid, antiRagdollRootPart, antiRagdollAnimator
local lastVelocity = Vector3.new(0, 0, 0)
local velocityChangeThreshold = 40
local velocityMagnitudeThreshold = 25
local maxVelocity = 15
local function isFlyingCarpetActive()
if not antiRagdollCharacter then return false end
local tool = antiRagdollCharacter:FindFirstChildWhichIsA("Tool")
if not tool then return false end
local hrp = antiRagdollCharacter:FindFirstChild("HumanoidRootPart")
if hrp then
for _, obj in ipairs(hrp:GetChildren()) do
if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
return true
end
end
end
return false
end
local function ragdollTimerActif()
local et = tonumber(LP:GetAttribute("RagdollEndTime"))
return et ~= nil and (et - Workspace:GetServerTimeNow()) > 0
end
local function isRagdolled()
if not antiRagdollHumanoid then return false end
local state = antiRagdollHumanoid:GetState()
return state == Enum.HumanoidStateType.Physics
or state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.FallingDown
or state == Enum.HumanoidStateType.GettingUp
or ragdollTimerActif()
end
local _lastCtl = 0
local function enableAntiRagdollControls()
local tc = os.clock()
if tc - _lastCtl < 0.5 then return end
_lastCtl = tc
pcall(function()
local PlayerModule = LP:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
require(PlayerModule):GetControls():Enable()
end)
end
local _lastCleanup = 0
local function cleanupRagdoll()
if not antiRagdollCharacter then return end
local tc = os.clock()
if tc - _lastCleanup < 0.08 then return end
_lastCleanup = tc
local carpetEquipped = isFlyingCarpetActive()
local function processChildren(parent)
for _, obj in ipairs(parent:GetChildren()) do
if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
or (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B")) then
obj:Destroy()
elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
if not carpetEquipped then obj:Destroy() end
elseif obj:IsA("Motor6D") then
obj.Enabled = true
elseif obj:IsA("BasePart") then
for _, child in ipairs(obj:GetChildren()) do
if child:IsA("Motor6D") then
child.Enabled = true
elseif child:IsA("BallSocketConstraint") or child:IsA("NoCollisionConstraint") or child:IsA("HingeConstraint") then
child:Destroy()
elseif child:IsA("Attachment") and (child.Name == "A" or child.Name == "B") then
child:Destroy()
end
end
end
end
end
pcall(function() processChildren(antiRagdollCharacter) end)
if antiRagdollAnimator then
for _, track in pairs(antiRagdollAnimator:GetPlayingAnimationTracks()) do
local animName = track.Animation and track.Animation.Name:lower() or ""
if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then
track:Stop(0)
end
end
end
end
local _dernierGrosNettoyage, _dernierEpisode = 0, 0
local function sortirDuRagdoll()
local hum, root, char = antiRagdollHumanoid, antiRagdollRootPart, antiRagdollCharacter
if not (hum and root and char and hum.Parent) then return end
local now = os.clock()
if now - _dernierEpisode > 1 then
_dernierEpisode = now
_G.MeerkoRagdollAnnules = (_G.MeerkoRagdollAnnules or 0) + 1
end
if ragdollTimerActif() then
pcall(function() LP:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
end
if _G.MeerkoStealHold or _G.__Els_VelFlying then return end
if now - _dernierGrosNettoyage >= 0.15 then
_dernierGrosNettoyage = now
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BallSocketConstraint")
or (d:IsA("Attachment") and d.Name:lower():find("ragdoll", 1, true)) then
pcall(function() d:Destroy() end)
end
end
end
if not _G.MeerkoInvisActive then
if root.Anchored then root.Anchored = false end
end
if hum.PlatformStand then hum.PlatformStand = false end
if hum.Health > 0 and not isFlyingCarpetActive() then
pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
end
if not _G.MeerkoInvisActive then
local cam = Workspace.CurrentCamera
if cam and cam.CameraSubject ~= hum then pcall(function() cam.CameraSubject = hum end) end
end
end
local function _harden(hum)
pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
pcall(function() hum.BreakJointsOnDeath = false end)
pcall(function() hum.RequiresNeck = false end)
pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
end
local function _revive(hum)
pcall(function() hum.Health = hum.MaxHealth end)
pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
end
local function setupAntiRagdollCharacter(char)
antiRagdollCharacter = char
antiRagdollHumanoid = char:WaitForChild("Humanoid", 10)
antiRagdollRootPart = char:WaitForChild("HumanoidRootPart", 10)
antiRagdollAnimator = antiRagdollHumanoid and antiRagdollHumanoid:FindFirstChildOfClass("Animator")
lastVelocity = Vector3.new(0, 0, 0)
if antiRagdollHumanoid then _harden(antiRagdollHumanoid) end
end
local function clearAntiRagdollConnections()
for _, c in pairs(antiRagdollConnections) do
pcall(function() c:Disconnect() end)
end
antiRagdollConnections = {}
end
local function setupAntiRagdollConnections()
clearAntiRagdollConnections()
if not antiRagdollHumanoid or not antiRagdollRootPart then return end
_harden(antiRagdollHumanoid)
table.insert(antiRagdollConnections, antiRagdollHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
if _G.AntiDieDisabled then return end
if antiRagdollHumanoid and antiRagdollHumanoid.Parent and antiRagdollHumanoid.Health <= 0 then
_revive(antiRagdollHumanoid)
end
end))
table.insert(antiRagdollConnections, antiRagdollHumanoid.Died:Connect(function()
if _G.AntiDieDisabled then return end
if antiRagdollHumanoid and antiRagdollHumanoid.Parent then
_revive(antiRagdollHumanoid)
end
end))
local _lastHarden = 0
table.insert(antiRagdollConnections, RunService.Heartbeat:Connect(function()
if not antiRagdollHumanoid or not antiRagdollHumanoid.Parent then return end
if not _G.AntiDieDisabled then
local now = os.clock()
if now - _lastHarden >= 1.0 then _lastHarden = now; _harden(antiRagdollHumanoid) end
if antiRagdollHumanoid.Health <= 0 then _revive(antiRagdollHumanoid) end
if _G.MeerkoStealHold and antiRagdollHumanoid.Health < antiRagdollHumanoid.MaxHealth then
pcall(function() antiRagdollHumanoid.Health = antiRagdollHumanoid.MaxHealth end)
end
end
if (_G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled) and isRagdolled() then
sortirDuRagdoll()
if _G.MeerkoStealHold then return end
if antiRagdollRootPart.AssemblyLinearVelocity.Magnitude > 60 then
lastVelocity = antiRagdollRootPart.AssemblyLinearVelocity
return
end
cleanupRagdoll()
local velocity = antiRagdollRootPart.AssemblyLinearVelocity
if (velocity - lastVelocity).Magnitude > velocityChangeThreshold
and velocity.Magnitude > velocityMagnitudeThreshold then
antiRagdollRootPart.AssemblyLinearVelocity = velocity.Unit * math.min(velocity.Magnitude, maxVelocity)
end
lastVelocity = velocity
end
end))
table.insert(antiRagdollConnections, antiRagdollHumanoid.StateChanged:Connect(function()
if (_G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled) and isRagdolled() then
if not isFlyingCarpetActive() then
antiRagdollHumanoid:ChangeState(Enum.HumanoidStateType.Running)
end
cleanupRagdoll()
sortirDuRagdoll()
local cam = Workspace.CurrentCamera
if cam and cam.CameraSubject ~= antiRagdollHumanoid then pcall(function() cam.CameraSubject = antiRagdollHumanoid end) end
enableAntiRagdollControls()
end
end))
table.insert(antiRagdollConnections, LP:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
if (_G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled) and ragdollTimerActif() then
sortirDuRagdoll()
cleanupRagdoll()
enableAntiRagdollControls()
end
end))
pcall(function()
local impulse
if _G.MeerkoGetRemote then
impulse = _G.MeerkoGetRemote("RemoteEvent", "CombatService/ApplyImpulse")
end
if not impulse then
local pkgs = RS:FindFirstChild("Packages")
local net  = pkgs and pkgs:FindFirstChild("Net")
impulse = net and net:FindFirstChild("RE/CombatService/ApplyImpulse")
end
if impulse then
table.insert(antiRagdollConnections, impulse.OnClientEvent:Connect(function()
if (_G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled) and isRagdolled() then
antiRagdollRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end))
end
end)
table.insert(antiRagdollConnections, antiRagdollCharacter.DescendantAdded:Connect(function()
if (_G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled) and isRagdolled() then
cleanupRagdoll()
end
end))
enableAntiRagdollControls()
cleanupRagdoll()
end
local function startAntiRagdoll()
local ancien = _G.MeerkoAntiRagdollAncien == true
_G.MeerkoAntiRagdollEnabled = ancien
_G.MeerkoAntiKnockbackEnabled = ancien
if LP.Character then
setupAntiRagdollCharacter(LP.Character)
setupAntiRagdollConnections()
end
end
local function stopAntiRagdoll()
_G.MeerkoAntiRagdollEnabled = false
_G.MeerkoAntiKnockbackEnabled = false
clearAntiRagdollConnections()
end
_G.toggleAntiRagdoll = function(enabled)
if enabled then startAntiRagdoll() else stopAntiRagdoll() end
end
_G.enableAntiKnockback = function() startAntiRagdoll() end
_G.disableAntiKnockback = function() stopAntiRagdoll() end
LP.CharacterAdded:Connect(function(char)
clearAntiRagdollConnections()
antiRagdollCharacter = nil; antiRagdollHumanoid = nil; antiRagdollRootPart = nil; antiRagdollAnimator = nil
local humanoid = char:WaitForChild("Humanoid", 10)
local rootPart = char:WaitForChild("HumanoidRootPart", 10)
if not humanoid or not rootPart then return end
task.wait(0.2)
setupAntiRagdollCharacter(char)
if _G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled then
setupAntiRagdollConnections()
end
end)
if LP.Character then
setupAntiRagdollCharacter(LP.Character)
if _G.MeerkoAntiRagdollEnabled or _G.MeerkoAntiKnockbackEnabled then
setupAntiRagdollConnections()
end
end
startAntiRagdoll()
local forceHum
local function brancherForce(char)
local hum = char and char:WaitForChild("Humanoid", 10)
if not hum then return end
forceHum = hum
_harden(hum)
hum.HealthChanged:Connect(function(h)
if not _G.AntiDieDisabled and h <= 0 and hum.Parent then _revive(hum) end
end)
hum.Died:Connect(function()
if not _G.AntiDieDisabled and hum.Parent then _revive(hum) end
end)
hum.StateChanged:Connect(function(_, new)
if not _G.AntiDieDisabled and new == Enum.HumanoidStateType.Dead and hum.Parent then _revive(hum) end
end)
end
LP.CharacterAdded:Connect(function(c) task.spawn(brancherForce, c) end)
if LP.Character then task.spawn(brancherForce, LP.Character) end
local _forceHarden = 0
RunService.Heartbeat:Connect(function()
local hum = forceHum
if _G.AntiDieDisabled or not (hum and hum.Parent) then return end
if hum.Health <= 0 then _revive(hum) end
local now = os.clock()
if now - _forceHarden >= 1 then _forceHarden = now; _harden(hum) end
end)
end)
if not okAD then _G.MeerkoAntiDieError = tostring(errAD) end
end)
task.spawn(function()
local LP = game:GetService("Players").LocalPlayer
LP:GetAttributeChangedSignal("Stealing"):Connect(function()
if LP:GetAttribute("Stealing") == true then return end
if _G.Els_BackToBrainrot == false then return end
task.delay(0.5, function()
if LP:GetAttribute("Stealing") == true then return end
if _G.__Els_VelFlying or _G.__Els_TPStarted or _G.isCloning then return end
if _G.Els_GoBackToTarget then pcall(_G.Els_GoBackToTarget) elseif _G.Els_StealTargetBest then pcall(_G.Els_StealTargetBest) end
end)
end)
end)
task.spawn(function()
local LP = game:GetService("Players").LocalPlayer
local lastAt = 0
local function onRag()
local et = tonumber(LP:GetAttribute("RagdollEndTime"))
if not et then return end
if _G.Els_BackToBrainrot == false then return end
local now = os.clock()
if now - lastAt < 1 then return end
lastAt = now
task.delay(0.5, function()
if LP:GetAttribute("Stealing") == true then return end
if _G.__Els_VelFlying or _G.__Els_TPStarted or _G.isCloning then return end
if _G.Els_GoBackToTarget then pcall(_G.Els_GoBackToTarget) elseif _G.Els_StealTargetBest then pcall(_G.Els_StealTargetBest) end
end)
end
LP:GetAttributeChangedSignal("RagdollEndTime"):Connect(onRag)
onRag()
end)
do
if _G.Els_BrainrotESP then pcall(_G.Els_BrainrotESP.Destroy) end
_G.Els_BrainrotESP = nil
pcall(function()
local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
local old = pg and pg:FindFirstChild("ElsBrainrotESP")
if old then old:Destroy() end
end)
end
;task.spawn(function()
local LP=game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
if _G.MeerkoCleanErrStop then pcall(_G.MeerkoCleanErrStop) end
local _ref = cloneref or function(x) return x end
local GS = _ref(game:GetService("GuiService"))
local running, conns = true, {}
task.spawn(function()
while running do
if _G.MeerkoClearErr ~= false then
pcall(function() GS:ClearError() end)
end
task.wait(tonumber(_G.MeerkoClearErrGap) or 0.35)
end
end)
conns[#conns + 1] = TeleportService.TeleportInitFailed:Connect(function(plr, result, message, placeId)
if plr ~= LP then return end
local name = "Unknown"
pcall(function() name = result and result.Name or tostring(result) end)
_G.MeerkoCleanErrLast = {
result = name, message = tostring(message or ""),
placeId = placeId, at = os.clock(),
}
end)
_G.MeerkoCleanErrStop = function()
running = false
for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
conns = {}
_G.MeerkoCleanErrStop = nil
end
end)
task.spawn(function()
if _G.Els_PlayerCloneCollisionStop then pcall(_G.Els_PlayerCloneCollisionStop) end
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local LP=Players.LocalPlayer
local _OTHER_CLONES = {}
do
local _MY_CLONE = tostring(LP.UserId) .. "_Clone"
local _seen = {}
local function _isOtherClone(inst)
if not inst then return false end
local n = inst.Name
if n == _MY_CLONE then return false end
if n:match("^%d+_Clone$") then return true end
if not n:find("lone", 1, true) then return false end
if not inst:IsA("Model") then return false end
if inst == LP.Character then return false end
if not inst:FindFirstChild("HumanoidRootPart") then return false end
if not inst:FindFirstChildOfClass("Humanoid") then return false end
for _, pl in ipairs(Players:GetPlayers()) do
if pl.Character == inst then return false end
end
return true
end
local function _neutralize(inst)
if not inst or _seen[inst] then return end
_seen[inst] = true
_OTHER_CLONES[#_OTHER_CLONES + 1] = inst
local function declaw(d)
if d:IsA("BasePart") and d.CanCollide then pcall(function() d.CanCollide = false end) end
end
for _, d in ipairs(inst:GetDescendants()) do declaw(d) end
inst.DescendantAdded:Connect(declaw)
inst.Destroying:Connect(function()
_seen[inst] = nil
for i = #_OTHER_CLONES, 1, -1 do
if _OTHER_CLONES[i] == inst then table.remove(_OTHER_CLONES, i); break end
end
end)
end
local function _scan(inst)
if _isOtherClone(inst) then _neutralize(inst) end
end
for _, c in ipairs(workspace:GetChildren()) do _scan(c) end
workspace.ChildAdded:Connect(function(c)
_scan(c)
task.defer(function() if c and c.Parent == workspace then _scan(c) end end)
end)
end
do
local _pSeen = setmetatable({}, { __mode = "k" })
local _ncBag = setmetatable({}, { __mode = "k" })
local function _declaw(d)
if d:IsA("BasePart") and d.CanCollide then pcall(function() d.CanCollide = false end) end
end
local function _declawChar(char)
if not char then return end
for _, d in ipairs(char:GetDescendants()) do _declaw(d) end
if not _pSeen[char] then
_pSeen[char] = true
char.DescendantAdded:Connect(_declaw)
end
end
local _THEIRS = { "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "Head" }
local function _noCollide(char)
if _G.MeerkoNoCollideConstraints == false or not char then return end
local c = LP.Character
local mine = c and c:FindFirstChild("HumanoidRootPart")
if not mine then return end
local bag = _ncBag[char]
if not bag or bag.root ~= mine then bag = { root = mine }; _ncBag[char] = bag end
for _, n in ipairs(_THEIRS) do
local part = char:FindFirstChild(n)
if part and part:IsA("BasePart") then
local nc = bag[n]
if not (nc and nc.Parent) then
pcall(function()
local k = Instance.new("NoCollisionConstraint")
k.Part0, k.Part1 = mine, part
k.Parent = mine
bag[n] = k
end)
end
end
end
end
local _watched = setmetatable({}, { __mode = "k" })
local _pinHooked = setmetatable({}, { __mode = "k" })
local function _pin(p)
if not p:IsA("BasePart") then return end
if p.CanCollide then p.CanCollide = false end
if _watched[p] then return end
_watched[p] = true
pcall(function()
p:GetPropertyChangedSignal("CanCollide"):Connect(function()
if p.CanCollide then p.CanCollide = false end
end)
end)
end
local function _pinChar(ch)
if not ch then return end
for _, d in ipairs(ch:GetDescendants()) do _pin(d) end
if not _pinHooked[ch] then
_pinHooked[ch] = true
ch.DescendantAdded:Connect(function(d) task.defer(_pin, d) end)
end
end
local function _hookPlayer(pl)
if pl == LP then return end
if pl.Character then _declawChar(pl.Character); _noCollide(pl.Character); _pinChar(pl.Character) end
pl.CharacterAdded:Connect(function(c)
task.wait(0.05)
_declawChar(c)
_noCollide(c)
_pinChar(c)
end)
end
for _, pl in ipairs(Players:GetPlayers()) do _hookPlayer(pl) end
Players.PlayerAdded:Connect(_hookPlayer)
LP.CharacterAdded:Connect(function()
task.wait(0.3)
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= LP and pl.Character then _noCollide(pl.Character) end
end
end)
local function _pinPlayer(pl)
if pl == LP then return end
if pl.Character then _pinChar(pl.Character) end
pl.CharacterAdded:Connect(function(c) task.wait(0.15) _pinChar(c) end)
end
for _, pl in ipairs(Players:GetPlayers()) do _pinPlayer(pl) end
Players.PlayerAdded:Connect(_pinPlayer)
local _MY_CLONE_N = tostring(LP.UserId) .. "_Clone"
local function _clones()
local t = _OTHER_CLONES
return (type(t) == "table") and t or {}
end
local _ncAcc = 0
local _ncParts = setmetatable({}, { __mode = "k" })
local function _declawParts(m, now)
local e = _ncParts[m]
if not e or now - e.t > 2 then
local list = {}
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("BasePart") then list[#list + 1] = d end
end
e = { t = now, list = list }
_ncParts[m] = e
end
local list = e.list
for i = 1, #list do
local p = list[i]
if p.CanCollide then p.CanCollide = false end
end
end
RunService.Stepped:Connect(function(_, dt)
if _G.MeerkoNoCollide == false or _G.isCloning == true then return end
_ncAcc = _ncAcc + (dt or 0.016)
if _ncAcc < 0.1 then return end
_ncAcc = 0
local c = LP.Character
local myHrp = c and c:FindFirstChild("HumanoidRootPart")
if not myHrp then return end
local mp = myHrp.Position
local rng = tonumber(_G.MeerkoNoCollideRange) or 28
local now = os.clock()
for _, pl in ipairs(Players:GetPlayers()) do
local ch = (pl ~= LP) and pl.Character
local h = ch and ch:FindFirstChild("HumanoidRootPart")
if h and (h.Position - mp).Magnitude <= rng then
_declawParts(ch, now)
end
end
for _, cl in ipairs(_clones()) do
if cl and cl.Parent and cl.Name ~= _MY_CLONE_N then
local h = cl:FindFirstChild("HumanoidRootPart")
if h and (h.Position - mp).Magnitude <= rng then
_declawParts(cl, now)
end
end
end
end)
task.spawn(function()
while true do
task.wait(1)
if _G.MeerkoNoCollide ~= false and _G.isCloning ~= true then
for _, pl in ipairs(Players:GetPlayers()) do
local ch = (pl ~= LP) and pl.Character
if ch then _pinChar(ch) end
end
for _, cl in ipairs(_clones()) do
if cl and cl.Parent and cl.Name ~= _MY_CLONE_N then _pinChar(cl) end
end
end
end
end)
end
end)
task.spawn(function()
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Stats=game:GetService("Stats")
local LP=Players.LocalPlayer
local pg=LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui",10)
if not pg then return end
local old=pg:FindFirstChild("ElsHubTopBar"); if old then old:Destroy() end
local T=_G.Els_Theme; local C=T.C
local YELLOW=Color3.fromRGB(255,200,70)
local g=Instance.new("ScreenGui"); g.Name="ElsHubTopBar"; g.ResetOnSpawn=false; g.IgnoreGuiInset=true; g.DisplayOrder=30; g.Parent=pg
local bar=Instance.new("Frame")
bar.AnchorPoint=Vector2.new(0.5,0); bar.Position=UDim2.new(0.5,0,0,8); bar.Size=UDim2.fromOffset(310,32)
T.window(bar); bar.Active=true; bar.Draggable=true; bar.Parent=g
T.accent(bar, UDim2.fromOffset(12,0), UDim2.new(1,-24,0,2))
local row=Instance.new("Frame", bar); row.BackgroundTransparency=1; row.Size=UDim2.fromScale(1,1)
local lay=Instance.new("UIListLayout", row); lay.FillDirection=Enum.FillDirection.Horizontal; lay.SortOrder=Enum.SortOrder.LayoutOrder
lay.HorizontalAlignment=Enum.HorizontalAlignment.Center; lay.VerticalAlignment=Enum.VerticalAlignment.Center; lay.Padding=UDim.new(0,10)
local title=T.label(row,{Name="Title",Size=UDim2.fromOffset(72,32),Text="ELS HUB",TextSize=14,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=1})
local tgr=Instance.new("UIGradient"); tgr.Color=ColorSequence.new(C.acc,C.acc2); tgr.Parent=title
local function sep(order)
local s=Instance.new("Frame"); s.Size=UDim2.fromOffset(1,16); s.BackgroundColor3=C.line; s.BorderSizePixel=0; s.LayoutOrder=order; s.Parent=row
end
sep(2)
local fpsL=T.label(row,{Name="FPS",Size=UDim2.fromOffset(64,32),RichText=true,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center,Text="FPS  --",LayoutOrder=3})
sep(4)
local pingL=T.label(row,{Name="Ping",Size=UDim2.fromOffset(96,32),RichText=true,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center,Text="PING  --",LayoutOrder=5})
task.delay(2.5, function()
if not g.Parent then return end
local hold=Instance.new("Frame"); hold.Name="Holding"
hold.AnchorPoint=Vector2.new(0.5,0); hold.Position=UDim2.new(0.5,0,1,6); hold.Size=UDim2.fromOffset(310,28)
T.window(hold); hold.Parent=bar
local hStroke=hold:FindFirstChildOfClass("UIStroke")
local hDot=Instance.new("Frame",hold); hDot.Size=UDim2.fromOffset(8,8); hDot.Position=UDim2.new(0,14,0.5,-4); hDot.BackgroundColor3=C.dim; hDot.BorderSizePixel=0; T.corner(hDot,4)
local hL=T.label(hold,{Position=UDim2.fromOffset(30,0),Size=UDim2.new(1,-42,1,0),RichText=true,TextColor3=C.dim,TextTruncate=Enum.TextTruncate.AtEnd,Text="HOLDING: None"})
local function isStealing()
if LP:GetAttribute("Stealing") then return true end
local char=LP.Character
return char~=nil and char:GetAttribute("Stealing") and true or false
end
local function heldName()
if not isStealing() then return nil end
local char=LP.Character
local any
if char then
for _,m in ipairs(char:GetChildren()) do
if m:IsA("Model") then
if m:FindFirstChild("RootPart") or m:FindFirstChild("FakeRootPart") or m:FindFirstChildWhichIsA("AnimationController",true) then return m.Name end
any=any or m.Name
end
end
end
if any then return any end
local p=_G.Els_LastPet
return p and tostring(p.name or p.index) or "Brainrot"
end
local function esc(s) return (s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")) end
local lastHeld=false
task.spawn(function()
while g.Parent do
local ok,n=pcall(heldName)
if not ok then n=nil end
if n~=lastHeld then
lastHeld=n
if n then
hL.Text="HOLDING: <font color=\""..T.hex(C.green).."\">"..esc(n).."</font>"
hDot.BackgroundColor3=C.green
if hStroke then hStroke.Color=C.green end
else
hL.Text="HOLDING: None"
hDot.BackgroundColor3=C.dim
if hStroke then hStroke.Color=C.line end
end
end
task.wait(0.2)
end
end)
end)
local pingItem,pingLookupAt=nil,-math.huge
local function pingMs()
if not pingItem and os.clock()-pingLookupAt>5 then
pingLookupAt=os.clock()
pcall(function()
local ps=Stats:FindFirstChild("PerformanceStats")
pingItem=(ps and ps:FindFirstChild("NetworkPing")) or Stats:FindFirstChild("NetworkPing",true)
end)
end
if pingItem then
local ok,v=pcall(function() return pingItem:GetValue() end)
if ok and type(v)=="number" and v>0 then return v end
end
local ok,v=pcall(function() return LP:GetNetworkPing()*1000 end)
if ok and type(v)=="number" and v>0 then return v end
ok,v=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
if ok and type(v)=="number" then return v end
return nil
end
local function paint(v,good,bad,higherIsBetter)
local col
if higherIsBetter then
col=(v>=good and C.green) or (v>=bad and YELLOW) or C.red
else
col=(v<=good and C.green) or (v<=bad and YELLOW) or C.red
end
return "<font color=\""..T.hex(col).."\">"
end
local frames,last=0,os.clock()
local conn=RunService.RenderStepped:Connect(function() frames=frames+1 end)
while g.Parent do
task.wait(0.5)
local now=os.clock()
local fps=frames/math.max(now-last,1e-3)
frames,last=0,now
fpsL.Text="FPS  "..paint(fps,50,30,true)..math.floor(fps+0.5).."</font>"
local p=pingMs()
if p then
pingL.Text="PING  "..paint(p,100,200,false)..math.floor(p+0.5).." ms</font>"
else
pingL.Text="PING  --"
end
end
conn:Disconnect()
end)
task.spawn(function()
if _G.ELS_AntiVoidStop then pcall(_G.ELS_AntiVoidStop) end
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local LP=Players.LocalPlayer
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
local function groundBelow(pos,depth)
local skip={}
for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then skip[#skip+1]=pl.Character end end
rp.FilterDescendantsInstances=skip
local hit=workspace:Raycast(pos,Vector3.new(0,-depth,0),rp)
return hit~=nil and hit.Instance~=nil and hit.Instance.Name~="XenHubLandPlatform"
end
local function busy()
return _G.BelsResetting or _G.__Els_VelFlying or _G.isCloning or _G.MeerkoInvisActive
end
local lastSafe,safeChar,lastSave,cooldown=nil,nil,0,0
local conn=RunService.Heartbeat:Connect(function()
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not (hrp and hum) or hum.Health<=0 then return end
local voidY=tonumber(_G.ELS_AntiVoidY) or -40
if char~=safeChar then
safeChar,lastSafe=char,nil
if hrp.Position.Y>=voidY then lastSafe=hrp.CFrame+Vector3.new(0,2,0) end
end
local now=os.clock()
if hrp.Position.Y>=voidY then
if now-lastSave>=0.2 and not hrp.Anchored and hum.FloorMaterial~=Enum.Material.Air then
lastSave=now
if groundBelow(hrp.Position,8) then lastSafe=hrp.CFrame+Vector3.new(0,1.5,0) end
end
return
end
if busy() or hrp.Anchored or now<cooldown or not lastSafe then return end
cooldown=now+0.5
local spot=lastSafe
hrp.CFrame=spot
hrp.AssemblyLinearVelocity=Vector3.zero
hrp.AssemblyAngularVelocity=Vector3.zero
if not groundBelow(spot.Position,20) then
task.spawn(function()
pcall(function() hrp.Anchored=true end)
pcall(function() LP:RequestStreamAroundAsync(spot.Position,3) end)
local t0=os.clock()
while hrp.Parent and os.clock()-t0<3 and not groundBelow(hrp.Position,20) do task.wait(0.1) end
if hrp.Parent then pcall(function() hrp.Anchored=false end) end
end)
end
end)
_G.ELS_AntiVoidStop=function() conn:Disconnect(); _G.ELS_AntiVoidStop=nil end
end)

-- Els: BASE TIMER
-- Shows the lock time of the base you are standing in.
-- The time is read from the Synchronizer (BlockEndTimeFirstFloor), so it works
-- even when the hub has destroyed the RemainingTime BillboardGui / PlotBlock.
task.spawn(function()
local Players = game:GetService("Players")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer
while not LP do task.wait(); LP = Players.LocalPlayer end
local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 10); if not pg then return end
local t0 = os.clock()
while not _G.Els_Theme and os.clock() - t0 < 30 do task.wait(0.2) end
local T = _G.Els_Theme; if not T then return end
local C = T.C
local YELLOW = Color3.fromRGB(255,200,70)
local POS_FILE = "Els_TimerPos.json"

-- base positions, cached (the hub can destroy plots)
local plotBox = {}
local function remember(plot)
pcall(function()
local cf, size = plot:GetBoundingBox()
if size.Magnitude > 1 then plotBox[plot.Name] = { cf = cf, size = size } end
end)
end
local function scanPlots()
local plots = workspace:FindFirstChild("Plots")
if not plots then return end
for _, p in ipairs(plots:GetChildren()) do
if not plotBox[p.Name] then remember(p) end
end
end
task.spawn(function()
local plots = workspace:WaitForChild("Plots", 30)
if plots then plots.ChildAdded:Connect(function(p) task.defer(remember, p) end) end
end)
-- base the player is in: inside the box, otherwise the closest one (< 70 studs)
local function currentPlot(pos)
local best, bestD
for name, b in pairs(plotBox) do
local lp = b.cf:PointToObjectSpace(pos)
local hx, hz = b.size.X/2 + 4, b.size.Z/2 + 4
if math.abs(lp.X) <= hx and math.abs(lp.Z) <= hz then return name end
local d = Vector2.new(pos.X - b.cf.X, pos.Z - b.cf.Z).Magnitude
if d < 70 and (not bestD or d < bestD) then best, bestD = name, d end
end
return best
end

local function cacheOf(ch)
if type(ch) ~= "table" then return nil end
local ct = rawget(ch, "CacheTable")
if type(ct) ~= "table" then
local ok, c2 = pcall(function() return ch.CacheTable end)
if ok and type(c2) == "table" then ct = c2 end
end
return type(ct) == "table" and ct or nil
end
local function getChan(name)
local ch
pcall(function() ch = _G.XenSyncGet(name) end)
return ch
end
local function secsLeft(v)
v = tonumber(v); if not v then return nil end
if v > 1e12 then v = v / 1000 end
if v > 1e9 then return v - workspace:GetServerTimeNow() end
return v
end
local function ownerName(o)
local name
pcall(function()
if typeof(o) == "Instance" then name = o:IsA("Player") and o.DisplayName or o.Name
elseif type(o) == "table" then name = o.DisplayName or o.Name
elseif type(o) == "number" then local p = Players:GetPlayerByUserId(o); name = p and p.DisplayName
elseif type(o) == "string" then name = o end
end)
return name
end
local function fmt(s)
s = math.ceil(s)
if s >= 60 then return string.format("%d:%02d", math.floor(s/60), s % 60) end
return s .. "s"
end
local function parseLabel(txt)
txt = tostring(txt or "")
local m, s = txt:match("(%d+):(%d+)")
if m then return tonumber(m)*60 + tonumber(s) end
local n = txt:match("(%d+)")
return n and tonumber(n) or nil
end

-- UI
local old = pg:FindFirstChild("ElsBaseTimers"); if old then old:Destroy() end
local g = Instance.new("ScreenGui"); g.Name = "ElsBaseTimers"; g.ResetOnSpawn = false; g.IgnoreGuiInset = true; g.Parent = pg
local win = Instance.new("Frame"); win.Name = "Els_BaseTimer"
win.Size = UDim2.fromOffset(180, 0); win.AutomaticSize = Enum.AutomaticSize.Y
win.Position = UDim2.new(1, -196, 0.5, -60)
pcall(function()
if isfile and readfile and isfile(POS_FILE) then
local d = HS:JSONDecode(readfile(POS_FILE))
if type(d) == "table" and tonumber(d.x) and tonumber(d.y) then win.Position = UDim2.fromOffset(tonumber(d.x), tonumber(d.y)) end
end
end)
T.window(win); win.Active = true; win.Draggable = true; win.Parent = g
do
local q = false
win:GetPropertyChangedSignal("Position"):Connect(function()
if q then return end
q = true
task.delay(0.6, function()
q = false
pcall(function()
local ap = win.AbsolutePosition
writefile(POS_FILE, HS:JSONEncode({ x = math.floor(ap.X), y = math.floor(ap.Y) }))
end)
end)
end)
end
local lay = Instance.new("UIListLayout", win); lay.Padding = UDim.new(0, 2); lay.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", win); pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 8); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
local tf = Instance.new("Frame", win); tf.Size = UDim2.new(1, 0, 0, 20); tf.BackgroundTransparency = 1; tf.LayoutOrder = 0
T.accent(tf, UDim2.new(0, 2, 0, -8), UDim2.new(1, -4, 0, 2))
T.title(tf, "BASE TIMER", 2, 0, 20)
local lblOwner = T.label(win, { Size = UDim2.new(1, 0, 0, 16), Text = "", TextColor3 = C.dim, Font = Enum.Font.GothamMedium,
TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1 })
local lblTime = T.label(win, { Size = UDim2.new(1, 0, 0, 30), Text = "—", TextSize = 24, Font = Enum.Font.GothamBlack,
TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 2 })

while g.Parent do
scanPlots()
local ch = LP.Character
local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
local name = hrp and currentPlot(hrp.Position)
if not name then
lblOwner.Text = "Not in a base"
lblTime.Text = "—"; lblTime.TextColor3 = C.dim
else
local left, owner, known = nil, nil, false
local ct = cacheOf(getChan(name))
if ct then
known = true
local v = rawget(ct, "BlockEndTimeFirstFloor")
if v == nil then pcall(function() v = ct.BlockEndTimeFirstFloor end) end
left = secsLeft(v)
local o = rawget(ct, "Owner"); if o == nil then pcall(function() o = ct.Owner end) end
owner = ownerName(o)
else
-- fallback: RemainingTime label if it still exists
local plots = workspace:FindFirstChild("Plots")
local plot = plots and plots:FindFirstChild(name)
local lbl = plot and plot:FindFirstChild("RemainingTime", true)
if lbl and lbl:IsA("TextLabel") then known = true; left = parseLabel(lbl.Text) end
end
if name == _G.__Els_MyPlot then owner = (owner or "My base") .. "  (me)" end
lblOwner.Text = owner or "Base"
if not known then
lblTime.Text = "?"; lblTime.TextColor3 = C.dim
elseif not left or left <= 0 then
lblTime.Text = "OPEN"; lblTime.TextColor3 = C.green
else
lblTime.Text = fmt(left)
lblTime.TextColor3 = (left <= 10) and YELLOW or C.txt
end
end
task.wait(0.2)
end
end)
