-- put this in localscript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

local walkspeed = 10
local runspeed = 20
local sprintkey = Enum.KeyCode.LeftShift

local humanoid
local focused = true
local menuOpen = GuiService.MenuIsOpen
local sprinting = false

local function setSprint(state)
	sprinting = state

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	humanoid.WalkSpeed = state and runspeed or walkspeed
end

local function stopSprint()
	setSprint(false)
end

local function setupCharacter(character)
	humanoid = nil
	sprinting = false

	local hum = character:WaitForChild("Humanoid", 10)

	if player.Character ~= character then return end
	if not hum or not hum:IsA("Humanoid") then return end

	humanoid = hum
	setSprint(false)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode ~= sprintkey then return end
	if processed or not focused or menuOpen then return end
	if UserInputService:GetFocusedTextBox() then return end

	setSprint(true)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode ~= sprintkey then return end
	stopSprint()
end)

UserInputService.WindowFocusReleased:Connect(function()
	focused = false
	stopSprint()
end)

UserInputService.WindowFocused:Connect(function()
	focused = true
end)

UserInputService.TextBoxFocused:Connect(stopSprint)

GuiService.MenuOpened:Connect(function()
	menuOpen = true
	stopSprint()
end)

GuiService.MenuClosed:Connect(function()
	menuOpen = false
end)

player.CharacterRemoving:Connect(function(character)
	if humanoid and humanoid:IsDescendantOf(character) then
		humanoid = nil
		sprinting = false
	end
end)

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	task.spawn(setupCharacter, player.Character)
end