-- Crystal Rush | Server Script
-- Βάλ' το ως Script μέσα στο ServerScriptService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local REMOTE_NAME = "CrystalRushEvent"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME) or Instance.new("RemoteEvent")
remote.Name = REMOTE_NAME
remote.Parent = ReplicatedStorage

local oldWorld = workspace:FindFirstChild("CrystalRushWorld")
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Folder")
world.Name = "CrystalRushWorld"
world.Parent = workspace

local function makePart(name, size, position, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Anchored = true
	part.Parent = parent or world
	return part
end

-- Η πίστα
local floor = makePart("Grass", Vector3.new(180, 2, 180), Vector3.new(0, 0, 0), Color3.fromRGB(56, 142, 60))
floor.Material = Enum.Material.Grass

local spawn = Instance.new("SpawnLocation")
spawn.Name = "CrystalRushSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 2, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Color = Color3.fromRGB(255, 235, 59)
spawn.Parent = world

-- Μικρά άλματα για εξερεύνηση
for i = 1, 9 do
	local platform = makePart("JumpPlatform", Vector3.new(10, 2, 10), Vector3.new(-65 + i * 14, 4 + (i % 3) * 4, -45), Color3.fromRGB(66, 165, 245))
	platform.Material = Enum.Material.Neon
end

-- Τα στατιστικά που φαίνονται αυτόματα στον πίνακα παικτών
local function setUpPlayer(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local crystals = Instance.new("IntValue")
	crystals.Name = "Crystals"
	crystals.Value = 0
	crystals.Parent = stats

	local speedLevel = Instance.new("IntValue")
	speedLevel.Name = "SpeedLevel"
	speedLevel.Parent = player
	local jumpLevel = Instance.new("IntValue")
	jumpLevel.Name = "JumpLevel"
	jumpLevel.Parent = player

	local function applyUpgrades(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = 16 + speedLevel.Value * 3
		humanoid.JumpPower = 50 + jumpLevel.Value * 8
	end
	player.CharacterAdded:Connect(applyUpgrades)
	if player.Character then applyUpgrades(player.Character) end
end

Players.PlayerAdded:Connect(setUpPlayer)
for _, player in Players:GetPlayers() do setUpPlayer(player) end

-- Κρύσταλλοι: ο server αποφασίζει ποιος τους παίρνει, άρα λειτουργεί δίκαια και με φίλους.
local crystalPositions = {
	Vector3.new(25, 4, 15), Vector3.new(-25, 4, 15), Vector3.new(40, 4, -20),
	Vector3.new(-40, 4, -20), Vector3.new(55, 4, 42), Vector3.new(-55, 4, 42),
	Vector3.new(0, 4, 65), Vector3.new(0, 4, -65), Vector3.new(20, 10, -45),
}

local function createCrystal(position)
	local crystal = Instance.new("Part")
	crystal.Name = "Crystal"
	crystal.Shape = Enum.PartType.Ball
	crystal.Size = Vector3.new(3, 3, 3)
	crystal.Position = position
	crystal.Anchored = true
	crystal.CanCollide = false
	crystal.Material = Enum.Material.Neon
	crystal.Color = Color3.fromRGB(0, 255, 255)
	crystal.Parent = world

	local light = Instance.new("PointLight")
	light.Color = crystal.Color
	light.Range = 10
	light.Brightness = 2
	light.Parent = crystal

	TweenService:Create(crystal, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = position + Vector3.new(0, 1.5, 0)}):Play()
	local taken = false
	crystal.Touched:Connect(function(hit)
		if taken then return end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		taken = true
		player.leaderstats.Crystals.Value += 1
		remote:FireClient(player, "Message", "+1 κρύσταλλος!")
		crystal:Destroy()
		task.wait(4)
		createCrystal(position)
	end)
end
for _, position in crystalPositions do createCrystal(position) end

local function buyUpgrade(player, kind)
	local crystals = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Crystals")
	if not crystals then return end
	local level = player:FindFirstChild(kind .. "Level")
	if not level then return end
	local cost = 3 + level.Value * 2
	if crystals.Value < cost then
		remote:FireClient(player, "Message", "Χρειάζεσαι " .. cost .. " κρυστάλλους.")
		return
	end
	crystals.Value -= cost
	level.Value += 1
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16 + player.SpeedLevel.Value * 3
			humanoid.JumpPower = 50 + player.JumpLevel.Value * 8
		end
	end
	remote:FireClient(player, "Message", "Αναβάθμιση επιτυχής! Επίπεδο: " .. level.Value)
end

remote.OnServerEvent:Connect(function(player, action)
	if action == "Speed" then buyUpgrade(player, "Speed") end
	if action == "Jump" then buyUpgrade(player, "Jump") end
end)
