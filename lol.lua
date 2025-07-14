--[=[
 ██╗     ██╗   ██╗██████╗ ██╗  ██╗    ██║  ██║ █████╗  ██████╗██╗  ██╗
 ██║     ██║   ██║██╔══██╗██║ ██╔╝    ██║  ██║██╔══██╗██╔════╝██║ ██╔╝
 ██║     ██║   ██║██████╔╝█████╔╝     ███████║███████║██║     █████╔╝ 
 ██║     ██║   ██║██╔══██╗██╔═██╗     ██╔══██║██╔══██║██║     ██╔═██╗ 
 ███████╗╚██████╔╝██║  ██║██║  ██╗    ██║  ██║██║  ██║╚██████╗██║  ██╗
 ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
]=]

-- Enhanced LURK HACK v2.1
-- Ultra Optimized for Zero Lag Performance
-- Instances: 218 | Scripts: 37 | Modules: 0 | Tags: 0

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local G2L = {};

local PerformanceConfig = {
    LoadDelay = 0.1,
    BatchSize = 5,
    MaxConnections = 50,
    UpdateInterval = 0.1,
    MemoryLimit = 1000
}

local Settings = {
    ESPColor = Color3.fromRGB(0, 170, 255),
    BaseNotificationEnabled = false,
    BaseNotificationRange = 50,
    NotificationSound = true,
    UITheme = "Dark"
}

local ConnectionManager = {
    connections = {},
    count = 0
}

function ConnectionManager:Add(connection)
    if self.count >= PerformanceConfig.MaxConnections then
        self.connections[1]:Disconnect()
        table.remove(self.connections, 1)
        self.count = self.count - 1
    end
    
    table.insert(self.connections, connection)
    self.count = self.count + 1
end

function ConnectionManager:Cleanup()
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
    self.count = 0
end

local BaseNotificationSystem = {
    enabled = false,
    basePosition = Vector3.new(0, 0, 0),
    lastNotification = 0,
    notificationCooldown = 5
}

function BaseNotificationSystem:Initialize()
    if not Settings.BaseNotificationEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    self.basePosition = rootPart.Position
    self.enabled = true
    
    ConnectionManager:Add(RunService.Heartbeat:Connect(function()
        if not self.enabled or not Settings.BaseNotificationEnabled then return end
        
        local currentTime = tick()
        if currentTime - self.lastNotification < self.notificationCooldown then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerChar = player.Character
                if playerChar then
                    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
                    if playerRoot then
                        local distance = (playerRoot.Position - self.basePosition).Magnitude
                        if distance <= Settings.BaseNotificationRange then
                            self:ShowNotification(player.Name .. " entered your base!")
                            self.lastNotification = currentTime
                            break
                        end
                    end
                end
            end
        end
    end))
end

function BaseNotificationSystem:ShowNotification(message)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "BaseNotification"
    notificationGui.Parent = PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "BASE ALERT!"
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 20)
    messageLabel.Position = UDim2.new(0, 10, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = frame
    
    local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 0, 20)
    })
    tween:Play()
    
    task.delay(4, function()
        local fadeOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, 20)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            notificationGui:Destroy()
        end)
    end)
    
    if Settings.NotificationSound then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        sound.Volume = 0.5
        sound.Parent = frame
        sound:Play()
    end
end

-- StarterGui.Lurk
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["Name"] = [[Lurk]];
G2L["1"]["ResetOnSpawn"] = false;


-- StarterGui.Lurk.Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["Active"] = true;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(18, 18, 28);
G2L["2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["2"]["Size"] = UDim2.new(0, 350, 0, 450);
G2L["2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.Lurk.Frame.UICorner
G2L["3"] = Instance.new("UICorner", G2L["2"]);



-- StarterGui.Lurk.Frame.UIStroke
G2L["4"] = Instance.new("UIStroke", G2L["2"]);
G2L["4"]["Color"] = Color3.fromRGB(0, 170, 255);
G2L["4"]["Thickness"] = 2;


-- StarterGui.Lurk.Frame.top
G2L["5"] = Instance.new("Frame", G2L["2"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(12, 12, 18);
G2L["5"]["Size"] = UDim2.new(1, 0, 0, 45);
G2L["5"]["Name"] = [[top]];


-- StarterGui.Lurk.Frame.top.UICorner
G2L["6"] = Instance.new("UICorner", G2L["5"]);



-- StarterGui.Lurk.Frame.top.TextLabel
G2L["7"] = Instance.new("TextLabel", G2L["5"]);
G2L["7"]["TextSize"] = 20;
G2L["7"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["7"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["7"]["TextColor3"] = Color3.fromRGB(0, 200, 255);
G2L["7"]["BackgroundTransparency"] = 1;
G2L["7"]["Size"] = UDim2.new(1, -50, 1, 0);
G2L["7"]["Text"] = [[LURK HACK v2.2]];
G2L["7"]["Position"] = UDim2.new(0, 15, 0, 0);


-- StarterGui.Lurk.Frame.top.Close
G2L["8"] = Instance.new("TextButton", G2L["5"]);
G2L["8"]["TextSize"] = 20;
G2L["8"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(220, 60, 60);
G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["8"]["Size"] = UDim2.new(0, 32, 0, 32);
G2L["8"]["Text"] = [[×]];
G2L["8"]["Name"] = [[Close]];
G2L["8"]["Position"] = UDim2.new(1, -37, 0, 4);


-- StarterGui.Lurk.Frame.top.Close.UICorner
G2L["9"] = Instance.new("UICorner", G2L["8"]);
G2L["9"]["CornerRadius"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.top.Close.LocalScript
G2L["a"] = Instance.new("LocalScript", G2L["8"]);



-- StarterGui.Lurk.Frame.tabs
G2L["b"] = Instance.new("Frame", G2L["2"]);
G2L["b"]["Size"] = UDim2.new(1, -20, 0, 40);
G2L["b"]["Position"] = UDim2.new(0, 10, 0, 50);
G2L["b"]["Name"] = [[tabs]];
G2L["b"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.tabs.UIListLayout
G2L["c"] = Instance.new("UIListLayout", G2L["b"]);
G2L["c"]["Padding"] = UDim.new(0, 5);
G2L["c"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["c"]["FillDirection"] = Enum.FillDirection.Horizontal;


-- StarterGui.Lurk.Frame.tabs.mainbtn
G2L["d"] = Instance.new("TextButton", G2L["b"]);
G2L["d"]["TextSize"] = 14;
G2L["d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(0, 170, 255);
G2L["d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["d"]["Size"] = UDim2.new(0.24, 0, 1, 0);
G2L["d"]["Text"] = [[Main]];
G2L["d"]["Name"] = [[mainbtn]];


-- StarterGui.Lurk.Frame.tabs.mainbtn.UICorner
G2L["e"] = Instance.new("UICorner", G2L["d"]);
G2L["e"]["CornerRadius"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.tabs.visualbtn
G2L["f"] = Instance.new("TextButton", G2L["b"]);
G2L["f"]["TextSize"] = 14;
G2L["f"]["TextColor3"] = Color3.fromRGB(200, 200, 200);
G2L["f"]["SelectionOrder"] = 1;
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(35, 35, 45);
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["f"]["Size"] = UDim2.new(0.24, 0, 1, 0);
G2L["f"]["Text"] = [[Visual]];
G2L["f"]["Name"] = [[visualbtn]];


-- StarterGui.Lurk.Frame.tabs.visualbtn.UICorner
G2L["10"] = Instance.new("UICorner", G2L["f"]);
G2L["10"]["CornerRadius"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.tabs.miscbtn
G2L["11"] = Instance.new("TextButton", G2L["b"]);
G2L["11"]["TextSize"] = 14;
G2L["11"]["TextColor3"] = Color3.fromRGB(200, 200, 200);
G2L["11"]["BackgroundColor3"] = Color3.fromRGB(35, 35, 45);
G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["11"]["Size"] = UDim2.new(0.24, 0, 1, 0);
G2L["11"]["Text"] = [[Misc]];
G2L["11"]["Name"] = [[miscbtn]];


-- StarterGui.Lurk.Frame.tabs.miscbtn.UICorner
G2L["12"] = Instance.new("UICorner", G2L["11"]);
G2L["12"]["CornerRadius"] = UDim.new(0, 8);

-- StarterGui.Lurk.Frame.tabs.settingsbtn
G2L["settingsbtn"] = Instance.new("TextButton", G2L["b"]);
G2L["settingsbtn"]["TextSize"] = 14;
G2L["settingsbtn"]["TextColor3"] = Color3.fromRGB(200, 200, 200);
G2L["settingsbtn"]["BackgroundColor3"] = Color3.fromRGB(35, 35, 45);
G2L["settingsbtn"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["settingsbtn"]["Size"] = UDim2.new(0.24, 0, 1, 0);
G2L["settingsbtn"]["Text"] = [[Settings]];
G2L["settingsbtn"]["Name"] = [[settingsbtn]];

-- StarterGui.Lurk.Frame.tabs.settingsbtn.UICorner
G2L["settingsbtn_corner"] = Instance.new("UICorner", G2L["settingsbtn"]);
G2L["settingsbtn_corner"]["CornerRadius"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.ScrollingFrame
G2L["13"] = Instance.new("ScrollingFrame", G2L["2"]);
G2L["13"]["BorderSizePixel"] = 0;
G2L["13"]["CanvasSize"] = UDim2.new(0, 0, 0, 200);
G2L["13"]["Size"] = UDim2.new(1, -20, 1, -100);
G2L["13"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 170, 255);
G2L["13"]["Position"] = UDim2.new(0, 10, 0, 95);
G2L["13"]["ScrollBarThickness"] = 6;
G2L["13"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.UIListLayout
G2L["14"] = Instance.new("UIListLayout", G2L["13"]);
G2L["14"]["Padding"] = UDim.new(0, 10);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual
G2L["15"] = Instance.new("Frame", G2L["13"]);
G2L["15"]["AutomaticSize"] = Enum.AutomaticSize.Y;
G2L["15"]["Size"] = UDim2.new(1, 0, 0, 0);
G2L["15"]["Name"] = [[visual]];
G2L["15"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.UIListLayout
G2L["16"] = Instance.new("UIListLayout", G2L["15"]);
G2L["16"]["Padding"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame
G2L["17"] = Instance.new("Frame", G2L["15"]);
G2L["17"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["17"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextLabel
G2L["18"] = Instance.new("TextLabel", G2L["17"]);
G2L["18"]["TextSize"] = 14;
G2L["18"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["18"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["18"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["18"]["BackgroundTransparency"] = 1;
G2L["18"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["18"]["Text"] = [[Esp HighLight]];


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton
G2L["19"] = Instance.new("TextButton", G2L["17"]);
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["19"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["19"]["Text"] = [[]];
G2L["19"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.UICorner
G2L["1a"] = Instance.new("UICorner", G2L["19"]);
G2L["1a"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame
G2L["1b"] = Instance.new("Frame", G2L["19"]);
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["1b"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["1b"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame.UICorner
G2L["1c"] = Instance.new("UICorner", G2L["1b"]);
G2L["1c"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
G2L["1d"] = Instance.new("LocalScript", G2L["19"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame
G2L["1e"] = Instance.new("Frame", G2L["15"]);
G2L["1e"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["1e"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextLabel
G2L["1f"] = Instance.new("TextLabel", G2L["1e"]);
G2L["1f"]["TextSize"] = 14;
G2L["1f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1f"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["1f"]["BackgroundTransparency"] = 1;
G2L["1f"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["1f"]["Text"] = [[Esp Name]];


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton
G2L["20"] = Instance.new("TextButton", G2L["1e"]);
G2L["20"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["20"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["20"]["Text"] = [[]];
G2L["20"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.UICorner
G2L["21"] = Instance.new("UICorner", G2L["20"]);
G2L["21"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame
G2L["22"] = Instance.new("Frame", G2L["20"]);
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["22"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["22"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame.UICorner
G2L["23"] = Instance.new("UICorner", G2L["22"]);
G2L["23"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
G2L["24"] = Instance.new("LocalScript", G2L["20"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame
G2L["25"] = Instance.new("Frame", G2L["15"]);
G2L["25"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["25"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextLabel
G2L["26"] = Instance.new("TextLabel", G2L["25"]);
G2L["26"]["TextSize"] = 14;
G2L["26"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["26"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["26"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["26"]["BackgroundTransparency"] = 1;
G2L["26"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["26"]["Text"] = [[Esp Base Time]];


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton
G2L["27"] = Instance.new("TextButton", G2L["25"]);
G2L["27"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["27"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["27"]["Text"] = [[]];
G2L["27"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.UICorner
G2L["28"] = Instance.new("UICorner", G2L["27"]);
G2L["28"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame
G2L["29"] = Instance.new("Frame", G2L["27"]);
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["29"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["29"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame.UICorner
G2L["2a"] = Instance.new("UICorner", G2L["29"]);
G2L["2a"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
G2L["2b"] = Instance.new("LocalScript", G2L["27"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame
G2L["2c"] = Instance.new("Frame", G2L["15"]);
G2L["2c"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["2c"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextLabel
G2L["2d"] = Instance.new("TextLabel", G2L["2c"]);
G2L["2d"]["TextSize"] = 14;
G2L["2d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2d"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["2d"]["BackgroundTransparency"] = 1;
G2L["2d"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["2d"]["Text"] = [[Esp Brainrot]];


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton
G2L["2e"] = Instance.new("TextButton", G2L["2c"]);
G2L["2e"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["2e"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["2e"]["Text"] = [[]];
G2L["2e"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.UICorner
G2L["2f"] = Instance.new("UICorner", G2L["2e"]);
G2L["2f"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame
G2L["30"] = Instance.new("Frame", G2L["2e"]);
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["30"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["30"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.Frame.UICorner
G2L["31"] = Instance.new("UICorner", G2L["30"]);
G2L["31"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
G2L["32"] = Instance.new("LocalScript", G2L["2e"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main
G2L["33"] = Instance.new("Frame", G2L["13"]);
G2L["33"]["Visible"] = false;
G2L["33"]["AutomaticSize"] = Enum.AutomaticSize.Y;
G2L["33"]["Size"] = UDim2.new(1, 0, 0, 0);
G2L["33"]["Name"] = [[main]];
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.UIListLayout
G2L["34"] = Instance.new("UIListLayout", G2L["33"]);
G2L["34"]["Padding"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["35"] = Instance.new("Frame", G2L["33"]);
G2L["35"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["35"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["36"] = Instance.new("TextLabel", G2L["35"]);
G2L["36"]["TextSize"] = 14;
G2L["36"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["36"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["36"]["BackgroundTransparency"] = 1;
G2L["36"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["36"]["Text"] = [[Air Jump]];


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton
G2L["37"] = Instance.new("TextButton", G2L["35"]);
G2L["37"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["37"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["37"]["Text"] = [[]];
G2L["37"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.UICorner
G2L["38"] = Instance.new("UICorner", G2L["37"]);
G2L["38"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame
G2L["39"] = Instance.new("Frame", G2L["37"]);
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["39"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["39"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame.UICorner
G2L["3a"] = Instance.new("UICorner", G2L["39"]);
G2L["3a"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
G2L["3b"] = Instance.new("LocalScript", G2L["37"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["3c"] = Instance.new("Frame", G2L["33"]);
G2L["3c"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["3c"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["3d"] = Instance.new("TextLabel", G2L["3c"]);
G2L["3d"]["TextSize"] = 14;
G2L["3d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["3d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3d"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["3d"]["BackgroundTransparency"] = 1;
G2L["3d"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["3d"]["Text"] = [[Speed Boost]];


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton
G2L["3e"] = Instance.new("TextButton", G2L["3c"]);
G2L["3e"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["3e"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["3e"]["Text"] = [[]];
G2L["3e"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.UICorner
G2L["3f"] = Instance.new("UICorner", G2L["3e"]);
G2L["3f"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame
G2L["40"] = Instance.new("Frame", G2L["3e"]);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["40"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["40"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame.UICorner
G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
G2L["42"] = Instance.new("LocalScript", G2L["3e"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["43"] = Instance.new("Frame", G2L["33"]);
G2L["43"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["43"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn
G2L["44"] = Instance.new("TextButton", G2L["43"]);
G2L["44"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["44"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["44"]["Text"] = [[]];
G2L["44"]["Name"] = [[FloatBtn]];
G2L["44"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn.UICorner
G2L["45"] = Instance.new("UICorner", G2L["44"]);
G2L["45"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn.Frame
G2L["46"] = Instance.new("Frame", G2L["44"]);
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["46"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["46"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn.Frame.UICorner
G2L["47"] = Instance.new("UICorner", G2L["46"]);
G2L["47"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn.LocalScript
G2L["48"] = Instance.new("LocalScript", G2L["44"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["49"] = Instance.new("TextLabel", G2L["43"]);
G2L["49"]["TextSize"] = 14;
G2L["49"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["49"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["49"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["49"]["BackgroundTransparency"] = 1;
G2L["49"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["49"]["Text"] = [[Float]];


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["4a"] = Instance.new("Frame", G2L["33"]);
G2L["4a"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["4a"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun
G2L["4b"] = Instance.new("TextButton", G2L["4a"]);
G2L["4b"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["4b"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["4b"]["Text"] = [[]];
G2L["4b"]["Name"] = [[antistun]];
G2L["4b"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun.UICorner
G2L["4c"] = Instance.new("UICorner", G2L["4b"]);
G2L["4c"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun.Frame
G2L["4d"] = Instance.new("Frame", G2L["4b"]);
G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["4d"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["4d"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun.Frame.UICorner
G2L["4e"] = Instance.new("UICorner", G2L["4d"]);
G2L["4e"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun.LocalScript
G2L["4f"] = Instance.new("LocalScript", G2L["4b"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["50"] = Instance.new("TextLabel", G2L["4a"]);
G2L["50"]["TextSize"] = 14;
G2L["50"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["50"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["50"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["50"]["BackgroundTransparency"] = 1;
G2L["50"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["50"]["Text"] = [[Anti Stun]];
G2L["50"]["Position"] = UDim2.new(0, 0, 0.06667, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["51"] = Instance.new("Frame", G2L["33"]);
G2L["51"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["51"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk
G2L["52"] = Instance.new("TextButton", G2L["51"]);
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["52"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["52"]["Text"] = [[]];
G2L["52"]["Name"] = [[antiafk]];
G2L["52"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk.UICorner
G2L["53"] = Instance.new("UICorner", G2L["52"]);
G2L["53"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk.Frame
G2L["54"] = Instance.new("Frame", G2L["52"]);
G2L["54"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["54"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["54"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk.Frame.UICorner
G2L["55"] = Instance.new("UICorner", G2L["54"]);
G2L["55"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk.LocalScript
G2L["56"] = Instance.new("LocalScript", G2L["52"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["57"] = Instance.new("TextLabel", G2L["51"]);
G2L["57"]["TextSize"] = 14;
G2L["57"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["57"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["57"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["57"]["BackgroundTransparency"] = 1;
G2L["57"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["57"]["Text"] = [[Anti Afk]];
G2L["57"]["Position"] = UDim2.new(0, 0, 0.06667, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame
G2L["58"] = Instance.new("Frame", G2L["33"]);
G2L["58"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["58"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton
G2L["59"] = Instance.new("TextButton", G2L["58"]);
G2L["59"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["59"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["59"]["Text"] = [[]];
G2L["59"]["Position"] = UDim2.new(1, -50, 0, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.UICorner
G2L["5a"] = Instance.new("UICorner", G2L["59"]);
G2L["5a"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame
G2L["5b"] = Instance.new("Frame", G2L["59"]);
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["5b"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["5b"]["Position"] = UDim2.new(0, 4, 0, 2);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.Frame.UICorner
G2L["5c"] = Instance.new("UICorner", G2L["5b"]);
G2L["5c"]["CornerRadius"] = UDim.new(0.5, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
G2L["5d"] = Instance.new("LocalScript", G2L["59"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
G2L["5e"] = Instance.new("LocalScript", G2L["59"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextLabel
G2L["5f"] = Instance.new("TextLabel", G2L["58"]);
G2L["5f"]["TextSize"] = 14;
G2L["5f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5f"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5f"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["5f"]["BackgroundTransparency"] = 1;
G2L["5f"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["5f"]["Text"] = [[Steal Helper]];
G2L["5f"]["Position"] = UDim2.new(0, 0, 0.06667, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc
G2L["60"] = Instance.new("Frame", G2L["13"]);
G2L["60"]["Visible"] = false;
G2L["60"]["AutomaticSize"] = Enum.AutomaticSize.Y;
G2L["60"]["Size"] = UDim2.new(1, 0, 0, 0);
G2L["60"]["Name"] = [[misc]];
G2L["60"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.UIListLayout
G2L["61"] = Instance.new("UIListLayout", G2L["60"]);
G2L["61"]["Padding"] = UDim.new(0, 8);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton
G2L["62"] = Instance.new("TextButton", G2L["60"]);
G2L["62"]["TextSize"] = 14;
G2L["62"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["62"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["62"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["62"]["Size"] = UDim2.new(0.99571, 0, 0.0084, 35);
G2L["62"]["Text"] = [[Invisibility Cloak]];
G2L["62"]["Position"] = UDim2.new(0, 0, 0.02671, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.UICorner
G2L["63"] = Instance.new("UICorner", G2L["62"]);
G2L["63"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
G2L["64"] = Instance.new("LocalScript", G2L["62"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton
G2L["65"] = Instance.new("TextButton", G2L["60"]);
G2L["65"]["TextSize"] = 14;
G2L["65"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["65"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["65"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["65"]["Size"] = UDim2.new(0.99571, 0, 0.0084, 35);
G2L["65"]["Text"] = [[Bee Launcher]];
G2L["65"]["Position"] = UDim2.new(0, 0, 0.02671, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.UICorner
G2L["66"] = Instance.new("UICorner", G2L["65"]);
G2L["66"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
G2L["67"] = Instance.new("LocalScript", G2L["65"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton
G2L["68"] = Instance.new("TextButton", G2L["60"]);
G2L["68"]["TextSize"] = 14;
G2L["68"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["68"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["68"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["68"]["Size"] = UDim2.new(0.99571, 0, 0.0084, 35);
G2L["68"]["Text"] = [[Medusa's Head]];
G2L["68"]["Position"] = UDim2.new(0, 0, 0.02671, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.UICorner
G2L["69"] = Instance.new("UICorner", G2L["68"]);
G2L["69"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
G2L["6a"] = Instance.new("LocalScript", G2L["68"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton
G2L["6b"] = Instance.new("TextButton", G2L["60"]);
G2L["6b"]["TextSize"] = 14;
G2L["6b"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["6b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["6b"]["Size"] = UDim2.new(0.99571, 0, 0.0084, 35);
G2L["6b"]["Text"] = [[Quantum Cloner]];
G2L["6b"]["Position"] = UDim2.new(0, 0, 0.02671, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.UICorner
G2L["6c"] = Instance.new("UICorner", G2L["6b"]);
G2L["6c"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
G2L["6d"] = Instance.new("LocalScript", G2L["6b"]);



-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton
G2L["6e"] = Instance.new("TextButton", G2L["60"]);
G2L["6e"]["TextSize"] = 14;
G2L["6e"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["6e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["6e"]["Size"] = UDim2.new(0.99571, 0, 0.0084, 35);
G2L["6e"]["Text"] = [[Rainbowrath Sword]];
G2L["6e"]["Position"] = UDim2.new(0, 0, 0.02671, 0);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.UICorner
G2L["6f"] = Instance.new("UICorner", G2L["6e"]);
G2L["6f"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
G2L["70"] = Instance.new("LocalScript", G2L["6e"]);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings
G2L["settings"] = Instance.new("Frame", G2L["13"]);
G2L["settings"]["AutomaticSize"] = Enum.AutomaticSize.Y;
G2L["settings"]["Size"] = UDim2.new(1, 0, 0, 0);
G2L["settings"]["Name"] = [[settings]];
G2L["settings"]["BackgroundTransparency"] = 1;

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.UIListLayout
G2L["settings_layout"] = Instance.new("UIListLayout", G2L["settings"]);
G2L["settings_layout"]["Padding"] = UDim.new(0, 8);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame
G2L["settings_frame1"] = Instance.new("Frame", G2L["settings"]);
G2L["settings_frame1"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["settings_frame1"]["BackgroundTransparency"] = 1;

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextLabel
G2L["settings_label1"] = Instance.new("TextLabel", G2L["settings_frame1"]);
G2L["settings_label1"]["TextSize"] = 14;
G2L["settings_label1"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["settings_label1"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["settings_label1"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["settings_label1"]["BackgroundTransparency"] = 1;
G2L["settings_label1"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["settings_label1"]["Text"] = [[Base Notification]];

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton
G2L["settings_btn1"] = Instance.new("TextButton", G2L["settings_frame1"]);
G2L["settings_btn1"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 81);
G2L["settings_btn1"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["settings_btn1"]["Text"] = [[]];
G2L["settings_btn1"]["Position"] = UDim2.new(1, -50, 0, 0);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.UICorner
G2L["settings_btn1_corner"] = Instance.new("UICorner", G2L["settings_btn1"]);
G2L["settings_btn1_corner"]["CornerRadius"] = UDim.new(0, 12);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.Frame
G2L["settings_btn1_frame"] = Instance.new("Frame", G2L["settings_btn1"]);
G2L["settings_btn1_frame"]["BackgroundColor3"] = Color3.fromRGB(241, 241, 241);
G2L["settings_btn1_frame"]["Size"] = UDim2.new(0, 21, 0, 21);
G2L["settings_btn1_frame"]["Position"] = UDim2.new(0, 4, 0, 2);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.Frame.UICorner
G2L["settings_btn1_frame_corner"] = Instance.new("UICorner", G2L["settings_btn1_frame"]);
G2L["settings_btn1_frame_corner"]["CornerRadius"] = UDim.new(0.5, 0);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.LocalScript
G2L["settings_btn1_script"] = Instance.new("LocalScript", G2L["settings_btn1"]);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame
G2L["settings_frame2"] = Instance.new("Frame", G2L["settings"]);
G2L["settings_frame2"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["settings_frame2"]["BackgroundTransparency"] = 1;

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextLabel
G2L["settings_label2"] = Instance.new("TextLabel", G2L["settings_frame2"]);
G2L["settings_label2"]["TextSize"] = 14;
G2L["settings_label2"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["settings_label2"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["settings_label2"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["settings_label2"]["BackgroundTransparency"] = 1;
G2L["settings_label2"]["Size"] = UDim2.new(0.7, 0, 1, 0);
G2L["settings_label2"]["Text"] = [[ESP Color]];

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton
G2L["settings_btn2"] = Instance.new("TextButton", G2L["settings_frame2"]);
G2L["settings_btn2"]["BackgroundColor3"] = Color3.fromRGB(0, 170, 255);
G2L["settings_btn2"]["Size"] = UDim2.new(0, 50, 0, 25);
G2L["settings_btn2"]["Text"] = [[]];
G2L["settings_btn2"]["Position"] = UDim2.new(1, -50, 0, 0);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.UICorner
G2L["settings_btn2_corner"] = Instance.new("UICorner", G2L["settings_btn2"]);
G2L["settings_btn2_corner"]["CornerRadius"] = UDim.new(0, 8);

-- StarterGui.Lurk.Frame.ScrollingFrame.settings.Frame.TextButton.LocalScript
G2L["settings_btn2_script"] = Instance.new("LocalScript", G2L["settings_btn2"]);



-- StarterGui.Lurk.Frame.LocalScript
G2L["71"] = Instance.new("LocalScript", G2L["2"]);



-- StarterGui.Lurk.S
G2L["72"] = Instance.new("Frame", G2L["1"]);
G2L["72"]["Visible"] = false;
G2L["72"]["Active"] = true;
G2L["72"]["BorderSizePixel"] = 0;
G2L["72"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["72"]["Size"] = UDim2.new(0, 123, 0, 55);
G2L["72"]["Position"] = UDim2.new(0.22838, 0, 0.40661, 0);
G2L["72"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["72"]["Name"] = [[S]];


-- StarterGui.Lurk.S.UICorner
G2L["73"] = Instance.new("UICorner", G2L["72"]);



-- StarterGui.Lurk.S.UIStroke
G2L["74"] = Instance.new("UIStroke", G2L["72"]);
G2L["74"]["Color"] = Color3.fromRGB(61, 61, 71);


-- StarterGui.Lurk.S.spid
G2L["75"] = Instance.new("TextButton", G2L["72"]);
G2L["75"]["TextSize"] = 14;
G2L["75"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["75"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["75"]["Size"] = UDim2.new(0.84105, 0, 0.0084, 35);
G2L["75"]["Text"] = [[Boost]];
G2L["75"]["Name"] = [[spid]];
G2L["75"]["Position"] = UDim2.new(0.07274, 0, 0.17114, 0);


-- StarterGui.Lurk.S.spid.UICorner
G2L["76"] = Instance.new("UICorner", G2L["75"]);
G2L["76"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.S.spid.Status
G2L["77"] = Instance.new("Frame", G2L["75"]);
G2L["77"]["BorderSizePixel"] = 0;
G2L["77"]["BackgroundColor3"] = Color3.fromRGB(172, 11, 11);
G2L["77"]["Size"] = UDim2.new(0, 13, 0, 13);
G2L["77"]["Position"] = UDim2.new(0.74604, 0, 0.3036, 0);
G2L["77"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["77"]["Name"] = [[Status]];


-- StarterGui.Lurk.S.spid.Status.UICorner
G2L["78"] = Instance.new("UICorner", G2L["77"]);
G2L["78"]["CornerRadius"] = UDim.new(0.9, 0);


-- StarterGui.Lurk.S.spid.LocalScript
G2L["79"] = Instance.new("LocalScript", G2L["75"]);



-- StarterGui.Lurk.S.LocalScript
G2L["7a"] = Instance.new("LocalScript", G2L["72"]);



-- StarterGui.Lurk.St
G2L["7b"] = Instance.new("Frame", G2L["1"]);
G2L["7b"]["Visible"] = false;
G2L["7b"]["Active"] = true;
G2L["7b"]["BorderSizePixel"] = 0;
G2L["7b"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["7b"]["Size"] = UDim2.new(0, 143, 0, 75);
G2L["7b"]["Position"] = UDim2.new(0.20894, 0, 0.53891, 0);
G2L["7b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7b"]["Name"] = [[St]];


-- StarterGui.Lurk.St.UICorner
G2L["7c"] = Instance.new("UICorner", G2L["7b"]);



-- StarterGui.Lurk.St.UIStroke
G2L["7d"] = Instance.new("UIStroke", G2L["7b"]);
G2L["7d"]["Color"] = Color3.fromRGB(61, 61, 71);


-- StarterGui.Lurk.St.Position
G2L["7e"] = Instance.new("TextLabel", G2L["7b"]);
G2L["7e"]["BorderSizePixel"] = 0;
G2L["7e"]["TextSize"] = 14;
G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7e"]["BackgroundTransparency"] = 1;
G2L["7e"]["Size"] = UDim2.new(0, 120, 0, 18);
G2L["7e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7e"]["Text"] = [[X.Y.Z]];
G2L["7e"]["Name"] = [[Position]];
G2L["7e"]["Position"] = UDim2.new(0.08104, 0, 0.76, 0);


-- StarterGui.Lurk.St.Position.LocalScript
G2L["7f"] = Instance.new("LocalScript", G2L["7e"]);



-- StarterGui.Lurk.St.LocalScript
G2L["80"] = Instance.new("LocalScript", G2L["7b"]);



-- StarterGui.Lurk.St.Button
G2L["81"] = Instance.new("TextButton", G2L["7b"]);
G2L["81"]["TextSize"] = 14;
G2L["81"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["81"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["81"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["81"]["Size"] = UDim2.new(0.93048, 0, 0.0084, 35);
G2L["81"]["Text"] = [[UP]];
G2L["81"]["Name"] = [[Button]];
G2L["81"]["Position"] = UDim2.new(0.03209, 0, 0.06205, 0);


-- StarterGui.Lurk.St.Button.UICorner
G2L["82"] = Instance.new("UICorner", G2L["81"]);
G2L["82"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.St.Button.LocalScript
G2L["83"] = Instance.new("LocalScript", G2L["81"]);



-- StarterGui.Lurk.Open
G2L["84"] = Instance.new("ImageButton", G2L["1"]);
G2L["84"]["BorderSizePixel"] = 0;
G2L["84"]["ScaleType"] = Enum.ScaleType.Crop;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["84"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["84"]["Image"] = [[rbxassetid://140272250553189]];
G2L["84"]["Size"] = UDim2.new(0, 50, 0, 50);
G2L["84"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["84"]["Name"] = [[Open]];
G2L["84"]["Position"] = UDim2.new(0.10155, 0, 0.5, 0);


-- StarterGui.Lurk.Open.UICorner
G2L["85"] = Instance.new("UICorner", G2L["84"]);
G2L["85"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.Open.LocalScript
G2L["86"] = Instance.new("LocalScript", G2L["84"]);



-- StarterGui.Lurk.Open.OpenScript
G2L["87"] = Instance.new("LocalScript", G2L["84"]);
G2L["87"]["Name"] = [[OpenScript]];


-- StarterGui.Lurk.Open.UIStroke
G2L["88"] = Instance.new("UIStroke", G2L["84"]);
G2L["88"]["Thickness"] = 2;
G2L["88"]["Color"] = Color3.fromRGB(73, 76, 118);


-- StarterGui.Lurk.F
G2L["89"] = Instance.new("Frame", G2L["1"]);
G2L["89"]["Visible"] = false;
G2L["89"]["Active"] = true;
G2L["89"]["BorderSizePixel"] = 0;
G2L["89"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["89"]["Size"] = UDim2.new(0, 187, 0, 86);
G2L["89"]["Position"] = UDim2.new(0.16618, 0, 0.71401, 0);
G2L["89"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["89"]["Name"] = [[F]];


-- StarterGui.Lurk.F.Draggable
G2L["8a"] = Instance.new("LocalScript", G2L["89"]);
G2L["8a"]["Name"] = [[Draggable]];


-- StarterGui.Lurk.F.Timer
G2L["8b"] = Instance.new("TextLabel", G2L["89"]);
G2L["8b"]["BorderSizePixel"] = 0;
G2L["8b"]["TextSize"] = 14;
G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["8b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8b"]["BackgroundTransparency"] = 0.1;
G2L["8b"]["Size"] = UDim2.new(0, 116, 0, 24);
G2L["8b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8b"]["Text"] = [[Timer: 0.0s]];
G2L["8b"]["Name"] = [[Timer]];
G2L["8b"]["Position"] = UDim2.new(0.18717, 0, 0.65116, 0);


-- StarterGui.Lurk.F.Timer.UICorner
G2L["8c"] = Instance.new("UICorner", G2L["8b"]);
G2L["8c"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.F.air
G2L["8d"] = Instance.new("TextButton", G2L["89"]);
G2L["8d"]["TextSize"] = 14;
G2L["8d"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["8d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["8d"]["Size"] = UDim2.new(0.93048, 0, 0.0084, 35);
G2L["8d"]["Text"] = [[Float & Move Forward]];
G2L["8d"]["Name"] = [[air]];
G2L["8d"]["Position"] = UDim2.new(0.03209, 0, 0.06205, 0);


-- StarterGui.Lurk.F.air.UICorner
G2L["8e"] = Instance.new("UICorner", G2L["8d"]);
G2L["8e"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.F.air.LocalScript
G2L["8f"] = Instance.new("LocalScript", G2L["8d"]);



-- StarterGui.Lurk.F.UIStroke
G2L["90"] = Instance.new("UIStroke", G2L["89"]);
G2L["90"]["Color"] = Color3.fromRGB(61, 61, 71);


-- StarterGui.Lurk.F.UICorner
G2L["91"] = Instance.new("UICorner", G2L["89"]);



-- StarterGui.Lurk.SwitchTabs
G2L["92"] = Instance.new("LocalScript", G2L["1"]);
G2L["92"]["Name"] = [[SwitchTabs]];


-- StarterGui.Lurk.MainFrame
G2L["93"] = Instance.new("Frame", G2L["1"]);
G2L["93"]["Visible"] = false;
G2L["93"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["93"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["93"]["ClipsDescendants"] = true;
G2L["93"]["Size"] = UDim2.new(0, 220, 0, 177);
G2L["93"]["Position"] = UDim2.new(0.76919, 0, 0.70817, 0);
G2L["93"]["Name"] = [[MainFrame]];


-- StarterGui.Lurk.MainFrame.UICorner
G2L["94"] = Instance.new("UICorner", G2L["93"]);
G2L["94"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.MainFrame.UIStroke
G2L["95"] = Instance.new("UIStroke", G2L["93"]);
G2L["95"]["Thickness"] = 2;
G2L["95"]["Color"] = Color3.fromRGB(61, 61, 81);


-- StarterGui.Lurk.MainFrame.Header
G2L["96"] = Instance.new("Frame", G2L["93"]);
G2L["96"]["BackgroundColor3"] = Color3.fromRGB(21, 21, 26);
G2L["96"]["Size"] = UDim2.new(1, 0, 0, 40);
G2L["96"]["Name"] = [[Header]];
G2L["96"]["BackgroundTransparency"] = 0.3;


-- StarterGui.Lurk.MainFrame.Header.UICorner
G2L["97"] = Instance.new("UICorner", G2L["96"]);
G2L["97"]["CornerRadius"] = UDim.new(0, 12);


-- StarterGui.Lurk.MainFrame.Header.Title
G2L["98"] = Instance.new("TextLabel", G2L["96"]);
G2L["98"]["TextSize"] = 18;
G2L["98"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["98"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["98"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["98"]["BackgroundTransparency"] = 1;
G2L["98"]["Size"] = UDim2.new(0.83182, -40, 1, 0);
G2L["98"]["Text"] = [[ESP BRAINROTS]];
G2L["98"]["Name"] = [[Title]];
G2L["98"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame
G2L["99"] = Instance.new("ScrollingFrame", G2L["93"]);
G2L["99"]["CanvasSize"] = UDim2.new(0, 0, 0, 304);
G2L["99"]["Name"] = [[ScrollFrame]];
G2L["99"]["ScrollBarImageTransparency"] = 1;
G2L["99"]["Size"] = UDim2.new(1, -10, 1, -50);
G2L["99"]["ScrollBarImageColor3"] = Color3.fromRGB(181, 181, 181);
G2L["99"]["Position"] = UDim2.new(0, 5, 0, 45);
G2L["99"]["ScrollBarThickness"] = 4;
G2L["99"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto
G2L["9a"] = Instance.new("Frame", G2L["99"]);
G2L["9a"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["9a"]["Name"] = [[Cocofanto Elefanto]];
G2L["9a"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button
G2L["9b"] = Instance.new("TextButton", G2L["9a"]);
G2L["9b"]["AutoButtonColor"] = false;
G2L["9b"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["9b"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["9b"]["Text"] = [[]];
G2L["9b"]["Name"] = [[Button]];
G2L["9b"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.UICorner
G2L["9c"] = Instance.new("UICorner", G2L["9b"]);
G2L["9c"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.Label
G2L["9d"] = Instance.new("TextLabel", G2L["9b"]);
G2L["9d"]["TextSize"] = 14;
G2L["9d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9d"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["9d"]["BackgroundTransparency"] = 1;
G2L["9d"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["9d"]["Text"] = [[Cocofanto Elefanto]];
G2L["9d"]["Name"] = [[Label]];
G2L["9d"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.Toggle
G2L["9e"] = Instance.new("Frame", G2L["9b"]);
G2L["9e"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["9e"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["9e"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["9e"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.Toggle.UICorner
G2L["9f"] = Instance.new("UICorner", G2L["9e"]);
G2L["9f"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.Toggle.UIStroke
G2L["a0"] = Instance.new("UIStroke", G2L["9e"]);
G2L["a0"]["Thickness"] = 2;
G2L["a0"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.LocalScript
G2L["a1"] = Instance.new("LocalScript", G2L["9b"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino
G2L["a2"] = Instance.new("Frame", G2L["99"]);
G2L["a2"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["a2"]["Position"] = UDim2.new(0, 0, 0, 38);
G2L["a2"]["Name"] = [[Gattatino Nyanino]];
G2L["a2"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button
G2L["a3"] = Instance.new("TextButton", G2L["a2"]);
G2L["a3"]["AutoButtonColor"] = false;
G2L["a3"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["a3"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["a3"]["Text"] = [[]];
G2L["a3"]["Name"] = [[Button]];
G2L["a3"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.UICorner
G2L["a4"] = Instance.new("UICorner", G2L["a3"]);
G2L["a4"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.Label
G2L["a5"] = Instance.new("TextLabel", G2L["a3"]);
G2L["a5"]["TextSize"] = 14;
G2L["a5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a5"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a5"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["a5"]["BackgroundTransparency"] = 1;
G2L["a5"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["a5"]["Text"] = [[Gattatino Nyanino]];
G2L["a5"]["Name"] = [[Label]];
G2L["a5"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.Toggle
G2L["a6"] = Instance.new("Frame", G2L["a3"]);
G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["a6"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["a6"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["a6"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.Toggle.UICorner
G2L["a7"] = Instance.new("UICorner", G2L["a6"]);
G2L["a7"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.Toggle.UIStroke
G2L["a8"] = Instance.new("UIStroke", G2L["a6"]);
G2L["a8"]["Thickness"] = 2;
G2L["a8"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.LocalScript
G2L["a9"] = Instance.new("LocalScript", G2L["a3"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre
G2L["aa"] = Instance.new("Frame", G2L["99"]);
G2L["aa"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["aa"]["Position"] = UDim2.new(0, 0, 0, 76);
G2L["aa"]["Name"] = [[Girafa Celestre]];
G2L["aa"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button
G2L["ab"] = Instance.new("TextButton", G2L["aa"]);
G2L["ab"]["AutoButtonColor"] = false;
G2L["ab"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["ab"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["ab"]["Text"] = [[]];
G2L["ab"]["Name"] = [[Button]];
G2L["ab"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.UICorner
G2L["ac"] = Instance.new("UICorner", G2L["ab"]);
G2L["ac"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.Label
G2L["ad"] = Instance.new("TextLabel", G2L["ab"]);
G2L["ad"]["TextSize"] = 14;
G2L["ad"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ad"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ad"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["ad"]["BackgroundTransparency"] = 1;
G2L["ad"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["ad"]["Text"] = [[Girafa Celestre]];
G2L["ad"]["Name"] = [[Label]];
G2L["ad"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.Toggle
G2L["ae"] = Instance.new("Frame", G2L["ab"]);
G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["ae"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["ae"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["ae"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.Toggle.UICorner
G2L["af"] = Instance.new("UICorner", G2L["ae"]);
G2L["af"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.Toggle.UIStroke
G2L["b0"] = Instance.new("UIStroke", G2L["ae"]);
G2L["b0"]["Thickness"] = 2;
G2L["b0"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.LocalScript
G2L["b1"] = Instance.new("LocalScript", G2L["ab"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala
G2L["b2"] = Instance.new("Frame", G2L["99"]);
G2L["b2"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["b2"]["Position"] = UDim2.new(0, 0, 0, 114);
G2L["b2"]["Name"] = [[Tralalero Tralala]];
G2L["b2"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button
G2L["b3"] = Instance.new("TextButton", G2L["b2"]);
G2L["b3"]["AutoButtonColor"] = false;
G2L["b3"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["b3"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["b3"]["Text"] = [[]];
G2L["b3"]["Name"] = [[Button]];
G2L["b3"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.UICorner
G2L["b4"] = Instance.new("UICorner", G2L["b3"]);
G2L["b4"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.Label
G2L["b5"] = Instance.new("TextLabel", G2L["b3"]);
G2L["b5"]["TextSize"] = 14;
G2L["b5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b5"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b5"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["b5"]["BackgroundTransparency"] = 1;
G2L["b5"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["b5"]["Text"] = [[Tralalero Tralala]];
G2L["b5"]["Name"] = [[Label]];
G2L["b5"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.Toggle
G2L["b6"] = Instance.new("Frame", G2L["b3"]);
G2L["b6"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["b6"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["b6"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["b6"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.Toggle.UICorner
G2L["b7"] = Instance.new("UICorner", G2L["b6"]);
G2L["b7"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.Toggle.UIStroke
G2L["b8"] = Instance.new("UIStroke", G2L["b6"]);
G2L["b8"]["Thickness"] = 2;
G2L["b8"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.LocalScript
G2L["b9"] = Instance.new("LocalScript", G2L["b3"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo
G2L["ba"] = Instance.new("Frame", G2L["99"]);
G2L["ba"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["ba"]["Position"] = UDim2.new(0, 0, 0, 152);
G2L["ba"]["Name"] = [[Matteo]];
G2L["ba"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button
G2L["bb"] = Instance.new("TextButton", G2L["ba"]);
G2L["bb"]["AutoButtonColor"] = false;
G2L["bb"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["bb"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["bb"]["Text"] = [[]];
G2L["bb"]["Name"] = [[Button]];
G2L["bb"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.UICorner
G2L["bc"] = Instance.new("UICorner", G2L["bb"]);
G2L["bc"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.Label
G2L["bd"] = Instance.new("TextLabel", G2L["bb"]);
G2L["bd"]["TextSize"] = 14;
G2L["bd"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["bd"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["bd"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["bd"]["BackgroundTransparency"] = 1;
G2L["bd"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["bd"]["Text"] = [[Matteo]];
G2L["bd"]["Name"] = [[Label]];
G2L["bd"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.Toggle
G2L["be"] = Instance.new("Frame", G2L["bb"]);
G2L["be"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["be"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["be"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["be"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.Toggle.UICorner
G2L["bf"] = Instance.new("UICorner", G2L["be"]);
G2L["bf"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.Toggle.UIStroke
G2L["c0"] = Instance.new("UIStroke", G2L["be"]);
G2L["c0"]["Thickness"] = 2;
G2L["c0"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.LocalScript
G2L["c1"] = Instance.new("LocalScript", G2L["bb"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun
G2L["c2"] = Instance.new("Frame", G2L["99"]);
G2L["c2"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["c2"]["Position"] = UDim2.new(0, 0, 0, 190);
G2L["c2"]["Name"] = [[Odin Din Din Dun]];
G2L["c2"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button
G2L["c3"] = Instance.new("TextButton", G2L["c2"]);
G2L["c3"]["AutoButtonColor"] = false;
G2L["c3"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["c3"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["c3"]["Text"] = [[]];
G2L["c3"]["Name"] = [[Button]];
G2L["c3"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.UICorner
G2L["c4"] = Instance.new("UICorner", G2L["c3"]);
G2L["c4"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.Label
G2L["c5"] = Instance.new("TextLabel", G2L["c3"]);
G2L["c5"]["TextSize"] = 14;
G2L["c5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["c5"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c5"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["c5"]["BackgroundTransparency"] = 1;
G2L["c5"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["c5"]["Text"] = [[Odin Din Din Dun]];
G2L["c5"]["Name"] = [[Label]];
G2L["c5"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.Toggle
G2L["c6"] = Instance.new("Frame", G2L["c3"]);
G2L["c6"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["c6"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["c6"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["c6"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.Toggle.UICorner
G2L["c7"] = Instance.new("UICorner", G2L["c6"]);
G2L["c7"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.Toggle.UIStroke
G2L["c8"] = Instance.new("UIStroke", G2L["c6"]);
G2L["c8"]["Thickness"] = 2;
G2L["c8"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.LocalScript
G2L["c9"] = Instance.new("LocalScript", G2L["c3"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000
G2L["ca"] = Instance.new("Frame", G2L["99"]);
G2L["ca"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["ca"]["Position"] = UDim2.new(0, 0, 0, 228);
G2L["ca"]["Name"] = [[Trenostruzzo Turbo 3000]];
G2L["ca"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button
G2L["cb"] = Instance.new("TextButton", G2L["ca"]);
G2L["cb"]["AutoButtonColor"] = false;
G2L["cb"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["cb"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["cb"]["Text"] = [[]];
G2L["cb"]["Name"] = [[Button]];
G2L["cb"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.UICorner
G2L["cc"] = Instance.new("UICorner", G2L["cb"]);
G2L["cc"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.Label
G2L["cd"] = Instance.new("TextLabel", G2L["cb"]);
G2L["cd"]["TextSize"] = 14;
G2L["cd"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["cd"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["cd"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["cd"]["BackgroundTransparency"] = 1;
G2L["cd"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["cd"]["Text"] = [[Trenostruzzo Turbo 3000]];
G2L["cd"]["Name"] = [[Label]];
G2L["cd"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.Toggle
G2L["ce"] = Instance.new("Frame", G2L["cb"]);
G2L["ce"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["ce"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["ce"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["ce"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.Toggle.UICorner
G2L["cf"] = Instance.new("UICorner", G2L["ce"]);
G2L["cf"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.Toggle.UIStroke
G2L["d0"] = Instance.new("UIStroke", G2L["ce"]);
G2L["d0"]["Thickness"] = 2;
G2L["d0"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.LocalScript
G2L["d1"] = Instance.new("LocalScript", G2L["cb"]);



-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito
G2L["d2"] = Instance.new("Frame", G2L["99"]);
G2L["d2"]["Size"] = UDim2.new(1, 0, 0, 36);
G2L["d2"]["Position"] = UDim2.new(0, 0, 0, 266);
G2L["d2"]["Name"] = [[Unclito Samito]];
G2L["d2"]["BackgroundTransparency"] = 1;


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button
G2L["d3"] = Instance.new("TextButton", G2L["d2"]);
G2L["d3"]["AutoButtonColor"] = false;
G2L["d3"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 51);
G2L["d3"]["Size"] = UDim2.new(1, -10, 1, -6);
G2L["d3"]["Text"] = [[]];
G2L["d3"]["Name"] = [[Button]];
G2L["d3"]["Position"] = UDim2.new(0, 5, 0, 3);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.UICorner
G2L["d4"] = Instance.new("UICorner", G2L["d3"]);
G2L["d4"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.Label
G2L["d5"] = Instance.new("TextLabel", G2L["d3"]);
G2L["d5"]["TextSize"] = 14;
G2L["d5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["d5"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d5"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["d5"]["BackgroundTransparency"] = 1;
G2L["d5"]["Size"] = UDim2.new(1, -30, 1, 0);
G2L["d5"]["Text"] = [[Unclito Samito]];
G2L["d5"]["Name"] = [[Label]];
G2L["d5"]["Position"] = UDim2.new(0, 10, 0, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.Toggle
G2L["d6"] = Instance.new("Frame", G2L["d3"]);
G2L["d6"]["BackgroundColor3"] = Color3.fromRGB(201, 51, 51);
G2L["d6"]["Size"] = UDim2.new(0, 16, 0, 16);
G2L["d6"]["Position"] = UDim2.new(1, -23, 0.5, -8);
G2L["d6"]["Name"] = [[Toggle]];


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.Toggle.UICorner
G2L["d7"] = Instance.new("UICorner", G2L["d6"]);
G2L["d7"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.Toggle.UIStroke
G2L["d8"] = Instance.new("UIStroke", G2L["d6"]);
G2L["d8"]["Thickness"] = 2;
G2L["d8"]["Color"] = Color3.fromRGB(31, 31, 41);


-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.LocalScript
G2L["d9"] = Instance.new("LocalScript", G2L["d3"]);



-- StarterGui.Lurk.MainFrame.LocalScript
G2L["da"] = Instance.new("LocalScript", G2L["93"]);



-- StarterGui.Lurk.Frame.top.Close.LocalScript
local function C_a()
local script = G2L["a"];
	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent.Visible = false
	end)
end;
task.spawn(C_a);
-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
local function C_1d()
local script = G2L["1d"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	local highlights = {}
	local updateQueue = {}
	local lastUpdate = 0
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
		local thumbTween = TweenService:Create(sliderThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target.Position})
		local buttonTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = target.Color})
		thumbTween:Play()
		buttonTween:Play()
	end
	
	local function applyHighlight(character)
		if not character or character:FindFirstChild("ESP_Highlight") then return end
	
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP_Highlight"
		highlight.FillColor = Settings.ESPColor
		highlight.FillTransparency = 0.7
		highlight.OutlineColor = Settings.ESPColor
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
		
		highlights[character] = highlight
	end
	
	local function removeHighlights()
		for character, highlight in pairs(highlights) do
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end
		highlights = {}
	end
	
	local function processUpdateQueue()
		local currentTime = tick()
		if currentTime - lastUpdate < PerformanceConfig.UpdateInterval then return end
		lastUpdate = currentTime
		
		local processed = 0
		while #updateQueue > 0 and processed < PerformanceConfig.BatchSize do
			local character = table.remove(updateQueue, 1)
			if character and character.Parent then
				applyHighlight(character)
			end
			processed = processed + 1
		end
	end
	
	local function queueHighlight(character)
		if character and not character:FindFirstChild("ESP_Highlight") then
			table.insert(updateQueue, character)
		end
	end
	
	local function toggleESP(state)
		if state then
			removeHighlights()
			
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					if player.Character then 
						queueHighlight(player.Character) 
					end
					
					ConnectionManager:Add(player.CharacterAdded:Connect(function(char)
						if isEnabled then 
							task.wait(PerformanceConfig.LoadDelay)
							queueHighlight(char) 
						end
					end))
				end
			end
			
			ConnectionManager:Add(Players.PlayerAdded:Connect(function(player)
				if isEnabled then
					ConnectionManager:Add(player.CharacterAdded:Connect(function(char)
						if isEnabled then 
							task.wait(PerformanceConfig.LoadDelay)
							queueHighlight(char) 
						end
					end))
				end
			end))
			
			ConnectionManager:Add(Players.PlayerRemoving:Connect(function(player)
				if player.Character then
					local highlight = player.Character:FindFirstChild("ESP_Highlight")
					if highlight then 
						highlight:Destroy()
						highlights[player.Character] = nil
					end
				end
			end))
			
			ConnectionManager:Add(RunService.Heartbeat:Connect(processUpdateQueue))
		else
			removeHighlights()
			updateQueue = {}
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleESP(isEnabled)
	end)
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			removeHighlights()
			updateQueue = {}
		end
	end)
end;
task.spawn(C_1d);
-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
local function C_24()
local script = G2L["24"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	
	local ESP_NAME_SETTINGS = {
		Font = Enum.Font.GothamBold,
		Color = Settings.ESPColor,
		Size = 18,
		StrokeColor = Color3.fromRGB(0, 0, 0),
		StrokeThickness = 2,
		Transparency = 0,
		Outline = true
	}
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local espInstances = {}
	local updateQueue = {}
	local lastUpdate = 0
	
	local function createEspName(player)
		local character = player.Character
		if not character then return end
		
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		if espInstances[player.Name] then
			espInstances[player.Name]:Destroy()
		end

		local espText = Instance.new("BillboardGui")
		espText.Name = "ESP_"..player.Name
		espText.Adornee = humanoidRootPart
		espText.Size = UDim2.new(0, 100, 0, 50)
		espText.StudsOffset = Vector3.new(0, 2.5, 0)
		espText.AlwaysOnTop = true
		espText.LightInfluence = 0
		espText.MaxDistance = 1000
		espText.Parent = humanoidRootPart

		local textLabel = Instance.new("TextLabel")
		textLabel.Text = player.Name
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = ESP_NAME_SETTINGS.Color
		textLabel.TextSize = ESP_NAME_SETTINGS.Size
		textLabel.Font = ESP_NAME_SETTINGS.Font
		textLabel.TextStrokeColor3 = ESP_NAME_SETTINGS.StrokeColor
		textLabel.TextStrokeTransparency = ESP_NAME_SETTINGS.Transparency
		textLabel.TextTransparency = 0
		textLabel.Parent = espText

		espInstances[player.Name] = espText
		return espText
	end
	
	local function removeAllESP()
		for _, esp in pairs(espInstances) do
			if esp and esp.Parent then
				esp:Destroy()
			end
		end
		espInstances = {}
	end
	
	local function processUpdateQueue()
		local currentTime = tick()
		if currentTime - lastUpdate < PerformanceConfig.UpdateInterval then return end
		lastUpdate = currentTime
		
		local processed = 0
		while #updateQueue > 0 and processed < PerformanceConfig.BatchSize do
			local player = table.remove(updateQueue, 1)
			if player and player.Parent then
				createEspName(player)
			end
			processed = processed + 1
		end
	end
	
	local function queueEspName(player)
		if player and player.Parent and not espInstances[player.Name] then
			table.insert(updateQueue, player)
		end
	end
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off

		local thumbTween = TweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		)

		local buttonTween = TweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		)

		thumbTween:Play()
		buttonTween:Play()
	end
	
	local function toggleEsp(state)
		if state then
			removeAllESP()

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer then
					if player.Character then
						queueEspName(player)
					end
					
					ConnectionManager:Add(player.CharacterAdded:Connect(function(character)
						if isEnabled then
							task.wait(PerformanceConfig.LoadDelay)
							queueEspName(player)
						end
					end))
				end
			end
			
			ConnectionManager:Add(Players.PlayerAdded:Connect(function(player)
				if isEnabled then
					ConnectionManager:Add(player.CharacterAdded:Connect(function(character)
						if isEnabled then
							task.wait(PerformanceConfig.LoadDelay)
							queueEspName(player)
						end
					end))
				end
			end))
			
			ConnectionManager:Add(Players.PlayerRemoving:Connect(function(player)
				if espInstances[player.Name] then
					espInstances[player.Name]:Destroy()
					espInstances[player.Name] = nil
				end
			end))
			
			ConnectionManager:Add(RunService.Heartbeat:Connect(processUpdateQueue))
		else
			removeAllESP()
			updateQueue = {}
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleEsp(isEnabled)
	end)
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			removeAllESP()
			updateQueue = {}
		end
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		toggleEsp(state)
	end
	
	function GetToggleState()
		return isEnabled
	end
end;
task.spawn(C_24);
-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
local function C_2b()
local script = G2L["2b"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local tweenService = game:GetService("TweenService")
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local SmartESP = {}
	SmartESP.__index = SmartESP
	
	function SmartESP.new()
		local self = setmetatable({}, SmartESP)
		self:Initialize()
		return self
	end
	
	function SmartESP:Initialize()
		self.settings = {
			maxDistance = 1000,
			updateInterval = 0.3,
			baseSize = UDim2.new(0, 150, 0, 30),
			offset = Vector3.new(0, 4, 0),
			colors = {
				myPlot = Color3.fromRGB(0, 200, 255),
				locked = Color3.fromRGB(255, 200, 0),
				unlocked = Color3.fromRGB(255, 50, 50),
				noOwner = Color3.fromRGB(150, 150, 150),
				newOwner = Color3.fromRGB(200, 0, 200)
			}
		}
	
		self.state = {
			active = false,
			instances = {},
			connection = nil,
			lastUpdate = 0,
			plotsFolder = nil,
			myPlot = nil,
			previousOwners = {}
		}
		self:FindMyPlot()
	end
	
	function SmartESP:FindMyPlot()
		local plotsFolder = self:FindPlotsFolder()
		if not plotsFolder then return end
		for _, plot in plotsFolder:GetChildren() do
			local yourBase = plot:FindFirstChild("YourBase", true)
			if yourBase and yourBase:IsA("BoolValue") and yourBase.Value then
				self.state.myPlot = plot.Name
				break
			end
		end
	end
	
	function SmartESP:FindPlotsFolder()
		if not self.state.plotsFolder or not self.state.plotsFolder.Parent then
			local possibleNames = {"Plots", "PlotSystem", "PlotsSystem", "Bases"}
			for _, name in ipairs(possibleNames) do
				local folder = workspace:FindFirstChild(name)
				if folder then
					self.state.plotsFolder = folder
					break
				end
			end
		end
		return self.state.plotsFolder
	end
	
	function SmartESP:CreateESP(plot, mainPart)
		if self.state.instances[plot.Name] then return self.state.instances[plot.Name] end
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP_"..plot.Name
		billboard.Size = self.settings.baseSize
		billboard.StudsOffset = self.settings.offset
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.MaxDistance = self.settings.maxDistance
		billboard.Parent = mainPart
	
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.85
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		frame.BorderSizePixel = 0
	
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, -8, 1, -8)
		label.Position = UDim2.new(0, 4, 0, 4)
		label.BackgroundTransparency = 1
		label.TextScaled = false
		label.TextSize = 12
		label.Font = Enum.Font.GothamMedium
		label.TextStrokeTransparency = 0.4
		label.TextStrokeColor3 = Color3.new(0, 0, 0)
		label.Parent = frame
	
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = frame
		frame.Parent = billboard
		self.state.instances[plot.Name] = billboard
		return billboard
	end
	
	function SmartESP:UpdateOwnership(plot)
		local ownerValue = plot:FindFirstChild("Owner", true)
		local plotName = plot.Name
		if ownerValue then
			local currentOwner = tostring(ownerValue.Value)
			local previousOwner = self.state.previousOwners[plotName]
			if currentOwner ~= previousOwner then
				if (previousOwner == nil or previousOwner == "") and currentOwner ~= "" then
					self.state.previousOwners[plotName] = currentOwner
					return "NEW OWNER"
				end
				self.state.previousOwners[plotName] = currentOwner
			end
			if currentOwner == "" or currentOwner == nil then
				self.state.previousOwners[plotName] = nil
			end
		end
		return nil
	end
	
	function SmartESP:Update()
		local currentTime = tick()
		if currentTime - self.state.lastUpdate < self.settings.updateInterval then return end
		self.state.lastUpdate = currentTime
		local plotsFolder = self:FindPlotsFolder()
		if not plotsFolder then return end
		self:FindMyPlot()
	
		for _, plot in plotsFolder:GetChildren() do
			local mainPart = plot:FindFirstChild("Main", true) or plot:FindFirstChild("BasePart", true)
			local timeLabel = plot:FindFirstChild("RemainingTime", true)
			local ownerValue = plot:FindFirstChild("Owner", true)
	
			if mainPart then
				local ownershipStatus = self:UpdateOwnership(plot)
				local isMyPlot = plot.Name == self.state.myPlot
	
				if isMyPlot then
					local billboard = self:CreateESP(plot, mainPart)
					billboard.Frame.Label.Text = "MY BASE"
					billboard.Frame.Label.TextColor3 = self.settings.colors.myPlot
				elseif ownershipStatus == "NEW OWNER" then
					local billboard = self:CreateESP(plot, mainPart)
					billboard.Frame.Label.Text = "CLAIMED"
					billboard.Frame.Label.TextColor3 = self.settings.colors.newOwner
				elseif ownerValue and (ownerValue.Value == nil or ownerValue.Value == "") then
					local billboard = self:CreateESP(plot, mainPart)
					billboard.Frame.Label.Text = "UNCLAIMED"
					billboard.Frame.Label.TextColor3 = self.settings.colors.noOwner
				elseif timeLabel then
					local billboard = self:CreateESP(plot, mainPart)
					local isUnlocked = (timeLabel.Text == "0s" or timeLabel.Text == "")
					billboard.Frame.Label.Text = isUnlocked and "UNLOCKED" or ("LOCKED: "..timeLabel.Text)
					billboard.Frame.Label.TextColor3 = isUnlocked and self.settings.colors.unlocked or self.settings.colors.locked
				end
	
				local camera = workspace.CurrentCamera
				if camera then
					local distance = (camera.CFrame.Position - mainPart.Position).Magnitude
					local scale = math.clamp(1.3 - (distance/self.settings.maxDistance), 0.7, 1.2)
					if self.state.instances[plot.Name] then
						self.state.instances[plot.Name].Size = UDim2.new(
							0, self.settings.baseSize.X.Offset * scale, 
							0, self.settings.baseSize.Y.Offset * scale
						)
					end
				end
			elseif self.state.instances[plot.Name] then
				self.state.instances[plot.Name]:Destroy()
				self.state.instances[plot.Name] = nil
				self.state.previousOwners[plot.Name] = nil
			end
		end
	end
	
	function SmartESP:Toggle()
		self.state.active = not self.state.active
		if self.state.connection then
			self.state.connection:Disconnect()
			self.state.connection = nil
		end
		if self.state.active then
			self.state.connection = game:GetService("RunService").Heartbeat:Connect(function()
				self:Update()
			end)
			self:Update()
		else
			self:ClearAll()
		end
	end
	
	function SmartESP:ClearAll()
		for _, instance in pairs(self.state.instances) do
			if instance then
				instance:Destroy()
			end
		end
		self.state.instances = {}
		self.state.previousOwners = {}
	end
	
	local espSystem = SmartESP.new()
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
		local thumbTween = tweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		)
		local buttonTween = tweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		)
		thumbTween:Play()
		buttonTween:Play()
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		espSystem:Toggle()
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		if state then
			espSystem:Toggle()
		else
			espSystem:Toggle()
		end
	end
	
	function GetToggleState()
		return isEnabled
	end
end;
task.spawn(C_2b);
-- StarterGui.Lurk.Frame.ScrollingFrame.visual.Frame.TextButton.LocalScript
local function C_32()
local script = G2L["32"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local tweenService = game:GetService("TweenService")
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
	local fmenu = screenGui and screenGui:FindFirstChild("MainFrame")
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
	
		tweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		):Play()
	
		tweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		):Play()
	end
	
	local function toggleMenu(state)
		if fmenu then
			fmenu.Visible = state
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleMenu(isEnabled)
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		toggleMenu(state)
	end
	
	function GetToggleState()
		return isEnabled
	end
	
	if fmenu then
		fmenu.Visible = false
	end
end;
task.spawn(C_32);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
local function C_3b()
local script = G2L["3b"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local JUMP_FORCE = 50
	local COOLDOWN = 0.5
	local JUMP_DURATION = 0.2
	local lastJumpTime = 0
	local isJumping = false
	local jumpConnection = nil
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
		local thumbTween = TweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		)
		local buttonTween = TweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		)
		thumbTween:Play()
		buttonTween:Play()
	end
	
	local function safeAirJump()
		if not isEnabled then return end
		local now = os.clock()
		if now - lastJumpTime < COOLDOWN or isJumping then return end

		local character = localPlayer.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not rootPart then return end

		isJumping = true
		lastJumpTime = now

		if rootPart:CanSetNetworkOwnership() then
			rootPart:SetNetworkOwner(localPlayer)
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
		bodyVelocity.Velocity = Vector3.new(0, JUMP_FORCE, 0)
		bodyVelocity.Parent = rootPart

		task.delay(JUMP_DURATION, function()
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity:Destroy()
			end
			if rootPart:CanSetNetworkOwnership() then
				rootPart:SetNetworkOwner(nil)
			end
			isJumping = false
		end)
	end
	
	local function setupJumpListener()
		if jumpConnection then
			jumpConnection:Disconnect()
		end
		
		if isEnabled then
			jumpConnection = UserInputService.JumpRequest:Connect(safeAirJump)
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		setupJumpListener()
	end)
	
	setupJumpListener()
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent and jumpConnection then
			jumpConnection:Disconnect()
		end
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		setupJumpListener()
	end
	
	function GetToggleState()
		return isEnabled
	end
end;
task.spawn(C_3b);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
local function C_42()
local script = G2L["42"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
	local fmenu = screenGui and screenGui:FindFirstChild("S")
	local speedConnection = nil
	local defaultSpeed = 24
	local boostSpeed = 50
	local lastUpdate = 0
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off

		TweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		):Play()

		TweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		):Play()
	end
	
	local function toggleSpeedBoost(state)
		if speedConnection then
			speedConnection:Disconnect()
			speedConnection = nil
		end
		
		if state then
			speedConnection = RunService.Heartbeat:Connect(function()
				local currentTime = tick()
				if currentTime - lastUpdate < PerformanceConfig.UpdateInterval then return end
				lastUpdate = currentTime
				
				local character = localPlayer.Character
				if not character then return end
				
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end
				
				if humanoid.WalkSpeed ~= boostSpeed then
					humanoid.WalkSpeed = boostSpeed
				end
			end)
		else
			local character = localPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = defaultSpeed
				end
			end
		end
	end
	
	local function toggleMenu(state)
		if fmenu then
			fmenu.Visible = state
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleSpeedBoost(isEnabled)
		toggleMenu(isEnabled)
	end)
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent and speedConnection then
			speedConnection:Disconnect()
		end
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		toggleSpeedBoost(state)
		toggleMenu(state)
	end
	
	function GetToggleState()
		return isEnabled
	end
	
	if fmenu then
		fmenu.Visible = false
	end
end;
task.spawn(C_42);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.FloatBtn.LocalScript
local function C_48()
local script = G2L["48"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local tweenService = game:GetService("TweenService")
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
	local fmenu = screenGui and screenGui:FindFirstChild("F")
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
	
		tweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		):Play()
	
		tweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		):Play()
	end
	
	local function toggleMenu(state)
		if fmenu then
			fmenu.Visible = state
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleMenu(isEnabled)
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		toggleMenu(state)
	end
	
	function GetToggleState()
		return isEnabled
	end
	
	if fmenu then
		fmenu.Visible = false
	end
end;
task.spawn(C_48);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antistun.LocalScript
local function C_4f()
local script = G2L["4f"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local antiStunConnections = {}
	local defaultWalkSpeed = 16
	local defaultJumpPower = 50
	local lastStunTime = 0
	local lastUpdate = 0
	
	local STUNNED_STATES = {
		[Enum.HumanoidStateType.Physics] = true,
		[Enum.HumanoidStateType.Ragdoll] = true,
		[Enum.HumanoidStateType.FallingDown] = true,
		[Enum.HumanoidStateType.PlatformStanding] = true,
		[Enum.HumanoidStateType.Seated] = true,
	}
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off

		TweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		):Play()

		TweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		):Play()
	end
	
	local function cleanupConnections()
		for _, conn in ipairs(antiStunConnections) do
			if conn then
				conn:Disconnect()
			end
		end
		antiStunConnections = {}
	end
	
	local function restoreMovement(humanoid)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		task.delay(0.05, function()
			if humanoid and humanoid.Parent then
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
				humanoid.WalkSpeed = defaultWalkSpeed
				humanoid.JumpPower = defaultJumpPower
			end
		end)
	end
	
	local function setupAntiStun()
		cleanupConnections()

		local character = localPlayer.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		defaultWalkSpeed = humanoid.WalkSpeed
		defaultJumpPower = humanoid.JumpPower

		ConnectionManager:Add(RunService.Heartbeat:Connect(function()
			if not isEnabled then return end

			local currentTime = tick()
			if currentTime - lastUpdate < PerformanceConfig.UpdateInterval then return end
			lastUpdate = currentTime

			if currentTime - lastStunTime < 0.1 then return end

			if STUNNED_STATES[humanoid:GetState()] then
				lastStunTime = currentTime
				restoreMovement(humanoid)
			end

			if humanoid.WalkSpeed < defaultWalkSpeed then
				humanoid.WalkSpeed = defaultWalkSpeed
			end

			if humanoid.JumpPower < defaultJumpPower then
				humanoid.JumpPower = defaultJumpPower
			end
		end))

		ConnectionManager:Add(localPlayer.CharacterAdded:Connect(function(newChar)
			task.wait(PerformanceConfig.LoadDelay)
			if isEnabled then
				setupAntiStun()
			end
		end))
	end
	
	local function setAntiStun(state)
		isEnabled = state
		animateToggle(state)

		if state then
			setupAntiStun()
		else
			cleanupConnections()
		end
	end
	
	button.MouseButton1Click:Connect(function()
		setAntiStun(not isEnabled)
	end)
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanupConnections()
		end
	end)
	
	return {
		SetEnabled = setAntiStun,
		GetEnabled = function() return isEnabled end,
		Toggle = function() setAntiStun(not isEnabled) end
	}
end;
task.spawn(C_4f);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.antiafk.LocalScript
local function C_56()
local script = G2L["56"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	local VirtualUser = game:GetService("VirtualUser")
	
	local antiAfkConnection = nil
	local idledConnection = nil
	local characterAddedConnection = nil
	local lastMoveTime = 0
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off

		local thumbTween = TweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		)

		local buttonTween = TweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		)

		thumbTween:Play()
		buttonTween:Play()
	end
	
	local function disconnectAntiAfk()
		if antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
		if idledConnection then
			idledConnection:Disconnect()
			idledConnection = nil
		end
		if characterAddedConnection then
			characterAddedConnection:Disconnect()
			characterAddedConnection = nil
		end
	end
	
	local function setupAntiAfk()
		disconnectAntiAfk()

		local function applyAntiAfk()
			local character = localPlayer.Character
			if not character then return end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end

			ConnectionManager:Add(RunService.Heartbeat:Connect(function()
				local currentTime = tick()
				if currentTime - lastMoveTime > 25 then
					humanoid:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
					lastMoveTime = currentTime
				end
			end))

			ConnectionManager:Add(localPlayer.Idled:Connect(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end))
		end

		applyAntiAfk()

		ConnectionManager:Add(localPlayer.CharacterAdded:Connect(function()
			task.wait(PerformanceConfig.LoadDelay)
			disconnectAntiAfk()
			applyAntiAfk()
		end))
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)

		if isEnabled then
			setupAntiAfk()
		else
			disconnectAntiAfk()
		end
	end)
	
	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			disconnectAntiAfk()
		end
	end)
	
	function SetToggleState(state)
		if isEnabled ~= state then
			isEnabled = state
			animateToggle(state)

			if state then
				setupAntiAfk()
			else
				disconnectAntiAfk()
			end
		end
	end
	
	function GetToggleState()
		return isEnabled
	end
end;
task.spawn(C_56);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
local function C_5d()
local script = G2L["5d"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local localPlayer = Players.LocalPlayer
	local antiAfkConnection = nil
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
	
		local thumbTween = tweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		)
	
		local buttonTween = tweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		)
	
		thumbTween:Play()
		buttonTween:Play()
	end
	
	local function enableAntiAfk()
		if antiAfkConnection then
			antiAfkConnection:Disconnect()
		end
	
		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
	
		antiAfkConnection = game:GetService("RunService").Heartbeat:Connect(function()
			humanoid:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
		end)
	end
	
	local function disableAntiAfk()
		if antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
	
		if isEnabled then
			enableAntiAfk()
		else
			disableAntiAfk()
		end
	end)
	
	function SetToggleState(state)
		if isEnabled ~= state then
			isEnabled = state
			animateToggle(state)
	
			if state then
				enableAntiAfk()
			else
				disableAntiAfk()
			end
		end
	end
	
	function GetToggleState()
		return isEnabled
	end
end;
task.spawn(C_5d);
-- StarterGui.Lurk.Frame.ScrollingFrame.main.Frame.TextButton.LocalScript
local function C_5e()
local script = G2L["5e"];
	local button = script.Parent
	local sliderThumb = button:FindFirstChild("Frame")
	local isEnabled = false
	local tweenService = game:GetService("TweenService")
	
	local toggleAnim = {
		On = {
			Position = UDim2.new(0, 25, 0, 2),
			Color = Color3.fromRGB(0, 170, 255)
		},
		Off = {
			Position = UDim2.new(0, 4, 0, 2),
			Color = Color3.fromRGB(70, 70, 80)
		}
	}
	
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
	local fmenu = screenGui and screenGui:FindFirstChild("St")
	
	local function animateToggle(state)
		local target = state and toggleAnim.On or toggleAnim.Off
	
		tweenService:Create(
			sliderThumb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = target.Position}
		):Play()
	
		tweenService:Create(
			button,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = target.Color}
		):Play()
	end
	
	local function toggleMenu(state)
		if fmenu then
			fmenu.Visible = state
		end
	end
	
	button.MouseButton1Click:Connect(function()
		isEnabled = not isEnabled
		animateToggle(isEnabled)
		toggleMenu(isEnabled)
	end)
	
	function SetToggleState(state)
		isEnabled = state
		animateToggle(state)
		toggleMenu(state)
	end
	
	function GetToggleState()
		return isEnabled
	end
	
	if fmenu then
		fmenu.Visible = false
	end
end;
task.spawn(C_5e);
-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
local function C_64()
local script = G2L["64"];
	local button = script.Parent
	local remote = game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]
	local tweenService = game:GetService("TweenService")
	
	local NORMAL_COLOR = Color3.fromRGB(50, 50, 60)
	local PRESSED_COLOR = Color3.fromRGB(0, 170, 255)
	local TWEEN_TIME = 0.3
	
	button.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = PRESSED_COLOR}
		)
		tween:Play()
	
		local success, result = pcall(function()
			return remote:InvokeServer("Invisibility Cloak")
		end)
	
		tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = NORMAL_COLOR}
		)
		tween:Play()
	end)
end;
task.spawn(C_64);
-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
local function C_67()
local script = G2L["67"];
	local button = script.Parent
	local remote = game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]
	local tweenService = game:GetService("TweenService")
	
	local NORMAL_COLOR = Color3.fromRGB(50, 50, 60)
	local PRESSED_COLOR = Color3.fromRGB(0, 170, 255)
	local TWEEN_TIME = 0.3
	
	button.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = PRESSED_COLOR}
		)
		tween:Play()
	
		local success, result = pcall(function()
			return remote:InvokeServer("Bee Launcher")
		end)
	
		tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = NORMAL_COLOR}
		)
		tween:Play()
	end)
end;
task.spawn(C_67);
-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
local function C_6a()
local script = G2L["6a"];
	local button = script.Parent
	local remote = game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]
	local tweenService = game:GetService("TweenService")
	
	local NORMAL_COLOR = Color3.fromRGB(50, 50, 60)
	local PRESSED_COLOR = Color3.fromRGB(0, 170, 255)
	local TWEEN_TIME = 0.3
	
	button.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = PRESSED_COLOR}
		)
		tween:Play()
	
		local success, result = pcall(function()
			return remote:InvokeServer("Medusa's Head")
		end)
	
		tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = NORMAL_COLOR}
		)
		tween:Play()
	end)
end;
task.spawn(C_6a);
-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
local function C_6d()
local script = G2L["6d"];
	local button = script.Parent
	local remote = game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]
	local tweenService = game:GetService("TweenService")
	
	local NORMAL_COLOR = Color3.fromRGB(50, 50, 60)
	local PRESSED_COLOR = Color3.fromRGB(0, 170, 255)
	local TWEEN_TIME = 0.3
	
	button.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = PRESSED_COLOR}
		)
		tween:Play()
	
		local success, result = pcall(function()
			return remote:InvokeServer("Quantum Cloner")
		end)
	
		tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = NORMAL_COLOR}
		)
		tween:Play()
	end)
end;
task.spawn(C_6d);
-- StarterGui.Lurk.Frame.ScrollingFrame.misc.TextButton.LocalScript
local function C_70()
local script = G2L["70"];
	local button = script.Parent
	local remote = game:GetService("ReplicatedStorage").Packages.Net["RF/CoinsShopService/RequestBuy"]
	local tweenService = game:GetService("TweenService")
	
	local NORMAL_COLOR = Color3.fromRGB(50, 50, 60)
	local PRESSED_COLOR = Color3.fromRGB(0, 170, 255)
	local TWEEN_TIME = 0.3
	
	button.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = PRESSED_COLOR}
		)
		tween:Play()
	
		local success, result = pcall(function()
			return remote:InvokeServer("Rainbowrath Sword")
		end)
	
		tween = tweenService:Create(
			button,
			TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundColor3 = NORMAL_COLOR}
		)
		tween:Play()
	end)
end;
task.spawn(C_70);
-- StarterGui.Lurk.Frame.LocalScript
local function C_71()
local script = G2L["71"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")
	
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
	
	
end;
task.spawn(C_71);
-- StarterGui.Lurk.S.spid.LocalScript
local function C_79()
local script = G2L["79"];
	local button = script.Parent
	local tweenService = game:GetService("TweenService")
	local textLabel = button:FindFirstChild("TextLabel") or button:FindFirstChildOfClass("TextLabel")
	local statusFrame = button:FindFirstChild("Status")
	local controller
	
	local function SpeedBoostController()
		local player = game:GetService("Players").LocalPlayer
		local runService = game:GetService("RunService")
	
		local isActive = false
		local defaultSpeed = 24
		local boostSpeed = 50
		local heartbeatConn = nil
		local wsConn = nil
		local charConn = nil
		local humanoid = nil
	
		local function applyBoost()
			if heartbeatConn then
				heartbeatConn:Disconnect()
				heartbeatConn = nil
			end
			if wsConn then
				wsConn:Disconnect()
				wsConn = nil
			end
	
			local character = player.Character
			if not character then return end
			humanoid = character:FindFirstChildOfClass("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")
	
			if not humanoid or not rootPart then return end
	
			if isActive then
				-- Force WalkSpeed every frame
				heartbeatConn = runService.Heartbeat:Connect(function()
					if humanoid and humanoid.Parent then
						if humanoid.WalkSpeed ~= boostSpeed then
							humanoid.WalkSpeed = boostSpeed
						end
					end
					if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
						local moveDir = humanoid.MoveDirection
						rootPart.Velocity = Vector3.new(
							moveDir.X * boostSpeed,
							rootPart.Velocity.Y,
							moveDir.Z * boostSpeed
						)
					end
				end)
				-- Listen for WalkSpeed changes (anti-cheat or other scripts)
				wsConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if isActive and humanoid.WalkSpeed ~= boostSpeed then
						humanoid.WalkSpeed = boostSpeed
					end
				end)
			else
				-- Reset WalkSpeed to default
				if humanoid then
					humanoid.WalkSpeed = defaultSpeed
				end
			end
		end
	
		local function onCharacterAdded(char)
			if heartbeatConn then
				heartbeatConn:Disconnect()
				heartbeatConn = nil
			end
			if wsConn then
				wsConn:Disconnect()
				wsConn = nil
			end
			humanoid = char:FindFirstChildOfClass("Humanoid")
			if isActive then
				applyBoost()
			end
		end
	
		-- Listen for character respawn
		charConn = player.CharacterAdded:Connect(onCharacterAdded)
	
		return {
			Toggle = function()
				isActive = not isActive
				applyBoost()
			end,
	
			Set = function(state)
				isActive = state
				applyBoost()
			end,
	
			Get = function()
				return isActive
			end,
	
			SetSpeed = function(newSpeed)
				boostSpeed = newSpeed
				if isActive then
					applyBoost()
				end
			end,
	
			Destroy = function()
				if heartbeatConn then
					heartbeatConn:Disconnect()
					heartbeatConn = nil
				end
				if wsConn then
					wsConn:Disconnect()
					wsConn = nil
				end
				if charConn then
					charConn:Disconnect()
					charConn = nil
				end
				if humanoid then
					humanoid.WalkSpeed = defaultSpeed
				end
			end
		}
	end
	
	controller = SpeedBoostController()
	
	local function updateVisuals()
		local isOn = controller.Get()
		-- Text
		if textLabel then
			textLabel.Text = isOn and "BOOST ON" or "BOOST OFF"
		end
		-- Status color
		if statusFrame then
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetColor = isOn and Color3.fromRGB(72, 167, 28) or Color3.fromRGB(167, 31, 31)
			tweenService:Create(statusFrame, tweenInfo, {
				BackgroundColor3 = targetColor
			}):Play()
		end
	end
	
	button.MouseButton1Click:Connect(function()
		controller.Toggle()
		updateVisuals()
	end)
	
	-- Initialize visuals OFF
	controller.Set(false)
	updateVisuals()
	
	-- Clean up on script removal
	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			controller.Destroy()
		end
	end)
end;
task.spawn(C_79);
-- StarterGui.Lurk.S.LocalScript
local function C_7a()
local script = G2L["7a"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")
	
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
	
	
end;
task.spawn(C_7a);
-- StarterGui.Lurk.St.Position.LocalScript
local function C_7f()
local script = G2L["7f"];
	local textLabel = script.Parent
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	
	local player = Players.LocalPlayer
	
	local function updatePosition()
		local character = player.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local pos = rootPart.Position
				textLabel.Text = string.format("(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
			else
				textLabel.Text = "(N/A)"
			end
		else
			textLabel.Text = "(N/A)"
		end
	end

	local renderConn

	local function startUpdating()
		if renderConn then
			renderConn:Disconnect()
		end
		renderConn = RunService.RenderStepped:Connect(updatePosition)
	end

	player.CharacterAdded:Connect(function()
		startUpdating()
	end)

	player.CharacterRemoving:Connect(function()
		if renderConn then
			renderConn:Disconnect()
			renderConn = nil
		end
		textLabel.Text = "(N/A)"
	end)

	-- Start if character already exists
	if player.Character then
		startUpdating()
	else
		textLabel.Text = "(N/A)"
	end

	-- Clean up on script removal
	script.AncestryChanged:Connect(function(_, parent)
		if not parent and renderConn then
			renderConn:Disconnect()
			renderConn = nil
		end
	end)

end;
task.spawn(C_7f);
-- StarterGui.Lurk.St.LocalScript
local function C_80()
	local script = G2L["80"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)


end;
task.spawn(C_80);
-- StarterGui.Lurk.St.Button.LocalScript
local function C_83()
	local script = G2L["83"];
	local button = script.Parent
	local Players = game:GetService("Players")

	button.Text = "UP"

	local stateUp = true

	local function getRoot()
		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		return character:FindFirstChild("HumanoidRootPart")
	end

	local function teleportToSky()
		local root = getRoot()
		if root then
			root.CFrame = root.CFrame + Vector3.new(0, 200, 0)
		end
	end

	local function teleportToGround()
		local root = getRoot()
		if root then
			root.CFrame = root.CFrame - Vector3.new(0, 50, 0)
		end
	end

	button.MouseButton1Click:Connect(function()
		if stateUp then
			button.Text = "DOWN"
			teleportToSky()
		else
			button.Text = "UP"
			teleportToGround()
		end
		stateUp = not stateUp
	end)

	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(function()
		button.Text = "UP"
		stateUp = true
	end)

end;
task.spawn(C_83);
-- StarterGui.Lurk.Open.LocalScript
local function C_86()
	local script = G2L["86"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)


end;
task.spawn(C_86);
-- StarterGui.Lurk.Open.OpenScript
local function C_87()
	local script = G2L["87"];
	local button = script.Parent
	local frame = button.Parent.Frame

	button.MouseButton1Click:Connect(function()
		frame.Visible = not frame.Visible
	end)
end;
task.spawn(C_87);
-- StarterGui.Lurk.F.Draggable
local function C_8a()
	local script = G2L["8a"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)


end;
task.spawn(C_8a);
-- StarterGui.Lurk.F.air.LocalScript
local function C_8f()
	local script = G2L["8f"];
	local button = script.Parent
	local frame = button.Parent
	local timerLabel = frame:FindFirstChild("Timer")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Camera = workspace:FindFirstChildOfClass("Camera")
	local UserInputService = game:GetService("UserInputService")

	local DEFAULT_TEXT = "Float & Move Forward"
	local ACTIVE_TEXT = "Actived (click to stop)"
	local FLIGHT_TIME = 15
	local FLIGHT_SPEED = 38
	local FLOAT_HEIGHT = 2.8
	local HEIGHT_CORRECTION_FORCE = 196.2

	local player = Players.LocalPlayer
	local flying = false
	local flightConn = nil
	local timerConn = nil
	local flightEndTime = 0
	local startY = nil
	local bodyPosition = nil

	local function setButtonState(isActive)
		button.Text = isActive and ACTIVE_TEXT or DEFAULT_TEXT
	end

	local function setTimerText(timeLeft)
		if timerLabel then
			timerLabel.Text = string.format("Timer: %04.1fs", math.max(0, timeLeft))
		end
	end

	local function stopFlight()
		flying = false
		setButtonState(false)
		setTimerText(FLIGHT_TIME)

		if flightConn then
			flightConn:Disconnect()
			flightConn = nil
		end
		if timerConn then
			timerConn:Disconnect()
			timerConn = nil
		end
		if bodyPosition then
			bodyPosition:Destroy()
			bodyPosition = nil
		end
	end

	local function startFlight()
		local character = player.Character
		if not character then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		if bodyPosition then
			bodyPosition:Destroy()
		end

		bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
		bodyPosition.Position = root.Position + Vector3.new(0, FLOAT_HEIGHT, 0)
		bodyPosition.P = 5000
		bodyPosition.D = 500
		bodyPosition.Parent = root

		startY = root.Position.Y + FLOAT_HEIGHT
		bodyPosition.Position = Vector3.new(root.Position.X, startY, root.Position.Z)

		flying = true
		setButtonState(true)
		flightEndTime = tick() + FLIGHT_TIME

		flightConn = RunService.Heartbeat:Connect(function(delta)
			local character = player.Character
			if not character then return end
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local cam = Camera
			if not cam then return end

			if bodyPosition then
				bodyPosition.Position = Vector3.new(root.Position.X, startY, root.Position.Z)
			end

			local look = cam.CFrame.LookVector
			look = Vector3.new(look.X, 0, look.Z)
			if look.Magnitude > 0 then
				look = look.Unit
			end

			root.Velocity = Vector3.new(look.X * FLIGHT_SPEED, root.Velocity.Y, look.Z * FLIGHT_SPEED)

			if look.Magnitude > 0.1 then
				root.CFrame = CFrame.new(root.Position, root.Position + look)
			end
		end)

		timerConn = RunService.Heartbeat:Connect(function()
			local timeLeft = flightEndTime - tick()
			setTimerText(timeLeft)
			if timeLeft <= 0 then
				stopFlight()
			end
		end)
	end

	button.MouseButton1Click:Connect(function()
		if flying then
			stopFlight()
		else
			startFlight()
		end
	end)

	player.CharacterAdded:Connect(function()
		stopFlight()
	end)

	setButtonState(false)
	setTimerText(FLIGHT_TIME)


	script.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stopFlight()
		end
	end)
end;
task.spawn(C_8f);
-- StarterGui.Lurk.SwitchTabs
local function C_92()
	local script = G2L["92"];
	local screengui = script.Parent

	-- Helper function to safely get a child and warn if missing
	local function safeWaitForChild(parent, childName)
		local child = parent:FindFirstChild(childName)
		if not child then
			warn("texwc: Missing UI element: " .. tostring(childName) .. " under " .. tostring(parent))
		end
		return child or Instance.new("Frame") -- dummy to prevent script breakage
	end

	local mainframe = safeWaitForChild(screengui, "Frame")
	local tabsframe = safeWaitForChild(mainframe, "tabs")
	local contentframe = safeWaitForChild(mainframe, "ScrollingFrame")

	-- Кнопки переключения
	local mainbtn = safeWaitForChild(tabsframe, "mainbtn")
	local visualbtn = safeWaitForChild(tabsframe, "visualbtn")
	local miscbtn = safeWaitForChild(tabsframe, "miscbtn")

	-- Вкладки контента
	local main = safeWaitForChild(contentframe, "main")
	local visual = safeWaitForChild(contentframe, "visual")
	local misc = safeWaitForChild(contentframe, "misc")

	-- Цвета
	local inactive_color = Color3.fromRGB(40, 40, 50)
	local active_color = Color3.fromRGB(0, 120, 215)

	-- Инициализация
	local current_tab = main
	main.Visible = true
	visual.Visible = false
	misc.Visible = false

	mainbtn.BackgroundColor3 = active_color
	visualbtn.BackgroundColor3 = inactive_color
	miscbtn.BackgroundColor3 = inactive_color

	-- Функция переключения вкладок
	local function switch_tab(tab, btn)
		-- Скрываем все вкладки
		main.Visible = false
		visual.Visible = false
		misc.Visible = false

		-- Показываем нужную вкладку
		tab.Visible = true

		-- Обновляем цвета кнопок
		mainbtn.BackgroundColor3 = inactive_color
		visualbtn.BackgroundColor3 = inactive_color
		miscbtn.BackgroundColor3 = inactive_color
		btn.BackgroundColor3 = active_color

		current_tab = tab
	end

	-- Обработчики кликов
	if mainbtn and main then
		mainbtn.MouseButton1Click:Connect(function()
			switch_tab(main, mainbtn)
		end)
	end

	if visualbtn and visual then
		visualbtn.MouseButton1Click:Connect(function()
			switch_tab(visual, visualbtn)
		end)
	end

	if miscbtn and misc then
		miscbtn.MouseButton1Click:Connect(function()
			switch_tab(misc, miscbtn)
		end)
	end
end;
task.spawn(C_92);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Cocofanto Elefanto.Button.LocalScript
local function C_a1()
	local script = G2L["a1"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Cocofanto Elefanto"
	local espColor = Color3.fromRGB(59, 42, 14)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_a1);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Gattatino Nyanino.Button.LocalScript
local function C_a9()
	local script = G2L["a9"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Gattatino Nyanino"
	local espColor = Color3.fromRGB(174, 58, 189)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_a9);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Girafa Celestre.Button.LocalScript
local function C_b1()
	local script = G2L["b1"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Girafa Celestre"
	local espColor = Color3.fromRGB(126, 189, 58)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_b1);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Tralalero Tralala.Button.LocalScript
local function C_b9()
	local script = G2L["b9"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Tralalero Tralala"
	local espColor = Color3.fromRGB(31, 94, 211)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_b9);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Matteo.Button.LocalScript
local function C_c1()
	local script = G2L["c1"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Matteo"
	local espColor = Color3.fromRGB(104, 82, 64)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_c1);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Odin Din Din Dun.Button.LocalScript
local function C_c9()
	local script = G2L["c9"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Odin Din Din Dun"
	local espColor = Color3.fromRGB(211, 160, 31)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_c9);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Trenostruzzo Turbo 3000.Button.LocalScript
local function C_d1()
	local script = G2L["d1"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Trenostruzzo Turbo 3000"
	local espColor = Color3.fromRGB(99, 98, 70)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_d1);
-- StarterGui.Lurk.MainFrame.ScrollFrame.Unclito Samito.Button.LocalScript
local function C_d9()
	local script = G2L["d9"];
	local button = script.Parent
	local toggle = button.Toggle
	local isActive = false
	local tweenService = game:GetService("TweenService")

	local modelName = "Unclito Samito"
	local espColor = Color3.fromRGB(182, 93, 93)
	local espInstance = nil
	local espConnection = nil

	local function createESP()
		local model = workspace:FindFirstChild(modelName)
		if not model then return end

		local mainPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
		if not mainPart then return end

		if espInstance then espInstance:Destroy() end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Size = UDim2.new(0, 200, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = mainPart
		billboard.Parent = mainPart

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 0.9
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = modelName:upper()
		label.TextColor3 = espColor
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		frame.Parent = billboard
		espInstance = billboard
	end

	local function updateESP()
		if not espInstance then
			createESP()
		end
	end

	button.MouseButton1Click:Connect(function()
		isActive = not isActive
		local targetColor = isActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

		tweenService:Create(
			toggle,
			TweenInfo.new(0.2),
			{BackgroundColor3 = targetColor}
		):Play()

		if isActive then
			createESP()
			espConnection = game:GetService("RunService").Heartbeat:Connect(updateESP)
		else
			if espConnection then
				espConnection:Disconnect()
				espConnection = nil
			end
			if espInstance then
				espInstance:Destroy()
				espInstance = nil
			end
		end
	end)
end;
task.spawn(C_d9);
-- StarterGui.Lurk.MainFrame.LocalScript
local function C_da()
	local script = G2L["da"];
	local frame = script.Parent
	local userInputService = game:GetService("UserInputService")

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)


end;
task.spawn(C_da);

-- Settings Scripts
local function Settings_BaseNotification()
    local script = G2L["settings_btn1_script"];
    local button = script.Parent
    local sliderThumb = button:FindFirstChild("Frame")
    local isEnabled = Settings.BaseNotificationEnabled
    
    local toggleAnim = {
        On = {
            Position = UDim2.new(0, 25, 0, 2),
            Color = Color3.fromRGB(0, 170, 255)
        },
        Off = {
            Position = UDim2.new(0, 4, 0, 2),
            Color = Color3.fromRGB(70, 70, 80)
        }
    }
    
    local function animateToggle(state)
        local target = state and toggleAnim.On or toggleAnim.Off
        local thumbTween = TweenService:Create(sliderThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target.Position})
        local buttonTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = target.Color})
        thumbTween:Play()
        buttonTween:Play()
    end
    
    button.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        Settings.BaseNotificationEnabled = isEnabled
        animateToggle(isEnabled)
        
        if isEnabled then
            BaseNotificationSystem:Initialize()
        else
            BaseNotificationSystem.enabled = false
        end
    end)
    
    animateToggle(isEnabled)
end;

local function Settings_ESPColor()
    local script = G2L["settings_btn2_script"];
    local button = script.Parent
    
    local colors = {
        Color3.fromRGB(0, 170, 255),
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(100, 255, 100),
        Color3.fromRGB(255, 255, 100),
        Color3.fromRGB(255, 100, 255),
        Color3.fromRGB(100, 255, 255)
    }
    
    local currentColorIndex = 1
    
    button.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex + 1
        if currentColorIndex > #colors then
            currentColorIndex = 1
        end
        
        Settings.ESPColor = colors[currentColorIndex]
        button.BackgroundColor3 = colors[currentColorIndex]
    end)
    
    button.BackgroundColor3 = Settings.ESPColor
end;

-- Enhanced Tab System
local function EnhancedTabSystem()
    local mainBtn = G2L["d"]
    local visualBtn = G2L["f"]
    local miscBtn = G2L["11"]
    local settingsBtn = G2L["settingsbtn"]
    
    local mainContent = G2L["33"]
    local visualContent = G2L["15"]
    local miscContent = G2L["60"]
    local settingsContent = G2L["settings"]
    
    local function showTab(content)
        mainContent.Visible = false
        visualContent.Visible = false
        miscContent.Visible = false
        settingsContent.Visible = false
        content.Visible = true
    end
    
    local function updateTabButtons(activeBtn)
        local buttons = {mainBtn, visualBtn, miscBtn, settingsBtn}
        local activeColor = Color3.fromRGB(0, 170, 255)
        local inactiveColor = Color3.fromRGB(35, 35, 45)
        local activeTextColor = Color3.fromRGB(255, 255, 255)
        local inactiveTextColor = Color3.fromRGB(200, 200, 200)
        
        for _, btn in pairs(buttons) do
            if btn == activeBtn then
                btn.BackgroundColor3 = activeColor
                btn.TextColor3 = activeTextColor
            else
                btn.BackgroundColor3 = inactiveColor
                btn.TextColor3 = inactiveTextColor
            end
        end
    end
    
    mainBtn.MouseButton1Click:Connect(function()
        showTab(mainContent)
        updateTabButtons(mainBtn)
    end)
    
    visualBtn.MouseButton1Click:Connect(function()
        showTab(visualContent)
        updateTabButtons(visualBtn)
    end)
    
    miscBtn.MouseButton1Click:Connect(function()
        showTab(miscContent)
        updateTabButtons(miscBtn)
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        showTab(settingsContent)
        updateTabButtons(settingsBtn)
    end)
    
    showTab(mainContent)
    updateTabButtons(mainBtn)
end;

local function initializeScript()
    task.wait(PerformanceConfig.LoadDelay)
    
    local mainGui = G2L["1"]
    if mainGui then
        mainGui.Parent = PlayerGui
    end
    
    ConnectionManager:Add(RunService.Heartbeat:Connect(function()
        if #ConnectionManager.connections > PerformanceConfig.MaxConnections then
            ConnectionManager:Cleanup()
        end
    end))
    
    task.spawn(Settings_BaseNotification)
    task.spawn(Settings_ESPColor)
    task.spawn(EnhancedTabSystem)
    
    if Settings.BaseNotificationEnabled then
        BaseNotificationSystem:Initialize()
    end
end

task.spawn(initializeScript)

return G2L["1"], require;
