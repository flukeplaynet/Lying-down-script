local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local isLyingDown = true
local speed = humanoid.WalkSpeed 

local bodyGyro, bodyVelocity

local function jump()
    if isLyingDown then
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -1, 0) * 3  -- adjust length if needed
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
        if rayResult then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, humanoid.JumpPower, hrp.Velocity.Z)
        end
    end
end

if UserInputService.TouchEnabled then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomJumpGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local jumpButton = Instance.new("TextButton")
    jumpButton.Name = "JumpButton"
    jumpButton.Text = "Jump"
    jumpButton.Size = UDim2.new(0, 100, 0, 50)
    jumpButton.Position = UDim2.new(1, -110, 1, -60)
    jumpButton.Parent = screenGui
    
    jumpButton.Activated:Connect(function()
        jump()
    end)
end

local function enableLyingDown()
    isLyingDown = true
    humanoid.PlatformStand = true

    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.D = 500
        bodyGyro.P = 3000
        bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyGyro.Parent = hrp
    end

    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)  -- leave Y unaffected
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
    end

    bodyGyro.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(90), 0, 0)
end

local function disableLyingDown()
    isLyingDown = false
    humanoid.PlatformStand = false

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    hrp.CFrame = CFrame.new(hrp.Position)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.L then
        if isLyingDown then
            disableLyingDown()
        else
            enableLyingDown()
        end
    elseif input.KeyCode == Enum.KeyCode.Space then
        jump()
    end
end)

enableLyingDown()

RunService.RenderStepped:Connect(function()
    if isLyingDown and bodyVelocity and bodyGyro then
        local moveDir = humanoid.MoveDirection
        bodyVelocity.Velocity = moveDir * humanoid.WalkSpeed
        
        bodyGyro.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(90), 0, 0)
    end
end)
