-- Crystal Rush | LocalScript
-- Βάλ' το ως LocalScript μέσα στο StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("CrystalRushEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "CrystalRushUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(260, 145)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
panel.BackgroundTransparency = 0.12
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundTransparency = 1
title.Text = "💎 CRYSTAL RUSH"
title.TextColor3 = Color3.fromRGB(80, 245, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = panel

local function button(text, y, action, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 38)
	b.Position = UDim2.fromOffset(10, y)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.Parent = panel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.Activated:Connect(function() remote:FireServer(action) end)
end
button("⚡ Αγορά Ταχύτητας", 48, "Speed", Color3.fromRGB(43, 126, 211))
button("⬆ Αγορά Άλματος", 96, "Jump", Color3.fromRGB(120, 76, 190))

local message = Instance.new("TextLabel")
message.Size = UDim2.new(0, 420, 0, 48)
message.Position = UDim2.new(0.5, -210, 0.12, 0)
message.BackgroundTransparency = 1
message.TextColor3 = Color3.fromRGB(255, 255, 255)
message.TextStrokeTransparency = 0.45
message.TextScaled = true
message.Font = Enum.Font.GothamBold
message.Parent = gui

remote.OnClientEvent:Connect(function(kind, text)
	if kind == "Message" then
		message.Text = text
		task.delay(2, function()
			if message.Text == text then message.Text = "" end
		end)
	end
end)
