--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Wait for LocalPlayer to initialize
local LocalPlayer
repeat
    LocalPlayer = Players.LocalPlayer
    task.wait()
until LocalPlayer

--// User Configuration
local webhook = getgenv().webhook or "https://discord.com/api/webhooks/1394479168745508894/K2Zn1npQ3fl6UrrHif00RFG6760LutOT3tT4DadBWFN1DaWVRKX8eFnaXuTldG2-SB5-"
local targetPets = getgenv().TargetPetNames or {}

--// Server and Search Settings
local visitedJobIds = {[game.JobId] = true}
local hops = 0
local maxHopsBeforeReset = 50
local teleportFails = 0
local maxTeleportRetries = 3
local detectedPets = {}
local webhookSent = false
local stopHopping = false

TeleportService.TeleportInitFailed:Connect(function(_, result)
    teleportFails += 1
    if result == Enum.TeleportResult.GameFull then
        warn("⚠️ Game full. Retrying teleport...")
    elseif result == Enum.TeleportResult.Unauthorized then
        warn("❌ Unauthorized/private server. Blacklisting and retrying...")
        visitedJobIds[game.JobId] = true
    else
        warn("❌ Other teleport error:", result)
    end

    if teleportFails >= maxTeleportRetries then
        warn("⚠️ Too many teleport fails. Forcing fresh server...")
        teleportFails = 0
        task.wait(1)
        TeleportService:Teleport(game.PlaceId)
    else
        task.wait(1)
        serverHop()
    end
end)

--// ESP Function
local function addESP(targetModel)
    if targetModel:FindFirstChild("PetESP") then return end
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "PetESP"
    Billboard.Adornee = targetModel
    Billboard.Size = UDim2.new(0, 100, 0, 30)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = targetModel

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "🎯 Target Pet"
    Label.TextColor3 = Color3.fromRGB(255, 0, 0)
    Label.TextStrokeTransparency = 0.5
    Label.Font = Enum.Font.SourceSansBold
    Label.TextScaled = true
    Label.Parent = Billboard
end

--// Mutation Extractor
local function getMutationName(model)
    local lower = string.lower(model.Name)
    if string.find(lower, "golden") then return "Golden" end
    if string.find(lower, "radioactive") then return "Radioactive" end
    if string.find(lower, "shiny") then return "Shiny" end
    if string.find(lower, "toxic") then return "Toxic" end
    if string.find(lower, "ghost") then return "Ghost" end
    if string.find(lower, "mutated") then return "Mutated" end
    return nil
end

--// Webhook Function
local function sendWebhook(foundPets, jobId)
    if webhook == "" then
        warn("⚠️ Webhook is empty, skipping notification.")
        return
    end

    local petCounts = {}
    for _, pet in ipairs(foundPets) do
        if pet then
            petCounts[pet] = (petCounts[pet] or 0) + 1
        end
    end

    local formattedPets = {}
    for petName, count in pairs(petCounts) do
        local mutation = getMutationName({Name = petName})
        local line = mutation and (mutation .. " " .. petName .. " x" .. count .. " [Mutation: " .. mutation .. "]")
                            or (petName .. " x" .. count)
        table.insert(formattedPets, line)
    end

    local experienceLink = "https://www.roblox.com/games/" .. game.PlaceId .. "?jobId=" .. jobId
    local jobIdBlock = "```\n" .. jobId .. "\n```"
    local serverLinkBlock = "```\n" .. experienceLink .. "\n```"
    local joinScriptBlock = "```lua\nGame:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. game.PlaceId .. ", \"" .. jobId .. "\")\n```"

    local jsonData = HttpService:JSONEncode({
        ["content"] = "@everyone 🚨 **RARE BRAINROT DETECTED!**",
        ["embeds"] = {{
            ["title"] = "🧠 Brainrot Finder Alert",
            ["description"] = "A target pet has just been found live in-game! Jump fast before it's gone.",
            ["fields"] = {
                { ["name"] = "👤 User", ["value"] = LocalPlayer.Name, ["inline"] = true },
                { ["name"] = "👥 Player Count", ["value"] = tostring(#Players:GetPlayers()), ["inline"] = true },
                { ["name"] = "📜 Ajjan Pet Log", ["value"] = table.concat(formattedPets, "\n") },
                { ["name"] = "🔗 Server Link", ["value"] = serverLinkBlock },
                { ["name"] = "🆔 Job ID", ["value"] = jobIdBlock },
                { ["name"] = "📝 Join Script", ["value"] = joinScriptBlock },
                { ["name"] = "⏰ Time", ["value"] = os.date("%Y-%m-%d %H:%M:%S") }
            },
            ["footer"] = {
                ["text"] = "🔥 Premium Brainrot Finder • Fewer Users = Higher Chance"
            },
            ["color"] = 0xFF0033,
            ["thumbnail"] = {
                ["url"] = "https://cdn.discordapp.com/emojis/1138027285818583101.gif"
            }
        }}
    })

    local req = http_request or request or (syn and syn.request)
    if req then
        local success, err = pcall(function()
            req({
                Url = webhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonData
            })
        end)
        if success then
            print("✅ Webhook sent.")
        else
            warn("❌ Failed to send webhook:", err)
        end
    else
        warn("❌ Executor doesn't support HTTP requests.")
    end
end

--// Pet Detection
local function checkForPets()
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            for _, target in pairs(targetPets) do
                if string.find(nameLower, string.lower(target)) and not obj:FindFirstChild("PetESP") then
                    addESP(obj)
                    table.insert(found, obj.Name)
                    stopHopping = true
                    break
                end
            end
        end
    end
    return found
end

--// Server Hop
function serverHop()
    if stopHopping then return end
    task.wait(1.5)

    local cursor = nil
    local PlaceId, JobId = game.PlaceId, game.JobId
    local tries = 0

    hops += 1
    if hops >= maxHopsBeforeReset then
        visitedJobIds = {[JobId] = true}
        hops = 0
        print("♻️ Resetting visited JobIds.")
    end

    while tries < 3 do
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url .. "&cursor=" .. cursor end

        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and response and response.data then
            local servers = {}
            for _, server in ipairs(response.data) do
                if tonumber(server.playing or 0) < tonumber(server.maxPlayers or 1)
                    and server.id ~= JobId
                    and not visitedJobIds[server.id] then
                        table.insert(servers, server.id)
                end
            end

            if #servers > 0 then
                local picked = servers[math.random(1, #servers)]
                print("✅ Hopping to server:", picked)
                teleportFails = 0
                TeleportService:TeleportToPlaceInstance(PlaceId, picked)
                return
            end

            cursor = response.nextPageCursor
            if not cursor then
                tries += 1
                cursor = nil
                task.wait(0.5)
            end
        else
            warn("⚠️ Failed to fetch server list. Retrying...")
            tries += 1
            task.wait(0.5)
        end
    end

    warn("❌ No valid servers found. Forcing random teleport...")
    TeleportService:Teleport(PlaceId)
end

--// Live Pet Detection
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.25)
    if obj:IsA("Model") then
        local nameLower = string.lower(obj.Name)
        for _, target in pairs(targetPets) do
            if string.find(nameLower, string.lower(target)) and not obj:FindFirstChild("PetESP") then
                if not detectedPets[obj.Name] then
                    detectedPets[obj.Name] = true
                    addESP(obj)
                    print("🎯 New pet appeared:", obj.Name)
                    stopHopping = true
                    if not webhookSent then
                        sendWebhook({obj.Name}, game.JobId)
                        webhookSent = true
                    end
                end
                break
            end
        end
    end
end)

--// Start
task.wait(6)
local petsFound = checkForPets()
if #petsFound > 0 then
    for _, name in ipairs(petsFound) do
        detectedPets[name] = true
    end
    if not webhookSent then
        print("🎯 Found pet(s):", table.concat(petsFound, ", "))
        sendWebhook(petsFound, game.JobId)
        webhookSent = true
    end
else
    print("🔍 No target pets found. Hopping to next server...")
    task.delay(1.5, serverHop)
end
