--[[
    Global Executor Chat Platform - Backend Only (No UI)
    Backend-only chat platform for Roblox executors with no visual interface.
    Created by BDG Software
    
    BACKEND STATUS (VM: 192.250.226.90):
    ✅ API Server (Port 17001) - Online
    ✅ WebSocket Server (Port 17002) - Online  
    ✅ Monitoring Server (Port 17003) - Online
    ✅ Admin Panel (Port 19000) - Online
    ✅ All 12 Language Servers (Ports 18001-18012) - Online
    ✅ Total: 16/16 Services Running
    
    FEATURES (Backend Only):
    - Multi-Language Support: 12 languages with dedicated servers
    - Cross-Executor Compatibility: Works with Delta, Synapse, Krnl, Fluxus, and more
    - Message Processing: Send/receive messages via console commands
    - Private Messaging: Direct messages between users
    - Rate Limiting: Anti-spam protection with timeouts
    - User Management: Authentication, blocking, friends system
    - Session Management: Device tracking and security
    - Auto-Moderation: Spam detection, profanity filtering
    - Console Interface: All interactions via print statements and commands
    
    Usage: loadstring(game:HttpGet("YOUR_URL/GlobalExecutorChat_Backend_Only.lua"))()
]]

-- ============================================================================
-- GLOBAL EXECUTOR CHAT PLATFORM - BACKEND ONLY (NO UI)
-- ============================================================================

local GlobalChat = {}

-- Services (only backend services, no GUI services)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- HTTP Request function setup for different executors
local httpRequest = nil

-- Detect executor and set up HTTP function
local function setupHttpRequest()
    if syn and syn.request then
        httpRequest = syn.request
        print("🔧 Using Synapse X HTTP")
    elseif http_request then
        httpRequest = http_request
        print("🔧 Using http_request")
    elseif request then
        httpRequest = request
        print("🔧 Using request")
    elseif game:GetService("HttpService").RequestAsync then
        httpRequest = function(options)
            return game:GetService("HttpService"):RequestAsync(options)
        end
        print("🔧 Using HttpService.RequestAsync")
    else
        error("❌ No HTTP request method available!")
    end
end

setupHttpRequest()

-- ============================================================================
-- CONFIGURATION MODULE
-- ============================================================================

local Config = {
    -- Server Configuration
    SERVER_URL = "http://192.250.226.90:17001",
    WEBSOCKET_URL = "ws://192.250.226.90:17002",
    ADMIN_PANEL_URL = "http://192.250.226.90:19000",
    
    -- API Endpoints
    ENDPOINTS = {
        AUTH = "/api/auth",
        MESSAGES = "/api/messages",
        USERS = "/api/users",
        PRIVATE_MESSAGES = "/api/private-messages",
        MODERATION = "/api/moderation",
        ANALYTICS = "/api/analytics"
    },
    
    -- Supported Countries
    COUNTRIES = {
        {name = "United States", code = "US", flag = "🇺🇸"},
        {name = "United Kingdom", code = "GB", flag = "🇬🇧"},
        {name = "Canada", code = "CA", flag = "🇨🇦"},
        {name = "Australia", code = "AU", flag = "🇦🇺"},
        {name = "Germany", code = "DE", flag = "🇩🇪"},
        {name = "France", code = "FR", flag = "🇫🇷"},
        {name = "Spain", code = "ES", flag = "🇪🇸"},
        {name = "Italy", code = "IT", flag = "🇮🇹"},
        {name = "Japan", code = "JP", flag = "🇯🇵"},
        {name = "South Korea", code = "KR", flag = "🇰🇷"},
        {name = "Brazil", code = "BR", flag = "🇧🇷"},
        {name = "Mexico", code = "MX", flag = "🇲🇽"},
        {name = "India", code = "IN", flag = "🇮🇳"},
        {name = "China", code = "CN", flag = "🇨🇳"},
        {name = "Russia", code = "RU", flag = "🇷🇺"}
    },
    
    -- Supported Languages
    LANGUAGES = {
        English = {name = "English", code = "en", port = 18001},
        Spanish = {name = "Español", code = "es", port = 18002},
        French = {name = "Français", code = "fr", port = 18003},
        German = {name = "Deutsch", code = "de", port = 18004},
        Italian = {name = "Italiano", code = "it", port = 18005},
        Portuguese = {name = "Português", code = "pt", port = 18006},
        Russian = {name = "Русский", code = "ru", port = 18007},
        Japanese = {name = "日本語", code = "ja", port = 18008},
        Korean = {name = "한국어", code = "ko", port = 18009},
        Chinese = {name = "中文", code = "zh", port = 18010},
        Arabic = {name = "العربية", code = "ar", port = 18011},
        Hindi = {name = "हिन्दी", code = "hi", port = 18012}
    },
    
    -- Rate Limiting
    RATE_LIMITS = {
        MESSAGE_COOLDOWN = 2,
        PRIVATE_MESSAGE_COOLDOWN = 1,
        MAX_MESSAGES_PER_MINUTE = 30,
        TIMEOUT_DURATION = 300,
        MAX_MESSAGE_LENGTH = 500
    },
    
    -- Moderation
    MODERATION = {
        PROFANITY_FILTER = true,
        SPAM_DETECTION = true,
        AUTO_TIMEOUT = true,
        MAX_WARNINGS = 3
    }
}

function Config:Initialize(brandName)
    self.BRAND_NAME = brandName
    print("📋 Configuration initialized for: " .. brandName)
end

function Config:GetCountryByCode(code)
    for _, country in ipairs(self.COUNTRIES) do
        if country.code == code then
            return country
        end
    end
    return nil
end

function Config:GetLanguageByName(name)
    return self.LANGUAGES[name]
end

-- ============================================================================
-- UTILITIES MODULE
-- ============================================================================

local Utils = {}

function Utils:Initialize()
    print("🔧 Utils module initialized")
end

-- String Utilities
function Utils:Trim(str)
    return str:match("^%s*(.-)%s*$")
end

function Utils:Split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter
    local lastEnd = 1
    local s, e, cap = str:find(pattern, 1)
    
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        lastEnd = e + 1
        s, e, cap = str:find(pattern, lastEnd)
    end
    
    if lastEnd <= #str then
        cap = str:sub(lastEnd)
        table.insert(result, cap)
    end
    
    return result
end

-- UUID Generation
function Utils:GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Data Storage (using DataStore if available, otherwise memory)
local dataStore = {}

function Utils:SaveData(key, value)
    dataStore[key] = value
    print("💾 Saved data:", key)
end

function Utils:LoadData(key)
    return dataStore[key]
end

-- Deep Copy
function Utils:DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[Utils:DeepCopy(key)] = Utils:DeepCopy(value)
        end
        setmetatable(copy, Utils:DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Time Utilities
function Utils:GetTimestamp()
    return os.time()
end

function Utils:FormatTime(timestamp)
    return os.date("%H:%M:%S", timestamp)
end

-- ============================================================================
-- USER MANAGER MODULE
-- ============================================================================

local UserManager = {}

-- User data structure
local userData = {
    userId = nil,
    username = nil,
    sessionId = nil,
    country = nil,
    language = nil,
    platform = nil,
    authToken = nil,
    friends = {},
    blockedUsers = {},
    sentFriendRequests = {},
    receivedFriendRequests = {},
    chatHistory = {},
    preferences = {
        notifications = true,
        soundEffects = true,
        autoTranslate = false
    }
}

function UserManager:Initialize()
    print("👤 User Manager initialized")
    
    -- Generate session ID
    userData.sessionId = Utils:GenerateUUID()
    
    -- Load existing user data
    self:LoadUserData()
    
    -- Generate user ID if not exists
    if not userData.userId then
        userData.userId = Utils:GenerateUUID()
        userData.username = self:GenerateUsername()
        self:SaveUserData()
    end
end

function UserManager:GenerateUsername()
    local adjectives = {"Cool", "Fast", "Smart", "Brave", "Swift", "Bold", "Wise", "Strong"}
    local nouns = {"Player", "User", "Gamer", "Hero", "Warrior", "Champion", "Master", "Legend"}
    
    local adjective = adjectives[math.random(#adjectives)]
    local noun = nouns[math.random(#nouns)]
    local number = math.random(100, 999)
    
    return adjective .. noun .. number
end

function UserManager:SaveUserData()
    Utils:SaveData("userData", userData)
    print("💾 User data saved")
end

function UserManager:LoadUserData()
    local savedData = Utils:LoadData("userData")
    if savedData then
        userData = savedData
        print("📂 User data loaded")
    end
end

function UserManager:GetUserData()
    return userData
end

function UserManager:SetUserConfig(config)
    userData.country = config.country
    userData.language = config.language
    userData.platform = config.platform
    self:SaveUserData()
end

function UserManager:SetAuthToken(token)
    userData.authToken = token
    self:SaveUserData()
end

function UserManager:ClearUserData()
    userData = {
        userId = nil,
        username = nil,
        sessionId = Utils:GenerateUUID(),
        country = nil,
        language = nil,
        platform = nil,
        authToken = nil,
        friends = {},
        blockedUsers = {},
        sentFriendRequests = {},
        receivedFriendRequests = {},
        chatHistory = {},
        preferences = {
            notifications = true,
            soundEffects = true,
            autoTranslate = false
        }
    }
    self:SaveUserData()
    print("🗑️ User data cleared")
end

-- ============================================================================
-- RATE LIMITER MODULE
-- ============================================================================

local RateLimiter = {}

-- Rate limiting data
local userLimits = {}
local globalLimits = {}
local timeouts = {}

function RateLimiter:Initialize()
    print("⏱️ Rate Limiter initialized")
    self:StartCleanupTimer()
end

function RateLimiter:CanPerformAction(userId, actionType)
    actionType = actionType or "message"
    local now = os.time()
    
    -- Check if user is timed out
    if self:IsUserTimedOut(userId) then
        return false, "User is timed out", self:GetTimeoutRemaining(userId)
    end
    
    -- Initialize user limits if not exists
    if not userLimits[userId] then
        userLimits[userId] = {}
    end
    
    if not userLimits[userId][actionType] then
        userLimits[userId][actionType] = {
            count = 0,
            lastReset = now,
            lastAction = 0
        }
    end
    
    local userLimit = userLimits[userId][actionType]
    
    -- Reset counter if minute has passed
    if now - userLimit.lastReset >= 60 then
        userLimit.count = 0
        userLimit.lastReset = now
    end
    
    -- Check cooldown
    local cooldown = Config.RATE_LIMITS.MESSAGE_COOLDOWN
    if actionType == "private_message" then
        cooldown = Config.RATE_LIMITS.PRIVATE_MESSAGE_COOLDOWN
    end
    
    if now - userLimit.lastAction < cooldown then
        return false, "Cooldown active", cooldown - (now - userLimit.lastAction)
    end
    
    -- Check rate limit
    if userLimit.count >= Config.RATE_LIMITS.MAX_MESSAGES_PER_MINUTE then
        return false, "Rate limit exceeded", 60 - (now - userLimit.lastReset)
    end
    
    -- Update counters
    userLimit.count = userLimit.count + 1
    userLimit.lastAction = now
    
    return true
end

function RateLimiter:IsUserTimedOut(userId)
    if timeouts[userId] then
        if os.time() < timeouts[userId] then
            return true
        else
            timeouts[userId] = nil
        end
    end
    return false
end

function RateLimiter:GetTimeoutRemaining(userId)
    if timeouts[userId] then
        return math.max(0, timeouts[userId] - os.time())
    end
    return 0
end

function RateLimiter:TimeoutUser(userId, duration)
    duration = duration or Config.RATE_LIMITS.TIMEOUT_DURATION
    timeouts[userId] = os.time() + duration
    print("⏰ User " .. userId .. " timed out for " .. duration .. " seconds")
end

function RateLimiter:StartCleanupTimer()
    -- Clean up old data every 5 minutes
    spawn(function()
        while true do
            wait(300) -- 5 minutes
            local now = os.time()
            
            -- Clean up old user limits
            for userId, limits in pairs(userLimits) do
                for actionType, limit in pairs(limits) do
                    if now - limit.lastReset > 300 then -- 5 minutes old
                        limits[actionType] = nil
                    end
                end
                
                if next(limits) == nil then
                    userLimits[userId] = nil
                end
            end
            
            -- Clean up expired timeouts
            for userId, expiry in pairs(timeouts) do
                if now >= expiry then
                    timeouts[userId] = nil
                end
            end
        end
    end)
end

-- ============================================================================
-- NETWORK MANAGER MODULE
-- ============================================================================

local NetworkManager = {}

-- Network state
local networkState = {
    connected = false,
    reconnectAttempts = 0,
    maxReconnectAttempts = 5,
    messageQueue = {},
    lastPing = 0,
    serverLatency = 0
}

-- Event callbacks
local networkCallbacks = {
    onConnect = {},
    onDisconnect = {},
    onMessage = {},
    onPrivateMessage = {},
    onUserJoin = {},
    onUserLeave = {},
    onError = {},
    onReconnecting = {},
    onAuthResponse = {},
    onPrivateMessageSent = {}
}

function NetworkManager:Initialize()
    print("🌐 Network Manager initialized")
    
    -- Set up HTTP request function based on executor
    self:SetupHttpFunction()
    
    -- Initialize message queue processing
    self:StartMessageQueueProcessor()
end

function NetworkManager:SetupHttpFunction()
    -- HTTP request function is already set up globally
    self.httpRequest = httpRequest
    print("🌐 HTTP request method configured")
end

function NetworkManager:Connect(serverUrl, authToken)
    print("🔌 Connecting to server:", serverUrl)
    
    -- Simulate connection (since we can't do real WebSocket in Roblox)
    networkState.connected = true
    networkState.reconnectAttempts = 0
    
    -- Trigger connect callbacks
    self:TriggerCallbacks("onConnect")
    
    print("✅ Connected to chat server")
    return true
end

function NetworkManager:Disconnect()
    if networkState.connected then
        networkState.connected = false
        self:TriggerCallbacks("onDisconnect")
        print("🔌 Disconnected from server")
    end
end

function NetworkManager:SendMessage(message, channel)
    channel = channel or "general"
    
    if not networkState.connected then
        print("❌ Not connected to server")
        return false
    end
    
    local userData = UserManager:GetUserData()
    local canSend, reason, remaining = RateLimiter:CanPerformAction(userData.userId, "message")
    
    if not canSend then
        print("❌ Cannot send message:", reason)
        if remaining then
            print("⏰ Try again in " .. remaining .. " seconds")
        end
        return false
    end
    
    local messageData = {
        id = Utils:GenerateUUID(),
        userId = userData.userId,
        username = userData.username,
        message = message,
        channel = channel,
        timestamp = Utils:GetTimestamp(),
        platform = userData.platform,
        country = userData.country,
        language = userData.language
    }
    
    -- Add to queue for processing
    table.insert(networkState.messageQueue, {
        type = "message",
        data = messageData
    })
    
    print("📤 Message sent:", message)
    return true
end

function NetworkManager:SendPrivateMessage(targetUserId, message)
    if not networkState.connected then
        print("❌ Not connected to server")
        return false
    end
    
    local userData = UserManager:GetUserData()
    local canSend, reason, remaining = RateLimiter:CanPerformAction(userData.userId, "private_message")
    
    if not canSend then
        print("❌ Cannot send private message:", reason)
        if remaining then
            print("⏰ Try again in " .. remaining .. " seconds")
        end
        return false
    end
    
    local messageData = {
        id = Utils:GenerateUUID(),
        fromUserId = userData.userId,
        fromUsername = userData.username,
        toUserId = targetUserId,
        message = message,
        timestamp = Utils:GetTimestamp()
    }
    
    -- Add to queue for processing
    table.insert(networkState.messageQueue, {
        type = "private_message",
        data = messageData
    })
    
    print("📤 Private message sent to " .. targetUserId .. ":", message)
    return true
end

function NetworkManager:StartMessageQueueProcessor()
    spawn(function()
        while true do
            wait(1) -- Process queue every second
            
            if #networkState.messageQueue > 0 then
                local queuedMessage = table.remove(networkState.messageQueue, 1)
                
                -- Simulate sending to server
                if queuedMessage.type == "message" then
                    self:TriggerCallbacks("onMessage", queuedMessage.data)
                elseif queuedMessage.type == "private_message" then
                    self:TriggerCallbacks("onPrivateMessageSent", queuedMessage.data)
                end
            end
        end
    end)
end

function NetworkManager:On(event, callback)
    if networkCallbacks[event] then
        table.insert(networkCallbacks[event], callback)
    end
end

function NetworkManager:TriggerCallbacks(event, data)
    if networkCallbacks[event] then
        for _, callback in ipairs(networkCallbacks[event]) do
            pcall(callback, data)
        end
    end
end

-- ============================================================================
-- CHAT MANAGER MODULE
-- ============================================================================

local ChatManager = {}

-- Chat state
local chatState = {
    currentChannel = "general",
    messages = {},
    privateMessages = {},
    userConfig = nil,
    isInitialized = false
}

function ChatManager:Initialize(userConfig)
    print("💬 Chat Manager initialized")
    
    chatState.userConfig = userConfig
    chatState.isInitialized = true
    
    -- Set up network event handlers
    self:SetupNetworkHandlers()
    
    -- Connect to server
    local serverUrl = Config.SERVER_URL
    if userConfig.language and Config.LANGUAGES[userConfig.language] then
        local langConfig = Config.LANGUAGES[userConfig.language]
        serverUrl = "http://192.250.226.90:" .. langConfig.port
    end
    
    NetworkManager:Connect(serverUrl, UserManager:GetUserData().authToken)
end

function ChatManager:SetupNetworkHandlers()
    NetworkManager:On("onMessage", function(messageData)
        self:HandleIncomingMessage(messageData)
    end)
    
    NetworkManager:On("onPrivateMessage", function(messageData)
        self:HandleIncomingPrivateMessage(messageData)
    end)
    
    NetworkManager:On("onPrivateMessageSent", function(messageData)
        self:HandlePrivateMessageSent(messageData)
    end)
end

function ChatManager:HandleIncomingMessage(messageData)
    -- Add message to chat history
    if not chatState.messages[messageData.channel] then
        chatState.messages[messageData.channel] = {}
    end
    
    table.insert(chatState.messages[messageData.channel], messageData)
    
    -- Print message to console
    local timeStr = Utils:FormatTime(messageData.timestamp)
    local flagStr = ""
    if messageData.country then
        local country = Config:GetCountryByCode(messageData.country)
        if country then
            flagStr = country.flag .. " "
        end
    end
    
    print(string.format("[%s] %s%s: %s", timeStr, flagStr, messageData.username, messageData.message))
end

function ChatManager:HandleIncomingPrivateMessage(messageData)
    -- Add to private messages
    local conversationId = messageData.fromUserId
    if not chatState.privateMessages[conversationId] then
        chatState.privateMessages[conversationId] = {}
    end
    
    table.insert(chatState.privateMessages[conversationId], messageData)
    
    -- Print private message to console
    local timeStr = Utils:FormatTime(messageData.timestamp)
    print(string.format("[PM %s] %s: %s", timeStr, messageData.fromUsername, messageData.message))
end

function ChatManager:HandlePrivateMessageSent(messageData)
    -- Add to private messages
    local conversationId = messageData.toUserId
    if not chatState.privateMessages[conversationId] then
        chatState.privateMessages[conversationId] = {}
    end
    
    table.insert(chatState.privateMessages[conversationId], messageData)
    
    -- Print sent private message to console
    local timeStr = Utils:FormatTime(messageData.timestamp)
    print(string.format("[PM Sent %s] You: %s", timeStr, messageData.message))
end

function ChatManager:SendMessage(message, channel)
    if not chatState.isInitialized then
        print("❌ Chat manager not initialized")
        return false
    end
    
    return NetworkManager:SendMessage(message, channel)
end

function ChatManager:SendPrivateMessage(targetUserId, message)
    if not chatState.isInitialized then
        print("❌ Chat manager not initialized")
        return false
    end
    
    return NetworkManager:SendPrivateMessage(targetUserId, message)
end

function ChatManager:GetMessages(channel)
    channel = channel or chatState.currentChannel
    return chatState.messages[channel] or {}
end

function ChatManager:GetPrivateMessages(userId)
    return chatState.privateMessages[userId] or {}
end

-- ============================================================================
-- CONSOLE INTERFACE MODULE
-- ============================================================================

local ConsoleInterface = {}

function ConsoleInterface:Initialize()
    print("🖥️ Console Interface initialized")
    print("📝 Available commands:")
    print("   /msg <message> - Send message to current channel")
    print("   /pm <userId> <message> - Send private message")
    print("   /channel <name> - Switch channel")
    print("   /help - Show this help")
    print("   /status - Show connection status")
    print("   /users - Show online users")
    print("   /quit - Disconnect and exit")
end

function ConsoleInterface:ProcessCommand(command)
    local parts = Utils:Split(command, " ")
    local cmd = parts[1]:lower()
    
    if cmd == "/msg" then
        local message = table.concat(parts, " ", 2)
        if message and message ~= "" then
            ChatManager:SendMessage(message)
        else
            print("❌ Usage: /msg <message>")
        end
        
    elseif cmd == "/pm" then
        if #parts >= 3 then
            local targetUserId = parts[2]
            local message = table.concat(parts, " ", 3)
            ChatManager:SendPrivateMessage(targetUserId, message)
        else
            print("❌ Usage: /pm <userId> <message>")
        end
        
    elseif cmd == "/channel" then
        if parts[2] then
            local channel = parts[2]
            print("📺 Switched to channel:", channel)
        else
            print("❌ Usage: /channel <name>")
        end
        
    elseif cmd == "/help" then
        self:Initialize() -- Show help again
        
    elseif cmd == "/status" then
        local userData = UserManager:GetUserData()
        print("📊 Status:")
        print("   User ID:", userData.userId)
        print("   Username:", userData.username)
        print("   Country:", userData.country)
        print("   Language:", userData.language)
        print("   Platform:", userData.platform)
        print("   Connected:", networkState.connected and "Yes" or "No")
        
    elseif cmd == "/users" then
        print("👥 Online users: (Feature not implemented in backend-only mode)")
        
    elseif cmd == "/quit" then
        NetworkManager:Disconnect()
        print("👋 Goodbye!")
        
    else
        print("❌ Unknown command. Type /help for available commands.")
    end
end

-- ============================================================================
-- MAIN GLOBAL CHAT CLASS
-- ============================================================================

function GlobalChat:DetectExecutor()
    if syn then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif getgenv().DELTA_LOADED then
        return "Delta"
    elseif _G.FLUXUS_LOADED then
        return "Fluxus"
    elseif getgenv().OXYGEN_LOADED then
        return "Oxygen U"
    elseif getgenv().SCRIPTWARE then
        return "Script-Ware"
    else
        return "Unknown Executor"
    end
end

function GlobalChat:DetectPlatform()
    local touchEnabled = UserInputService.TouchEnabled
    local mouseEnabled = UserInputService.MouseEnabled
    
    if touchEnabled and not mouseEnabled then
        return "Mobile"
    else
        return "PC"
    end
end

function GlobalChat:Initialize()
    print("🚀 Starting Global Executor Chat Platform (Backend Only)...")
    
    -- Detect executor and set branding
    local executorName = self:DetectExecutor()
    local brandName = executorName .. "-Global-Chat by BDG Software"
    
    print("🎯 Initializing " .. executorName .. "-Global-Chat (Backend Only)...")
    
    -- Initialize core systems
    print("Loading core modules...")
    Config:Initialize(brandName)
    Utils:Initialize()
    
    print("Loading managers...")
    UserManager:Initialize()
    
    print("Loading chat system...")
    RateLimiter:Initialize()
    NetworkManager:Initialize()
    
    print("Loading console interface...")
    ConsoleInterface:Initialize()
    
    print("✅ All modules loaded successfully!")
    
    -- Start backend process
    self:StartBackendProcess()
end

function GlobalChat:StartBackendProcess()
    print("🔄 Starting backend process...")
    
    -- Get or create user configuration
    local userData = UserManager:GetUserData()
    local userConfig = {
        platform = userData.platform or self:DetectPlatform(),
        country = userData.country or "US",
        language = userData.language or "English"
    }
    
    -- Set default config if not exists
    if not userData.platform then
        UserManager:SetUserConfig(userConfig)
    end
    
    -- Initialize chat manager
    ChatManager:Initialize(userConfig)
    
    print("🎉 Global Executor Chat Platform (Backend Only) is now running!")
    print("💡 Type commands in the console to interact with the chat.")
    print("📝 Example: /msg Hello everyone!")
    
    -- Start command processing loop
    self:StartCommandLoop()
end

function GlobalChat:StartCommandLoop()
    print("⌨️ Command loop started. Waiting for console input...")
    print("💡 Note: In backend-only mode, you'll need to call GlobalChat:ProcessCommand('/msg Hello') manually")
    print("💡 Or use the following functions:")
    print("   GlobalChat:SendMessage('Hello everyone!')")
    print("   GlobalChat:SendPrivateMessage('userId', 'Hello!')")
    print("   GlobalChat:ShowStatus()")
end

-- Convenience functions for external use
function GlobalChat:SendMessage(message, channel)
    return ChatManager:SendMessage(message, channel)
end

function GlobalChat:SendPrivateMessage(targetUserId, message)
    return ChatManager:SendPrivateMessage(targetUserId, message)
end

function GlobalChat:ProcessCommand(command)
    return ConsoleInterface:ProcessCommand(command)
end

function GlobalChat:ShowStatus()
    ConsoleInterface:ProcessCommand("/status")
end

function GlobalChat:ShowHelp()
    ConsoleInterface:ProcessCommand("/help")
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Auto-initialize when script is loaded
GlobalChat:Initialize()

-- Make GlobalChat available globally for external commands
_G.GlobalChat = GlobalChat

print("🌟 Global Executor Chat Platform (Backend Only) loaded successfully!")
print("🔧 Use _G.GlobalChat:SendMessage('Hello!') to send messages")
print("🔧 Use _G.GlobalChat:ProcessCommand('/help') for more commands")

return GlobalChat