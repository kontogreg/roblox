-- JUMP FOR ANIMALS | Server Script
-- Βάλ' το στο ServerScriptService. Αν έχεις το παλιό CrystalRush_Server Script,
-- σβήσε τον κώδικά του και βάλε αυτόν.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local event = ReplicatedStorage:FindFirstChild("AnimalJumpEvent") or Instance.new("RemoteEvent")
event.Name = "AnimalJumpEvent"
event.Parent = ReplicatedStorage

local oldWorld = workspace:FindFirstChild("AnimalJumpWorld")
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Folder")
world.Name = "AnimalJumpWorld"
world.Parent = workspace

local function part(name, size, position, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Parent = world
	return p
end

local function sign(position, text, color, width)
	local board = part("Sign_" .. text, Vector3.new(width or 22, 7, 1), position, color)
	board.Material = Enum.Material.WoodPlanks
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.25
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	return board
end

-- Αφετηρία
local ground = part("StartIsland", Vector3.new(72, 3, 72), Vector3.new(0, 0, 0), Color3.fromRGB(66, 160, 80))
ground.Material = Enum.Material.Grass
local spawn = Instance.new("SpawnLocation")
spawn.Name = "AnimalJumpSpawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 2, -65)
spawn.Anchored = true
spawn.Neutral = true
spawn.Color = Color3.fromRGB(255, 235, 59)
spawn.Parent = world

-- Χρωματιστό χωριό-λόμπι: εδώ ξεκινούν όλοι οι παίκτες.
local path = part("GoldenPath", Vector3.new(16, 1, 70), Vector3.new(0, 2, -32), Color3.fromRGB(255, 222, 92))
path.Material = Enum.Material.Sand

local shop = part("CrystalShop", Vector3.new(26, 16, 14), Vector3.new(-44, 9, -58), Color3.fromRGB(50, 155, 220))
shop.Material = Enum.Material.WoodPlanks
sign(Vector3.new(-44, 18, -51), "💎 SHOP", Color3.fromRGB(26, 110, 190), 25)
local museum = part("AnimalHouse", Vector3.new(26, 16, 14), Vector3.new(44, 9, -58), Color3.fromRGB(238, 139, 59))
museum.Material = Enum.Material.WoodPlanks
sign(Vector3.new(44, 18, -51), "🐾 ΖΩΑ", Color3.fromRGB(191, 92, 28), 25)

for _, data in ipairs({{-62, -35}, {-52, -25}, {58, -28}, {67, -40}}) do
	part("TreeTrunk", Vector3.new(3, 13, 3), Vector3.new(data[1], 8, data[2]), Color3.fromRGB(105, 70, 35))
	local leaves = part("TreeLeaves", Vector3.new(12, 12, 12), Vector3.new(data[1], 18, data[2]), Color3.fromRGB(57, 163, 75))
	leaves.Shape = Enum.PartType.Ball
end

-- Η πύλη που σε βάζει στην αρχή του πύργου.
local portal = part("JumpPortal", Vector3.new(18, 1, 12), Vector3.new(0, 2, -12), Color3.fromRGB(143, 83, 210))
portal.Material = Enum.Material.Neon
sign(Vector3.new(0, 10, -17), "⬆ JUMP TOWER", Color3.fromRGB(118, 62, 190), 28)
portal.Touched:Connect(function(hit)
	local character = hit.Parent
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then root.CFrame = CFrame.new(-14, 13, 0) end
end)

-- Κάθε γραμμή είναι: όνομα ζώου, ύψος, χρώμα, θέση X.
-- Για να προσθέσεις δικό σου ζώο, γράψε ακόμη μία παρόμοια γραμμή.
local animals = {
	{"🐶 Σκυλάκι", 18, Color3.fromRGB(154, 102, 55), -12},
	{"🐱 Γατάκι", 38, Color3.fromRGB(255, 183, 77), 12},
	{"🐰 Κουνελάκι", 62, Color3.fromRGB(235, 235, 245), -14},
	{"🦊 Αλεπού", 90, Color3.fromRGB(239, 108, 0), 14},
	{"🐼 Πάντα", 122, Color3.fromRGB(70, 70, 80), -12},
	{"🦁 Λιοντάρι", 158, Color3.fromRGB(255, 193, 7), 12},
	{"🐉 Δράκος", 198, Color3.fromRGB(116, 80, 170), 0},
}

-- Πλατφόρμες: το άλμα γίνεται σταδιακά δυσκολότερο και το Jump βοηθάει.
local platformPositions = {
	Vector3.new(-14, 8, 0), Vector3.new(12, 17, 0), Vector3.new(-12, 29, 0),
	Vector3.new(14, 42, 0), Vector3.new(-15, 56, 0), Vector3.new(12, 72, 0),
	Vector3.new(-14, 90, 0), Vector3.new(14, 110, 0), Vector3.new(-12, 132, 0),
	Vector3.new(13, 156, 0), Vector3.new(-10, 182, 0), Vector3.new(0, 210, 0),
}
for number, position in ipairs(platformPositions) do
	local platform = part("JumpPlatform" .. number, Vector3.new(15, 2, 15), position, Color3.fromHSV(number / 15, 0.7, 1))
	platform.Material = Enum.Material.Neon
end

local function billboard(adornee, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(180, 42)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Adornee = adornee
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.25
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function playerHasAnimal(player, animalName)
	return player:FindFirstChild("AnimalCollection") and player.AnimalCollection:FindFirstChild(animalName) ~= nil
end

local function createAnimal(info)
	local name, height, color, x = info[1], info[2], info[3], info[4]
	local animal = part("Animal_" .. name, Vector3.new(5, 5, 5), Vector3.new(x, height + 5, 0), color)
	animal.Shape = Enum.PartType.Ball
	animal.Material = Enum.Material.Neon
	animal.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 14
	light.Brightness = 2
	light.Parent = animal
	billboard(animal, name .. "\nΦτάσε στο ύψος " .. height, Color3.new(1, 1, 1))
	TweenService:Create(animal, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = animal.Position + Vector3.new(0, 1.6, 0)}):Play()
	animal.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or playerHasAnimal(player, name) then return end
		local saved = Instance.new("StringValue")
		saved.Name = name
		saved.Value = name
		saved.Parent = player.AnimalCollection
		player.leaderstats.Animals.Value += 1
		event:FireClient(player, "Animal", name)
		event:FireClient(player, "Message", "Μπράβο! Βρήκες: " .. name)
	end)
end
for _, info in ipairs(animals) do createAnimal(info) end

local function createCrystal(position)
	local crystal = part("Crystal", Vector3.new(2.5, 2.5, 2.5), position, Color3.fromRGB(0, 240, 255))
	crystal.Shape = Enum.PartType.Ball
	crystal.Material = Enum.Material.Neon
	crystal.CanCollide = false
	local taken = false
	crystal.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or taken then return end
		taken = true
		player.leaderstats.Crystals.Value += 1
		event:FireClient(player, "Message", "+1 κρύσταλλος")
		crystal:Destroy()
		task.delay(5, function() createCrystal(position) end)
	end)
end
for _, position in ipairs(platformPositions) do
	createCrystal(position + Vector3.new(0, 3, 4))
end

local function applyStats(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.UseJumpPower = true
	humanoid.WalkSpeed = 16 + player.SpeedLevel.Value * 3
	humanoid.JumpPower = 50 + player.JumpLevel.Value * 10
end

local function setUpPlayer(player)
	if player:FindFirstChild("leaderstats") then return end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	for _, statName in ipairs({"Crystals", "Animals"}) do
		local value = Instance.new("IntValue")
		value.Name = statName
		value.Parent = stats
	end
	for _, levelName in ipairs({"SpeedLevel", "JumpLevel"}) do
		local value = Instance.new("IntValue")
		value.Name = levelName
		value.Parent = player
	end
	local collection = Instance.new("Folder")
	collection.Name = "AnimalCollection"
	collection.Parent = player
	player.CharacterAdded:Connect(function(character) applyStats(player, character) end)
	if player.Character then applyStats(player, player.Character) end
end
Players.PlayerAdded:Connect(setUpPlayer)
for _, player in Players:GetPlayers() do setUpPlayer(player) end

local function buy(player, upgradeName)
	local level = player:FindFirstChild(upgradeName .. "Level")
	local crystals = player.leaderstats.Crystals
	local cost = 3 + level.Value * 3
	if crystals.Value < cost then
		event:FireClient(player, "Message", "Χρειάζεσαι " .. cost .. " κρυστάλλους.")
		return
	end
	crystals.Value -= cost
	level.Value += 1
	if player.Character then applyStats(player, player.Character) end
	event:FireClient(player, "Message", "Έγινες πιο δυνατός! " .. upgradeName .. " επίπεδο " .. level.Value)
end
event.OnServerEvent:Connect(function(player, action)
	if action == "Jump" then buy(player, "Jump") end
	if action == "Speed" then buy(player, "Speed") end
	if action == "Tower" and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(-14, 13, 0) end
	end
end)
