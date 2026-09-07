-- JUMP FOR ANIMALS | LocalScript
-- Βάλ' το στο StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("AnimalJumpEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "AnimalJumpUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(285, 256)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(31, 42, 72)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundTransparency = 1
title.Text = "🐾 JUMP FOR ANIMALS"
title.TextColor3 = Color3.fromRGB(255, 230, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = panel

local function makeButton(text, y, action, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 38)
	button.Position = UDim2.fromOffset(10, y)
	button.BackgroundColor3 = color
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = panel
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
	button.Activated:Connect(function() event:FireServer(action) end)
end
makeButton("🚪 ΠΗΓΑΙΝΕ ΣΤΟΝ ΠΥΡΓΟ", 48, "Tower", Color3.fromRGB(224, 76, 82))
makeButton("⬆ Αγορά Άλματος", 92, "Jump", Color3.fromRGB(119, 82, 194))
makeButton("⚡ Αγορά Ταχύτητας", 136, "Speed", Color3.fromRGB(43, 126, 211))

local collection = Instance.new("TextLabel")
collection.Size = UDim2.new(1, -20, 0, 60)
collection.Position = UDim2.fromOffset(10, 184)
collection.BackgroundTransparency = 1
collection.Text = "Ζώα που βρήκες:\n(ακόμη κανένα)"
collection.TextColor3 = Color3.fromRGB(255, 255, 255)
collection.TextWrapped = true
collection.TextSize = 16
collection.Font = Enum.Font.Gotham
collection.Parent = panel

local message = Instance.new("TextLabel")
message.Size = UDim2.fromOffset(560, 48)
message.Position = UDim2.new(0.5, -280, 0.12, 0)
message.BackgroundTransparency = 1
message.TextColor3 = Color3.new(1, 1, 1)
message.TextStrokeTransparency = 0.35
message.TextScaled = true
message.Font = Enum.Font.GothamBold
message.Parent = gui

local found = {}
event.OnClientEvent:Connect(function(kind, text)
	if kind == "Animal" then
		table.insert(found, text)
		collection.Text = "Ζώα που βρήκες (" .. #found .. "):\n" .. table.concat(found, "  ")
	elseif kind == "Message" then
		message.Text = text
		task.delay(2.5, function()
			if message.Text == text then message.Text = "" end
		end)
	end
end)
