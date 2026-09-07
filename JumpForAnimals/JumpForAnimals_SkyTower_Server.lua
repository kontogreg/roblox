-- JUMP FOR ANIMALS: SKY TOWER | Server Script
-- Βάλ' το ως Script στο ServerScriptService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local event = ReplicatedStorage:FindFirstChild("AnimalJumpEvent") or Instance.new("RemoteEvent")
event.Name = "AnimalJumpEvent"
event.Parent = ReplicatedStorage

local old = workspace:FindFirstChild("AnimalJumpWorld")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "AnimalJumpWorld"
world.Parent = workspace

local function makePart(name, size, position, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Parent = world
	return p
end

local function makeSign(position, text, color)
	local sign = makePart("Sign", Vector3.new(32, 8, 1), position, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.25
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- Βάση και σημείο που εμφανίζεται ο παίκτης.
local base = makePart("Base", Vector3.new(100, 3, 100), Vector3.new(0, 0, 0), Color3.fromRGB(251, 204, 109))
base.Material = Enum.Material.Sand
local spawn = Instance.new("SpawnLocation")
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 2, -28)
spawn.Anchored = true
spawn.Neutral = true
spawn.Color = Color3.fromRGB(255, 235, 59)
spawn.Parent = world
makeSign(Vector3.new(0, 12, -42), "🐾 JUMP FOR ANIMALS", Color3.fromRGB(47, 127, 215))

-- Ο ψηλός μαύρος πύργος στη μέση.
local tower = makePart("SkyTower", Vector3.new(18, 240, 18), Vector3.new(0, 120, 15), Color3.fromRGB(34, 37, 49))
tower.Material = Enum.Material.Slate

-- 54 μικρά, χρωματιστά σκαλοπάτια που γυρίζουν γύρω από τον πύργο.
-- Κάθε επόμενο είναι μόνο 3 studs πιο ψηλά: γίνεται με το αρχικό άλμα.
local steps = {}
for number = 1, 54 do
	local angle = number * 0.47
	local position = Vector3.new(math.cos(angle) * 20, 3 + number * 3.2, 15 + math.sin(angle) * 20)
	table.insert(steps, position)
	local step = makePart("Step" .. number, Vector3.new(11, 2, 11), position, Color3.fromHSV((number % 12) / 12, 0.76, 1))
	step.Material = Enum.Material.Neon
end

local animals = {
	{"🐶 Σκυλάκι", Color3.fromRGB(151, 91, 48), 6},
	{"🐱 Γατάκι", Color3.fromRGB(255, 173, 69), 13},
	{"🐰 Κουνελάκι", Color3.fromRGB(245, 245, 250), 20},
	{"🦊 Αλεπού", Color3.fromRGB(239, 104, 27), 28},
	{"🐼 Πάντα", Color3.fromRGB(72, 72, 82), 36},
	{"🦁 Λιοντάρι", Color3.fromRGB(255, 195, 24), 45},
	{"🐉 Δράκος", Color3.fromRGB(137, 77, 202), 54},
}

local function hasAnimal(player, name)
	return player.AnimalCollection:FindFirstChild(name) ~= nil
end

local function addAnimal(info)
	local name, color, stepNumber = info[1], info[2], info[3]
	local position = steps[stepNumber] + Vector3.new(0, 4, 0)
	local pet = makePart("Pet" .. stepNumber, Vector3.new(5, 5, 5), position, color)
	pet.Shape = Enum.PartType.Ball
	pet.Material = Enum.Material.Neon
	pet.CanCollide = false
	local glow = Instance.new("PointLight")
	glow.Color = color
	glow.Range = 13
	glow.Brightness = 2
	glow.Parent = pet
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(180, 48)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = pet
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name .. "\nΠΑΡΕ ΜΕ!"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	TweenService:Create(pet, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = position + Vector3.new(0, 1.5, 0)}):Play()
	pet.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or hasAnimal(player, name) then return end
		local item = Instance.new("StringValue")
		item.Name = name
		item.Parent = player.AnimalCollection
		player.leaderstats.Animals.Value += 1
		event:FireClient(player, "Animal", name)
		event:FireClient(player, "Message", "🎉 Πήρες το " .. name .. "!")
	end)
end
for _, info in ipairs(animals) do addAnimal(info) end

local function addCrystal(stepNumber)
	local position = steps[stepNumber] + Vector3.new(0, 3, 0)
	local crystal = makePart("Crystal", Vector3.new(2.5, 2.5, 2.5), position, Color3.fromRGB(0, 245, 255))
	crystal.Shape = Enum.PartType.Ball
	crystal.Material = Enum.Material.Neon
	crystal.CanCollide = false
	local used = false
	crystal.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or used then return end
		used = true
		player.leaderstats.Crystals.Value += 1
		event:FireClient(player, "Message", "+1 κρύσταλλος 💎")
		crystal:Destroy()
		task.delay(5, function() addCrystal(stepNumber) end)
	end)
end
for n = 3, 52, 4 do addCrystal(n) end

local function applyStats(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.UseJumpPower = true
	humanoid.WalkSpeed = 16 + player.SpeedLevel.Value * 3
	humanoid.JumpPower = 50 + player.JumpLevel.Value * 10
end

local function setUpPlayer(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	for _, name in ipairs({"Crystals", "Animals"}) do
		local value = Instance.new("IntValue")
		value.Name = name
		value.Parent = stats
	end
	for _, name in ipairs({"SpeedLevel", "JumpLevel"}) do
		local value = Instance.new("IntValue")
		value.Name = name
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

local function buy(player, upgrade)
	local level = player[upgrade .. "Level"]
	local crystals = player.leaderstats.Crystals
	local cost = 3 + level.Value * 3
	if crystals.Value < cost then
		event:FireClient(player, "Message", "Θέλεις " .. cost .. " κρυστάλλους.")
		return
	end
	crystals.Value -= cost
	level.Value += 1
	if player.Character then applyStats(player, player.Character) end
	event:FireClient(player, "Message", "Αναβάθμιση " .. upgrade .. " επιπέδου " .. level.Value .. "!")
end

event.OnServerEvent:Connect(function(player, action)
	if action == "Jump" then buy(player, "Jump") end
	if action == "Speed" then buy(player, "Speed") end
	if action == "Tower" and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(steps[1] + Vector3.new(0, 5, 0)) end
	end
end)
