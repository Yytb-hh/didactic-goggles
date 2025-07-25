--[[
    Global Executor Chat Platform - Unified Script
    Complete chat platform designed for Roblox executors with professional UI, multi-language support, and robust features.
    Created by BDG Software
    
    BACKEND STATUS (VM: 192.250.226.90):
    ✅ API Server (Port 17001) - Online
    ✅ WebSocket Server (Port 17002) - Online  
    ✅ Monitoring Server (Port 17003) - Online
    ✅ Admin Panel (Port 19000) - Online
    ✅ All 12 Language Servers (Ports 18001-18012) - Online
    ✅ Total: 16/16 Services Running
    
    FEATURES:
    - Multi-Language Support: 12 languages with dedicated servers
    - Cross-Executor Compatibility: Works with Delta, Synapse, Krnl, Fluxus, and more
    - Responsive UI: Optimized for both mobile and desktop platforms
    - Discord-like Interface: Modern, intuitive chat experience
    - Message Threading: Create and participate in message threads
    - Private Messaging: Direct messages between users
    - Rate Limiting: Anti-spam protection with timeouts
    - Emoji Support: Full emoji picker with Unicode support
    - User Management: Authentication, blocking, friends system
    - Multiple Themes: Dark, Light, AMOLED, Synthwave, Ocean
    - Real-time Notifications: Roblox-integrated notifications
    - Session Management: Device tracking and security
    - Auto-Moderation: Spam detection, profanity filtering
    - Admin Panel: Full management interface at http://192.250.226.90:19000
    
    Usage: loadstring(game:HttpGet("YOUR_URL/GlobalExecutorChat_Unified.lua"))()
]]

-- ============================================================================
-- GLOBAL EXECUTOR CHAT PLATFORM - UNIFIED SCRIPT
-- ============================================================================

local GlobalChat = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

-- HTTP Request function setup for different executors
local httpRequest
if syn and syn.request then
    httpRequest = syn.request
elseif request then
    httpRequest = request
elseif http_request then
    httpRequest = http_request
elseif fluxus and fluxus.request then
    httpRequest = fluxus.request
else
    -- Fallback to HttpService
    httpRequest = function(options)
        return HttpService:RequestAsync(options)
    end
end

-- ============================================================================
-- CONFIGURATION MODULE
-- ============================================================================

local Config = {
    -- Application Information
    APP_NAME = "Global-Executor-Chat",
    VERSION = "1.0.0",
    AUTHOR = "BDG Software",
    BRAND_NAME = nil, -- Set dynamically
    
    -- Server Configuration (Updated with working VM infrastructure)
    SERVER_URL = "wss://192.250.226.90:17002",
    WEBSOCKET_URL = "wss://192.250.226.90:17002", -- Secure WebSocket URL
    API_BASE_URL = "https://192.250.226.90:17001", -- Secure HTTP URL
    HEARTBEAT_INTERVAL = 30,
    RECONNECT_DELAY = 5,
    MAX_RECONNECT_ATTEMPTS = 10,
    
    -- Server Ports (All services confirmed online)
    PORTS = {
        API_SERVER = 17001,        -- Main API server (online)
        WEBSOCKET_SERVER = 17002,  -- WebSocket server (online)
        MONITORING = 17003,        -- Monitoring server (online)
        ADMIN_PANEL = 19000,       -- Admin panel (online)
        -- Language servers (all online)
        LANG_ENGLISH = 18001,
        LANG_SPANISH = 18002,
        LANG_FRENCH = 18003,
        LANG_GERMAN = 18004,
        LANG_ITALIAN = 18005,
        LANG_PORTUGUESE = 18006,
        LANG_RUSSIAN = 18007,
        LANG_JAPANESE = 18008,
        LANG_KOREAN = 18009,
        LANG_CHINESE = 18010,
        LANG_HINDI = 18011,
        LANG_ARABIC = 18012
    },
    
    -- Language Server URLs (All confirmed working)
    LANGUAGE_SERVERS = {
        english = "http://192.250.226.90:18001",
        spanish = "http://192.250.226.90:18002",
        french = "http://192.250.226.90:18003",
        german = "http://192.250.226.90:18004",
        italian = "http://192.250.226.90:18005",
        portuguese = "http://192.250.226.90:18006",
        russian = "http://192.250.226.90:18007",
        japanese = "http://192.250.226.90:18008",
        korean = "http://192.250.226.90:18009",
        chinese = "http://192.250.226.90:18010",
        hindi = "http://192.250.226.90:18011",
        arabic = "http://192.250.226.90:18012"
    },
    
    -- Rate Limiting
    RATE_LIMIT = {
        MESSAGES_PER_MINUTE = 20,
        TIMEOUT_DURATION = 30,
        BURST_LIMIT = 5,
        BURST_WINDOW = 10
    },
    
    -- UI Configuration
    UI = {
        ANIMATION_SPEED = 0.3,
        FADE_SPEED = 0.2,
        NOTIFICATION_DURATION = 5,
        MAX_CHAT_HISTORY = 500,
        MESSAGE_MAX_LENGTH = 2000,
        USERNAME_MAX_LENGTH = 20
    },
    
    -- Mobile UI Specific
    MOBILE = {
        FLOATING_BUTTON_SIZE = UDim2.new(0, 60, 0, 60),
        FLOATING_BUTTON_POSITION = UDim2.new(1, -80, 1, -80),
        NOTIFICATION_BADGE_SIZE = UDim2.new(0, 20, 0, 20),
        CHAT_WINDOW_SIZE = UDim2.new(0.95, 0, 0.8, 0),
        KEYBOARD_OFFSET = 200
    },
    
    -- Desktop UI Specific
    DESKTOP = {
        WINDOW_MIN_SIZE = Vector2.new(800, 600),
        WINDOW_DEFAULT_SIZE = Vector2.new(1000, 700),
        SIDEBAR_WIDTH = 250,
        CHAT_INPUT_HEIGHT = 50,
        MESSAGE_PADDING = 10
    },
    
    -- Supported Countries and Languages
    COUNTRIES = {
        {code = "US", name = "United States", flag = "🇺🇸", languages = {"English"}},
        {code = "GB", name = "United Kingdom", flag = "🇬🇧", languages = {"English"}},
        {code = "CA", name = "Canada", flag = "🇨🇦", languages = {"English", "French"}},
        {code = "AU", name = "Australia", flag = "🇦🇺", languages = {"English"}},
        {code = "DE", name = "Germany", flag = "🇩🇪", languages = {"German", "English"}},
        {code = "FR", name = "France", flag = "🇫🇷", languages = {"French", "English"}},
        {code = "ES", name = "Spain", flag = "🇪🇸", languages = {"Spanish", "English"}},
        {code = "IT", name = "Italy", flag = "🇮🇹", languages = {"Italian", "English"}},
        {code = "BR", name = "Brazil", flag = "🇧🇷", languages = {"Portuguese", "English"}},
        {code = "MX", name = "Mexico", flag = "🇲🇽", languages = {"Spanish", "English"}},
        {code = "JP", name = "Japan", flag = "🇯🇵", languages = {"Japanese", "English"}},
        {code = "KR", name = "South Korea", flag = "🇰🇷", languages = {"Korean", "English"}},
        {code = "CN", name = "China", flag = "🇨🇳", languages = {"Chinese", "English"}},
        {code = "RU", name = "Russia", flag = "🇷🇺", languages = {"Russian", "English"}},
        {code = "IN", name = "India", flag = "🇮🇳", languages = {"Hindi", "English"}},
        {code = "PH", name = "Philippines", flag = "🇵🇭", languages = {"Filipino", "English"}},
        {code = "TH", name = "Thailand", flag = "🇹🇭", languages = {"Thai", "English"}},
        {code = "VN", name = "Vietnam", flag = "🇻🇳", languages = {"Vietnamese", "English"}},
        {code = "ID", name = "Indonesia", flag = "🇮🇩", languages = {"Indonesian", "English"}},
        {code = "MY", name = "Malaysia", flag = "🇲🇾", languages = {"Malay", "English"}},
        {code = "SG", name = "Singapore", flag = "🇸🇬", languages = {"English", "Chinese", "Malay"}},
        {code = "NL", name = "Netherlands", flag = "🇳🇱", languages = {"Dutch", "English"}},
        {code = "SE", name = "Sweden", flag = "🇸🇪", languages = {"Swedish", "English"}},
        {code = "NO", name = "Norway", flag = "🇳🇴", languages = {"Norwegian", "English"}},
        {code = "DK", name = "Denmark", flag = "🇩🇰", languages = {"Danish", "English"}},
        {code = "FI", name = "Finland", flag = "🇫🇮", languages = {"Finnish", "English"}},
        {code = "PL", name = "Poland", flag = "🇵🇱", languages = {"Polish", "English"}},
        {code = "TR", name = "Turkey", flag = "🇹🇷", languages = {"Turkish", "English"}},
        {code = "SA", name = "Saudi Arabia", flag = "🇸🇦", languages = {"Arabic", "English"}},
        {code = "AE", name = "UAE", flag = "🇦🇪", languages = {"Arabic", "English"}},
        {code = "EG", name = "Egypt", flag = "🇪🇬", languages = {"Arabic", "English"}},
        {code = "ZA", name = "South Africa", flag = "🇿🇦", languages = {"English", "Afrikaans"}},
        {code = "NG", name = "Nigeria", flag = "🇳🇬", languages = {"English"}},
        {code = "AR", name = "Argentina", flag = "🇦🇷", languages = {"Spanish", "English"}},
        {code = "CL", name = "Chile", flag = "🇨🇱", languages = {"Spanish", "English"}},
        {code = "CO", name = "Colombia", flag = "🇨🇴", languages = {"Spanish", "English"}},
        {code = "PE", name = "Peru", flag = "🇵🇪", languages = {"Spanish", "English"}},
        {code = "OTHER", name = "Other", flag = "🌍", languages = {"English"}}
    },
    
    -- Language Configurations
    LANGUAGES = {
        English = {code = "en", name = "English", nativeName = "English", rtl = false},
        Spanish = {code = "es", name = "Spanish", nativeName = "Español", rtl = false},
        French = {code = "fr", name = "French", nativeName = "Français", rtl = false},
        German = {code = "de", name = "German", nativeName = "Deutsch", rtl = false},
        Italian = {code = "it", name = "Italian", nativeName = "Italiano", rtl = false},
        Portuguese = {code = "pt", name = "Portuguese", nativeName = "Português", rtl = false},
        Russian = {code = "ru", name = "Russian", nativeName = "Русский", rtl = false},
        Japanese = {code = "ja", name = "Japanese", nativeName = "日本語", rtl = false},
        Korean = {code = "ko", name = "Korean", nativeName = "한국어", rtl = false},
        Chinese = {code = "zh", name = "Chinese", nativeName = "中文", rtl = false},
        Hindi = {code = "hi", name = "Hindi", nativeName = "हिन्दी", rtl = false},
        Arabic = {code = "ar", name = "Arabic", nativeName = "العربية", rtl = true},
        Thai = {code = "th", name = "Thai", nativeName = "ไทย", rtl = false},
        Vietnamese = {code = "vi", name = "Vietnamese", nativeName = "Tiếng Việt", rtl = false},
        Indonesian = {code = "id", name = "Indonesian", nativeName = "Bahasa Indonesia", rtl = false},
        Malay = {code = "ms", name = "Malay", nativeName = "Bahasa Melayu", rtl = false},
        Filipino = {code = "fil", name = "Filipino", nativeName = "Filipino", rtl = false},
        Dutch = {code = "nl", name = "Dutch", nativeName = "Nederlands", rtl = false},
        Swedish = {code = "sv", name = "Swedish", nativeName = "Svenska", rtl = false},
        Norwegian = {code = "no", name = "Norwegian", nativeName = "Norsk", rtl = false},
        Danish = {code = "da", name = "Danish", nativeName = "Dansk", rtl = false},
        Finnish = {code = "fi", name = "Finnish", nativeName = "Suomi", rtl = false},
        Polish = {code = "pl", name = "Polish", nativeName = "Polski", rtl = false},
        Turkish = {code = "tr", name = "Turkish", nativeName = "Türkçe", rtl = false},
        Afrikaans = {code = "af", name = "Afrikaans", nativeName = "Afrikaans", rtl = false}
    },
    
    -- Theme Configurations
    THEMES = {
        Dark = {
            name = "Dark",
            primary = Color3.fromRGB(54, 57, 63),
            secondary = Color3.fromRGB(47, 49, 54),
            accent = Color3.fromRGB(114, 137, 218),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(185, 187, 190),
            textMuted = Color3.fromRGB(114, 118, 125),
            success = Color3.fromRGB(67, 181, 129),
            warning = Color3.fromRGB(250, 166, 26),
            error = Color3.fromRGB(240, 71, 71),
            online = Color3.fromRGB(67, 181, 129),
            idle = Color3.fromRGB(250, 166, 26),
            dnd = Color3.fromRGB(240, 71, 71),
            offline = Color3.fromRGB(116, 127, 141)
        },
        Light = {
            name = "Light",
            primary = Color3.fromRGB(255, 255, 255),
            secondary = Color3.fromRGB(246, 246, 246),
            accent = Color3.fromRGB(88, 101, 242),
            text = Color3.fromRGB(32, 34, 37),
            textSecondary = Color3.fromRGB(79, 84, 92),
            textMuted = Color3.fromRGB(116, 127, 141),
            success = Color3.fromRGB(59, 165, 93),
            warning = Color3.fromRGB(255, 168, 0),
            error = Color3.fromRGB(237, 66, 69),
            online = Color3.fromRGB(59, 165, 93),
            idle = Color3.fromRGB(255, 168, 0),
            dnd = Color3.fromRGB(237, 66, 69),
            offline = Color3.fromRGB(116, 127, 141)
        },
        AMOLED = {
            name = "AMOLED",
            primary = Color3.fromRGB(0, 0, 0),
            secondary = Color3.fromRGB(16, 16, 16),
            accent = Color3.fromRGB(0, 255, 127),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(200, 200, 200),
            textMuted = Color3.fromRGB(150, 150, 150),
            success = Color3.fromRGB(0, 255, 127),
            warning = Color3.fromRGB(255, 193, 7),
            error = Color3.fromRGB(255, 82, 82),
            online = Color3.fromRGB(0, 255, 127),
            idle = Color3.fromRGB(255, 193, 7),
            dnd = Color3.fromRGB(255, 82, 82),
            offline = Color3.fromRGB(100, 100, 100)
        },
        Synthwave = {
            name = "Synthwave",
            primary = Color3.fromRGB(16, 4, 43),
            secondary = Color3.fromRGB(25, 6, 62),
            accent = Color3.fromRGB(255, 0, 128),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(255, 20, 147),
            textMuted = Color3.fromRGB(138, 43, 226),
            success = Color3.fromRGB(0, 255, 255),
            warning = Color3.fromRGB(255, 215, 0),
            error = Color3.fromRGB(255, 69, 0),
            online = Color3.fromRGB(0, 255, 255),
            idle = Color3.fromRGB(255, 215, 0),
            dnd = Color3.fromRGB(255, 69, 0),
            offline = Color3.fromRGB(75, 0, 130)
        },
        Ocean = {
            name = "Ocean",
            primary = Color3.fromRGB(13, 71, 161),
            secondary = Color3.fromRGB(21, 101, 192),
            accent = Color3.fromRGB(3, 169, 244),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(224, 247, 250),
            textMuted = Color3.fromRGB(144, 202, 249),
            success = Color3.fromRGB(76, 175, 80),
            warning = Color3.fromRGB(255, 193, 7),
            error = Color3.fromRGB(244, 67, 54),
            online = Color3.fromRGB(76, 175, 80),
            idle = Color3.fromRGB(255, 193, 7),
            dnd = Color3.fromRGB(244, 67, 54),
            offline = Color3.fromRGB(96, 125, 139)
        }
    },
    
    -- Default Settings
    DEFAULTS = {
        theme = "Dark",
        language = "English",
        country = "US",
        platform = "PC",
        notifications = true,
        sounds = true,
        autoScroll = true,
        showTimestamps = true,
        compactMode = false,
        fontSize = 14
    },
    
    -- Message Types
    MESSAGE_TYPES = {
        NORMAL = "normal",
        SYSTEM = "system",
        PRIVATE = "private",
        REPLY = "reply",
        THREAD = "thread",
        JOIN = "join",
        LEAVE = "leave",
        ERROR = "error"
    },
    
    -- User Status Types
    USER_STATUS = {
        ONLINE = "online",
        IDLE = "idle",
        DND = "dnd",
        OFFLINE = "offline"
    },
    
    -- Emoji Categories
    EMOJI_CATEGORIES = {
        "Smileys & Emotion",
        "People & Body",
        "Animals & Nature",
        "Food & Drink",
        "Activities",
        "Travel & Places",
        "Objects",
        "Symbols",
        "Flags"
    }
}

-- Config methods
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

function Config:GetThemeByName(name)
    return self.THEMES[name] or self.THEMES.Dark
end

function Config:GetLanguagesForCountry(countryCode)
    local country = self:GetCountryByCode(countryCode)
    return country and country.languages or {"English"}
end

function Config:ValidateConfig(config)
    local errors = {}
    
    if not config.country or not self:GetCountryByCode(config.country) then
        table.insert(errors, "Invalid country code")
    end
    
    if not config.language or not self:GetLanguageByName(config.language) then
        table.insert(errors, "Invalid language")
    end
    
    if not config.theme or not self:GetThemeByName(config.theme) then
        table.insert(errors, "Invalid theme")
    end
    
    if config.platform ~= "Mobile" and config.platform ~= "PC" then
        table.insert(errors, "Invalid platform")
    end
    
    return #errors == 0, errors
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

function Utils:Escape(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

function Utils:FormatTime(timestamp)
    local now = os.time()
    local diff = now - timestamp
    
    if diff < 60 then
        return "now"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. "m"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. "h"
    else
        return os.date("%m/%d", timestamp)
    end
end

function Utils:FormatTimestamp(timestamp)
    return os.date("%H:%M", timestamp)
end

-- Table Utilities
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

function Utils:Merge(t1, t2)
    local result = Utils:DeepCopy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = Utils:Merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function Utils:Contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function Utils:TableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- UI Utilities
function Utils:CreateTween(object, info, properties)
    local tweenInfo = TweenInfo.new(
        info.duration or 0.3,
        info.easingStyle or Enum.EasingStyle.Quad,
        info.easingDirection or Enum.EasingDirection.Out,
        info.repeatCount or 0,
        info.reverses or false,
        info.delayTime or 0
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

function Utils:FadeIn(object, duration)
    duration = duration or 0.3
    object.Transparency = 1
    
    local tween = self:CreateTween(object, {duration = duration}, {Transparency = 0})
    tween:Play()
    
    return tween
end

function Utils:FadeOut(object, duration)
    duration = duration or 0.3
    
    local tween = self:CreateTween(object, {duration = duration}, {Transparency = 1})
    tween:Play()
    
    return tween
end

function Utils:SlideIn(object, direction, duration)
    duration = duration or 0.3
    direction = direction or "left"
    
    local originalPosition = object.Position
    local startPosition
    
    if direction == "left" then
        startPosition = UDim2.new(originalPosition.X.Scale - 1, originalPosition.X.Offset, originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif direction == "right" then
        startPosition = UDim2.new(originalPosition.X.Scale + 1, originalPosition.X.Offset, originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif direction == "up" then
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, originalPosition.Y.Scale - 1, originalPosition.Y.Offset)
    else -- down
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, originalPosition.Y.Scale + 1, originalPosition.Y.Offset)
    end
    
    object.Position = startPosition
    
    local tween = self:CreateTween(object, {duration = duration}, {Position = originalPosition})
    tween:Play()
    
    return tween
end

function Utils:Bounce(object, scale)
    scale = scale or 1.1
    local originalSize = object.Size
    
    local bounceUp = self:CreateTween(object, {duration = 0.1}, {Size = UDim2.new(originalSize.X.Scale * scale, originalSize.X.Offset, originalSize.Y.Scale * scale, originalSize.Y.Offset)})
    local bounceDown = self:CreateTween(object, {duration = 0.1}, {Size = originalSize})
    
    bounceUp:Play()
    bounceUp.Completed:Connect(function()
        bounceDown:Play()
    end)
    
    return bounceUp
end

-- Text Utilities
function Utils:GetTextSize(text, font, fontSize, maxWidth)
    local textBounds = TextService:GetTextSize(text, fontSize, font, Vector2.new(maxWidth or math.huge, math.huge))
    return textBounds
end

function Utils:WrapText(text, font, fontSize, maxWidth)
    local words = self:Split(text, " ")
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        local textSize = self:GetTextSize(testLine, font, fontSize)
        
        if textSize.X <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                table.insert(lines, word)
            end
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Color Utilities
function Utils:LerpColor(color1, color2, alpha)
    return Color3.new(
        color1.R + (color2.R - color1.R) * alpha,
        color1.G + (color2.G - color1.G) * alpha,
        color1.B + (color2.B - color1.B) * alpha
    )
end

function Utils:ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utils:HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

-- Math Utilities
function Utils:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils:Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils:Round(number, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(number * mult + 0.5) / mult
end

-- UUID Generation
function Utils:GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- Validation Utilities
function Utils:IsValidEmail(email)
    return email:match("^[%w%._%+%-]+@[%w%._%+%-]+%.%w+$") ~= nil
end

function Utils:IsValidUsername(username)
    return username:match("^[%w_%-]+$") ~= nil and #username >= 3 and #username <= 20
end

function Utils:SanitizeInput(input)
    -- Remove potentially dangerous characters
    input = input:gsub("[<>\"'&]", "")
    -- Trim whitespace
    input = self:Trim(input)
    return input
end

-- Platform Detection
function Utils:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils:IsPC()
    return UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
end

function Utils:GetPlatform()
    if self:IsMobile() then
        return "Mobile"
    else
        return "PC"
    end
end

-- Storage Utilities (using persistent storage)
function Utils:SaveData(key, data)
    -- Ensure key is valid
    key = "GlobalChat_" .. key
    
    -- Convert data to JSON
    local jsonData = HttpService:JSONEncode(data)
    
    -- Try to use executor-specific persistent storage
    local success = false
    
    -- Try Synapse
    if syn and syn.write_file then
        success = pcall(function()
            syn.write_file(key .. ".json", jsonData)
        end)
    -- Try Krnl
    elseif writefile then
        success = pcall(function()
            writefile(key .. ".json", jsonData)
        end)
    -- Try Fluxus
    elseif fluxus and fluxus.write_file then
        success = pcall(function()
            fluxus.write_file(key .. ".json", jsonData)
        end)
    -- Try Script-Ware
    elseif saveinstance then
        success = pcall(function()
            writefile(key .. ".json", jsonData)
        end)
    end
    
    if not success then
        print("⚠️ Failed to save data to persistent storage")
    end
    
    return success
end

function Utils:LoadData(key, default)
    -- Ensure key is valid
    key = "GlobalChat_" .. key
    
    local content = nil
    local success = false
    
    -- Try to use executor-specific persistent storage
    -- Try Synapse
    if syn and syn.read_file then
        success, content = pcall(function()
            return syn.read_file(key .. ".json")
        end)
    -- Try Krnl
    elseif readfile then
        success, content = pcall(function()
            return readfile(key .. ".json")
        end)
    -- Try Fluxus
    elseif fluxus and fluxus.read_file then
        success, content = pcall(function()
            return fluxus.read_file(key .. ".json")
        end)
    -- Try Script-Ware
    elseif saveinstance then
        success, content = pcall(function()
            return readfile(key .. ".json")
        end)
    end
    
    if success and content then
        local parseSuccess, result = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        
        if parseSuccess then
            return result
        end
    end
    
    return default
end

function Utils:ClearData(key)
    -- Ensure key is valid
    key = "GlobalChat_" .. key
    
    -- Try to use executor-specific persistent storage
    local success = false
    
    -- Try Synapse
    if syn and syn.delfile then
        success = pcall(function()
            syn.delfile(key .. ".json")
        end)
    -- Try Krnl
    elseif delfile then
        success = pcall(function()
            delfile(key .. ".json")
        end)
    -- Try Fluxus
    elseif fluxus and fluxus.delete_file then
        success = pcall(function()
            fluxus.delete_file(key .. ".json")
        end)
    -- Try Script-Ware
    elseif saveinstance then
        success = pcall(function()
            delfile(key .. ".json")
        end)
    end
    
    return success
end

-- Network Utilities
function Utils:MakeRequest(url, method, headers, body)
    method = method or "GET"
    headers = headers or {}
    
    local requestData = {
        Url = url,
        Method = method,
        Headers = headers
    }
    
    if body then
        requestData.Body = body
    end
    
    local success, response = pcall(function()
        return HttpService:RequestAsync(requestData)
    end)
    
    if success then
        return response
    else
        warn("Request failed: " .. tostring(response))
        return nil
    end
end

-- Debounce Utility
function Utils:Debounce(func, delay)
    local timer
    return function(...)
        local args = {...}
        if timer then
            timer:Disconnect()
        end
        timer = RunService.Heartbeat:Connect(function()
            wait(delay)
            timer:Disconnect()
            func(unpack(args))
        end)
    end
end

-- Throttle Utility
function Utils:Throttle(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            func(...)
        end
    end
end

-- Event Emitter
local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter.new()
    return setmetatable({
        events = {}
    }, EventEmitter)
end

function EventEmitter:On(event, callback)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
end

function EventEmitter:Off(event, callback)
    if self.events[event] then
        for i, cb in ipairs(self.events[event]) do
            if cb == callback then
                table.remove(self.events[event], i)
                break
            end
        end
    end
end

function EventEmitter:Emit(event, ...)
    if self.events[event] then
        for _, callback in ipairs(self.events[event]) do
            callback(...)
        end
    end
end

function EventEmitter:Once(event, callback)
    local function onceCallback(...)
        callback(...)
        self:Off(event, onceCallback)
    end
    self:On(event, onceCallback)
end

Utils.EventEmitter = EventEmitter

function Utils:Cleanup()
    storage = {}
end

-- ============================================================================
-- THEME MANAGER MODULE
-- ============================================================================

local ThemeManager = {}

-- Current theme data
local currentTheme = nil
local themeCallbacks = {}

function ThemeManager:Initialize()
    print("🎨 Theme Manager initialized")
    self:SetTheme("Dark")
end

function ThemeManager:SetTheme(themeName)
    local theme = Config:GetThemeByName(themeName)
    if not theme then
        warn("Theme not found: " .. tostring(themeName))
        return false
    end
    
    currentTheme = Utils:DeepCopy(theme)
    
    -- Notify all registered callbacks
    for _, callback in ipairs(themeCallbacks) do
        callback(currentTheme)
    end
    
    print("🎨 Theme changed to: " .. themeName)
    return true
end

function ThemeManager:GetCurrentTheme()
    return currentTheme or Config.THEMES.Dark
end

function ThemeManager:GetTheme(themeName)
    return Config:GetThemeByName(themeName)
end

function ThemeManager:GetAvailableThemes()
    local themes = {}
    for name, theme in pairs(Config.THEMES) do
        themes[name] = {
            name = theme.name,
            preview = {
                primary = theme.primary,
                secondary = theme.secondary,
                accent = theme.accent,
                text = theme.text
            }
        }
    end
    return themes
end

function ThemeManager:OnThemeChanged(callback)
    table.insert(themeCallbacks, callback)
    
    -- Call immediately with current theme
    if currentTheme then
        callback(currentTheme)
    end
end

function ThemeManager:OffThemeChanged(callback)
    for i, cb in ipairs(themeCallbacks) do
        if cb == callback then
            table.remove(themeCallbacks, i)
            break
        end
    end
end

function ThemeManager:ApplyTheme(guiObject, styleConfig)
    if not currentTheme or not guiObject then
        return
    end
    
    -- Apply basic styling based on object type
    if guiObject:IsA("Frame") then
        self:ApplyFrameTheme(guiObject, styleConfig)
    elseif guiObject:IsA("TextLabel") then
        self:ApplyTextLabelTheme(guiObject, styleConfig)
    elseif guiObject:IsA("TextButton") then
        self:ApplyTextButtonTheme(guiObject, styleConfig)
    elseif guiObject:IsA("TextBox") then
        self:ApplyTextBoxTheme(guiObject, styleConfig)
    elseif guiObject:IsA("ImageLabel") then
        self:ApplyImageLabelTheme(guiObject, styleConfig)
    elseif guiObject:IsA("ImageButton") then
        self:ApplyImageButtonTheme(guiObject, styleConfig)
    elseif guiObject:IsA("ScrollingFrame") then
        self:ApplyScrollingFrameTheme(guiObject, styleConfig)
    end
    
    -- Apply custom style overrides
    if styleConfig then
        self:ApplyCustomStyle(guiObject, styleConfig)
    end
end

function ThemeManager:ApplyFrameTheme(frame, style)
    style = style or {}
    
    if style.background == "primary" then
        frame.BackgroundColor3 = currentTheme.primary
    elseif style.background == "secondary" then
        frame.BackgroundColor3 = currentTheme.secondary
    elseif style.background == "accent" then
        frame.BackgroundColor3 = currentTheme.accent
    elseif style.background then
        frame.BackgroundColor3 = style.background
    else
        frame.BackgroundColor3 = currentTheme.primary
    end
    
    frame.BorderSizePixel = style.borderSize or 0
    frame.BackgroundTransparency = style.transparency or 0
    
    if style.cornerRadius then
        local corner = frame:FindFirstChild("UICorner") or Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, style.cornerRadius)
        corner.Parent = frame
    end
end

function ThemeManager:ApplyTextLabelTheme(label, style)
    style = style or {}
    
    if style.textColor == "primary" then
        label.TextColor3 = currentTheme.text
    elseif style.textColor == "secondary" then
        label.TextColor3 = currentTheme.textSecondary
    elseif style.textColor == "muted" then
        label.TextColor3 = currentTheme.textMuted
    elseif style.textColor == "accent" then
        label.TextColor3 = currentTheme.accent
    elseif style.textColor then
        label.TextColor3 = style.textColor
    else
        label.TextColor3 = currentTheme.text
    end
    
    if style.background then
        self:ApplyFrameTheme(label, style)
    else
        label.BackgroundTransparency = 1
    end
end

function ThemeManager:ApplyTextButtonTheme(button, style)
    style = style or {}
    
    -- Apply text styling
    self:ApplyTextLabelTheme(button, style)
    
    -- Apply button-specific styling
    if style.buttonStyle == "primary" then
        button.BackgroundColor3 = currentTheme.accent
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif style.buttonStyle == "secondary" then
        button.BackgroundColor3 = currentTheme.secondary
        button.TextColor3 = currentTheme.text
    elseif style.buttonStyle == "danger" then
        button.BackgroundColor3 = currentTheme.error
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        button.BackgroundColor3 = currentTheme.secondary
        button.TextColor3 = currentTheme.text
    end
    
    button.BorderSizePixel = 0
    
    if style.cornerRadius then
        local corner = button:FindFirstChild("UICorner") or Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, style.cornerRadius)
        corner.Parent = button
    end
end

function ThemeManager:ApplyTextBoxTheme(textBox, style)
    style = style or {}
    
    textBox.BackgroundColor3 = currentTheme.secondary
    textBox.TextColor3 = currentTheme.text
    textBox.PlaceholderColor3 = currentTheme.textMuted
    textBox.BorderSizePixel = 1
    textBox.BorderColor3 = currentTheme.accent
    
    if style.cornerRadius then
        local corner = textBox:FindFirstChild("UICorner") or Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, style.cornerRadius)
        corner.Parent = textBox
    end
end

function ThemeManager:ApplyScrollingFrameTheme(scrollFrame, style)
    style = style or {}
    
    scrollFrame.BackgroundColor3 = currentTheme.primary
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarImageColor3 = currentTheme.accent
    scrollFrame.ScrollBarThickness = 8
    
    if style.cornerRadius then
        local corner = scrollFrame:FindFirstChild("UICorner") or Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, style.cornerRadius)
        corner.Parent = scrollFrame
    end
end

function ThemeManager:ApplyCustomStyle(guiObject, style)
    for property, value in pairs(style) do
        if property ~= "background" and property ~= "textColor" and property ~= "buttonStyle" and property ~= "cornerRadius" then
            local success = pcall(function()
                guiObject[property] = value
            end)
            if not success then
                warn("Failed to apply style property: " .. property)
            end
        end
    end
end

-- ============================================================================
-- USER MANAGER MODULE
-- ============================================================================

local UserManager = {}

-- User data storage
local userData = {
    userId = nil,
    username = nil,
    country = nil,
    language = nil,
    theme = nil,
    platform = nil,
    preferences = {
        theme = "dark",
        language = "en",
        notifications = true,
        sounds = true,
        autoTranslate = false,
        showTimestamps = true,
        compactMode = false,
        fontSize = "medium",
        chatHistoryLimit = 1000,
        privateMessageNotifications = true,
        friendRequestNotifications = true,
        blockedUsersList = {},
        favoriteChannels = {},
        customStatus = nil,
        awayMessage = nil,
        timezone = "UTC",
        dateFormat = "MM/DD/YYYY",
        timeFormat = "12h"
    },
    setupComplete = false,
    sessionId = nil,
    status = "online",
    authToken = nil,
    isAuthenticated = false,
    serverUserId = nil,
    serverUsername = nil,
    friends = {},
    pendingFriendRequests = {},
    sentFriendRequests = {},
    chatHistory = {},
    blockedUsers = {}
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
    local adjectives = {
        "Swift", "Brave", "Clever", "Bright", "Quick", "Smart", "Bold", "Cool",
        "Epic", "Fast", "Great", "Happy", "Lucky", "Magic", "Noble", "Power",
        "Royal", "Sharp", "Super", "Ultra", "Wise", "Alpha", "Beta", "Cyber",
        "Dark", "Fire", "Ice", "Light", "Moon", "Star", "Storm", "Thunder"
    }
    
    local nouns = {
        "Gamer", "Player", "User", "Coder", "Hacker", "Ninja", "Warrior", "Hero",
        "Legend", "Master", "Pro", "Elite", "Champion", "Ace", "Boss", "Chief",
        "King", "Queen", "Lord", "Knight", "Wizard", "Mage", "Hunter", "Ranger",
        "Scout", "Pilot", "Captain", "Admiral", "General", "Commander", "Agent"
    }
    
    local adjective = adjectives[math.random(#adjectives)]
    local noun = nouns[math.random(#nouns)]
    local number = math.random(100, 999)
    
    return adjective .. noun .. number
end

-- User Configuration Methods
function UserManager:SetUserCountry(country)
    userData.country = country
    self:SaveUserData()
    print("🌍 User country set to: " .. country)
end

function UserManager:SetUserLanguage(language)
    userData.language = language
    self:SaveUserData()
    print("🗣️ User language set to: " .. language)
end

function UserManager:SetUserTheme(theme)
    userData.theme = theme
    self:SaveUserData()
    print("🎨 User theme set to: " .. theme)
end

function UserManager:SetUserPlatform(platform)
    userData.platform = platform
    self:SaveUserData()
    print("📱 User platform set to: " .. platform)
end

function UserManager:SetUsername(username)
    if Utils:IsValidUsername(username) then
        userData.username = Utils:SanitizeInput(username)
        self:SaveUserData()
        return true
    end
    return false
end

function UserManager:SetUserStatus(status)
    if Config.USER_STATUS[status:upper()] then
        userData.status = status:lower()
        self:SaveUserData()
        return true
    end
    return false
end

function UserManager:CompleteSetup()
    userData.setupComplete = true
    self:SaveUserData()
    print("✅ User setup completed")
end

-- Preference Management
function UserManager:SetPreference(key, value)
    userData.preferences[key] = value
    self:SaveUserData()
end

function UserManager:GetPreference(key, default)
    return userData.preferences[key] or default
end

function UserManager:ResetPreferences()
    userData.preferences = Utils:DeepCopy(Config.DEFAULTS)
    self:SaveUserData()
end

-- Data Persistence
function UserManager:SaveUserData()
    Utils:SaveData("globalchat_userdata", userData)
end

function UserManager:SaveCredentials(username, password, rememberMe)
    if rememberMe then
        -- Create a simple encryption by XORing with a key
        local encryptionKey = "GlobalChat_SecureKey_" .. Utils:GenerateUUID():sub(1, 8)
        local encryptedPassword = ""
        
        -- Simple XOR encryption (not truly secure but better than plaintext)
        for i = 1, #password do
            local char = string.byte(password:sub(i, i))
            local keyChar = string.byte(encryptionKey:sub((i % #encryptionKey) + 1, (i % #encryptionKey) + 1))
            encryptedPassword = encryptedPassword .. string.char(bit32.bxor(char, keyChar))
        end
        
        local credentials = {
            username = username,
            password = encryptedPassword,
            key = encryptionKey,
            timestamp = os.time()
        }
        
        Utils:SaveData("globalchat_credentials", credentials)
        print("✅ Credentials saved for automatic login")
    else
        -- If remember me is disabled, clear any saved credentials
        self:ClearSavedCredentials()
    end
end

function UserManager:ClearSavedCredentials()
    Utils:SaveData("globalchat_credentials", nil)
    print("🔄 Saved credentials cleared")
end

function UserManager:Logout()
    -- Clear authentication data
    userData.authToken = nil
    userData.isAuthenticated = false
    userData.serverUserId = nil
    
    -- Clear saved credentials
    self:ClearSavedCredentials()
    
    -- Disconnect from server
    NetworkManager:Disconnect()
    
    -- Show authentication screen again
    GlobalChat:ShowAuthenticationScreen()
    
    -- Save the updated user data
    self:SaveUserData()
    
    print("👋 User logged out successfully")
    
    -- Disconnect from server
    NetworkManager:DisconnectFromServer()
    
    -- Return to login screen
    GlobalChat:ShowAuthenticationScreen()
end

function UserManager:GetSavedCredentials()
    local credentials = Utils:LoadData("globalchat_credentials", nil)
    
    if credentials and credentials.username and credentials.password and credentials.key then
        -- Decrypt password
        local encryptedPassword = credentials.password
        local encryptionKey = credentials.key
        local decryptedPassword = ""
        
        -- Simple XOR decryption
        for i = 1, #encryptedPassword do
            local char = string.byte(encryptedPassword:sub(i, i))
            local keyChar = string.byte(encryptionKey:sub((i % #encryptionKey) + 1, (i % #encryptionKey) + 1))
            decryptedPassword = decryptedPassword .. string.char(bit32.bxor(char, keyChar))
        end
        
        return {
            username = credentials.username,
            password = decryptedPassword,
            timestamp = credentials.timestamp
        }
    end
    
    return nil
end

function UserManager:LoadUserData()
    local loadedData = Utils:LoadData("globalchat_userdata", {})
    
    -- Merge with current data, preserving session info
    for key, value in pairs(loadedData) do
        if key ~= "sessionId" then
            userData[key] = value
        end
    end
    
    -- Apply defaults for missing preferences
    if not userData.preferences then
        userData.preferences = {}
    end
    
    for key, value in pairs(Config.DEFAULTS) do
        if userData.preferences[key] == nil then
            userData.preferences[key] = value
        end
    end
end

function UserManager:ClearUserData()
    Utils:ClearData("globalchat_userdata")
    userData = {
        userId = Utils:GenerateUUID(),
        username = self:GenerateUsername(),
        country = nil,
        language = nil,
        theme = nil,
        platform = nil,
        preferences = Utils:DeepCopy(Config.DEFAULTS),
        setupComplete = false,
        sessionId = Utils:GenerateUUID(),
        status = "online"
    }
    self:SaveUserData()
end

-- Getters
function UserManager:GetUserConfig()
    return Utils:DeepCopy(userData)
end

-- Authentication Methods
function UserManager:SetAuthToken(token)
    userData.authToken = token
    userData.isAuthenticated = token ~= nil
    self:SaveUserData()
end

function UserManager:GetAuthToken()
    return userData.authToken
end

function UserManager:IsAuthenticated()
    return userData.isAuthenticated and userData.authToken ~= nil
end

function UserManager:SetServerUserData(serverUserId, serverUsername)
    userData.serverUserId = serverUserId
    userData.serverUsername = serverUsername
    self:SaveUserData()
end

function UserManager:ClearAuthData()
    userData.authToken = nil
    userData.isAuthenticated = false
    userData.serverUserId = nil
    userData.serverUsername = nil
    userData.friends = {}
    userData.pendingFriendRequests = {}
    userData.sentFriendRequests = {}
    userData.chatHistory = {}
    userData.blockedUsers = {}
    self:SaveUserData()
end

-- ============================================================================
-- FRIENDS SYSTEM METHODS
-- ============================================================================

function UserManager:SendFriendRequest(username)
    if not self:IsAuthenticated() then
        return false, "Not authenticated"
    end
    
    local success, response = NetworkManager:SendFriendRequest(username)
    if success then
        -- Add to sent requests locally
        table.insert(userData.sentFriendRequests, {
            username = username,
            timestamp = os.time()
        })
        self:SaveUserData()
    end
    
    return success, response
end

function UserManager:AcceptFriendRequest(friendId)
    if not self:IsAuthenticated() then
        return false, "Not authenticated"
    end
    
    local success, response = NetworkManager:AcceptFriendRequest(friendId)
    if success then
        -- Remove from pending requests and add to friends
        for i, request in ipairs(userData.pendingFriendRequests) do
            if request.id == friendId then
                table.remove(userData.pendingFriendRequests, i)
                table.insert(userData.friends, {
                    id = friendId,
                    username = request.username,
                    status = "online",
                    acceptedAt = os.time()
                })
                break
            end
        end
        self:SaveUserData()
    end
    
    return success, response
end

function UserManager:DeclineFriendRequest(friendId)
    if not self:IsAuthenticated() then
        return false, "Not authenticated"
    end
    
    local success, response = NetworkManager:DeclineFriendRequest(friendId)
    if success then
        -- Remove from pending requests
        for i, request in ipairs(userData.pendingFriendRequests) do
            if request.id == friendId then
                table.remove(userData.pendingFriendRequests, i)
                break
            end
        end
        self:SaveUserData()
    end
    
    return success, response
end

function UserManager:RemoveFriend(friendId)
    if not self:IsAuthenticated() then
        return false, "Not authenticated"
    end
    
    local success, response = NetworkManager:RemoveFriend(friendId)
    if success then
        -- Remove from friends list
        for i, friend in ipairs(userData.friends) do
            if friend.id == friendId then
                table.remove(userData.friends, i)
                break
            end
        end
        self:SaveUserData()
    end
    
    return success, response
end

function UserManager:GetFriends()
    return userData.friends or {}
end

function UserManager:GetPendingFriendRequests()
    return userData.pendingFriendRequests or {}
end

function UserManager:GetSentFriendRequests()
    return userData.sentFriendRequests or {}
end

function UserManager:UpdateFriendsData(friendsData)
    userData.friends = friendsData.friends or {}
    userData.pendingFriendRequests = friendsData.pendingRequests or {}
    userData.sentFriendRequests = friendsData.sentRequests or {}
    self:SaveUserData()
end

-- ============================================================================
-- PREFERENCES METHODS
-- ============================================================================

function UserManager:SavePreferences(preferences)
    if not self:IsAuthenticated() then
        -- Save locally only
        for key, value in pairs(preferences) do
            userData.preferences[key] = value
        end
        self:SaveUserData()
        return true, "Preferences saved locally"
    end
    
    -- Save to server
    local success, response = NetworkManager:SaveUserPreferences(preferences)
    if success then
        -- Update local preferences
        for key, value in pairs(preferences) do
            userData.preferences[key] = value
        end
        self:SaveUserData()
    end
    
    return success, response
end

function UserManager:GetPreferences()
    return userData.preferences or {}
end

function UserManager:UpdatePreferencesFromServer(serverPreferences)
    userData.preferences = serverPreferences
    self:SaveUserData()
end

-- ============================================================================
-- CHAT HISTORY METHODS
-- ============================================================================

function UserManager:SaveChatMessage(channelId, messageData)
    if not userData.chatHistory[channelId] then
        userData.chatHistory[channelId] = {}
    end
    
    table.insert(userData.chatHistory[channelId], messageData)
    
    -- Limit chat history size
    local limit = userData.preferences.chatHistoryLimit or 1000
    if #userData.chatHistory[channelId] > limit then
        table.remove(userData.chatHistory[channelId], 1)
    end
    
    self:SaveUserData()
    
    -- Save to server if authenticated
    if self:IsAuthenticated() then
        NetworkManager:SaveChatHistory(channelId, messageData)
    end
end

function UserManager:GetChatHistory(channelId)
    return userData.chatHistory[channelId] or {}
end

function UserManager:ClearChatHistory(channelId)
    userData.chatHistory[channelId] = {}
    self:SaveUserData()
    
    -- Clear on server if authenticated
    if self:IsAuthenticated() then
        NetworkManager:ClearChatHistory(channelId)
    end
end

function UserManager:UpdateChatHistoryFromServer(channelId, serverHistory)
    userData.chatHistory[channelId] = serverHistory
    self:SaveUserData()
end

-- ============================================================================
-- BLOCKED USERS METHODS
-- ============================================================================

function UserManager:BlockUser(username)
    if not table.find(userData.blockedUsers, username) then
        table.insert(userData.blockedUsers, username)
        self:SaveUserData()
    end
    
    -- Block on server if authenticated
    if self:IsAuthenticated() then
        NetworkManager:BlockUser(username)
    end
end

function UserManager:UnblockUser(username)
    for i, blockedUser in ipairs(userData.blockedUsers) do
        if blockedUser == username then
            table.remove(userData.blockedUsers, i)
            self:SaveUserData()
            break
        end
    end
    
    -- Unblock on server if authenticated
    if self:IsAuthenticated() then
        NetworkManager:UnblockUser(username)
    end
end

function UserManager:IsUserBlocked(username)
    return table.find(userData.blockedUsers, username) ~= nil
end

function UserManager:GetBlockedUsers()
    return userData.blockedUsers or {}
end

function UserManager:LoginSuccess(authData)
    userData.authToken = authData.token
    userData.isAuthenticated = true
    userData.serverUserId = authData.user.id
    userData.serverUsername = authData.user.username
    
    -- Update local username if different
    if authData.user.username ~= userData.username then
        userData.username = authData.user.username
    end
    
    self:SaveUserData()
    print("✅ User authenticated successfully: " .. userData.serverUsername)
    
    -- Load all user data from server
    self:LoadServerData()
end

function UserManager:LoadServerData()
    if not self:IsAuthenticated() then
        return
    end
    
    print("📥 Loading user data from server...")
    
    -- Load user profile (includes friends, preferences, etc.)
    local success, profileData = NetworkManager:GetUserProfile()
    if success and profileData.success then
        local profile = profileData.profile
        
        -- Update preferences
        if profile.preferences then
            self:UpdatePreferencesFromServer(profile.preferences)
            print("✅ Preferences loaded from server")
        end
        
        -- Update friends data
        if profile.friends or profile.pendingFriendRequests then
            self:UpdateFriendsData({
                friends = profile.friends or {},
                pendingRequests = profile.pendingFriendRequests or {},
                sentRequests = {} -- Will be loaded separately if needed
            })
            print("✅ Friends data loaded from server")
        end
        
        print("✅ All user data synchronized with server")
    else
        print("⚠️ Failed to load user data from server")
    end
end

function UserManager:GetUserId()
    return userData.userId
end

function UserManager:GetUsername()
    return userData.username
end

function UserManager:GetUserCountry()
    return userData.country
end

function UserManager:GetUserLanguage()
    return userData.language
end

function UserManager:GetUserTheme()
    return userData.theme
end

function UserManager:GetUserPlatform()
    return userData.platform
end

function UserManager:GetUserStatus()
    return userData.status
end

function UserManager:GetSessionId()
    return userData.sessionId
end

function UserManager:IsSetupComplete()
    return userData.setupComplete
end

-- User Profile Methods
function UserManager:GetUserProfile()
    return {
        userId = userData.userId,
        username = userData.username,
        country = userData.country,
        language = userData.language,
        status = userData.status,
        platform = userData.platform,
        joinedAt = userData.joinedAt or os.time()
    }
end

function UserManager:UpdateProfile(profileData)
    local updated = false
    
    if profileData.username and profileData.username ~= userData.username then
        if self:SetUsername(profileData.username) then
            updated = true
        end
    end
    
    if profileData.status and profileData.status ~= userData.status then
        if self:SetUserStatus(profileData.status) then
            updated = true
        end
    end
    
    return updated
end

-- Statistics Methods
function UserManager:GetUserStats()
    return {
        messagesSent = self:GetPreference("messagesSent", 0),
        timeSpent = self:GetPreference("timeSpent", 0),
        favoriteChannels = self:GetPreference("favoriteChannels", {}),
        blockedUsers = self:GetPreference("blockedUsers", {}),
        friendsList = self:GetPreference("friendsList", {})
    }
end

function UserManager:IncrementMessageCount()
    local count = self:GetPreference("messagesSent", 0)
    self:SetPreference("messagesSent", count + 1)
end

function UserManager:AddTimeSpent(seconds)
    local time = self:GetPreference("timeSpent", 0)
    self:SetPreference("timeSpent", time + seconds)
end

-- Social Features
function UserManager:AddFriend(userId, username)
    local friends = self:GetPreference("friendsList", {})
    friends[userId] = {
        username = username,
        addedAt = os.time()
    }
    self:SetPreference("friendsList", friends)
end

function UserManager:RemoveFriend(userId)
    local friends = self:GetPreference("friendsList", {})
    friends[userId] = nil
    self:SetPreference("friendsList", friends)
end

function UserManager:IsFriend(userId)
    local friends = self:GetPreference("friendsList", {})
    return friends[userId] ~= nil
end

function UserManager:BlockUser(userId, username)
    local blocked = self:GetPreference("blockedUsers", {})
    blocked[userId] = {
        username = username,
        blockedAt = os.time()
    }
    self:SetPreference("blockedUsers", blocked)
end

function UserManager:UnblockUser(userId)
    local blocked = self:GetPreference("blockedUsers", {})
    blocked[userId] = nil
    self:SetPreference("blockedUsers", blocked)
end

function UserManager:IsBlocked(userId)
    local blocked = self:GetPreference("blockedUsers", {})
    return blocked[userId] ~= nil
end

-- Channel Preferences
function UserManager:AddFavoriteChannel(channelId, channelName)
    local favorites = self:GetPreference("favoriteChannels", {})
    favorites[channelId] = {
        name = channelName,
        addedAt = os.time()
    }
    self:SetPreference("favoriteChannels", favorites)
end

function UserManager:RemoveFavoriteChannel(channelId)
    local favorites = self:GetPreference("favoriteChannels", {})
    favorites[channelId] = nil
    self:SetPreference("favoriteChannels", favorites)
end

function UserManager:IsFavoriteChannel(channelId)
    local favorites = self:GetPreference("favoriteChannels", {})
    return favorites[channelId] ~= nil
end

function UserManager:Cleanup()
    self:SaveUserData()
    print("👤 User Manager cleaned up")
end

-- ============================================================================
-- CHAT MANAGER MODULE
-- ============================================================================

local ChatManager = {}

-- Chat state
local chatState = {
    currentChannel = nil,
    messages = {},
    threads = {},
    privateMessages = {},
    users = {},
    isConnected = false,
    userConfig = nil
}

-- Event system
local eventEmitter = nil

function ChatManager:Initialize(userConfig)
    print("💬 Chat Manager initialized")
    
    chatState.userConfig = userConfig
    eventEmitter = Utils.EventEmitter.new()
    
    -- Initialize message storage
    self:LoadChatHistory()
    
    -- Set up event handlers
    self:SetupEventHandlers()
end

function ChatManager:SetupEventHandlers()
    -- Handle incoming messages from network
    eventEmitter:On("message_received", function(messageData)
        self:HandleIncomingMessage(messageData)
    end)
    
    -- Handle user join/leave events
    eventEmitter:On("user_joined", function(userData)
        self:HandleUserJoined(userData)
    end)
    
    eventEmitter:On("user_left", function(userData)
        self:HandleUserLeft(userData)
    end)
    
    -- Handle connection status changes
    eventEmitter:On("connection_changed", function(isConnected)
        chatState.isConnected = isConnected
        self:UpdateConnectionStatus(isConnected)
    end)
end

-- Send message
function ChatManager:SendMessage(content, messageType, replyTo, threadId)
    if not chatState.isConnected then
        return false, "Not connected to server"
    end
    
    if not content or Utils:Trim(content) == "" then
        return false, "Message cannot be empty"
    end
    
    if #content > Config.UI.MESSAGE_MAX_LENGTH then
        return false, "Message too long"
    end
    
    messageType = messageType or Config.MESSAGE_TYPES.NORMAL
    
    -- Create message object
    local message = {
        id = Utils:GenerateUUID(),
        content = Utils:SanitizeInput(content),
        userId = chatState.userConfig.userId,
        username = chatState.userConfig.username,
        timestamp = os.time(),
        type = messageType,
        replyTo = replyTo,
        threadId = threadId,
        edited = false,
        editedAt = nil,
        reactions = {},
        attachments = {}
    }
    
    -- Add to local messages immediately (optimistic update)
    self:AddMessage(message)
    
    -- Send to server
    eventEmitter:Emit("send_message", message)
    
    return true, message.id
end

-- Send private message
function ChatManager:SendPrivateMessage(targetUserId, content)
    if not chatState.isConnected then
        return false, "Not connected to server"
    end
    
    if not content or Utils:Trim(content) == "" then
        return false, "Message cannot be empty"
    end
    
    -- Create private message
    local message = {
        id = Utils:GenerateUUID(),
        content = Utils:SanitizeInput(content),
        fromUserId = chatState.userConfig.userId,
        fromUsername = chatState.userConfig.username,
        toUserId = targetUserId,
        timestamp = os.time(),
        type = Config.MESSAGE_TYPES.PRIVATE,
        read = false
    }
    
    -- Add to local private messages
    if not chatState.privateMessages[targetUserId] then
        chatState.privateMessages[targetUserId] = {}
    end
    table.insert(chatState.privateMessages[targetUserId], message)
    
    -- Send to server
    eventEmitter:Emit("send_private_message", message)
    
    return true, message.id
end

-- Reply to message
function ChatManager:ReplyToMessage(originalMessageId, content)
    local originalMessage = self:GetMessageById(originalMessageId)
    if not originalMessage then
        return false, "Original message not found"
    end
    
    return self:SendMessage(content, Config.MESSAGE_TYPES.REPLY, originalMessageId)
end

-- Create thread from message
function ChatManager:CreateThread(originalMessageId, content)
    local originalMessage = self:GetMessageById(originalMessageId)
    if not originalMessage then
        return false, "Original message not found"
    end
    
    local threadId = Utils:GenerateUUID()
    
    -- Create thread object
    local thread = {
        id = threadId,
        originalMessageId = originalMessageId,
        createdBy = chatState.userConfig.userId,
        createdAt = os.time(),
        title = self:GenerateThreadTitle(originalMessage.content),
        messages = {},
        participants = {[chatState.userConfig.userId] = true}
    }
    
    chatState.threads[threadId] = thread
    
    -- Send initial message to thread
    return self:SendMessage(content, Config.MESSAGE_TYPES.THREAD, originalMessageId, threadId)
end

-- Edit message
function ChatManager:EditMessage(messageId, newContent)
    local message = self:GetMessageById(messageId)
    if not message then
        return false, "Message not found"
    end
    
    if message.userId ~= chatState.userConfig.userId then
        return false, "Can only edit your own messages"
    end
    
    if not newContent or Utils:Trim(newContent) == "" then
        return false, "Message cannot be empty"
    end
    
    -- Update message
    message.content = Utils:SanitizeInput(newContent)
    message.edited = true
    message.editedAt = os.time()
    
    -- Send edit to server
    eventEmitter:Emit("edit_message", {
        messageId = messageId,
        newContent = message.content,
        editedAt = message.editedAt
    })
    
    -- Update UI
    eventEmitter:Emit("message_updated", message)
    
    return true
end

-- Delete message
function ChatManager:DeleteMessage(messageId)
    local message = self:GetMessageById(messageId)
    if not message then
        return false, "Message not found"
    end
    
    if message.userId ~= chatState.userConfig.userId then
        return false, "Can only delete your own messages"
    end
    
    -- Remove from local storage
    self:RemoveMessage(messageId)
    
    -- Send delete to server
    eventEmitter:Emit("delete_message", messageId)
    
    -- Update UI
    eventEmitter:Emit("message_deleted", messageId)
    
    return true
end

-- Add reaction to message
function ChatManager:AddReaction(messageId, emoji)
    local message = self:GetMessageById(messageId)
    if not message then
        return false, "Message not found"
    end
    
    local userId = chatState.userConfig.userId
    
    -- Initialize reactions if not exists
    if not message.reactions[emoji] then
        message.reactions[emoji] = {}
    end
    
    -- Toggle reaction
    if message.reactions[emoji][userId] then
        message.reactions[emoji][userId] = nil
        -- Remove emoji key if no reactions left
        if next(message.reactions[emoji]) == nil then
            message.reactions[emoji] = nil
        end
    else
        message.reactions[emoji][userId] = {
            userId = userId,
            username = chatState.userConfig.username,
            timestamp = os.time()
        }
    end
    
    -- Send to server
    eventEmitter:Emit("toggle_reaction", {
        messageId = messageId,
        emoji = emoji,
        userId = userId
    })
    
    -- Update UI
    eventEmitter:Emit("message_updated", message)
    
    return true
end

-- Handle incoming message
function ChatManager:HandleIncomingMessage(messageData)
    -- Validate message
    if not self:ValidateMessage(messageData) then
        return
    end
    
    -- Add to appropriate storage
    if messageData.type == Config.MESSAGE_TYPES.PRIVATE then
        self:HandlePrivateMessage(messageData)
    elseif messageData.threadId then
        self:HandleThreadMessage(messageData)
    else
        self:AddMessage(messageData)
    end
    
    -- Trigger notifications
    self:TriggerNotifications(messageData)
    
    -- Update UI
    eventEmitter:Emit("new_message", messageData)
end

-- Handle private message
function ChatManager:HandlePrivateMessage(messageData)
    local otherUserId = messageData.fromUserId == chatState.userConfig.userId 
        and messageData.toUserId or messageData.fromUserId
    
    if not chatState.privateMessages[otherUserId] then
        chatState.privateMessages[otherUserId] = {}
    end
    
    table.insert(chatState.privateMessages[otherUserId], messageData)
    
    -- Save to storage
    self:SavePrivateMessages()
end

-- Handle thread message
function ChatManager:HandleThreadMessage(messageData)
    local thread = chatState.threads[messageData.threadId]
    if not thread then
        -- Create thread if it doesn't exist
        thread = {
            id = messageData.threadId,
            originalMessageId = messageData.replyTo,
            createdBy = messageData.userId,
            createdAt = messageData.timestamp,
            title = "Thread",
            messages = {},
            participants = {}
        }
        chatState.threads[messageData.threadId] = thread
    end
    
    -- Add message to thread
    table.insert(thread.messages, messageData)
    
    -- Add participant
    thread.participants[messageData.userId] = true
    
    -- Save threads
    self:SaveThreads()
end

-- Handle user joined
function ChatManager:HandleUserJoined(userData)
    chatState.users[userData.userId] = userData
    
    -- Create system message
    local systemMessage = {
        id = Utils:GenerateUUID(),
        content = userData.username .. " joined the chat",
        userId = "system",
        username = "System",
        timestamp = os.time(),
        type = Config.MESSAGE_TYPES.JOIN
    }
    
    self:AddMessage(systemMessage)
    eventEmitter:Emit("user_joined_chat", userData)
end

-- Handle user left
function ChatManager:HandleUserLeft(userData)
    -- Create system message
    local systemMessage = {
        id = Utils:GenerateUUID(),
        content = userData.username .. " left the chat",
        userId = "system",
        username = "System",
        timestamp = os.time(),
        type = Config.MESSAGE_TYPES.LEAVE
    }
    
    self:AddMessage(systemMessage)
    
    -- Remove from users list
    chatState.users[userData.userId] = nil
    
    eventEmitter:Emit("user_left_chat", userData)
end

-- Add message to storage
function ChatManager:AddMessage(message)
    table.insert(chatState.messages, message)
    
    -- Maintain message limit
    if #chatState.messages > Config.UI.MAX_CHAT_HISTORY then
        table.remove(chatState.messages, 1)
    end
    
    -- Save to storage
    self:SaveChatHistory()
    
    -- Save to server via UserManager
    local channelId = chatState.currentChannel or "general"
    UserManager:SaveChatMessage(channelId, message)
end

-- Remove message from storage
function ChatManager:RemoveMessage(messageId)
    for i, message in ipairs(chatState.messages) do
        if message.id == messageId then
            table.remove(chatState.messages, i)
            break
        end
    end
    
    self:SaveChatHistory()
end

-- Get message by ID
function ChatManager:GetMessageById(messageId)
    for _, message in ipairs(chatState.messages) do
        if message.id == messageId then
            return message
        end
    end
    return nil
end

-- Get messages
function ChatManager:GetMessages(limit, offset)
    limit = limit or 50
    offset = offset or 0
    
    local totalMessages = #chatState.messages
    local startIndex = math.max(1, totalMessages - offset - limit + 1)
    local endIndex = totalMessages - offset
    
    local messages = {}
    for i = startIndex, endIndex do
        if chatState.messages[i] then
            table.insert(messages, chatState.messages[i])
        end
    end
    
    return messages
end

-- Get private messages with user
function ChatManager:GetPrivateMessages(userId)
    return chatState.privateMessages[userId] or {}
end

-- Get thread messages
function ChatManager:GetThreadMessages(threadId)
    local thread = chatState.threads[threadId]
    return thread and thread.messages or {}
end

-- Get thread info
function ChatManager:GetThread(threadId)
    return chatState.threads[threadId]
end

-- Get all threads
function ChatManager:GetThreads()
    local threads = {}
    for _, thread in pairs(chatState.threads) do
        table.insert(threads, thread)
    end
    
    -- Sort by creation time
    table.sort(threads, function(a, b)
        return a.createdAt > b.createdAt
    end)
    
    return threads
end

-- Get online users
function ChatManager:GetOnlineUsers()
    local users = {}
    for _, user in pairs(chatState.users) do
        table.insert(users, user)
    end
    
    -- Sort by username
    table.sort(users, function(a, b)
        return a.username:lower() < b.username:lower()
    end)
    
    return users
end

-- Search messages
function ChatManager:SearchMessages(query, options)
    options = options or {}
    query = query:lower()
    
    local results = {}
    local searchIn = options.searchIn or "all" -- "all", "current", "private", "threads"
    
    local function searchInMessages(messages)
        for _, message in ipairs(messages) do
            if message.content:lower():find(query, 1, true) or 
               message.username:lower():find(query, 1, true) then
                table.insert(results, message)
            end
        end
    end
    
    if searchIn == "all" or searchIn == "current" then
        searchInMessages(chatState.messages)
    end
    
    if searchIn == "all" or searchIn == "private" then
        for _, messages in pairs(chatState.privateMessages) do
            searchInMessages(messages)
        end
    end
    
    if searchIn == "all" or searchIn == "threads" then
        for _, thread in pairs(chatState.threads) do
            searchInMessages(thread.messages)
        end
    end
    
    -- Sort by timestamp (newest first)
    table.sort(results, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Limit results
    local limit = options.limit or 50
    if #results > limit then
        local limitedResults = {}
        for i = 1, limit do
            table.insert(limitedResults, results[i])
        end
        results = limitedResults
    end
    
    return results
end

-- Validate message
function ChatManager:ValidateMessage(messageData)
    if not messageData.id or not messageData.content or not messageData.userId then
        return false
    end
    
    if not messageData.timestamp or not messageData.username then
        return false
    end
    
    return true
end

-- Generate thread title
function ChatManager:GenerateThreadTitle(originalContent)
    local title = originalContent:sub(1, 30)
    if #originalContent > 30 then
        title = title .. "..."
    end
    return title
end

-- Trigger notifications
function ChatManager:TriggerNotifications(messageData)
    -- Don't notify for own messages
    if messageData.userId == chatState.userConfig.userId then
        return
    end
    
    local currentUserId = chatState.userConfig.userId
    local currentUsername = chatState.userConfig.username
    
    -- Check for mentions
    if messageData.content:find("@" .. currentUsername, 1, true) or 
       messageData.content:find("@everyone", 1, true) then
        eventEmitter:Emit("mention_notification", messageData, "mention")
    end
    
    -- Check for replies
    if messageData.type == Config.MESSAGE_TYPES.REPLY then
        local originalMessage = self:GetMessageById(messageData.replyTo)
        if originalMessage and originalMessage.userId == currentUserId then
            eventEmitter:Emit("reply_notification", messageData, originalMessage)
        end
    end
    
    -- Check for private messages
    if messageData.type == Config.MESSAGE_TYPES.PRIVATE and 
       messageData.toUserId == currentUserId then
        eventEmitter:Emit("private_message_notification", messageData)
    end
    
    -- General message notification
    eventEmitter:Emit("message_notification", messageData)
end

-- Update connection status
function ChatManager:UpdateConnectionStatus(isConnected)
    eventEmitter:Emit("connection_status_changed", isConnected)
    
    if isConnected then
        print("💬 Connected to chat server")
    else
        print("💬 Disconnected from chat server")
    end
end

-- Get chat statistics
function ChatManager:GetChatStatistics()
    local stats = {
        totalMessages = #chatState.messages,
        privateConversations = 0,
        activeThreads = 0,
        onlineUsers = 0,
        myMessages = 0
    }
    
    -- Count private conversations
    for _ in pairs(chatState.privateMessages) do
        stats.privateConversations = stats.privateConversations + 1
    end
    
    -- Count active threads
    for _ in pairs(chatState.threads) do
        stats.activeThreads = stats.activeThreads + 1
    end
    
    -- Count online users
    for _ in pairs(chatState.users) do
        stats.onlineUsers = stats.onlineUsers + 1
    end
    
    -- Count my messages
    for _, message in ipairs(chatState.messages) do
        if message.userId == chatState.userConfig.userId then
            stats.myMessages = stats.myMessages + 1
        end
    end
    
    return stats
end

-- Export chat data
function ChatManager:ExportChatData()
    return {
        messages = chatState.messages,
        privateMessages = chatState.privateMessages,
        threads = chatState.threads,
        exportTime = os.time(),
        userConfig = chatState.userConfig
    }
end

-- Clear chat history
function ChatManager:ClearChatHistory()
    chatState.messages = {}
    self:SaveChatHistory()
    eventEmitter:Emit("chat_cleared")
end

-- Save chat history
function ChatManager:SaveChatHistory()
    Utils:SaveData("chat_messages", chatState.messages)
end

-- Load chat history
function ChatManager:LoadChatHistory()
    chatState.messages = Utils:LoadData("chat_messages", {})
end

-- Save private messages
function ChatManager:SavePrivateMessages()
    Utils:SaveData("private_messages", chatState.privateMessages)
end

-- Load private messages
function ChatManager:LoadPrivateMessages()
    chatState.privateMessages = Utils:LoadData("private_messages", {})
end

-- Save threads
function ChatManager:SaveThreads()
    Utils:SaveData("chat_threads", chatState.threads)
end

-- Load threads
function ChatManager:LoadThreads()
    chatState.threads = Utils:LoadData("chat_threads", {})
end

-- Event system methods
function ChatManager:On(event, callback)
    eventEmitter:On(event, callback)
end

function ChatManager:Off(event, callback)
    eventEmitter:Off(event, callback)
end

function ChatManager:Emit(event, ...)
    eventEmitter:Emit(event, ...)
end

-- Get current state
function ChatManager:GetState()
    return {
        isConnected = chatState.isConnected,
        messageCount = #chatState.messages,
        userCount = Utils:TableLength(chatState.users),
        threadCount = Utils:TableLength(chatState.threads),
        privateConversations = Utils:TableLength(chatState.privateMessages)
    }
end

function ChatManager:Cleanup()
    -- Save all data
    self:SaveChatHistory()
    self:SavePrivateMessages()
    self:SaveThreads()
    
    -- Clear state
    chatState = {
        currentChannel = nil,
        messages = {},
        threads = {},
        privateMessages = {},
        users = {},
        isConnected = false,
        userConfig = nil
    }
    
    print("💬 Chat Manager cleaned up")
end

-- ============================================================================
-- NOTIFICATION MANAGER MODULE
-- ============================================================================

local NotificationManager = {}

-- Notification queue and settings
local notificationQueue = {}
local notificationSettings = {
    enabled = true,
    sounds = true,
    showPreviews = true,
    mentions = true,
    privateMessages = true,
    replies = true,
    systemMessages = false
}

-- Settings menu
local function createSettingsMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatSettings"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main container with blur effect
    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "BlurBackground"
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 0.5
    blurFrame.BorderSizePixel = 0
    blurFrame.Parent = screenGui
    
    -- Settings panel
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsPanel"
    settingsFrame.Size = UDim2.new(0, 400, 0, 500)
    settingsFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    settingsFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = settingsFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Settings"
    titleLabel.TextColor3 = ThemeManager:GetCurrentTheme().textPrimary
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = settingsFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = ThemeManager:GetCurrentTheme().textPrimary
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = settingsFrame
    
    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -40, 1, -70)
    contentFrame.Position = UDim2.new(0, 20, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    contentFrame.Parent = settingsFrame
    
    -- Account section
    local accountLabel = Instance.new("TextLabel")
    accountLabel.Name = "AccountLabel"
    accountLabel.Size = UDim2.new(1, 0, 0, 30)
    accountLabel.Position = UDim2.new(0, 0, 0, 0)
    accountLabel.BackgroundTransparency = 1
    accountLabel.Text = "Account"
    accountLabel.TextColor3 = ThemeManager:GetCurrentTheme().accent
    accountLabel.TextSize = 18
    accountLabel.Font = Enum.Font.GothamBold
    accountLabel.TextXAlignment = Enum.TextXAlignment.Left
    accountLabel.Parent = contentFrame
    
    -- Username display
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(1, 0, 0, 25)
    usernameLabel.Position = UDim2.new(0, 0, 0, 40)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "Username: " .. (userData.username or "Guest")
    usernameLabel.TextColor3 = ThemeManager:GetCurrentTheme().textPrimary
    usernameLabel.TextSize = 16
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = contentFrame
    
    -- Logout button
    local logoutButton = Instance.new("TextButton")
    logoutButton.Name = "LogoutButton"
    logoutButton.Size = UDim2.new(1, 0, 0, 40)
    logoutButton.Position = UDim2.new(0, 0, 0, 80)
    logoutButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    logoutButton.BorderSizePixel = 0
    logoutButton.Text = "Logout"
    logoutButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoutButton.TextSize = 16
    logoutButton.Font = Enum.Font.GothamBold
    logoutButton.Parent = contentFrame
    
    local logoutCorner = Instance.new("UICorner")
    logoutCorner.CornerRadius = UDim.new(0, 8)
    logoutCorner.Parent = logoutButton
    
    -- Notification settings section
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Name = "NotificationLabel"
    notifLabel.Size = UDim2.new(1, 0, 0, 30)
    notifLabel.Position = UDim2.new(0, 0, 0, 150)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "Notifications"
    notifLabel.TextColor3 = ThemeManager:GetCurrentTheme().accent
    notifLabel.TextSize = 18
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = contentFrame
    
    -- Event connections
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    logoutButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        UserManager:Logout()
    end)
    
    return screenGui
end

-- Function to show settings menu
function showSettingsMenu()
    createSettingsMenu()
end

-- Sound IDs for different notification types
local SOUND_IDS = {
    message = "rbxassetid://131961136",
    mention = "rbxassetid://131961136",
    private_message = "rbxassetid://131961136",
    reply = "rbxassetid://131961136",
    join = "rbxassetid://131961136",
    leave = "rbxassetid://131961136",
    error = "rbxassetid://131961136"
}

function NotificationManager:Initialize()
    print("🔔 Notification Manager initialized")
    
    -- Load user notification preferences
    self:LoadNotificationSettings()
    
    -- Set up notification permission
    self:RequestNotificationPermission()
end

function NotificationManager:RequestNotificationPermission()
    local success, result = pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "Global Chat notifications enabled!";
            Color = Color3.fromRGB(0, 255, 0);
            Font = Enum.Font.GothamBold;
            FontSize = Enum.FontSize.Size18;
        })
    end)
    
    if not success then
        warn("Failed to request notification permission: " .. tostring(result))
    end
end

function NotificationManager:ShowMessageNotification(messageData)
    if not self:ShouldShowNotification("message", messageData) then
        return
    end
    
    local title = "New Message"
    local text = messageData.username .. ": " .. self:TruncateText(messageData.content, 50)
    
    self:QueueNotification({
        type = "message",
        title = title,
        text = text,
        data = messageData,
        sound = SOUND_IDS.message
    })
end

function NotificationManager:ShowMentionNotification(messageData, mentionType)
    if not self:ShouldShowNotification("mentions", messageData) then
        return
    end
    
    local title = mentionType == "everyone" and "Everyone Mentioned" or "You were mentioned"
    local text = messageData.username .. " mentioned you: " .. self:TruncateText(messageData.content, 40)
    
    self:QueueNotification({
        type = "mention",
        title = title,
        text = text,
        data = messageData,
        sound = SOUND_IDS.mention,
        priority = "high"
    })
end

function NotificationManager:ShowPrivateMessageNotification(messageData)
    if not self:ShouldShowNotification("privateMessages", messageData) then
        return
    end
    
    local title = "Private Message"
    local text = messageData.username .. ": " .. self:TruncateText(messageData.content, 50)
    
    self:QueueNotification({
        type = "private_message",
        title = title,
        text = text,
        data = messageData,
        sound = SOUND_IDS.private_message,
        priority = "high"
    })
end

function NotificationManager:ShowReplyNotification(messageData, originalMessage)
    if not self:ShouldShowNotification("replies", messageData) then
        return
    end
    
    local title = "Reply to your message"
    local text = messageData.username .. " replied: " .. self:TruncateText(messageData.content, 40)
    
    self:QueueNotification({
        type = "reply",
        title = title,
        text = text,
        data = messageData,
        originalMessage = originalMessage,
        sound = SOUND_IDS.reply,
        priority = "high"
    })
end

function NotificationManager:ShowSystemNotification(messageData)
    if not self:ShouldShowNotification("systemMessages", messageData) then
        return
    end
    
    local title = "System Message"
    local text = messageData.content
    
    self:QueueNotification({
        type = "system",
        title = title,
        text = text,
        data = messageData,
        sound = SOUND_IDS.message
    })
end

function NotificationManager:QueueNotification(notification)
    table.insert(notificationQueue, notification)
    self:ProcessNotificationQueue()
end

function NotificationManager:ProcessNotificationQueue()
    if #notificationQueue == 0 then
        return
    end
    
    local notification = table.remove(notificationQueue, 1)
    self:DisplayNotification(notification)
    
    -- Process next notification after delay
    if #notificationQueue > 0 then
        spawn(function()
            wait(0.5)
            self:ProcessNotificationQueue()
        end)
    end
end

function NotificationManager:DisplayNotification(notification)
    -- Display Roblox notification
    local success, result = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = notification.title;
            Text = notification.text;
            Duration = Config.UI.NOTIFICATION_DURATION;
            Button1 = "View";
            Button2 = "Dismiss";
        })
    end)
    
    if not success then
        warn("Failed to display notification: " .. tostring(result))
    end
    
    -- Play sound if enabled
    if notificationSettings.sounds and notification.sound then
        self:PlayNotificationSound(notification.sound)
    end
    
    print("🔔 Notification: " .. notification.title .. " - " .. notification.text)
end

function NotificationManager:PlayNotificationSound(soundId)
    local success, result = pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound.Parent = SoundService
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
    
    if not success then
        warn("Failed to play notification sound: " .. tostring(result))
    end
end

function NotificationManager:ShouldShowNotification(type, messageData)
    if not notificationSettings.enabled then
        return false
    end
    
    if not notificationSettings[type] then
        return false
    end
    
    -- Don't show notifications for own messages
    if messageData and messageData.userId == UserManager:GetUserId() then
        return false
    end
    
    return true
end

function NotificationManager:TruncateText(text, maxLength)
    if #text <= maxLength then
        return text
    end
    
    return text:sub(1, maxLength - 3) .. "..."
end

function NotificationManager:UpdateSettings(settings)
    for key, value in pairs(settings) do
        if notificationSettings[key] ~= nil then
            notificationSettings[key] = value
        end
    end
    
    self:SaveNotificationSettings()
end

function NotificationManager:GetSettings()
    return Utils:DeepCopy(notificationSettings)
end

function NotificationManager:SaveNotificationSettings()
    Utils:SaveData("notification_settings", notificationSettings)
end

function NotificationManager:LoadNotificationSettings()
    local loadedSettings = Utils:LoadData("notification_settings", {})
    
    for key, value in pairs(loadedSettings) do
        if notificationSettings[key] ~= nil then
            notificationSettings[key] = value
        end
    end
end

function NotificationManager:Cleanup()
    notificationQueue = {}
    print("🔔 Notification Manager cleaned up")
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
            window_start = now,
            burst_count = 0,
            burst_start = now
        }
    end
    
    local userLimit = userLimits[userId][actionType]
    local config = self:GetActionConfig(actionType)
    
    -- Check burst limit
    if now - userLimit.burst_start > config.burst_window then
        userLimit.burst_count = 0
        userLimit.burst_start = now
    end
    
    if userLimit.burst_count >= config.burst_limit then
        return false, "Burst limit exceeded", config.burst_window - (now - userLimit.burst_start)
    end
    
    -- Check rate limit
    if now - userLimit.window_start > 60 then -- 1 minute window
        userLimit.count = 0
        userLimit.window_start = now
    end
    
    if userLimit.count >= config.rate_limit then
        -- Apply timeout
        self:ApplyTimeout(userId, config.timeout_duration)
        return false, "Rate limit exceeded - timeout applied", config.timeout_duration
    end
    
    return true
end

function RateLimiter:RecordAction(userId, actionType)
    actionType = actionType or "message"
    local now = os.time()
    
    -- Initialize if not exists
    if not userLimits[userId] then
        userLimits[userId] = {}
    end
    
    if not userLimits[userId][actionType] then
        userLimits[userId][actionType] = {
            count = 0,
            window_start = now,
            burst_count = 0,
            burst_start = now
        }
    end
    
    local userLimit = userLimits[userId][actionType]
    
    -- Increment counters
    userLimit.count = userLimit.count + 1
    userLimit.burst_count = userLimit.burst_count + 1
    
    -- Update global statistics
    if not globalLimits[actionType] then
        globalLimits[actionType] = {
            total_actions = 0,
            actions_per_minute = 0,
            window_start = now
        }
    end
    
    local globalLimit = globalLimits[actionType]
    globalLimit.total_actions = globalLimit.total_actions + 1
    
    -- Reset global window if needed
    if now - globalLimit.window_start > 60 then
        globalLimit.actions_per_minute = 0
        globalLimit.window_start = now
    end
    
    globalLimit.actions_per_minute = globalLimit.actions_per_minute + 1
end

function RateLimiter:GetActionConfig(actionType)
    local configs = {
        message = {
            rate_limit = Config.RATE_LIMIT.MESSAGES_PER_MINUTE,
            burst_limit = Config.RATE_LIMIT.BURST_LIMIT,
            burst_window = Config.RATE_LIMIT.BURST_WINDOW,
            timeout_duration = Config.RATE_LIMIT.TIMEOUT_DURATION
        },
        private_message = {
            rate_limit = math.floor(Config.RATE_LIMIT.MESSAGES_PER_MINUTE / 2),
            burst_limit = math.floor(Config.RATE_LIMIT.BURST_LIMIT / 2),
            burst_window = Config.RATE_LIMIT.BURST_WINDOW,
            timeout_duration = Config.RATE_LIMIT.TIMEOUT_DURATION
        },
        reaction = {
            rate_limit = Config.RATE_LIMIT.MESSAGES_PER_MINUTE * 2,
            burst_limit = Config.RATE_LIMIT.BURST_LIMIT * 2,
            burst_window = Config.RATE_LIMIT.BURST_WINDOW,
            timeout_duration = 10
        },
        join_channel = {
            rate_limit = 5,
            burst_limit = 2,
            burst_window = 30,
            timeout_duration = 60
        }
    }
    
    return configs[actionType] or configs.message
end

function RateLimiter:ApplyTimeout(userId, duration)
    timeouts[userId] = {
        start_time = os.time(),
        duration = duration,
        reason = "Rate limit exceeded"
    }
    
    print("⏱️ User " .. userId .. " timed out for " .. duration .. " seconds")
end

function RateLimiter:IsUserTimedOut(userId)
    local timeout = timeouts[userId]
    if not timeout then
        return false
    end
    
    local now = os.time()
    if now - timeout.start_time >= timeout.duration then
        timeouts[userId] = nil
        return false
    end
    
    return true
end

function RateLimiter:GetTimeoutRemaining(userId)
    local timeout = timeouts[userId]
    if not timeout then
        return 0
    end
    
    local now = os.time()
    local remaining = timeout.duration - (now - timeout.start_time)
    return math.max(0, remaining)
end

function RateLimiter:RemoveTimeout(userId)
    timeouts[userId] = nil
    print("⏱️ Timeout removed for user " .. userId)
end

function RateLimiter:GetUserStats(userId)
    local stats = {
        timeouts = 0,
        actions_today = 0,
        current_timeout = nil
    }
    
    if timeouts[userId] then
        stats.current_timeout = {
            remaining = self:GetTimeoutRemaining(userId),
            reason = timeouts[userId].reason
        }
    end
    
    return stats
end

function RateLimiter:GetGlobalStats()
    local stats = {
        total_users = Utils:TableLength(userLimits),
        active_timeouts = Utils:TableLength(timeouts),
        actions_per_minute = {}
    }
    
    for actionType, limit in pairs(globalLimits) do
        stats.actions_per_minute[actionType] = limit.actions_per_minute
    end
    
    return stats
end

function RateLimiter:StartCleanupTimer()
    spawn(function()
        while true do
            wait(300) -- Clean up every 5 minutes
            self:CleanupExpiredData()
        end
    end)
end

function RateLimiter:CleanupExpiredData()
    local now = os.time()
    
    -- Clean up expired timeouts
    for userId, timeout in pairs(timeouts) do
        if now - timeout.start_time >= timeout.duration then
            timeouts[userId] = nil
        end
    end
    
    -- Clean up old user limits (older than 1 hour)
    for userId, limits in pairs(userLimits) do
        for actionType, limit in pairs(limits) do
            if now - limit.window_start > 3600 then
                limits[actionType] = nil
            end
        end
        
        -- Remove user if no limits left
        if next(limits) == nil then
            userLimits[userId] = nil
        end
    end
    
    print("⏱️ Rate limiter cleanup completed")
end

function RateLimiter:Cleanup()
    userLimits = {}
    globalLimits = {}
    timeouts = {}
    print("⏱️ Rate Limiter cleaned up")
end

-- ============================================================================
-- NETWORK MANAGER MODULE
-- ============================================================================

local NetworkManager = {}

-- Network state
local networkState = {
    isConnected = false,
    currentServer = nil,
    sessionToken = nil,
    lastPing = 0,
    lastTokenRefresh = 0,
    reconnectAttempts = 0,
    messageQueue = {},
    heartbeatConnection = nil,
    websocket = nil
}

-- Event callbacks
local eventCallbacks = {
    onConnected = {},
    onDisconnected = {},
    onMessage = {},
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

function NetworkManager:ConnectToServer(serverUrl, authToken)
    if networkState.isConnected then
        self:DisconnectFromServer()
    end
    
    networkState.currentServer = serverUrl
    networkState.sessionToken = authToken
    networkState.reconnectAttempts = 0
    networkState.lastPing = os.time() -- Initialize lastPing
    
    print("🌐 Connecting to server: " .. serverUrl)
    
    -- Real WebSocket connection implementation
    spawn(function()
        local success, errorMsg = pcall(function()
            -- Create WebSocket connection
            local ws = WebSocket.connect(serverUrl)
            networkState.websocket = ws
            
            -- Set up event handlers
            ws.OnMessage:Connect(function(message)
                self:HandleWebSocketMessage(message)
            end)
            
            ws.OnClose:Connect(function(code, reason)
                print("🔌 WebSocket closed: " .. (reason or "Unknown reason") .. " (Code: " .. code .. ")")
                networkState.isConnected = false
                self:TriggerEvent("onDisconnected", reason)
                self:HandleConnectionFailure()
            end)
            
            ws.OnError:Connect(function(error)
                print("❌ WebSocket error: " .. tostring(error))
                self:TriggerEvent("onError", error)
            end)
            
            -- Send authentication message
            local authMessage = {
                type = "auth",
                userId = UserManager:GetUserId(),
                username = UserManager:GetUsername(),
                executor = identifyExecutor(),
                token = authToken
            }
            
            ws:Send(HttpService:JSONEncode(authMessage))
            
            -- Connection successful
            networkState.isConnected = true
            networkState.lastPing = os.time()
            self:TriggerEvent("onConnected", serverUrl)
            self:StartHeartbeat()
            
            print("✅ Connected to server successfully")
        end)
        
        if not success then
            print("❌ WebSocket connection failed: " .. tostring(errorMsg))
            self:TriggerEvent("onError", "Connection failed: " .. tostring(errorMsg))
            self:HandleConnectionFailure()
        end
    end)
end

function NetworkManager:HandleWebSocketMessage(message)
    local success, data = pcall(function()
        return HttpService:JSONDecode(message)
    end)
    
    if not success then
        print("❌ Failed to parse WebSocket message: " .. tostring(data))
        return
    end
    
    -- Update last ping time for connection health monitoring
    networkState.lastPing = os.time()
    
    -- Process message based on type
    if data.type == "auth_success" then
        self:TriggerEvent("onAuthResponse", data)
        print("🔐 Authentication successful")
    elseif data.type == "auth_error" then
        self:TriggerEvent("onAuthError", data)
        print("❌ Authentication error: " .. (data.message or "Unknown error"))
    elseif data.type == "chat_message" then
        self:TriggerEvent("onMessage", data)
    elseif data.type == "private_message" then
        self:TriggerEvent("onPrivateMessage", data)
    elseif data.type == "message_delivered" then
        self:TriggerEvent("onMessageDelivered", data)
    elseif data.type == "user_joined" then
        self:TriggerEvent("onUserJoined", data)
    elseif data.type == "user_left" then
        self:TriggerEvent("onUserLeft", data)
    elseif data.type == "user_typing" then
        self:TriggerEvent("onUserTyping", data)
    elseif data.type == "user_block" then
        self:TriggerEvent("onUserBlocked", data)
        -- Update local block list
        local blockList = UserManager:GetBlockedUsers()
        if not table.find(blockList, data.username) then
            table.insert(blockList, data.username)
            UserManager:SetBlockedUsers(blockList)
        end
    elseif data.type == "user_unblock" then
        self:TriggerEvent("onUserUnblocked", data)
        -- Update local block list
        local blockList = UserManager:GetBlockedUsers()
        local index = table.find(blockList, data.username)
        if index then
            table.remove(blockList, index)
            UserManager:SetBlockedUsers(blockList)
        end
    elseif data.type == "thread_created" then
        self:TriggerEvent("onThreadCreated", data)
    elseif data.type == "thread_message" then
        self:TriggerEvent("onThreadMessage", data)
    elseif data.type == "error" then
        self:TriggerEvent("onError", data.message)
        print("❌ Server error: " .. (data.message or "Unknown error"))
    elseif data.type == "pong" then
        -- Heartbeat response
        networkState.lastPing = os.time()
    elseif data.type == "token_refresh" then
        -- Update authentication token
        if data.token then
            UserManager:SetAuthToken(data.token)
            print("🔄 Authentication token refreshed")
        end
    else
        print("⚠️ Unknown message type: " .. data.type)
    end
end

function NetworkManager:DisconnectFromServer()
    if not networkState.isConnected then
        return
    end
    
    networkState.isConnected = false
    
    -- Close WebSocket connection
    if networkState.websocket then
        -- Send disconnect message
        local disconnectMessage = {
            type = "disconnect",
            userId = UserManager:GetUserId(),
            reason = "User disconnected"
        }
        
        -- Try to send disconnect message
        pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(disconnectMessage))
            networkState.websocket:Close()
        end)
        
        networkState.websocket = nil
    end
    
    -- Stop heartbeat
    if networkState.heartbeatConnection then
        networkState.heartbeatConnection:Disconnect()
        networkState.heartbeatConnection = nil
    end
    
    self:TriggerEvent("onDisconnected", networkState.currentServer)
    
    networkState.currentServer = nil
    networkState.sessionToken = nil
    
    print("🔌 Disconnected from server")
end

function NetworkManager:SendMessage(messageData)
    if not networkState.isConnected then
        -- Queue message for later
        table.insert(networkState.messageQueue, {
            type = "message",
            data = messageData,
            timestamp = os.time()
        })
        return false, "Not connected - message queued"
    end
    
    -- Send message via WebSocket
    if networkState.websocket then
        local messagePacket = {
            type = "chat_message",
            message = messageData
        }
        
        local success, errorMsg = pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(messagePacket))
        end)
        
        if not success then
            print("❌ Failed to send message: " .. tostring(errorMsg))
            return false, "Failed to send message: " .. tostring(errorMsg)
        end
        
        return true, "Message sent"
    else
        return false, "WebSocket connection not established"
    end
end

function NetworkManager:SendPrivateMessage(messageData)
    if not networkState.isConnected then
        table.insert(networkState.messageQueue, {
            type = "private_message",
            data = messageData,
            timestamp = os.time()
        })
        return false, "Not connected - message queued"
    end
    
    -- Send private message via WebSocket
    if networkState.websocket then
        local messagePacket = {
            type = "private_message",
            message = messageData
        }
        
        local success, errorMsg = pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(messagePacket))
        end)
        
        if not success then
            print("❌ Failed to send private message: " .. tostring(errorMsg))
            return false, "Failed to send private message: " .. tostring(errorMsg)
        end
        
        return true, "Private message sent"
    else
        return false, "WebSocket connection not established"
    end
end

function NetworkManager:SendAuthRequest(username, password, isSignup)
    -- First, connect to WebSocket if not already connected
    if not networkState.websocket then
        self:ConnectToServer(Config.WEBSOCKET_URL)
    end
    
    -- Send authentication via WebSocket
    if networkState.websocket then
        local authMessage = {
            type = isSignup and "register" or "login",
            username = username,
            password = password,
            executor = self:GetExecutorInfo(),
            platform = self:GetPlatformInfo(),
            timestamp = os.time()
        }
        
        local success, errorMsg = pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(authMessage))
        end)
        
        if not success then
            print("❌ Failed to send authentication request: " .. tostring(errorMsg))
            self:TriggerEvent("onAuthError", {message = "Failed to send authentication request"})
            return
        end
        
        -- Authentication response will be handled by the WebSocket message handler
        return
    end
    
    -- Fallback to HTTP if WebSocket is not available
    local endpoint = isSignup and "/api/v1/auth/register" or "/api/v1/auth/login"
    local url = Config.API_BASE_URL .. endpoint
    
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            username = username,
            password = password,
            executor = self:GetExecutorInfo(),
            platform = self:GetPlatformInfo()
        })
    }
    
    spawn(function()
        local success, response = pcall(function()
            return self.httpRequest(requestData)
        end)
        
        if success and response.Success then
            local data = HttpService:JSONDecode(response.Body)
            self:TriggerEvent("onAuthResponse", true, data)
        else
            local errorMsg = "Authentication failed"
            if response and response.Body then
                local errorData = pcall(function()
                    return HttpService:JSONDecode(response.Body)
                end)
                if errorData and errorData.error then
                    errorMsg = errorData.error
                end
            end
            self:TriggerEvent("onAuthResponse", false, errorMsg)
        end
    end)
end

-- These functions have been replaced with real WebSocket implementations
-- and are no longer needed. The server will echo back messages via WebSocket.
function NetworkManager:SimulateSendMessage(messageData)
    -- This function is deprecated and only kept for backward compatibility
    print("⚠️ Warning: Using deprecated SimulateSendMessage function")
    -- No action needed as the server will echo back messages
end

function NetworkManager:SimulateSendPrivateMessage(messageData)
    -- This function is deprecated and only kept for backward compatibility
    print("⚠️ Warning: Using deprecated SimulateSendPrivateMessage function")
    -- No action needed as the server will handle private messages
end

function NetworkManager:StartHeartbeat()
    -- Initialize token refresh timer
    networkState.lastTokenRefresh = os.time()
    
    networkState.heartbeatConnection = RunService.Heartbeat:Connect(function()
        local now = os.time()
        
        -- Handle heartbeat
        if now - networkState.lastPing >= Config.HEARTBEAT_INTERVAL then
            self:SendHeartbeat()
            networkState.lastPing = now
        end
        
        -- Handle token refresh (every 30 minutes)
        if UserManager:IsAuthenticated() and now - networkState.lastTokenRefresh >= 1800 then
            self:RefreshToken()
            networkState.lastTokenRefresh = now
        end
    end)
end

function NetworkManager:SendHeartbeat()
    if not networkState.isConnected or not networkState.websocket then
        return
    end

    -- Send real heartbeat via WebSocket
    local heartbeatPacket = {
        type = "ping",
        userId = UserManager:GetUserId(),
        timestamp = os.time()
    }
    
    local success, errorMsg = pcall(function()
        networkState.websocket:Send(HttpService:JSONEncode(heartbeatPacket))
    end)
    
    if success then
        print("💓 Heartbeat sent")
    else
        print("❌ Failed to send heartbeat: " .. tostring(errorMsg))
        -- If heartbeat fails, check connection status
        self:CheckConnectionStatus()
    end
end

function NetworkManager:CheckConnectionStatus()
    -- If we haven't received a response in 2x the heartbeat interval, consider the connection dead
    local now = os.time()
    if now - networkState.lastPing > (Config.HEARTBEAT_INTERVAL * 2) then
        print("⚠️ Connection appears to be dead, attempting to reconnect")
        self:DisconnectFromServer()
        self:HandleConnectionFailure()
    end
end

function NetworkManager:RefreshToken()
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end
    
    -- Send token refresh request via WebSocket
    if networkState.websocket then
        local refreshMessage = {
            type = "token_refresh",
            userId = UserManager:GetUserId(),
            currentToken = UserManager:GetAuthToken(),
            timestamp = os.time()
        }
        
        local success, errorMsg = pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(refreshMessage))
        end)
        
        if not success then
            print("❌ Failed to send token refresh request: " .. tostring(errorMsg))
            return false, "Failed to send token refresh request"
        end
        
        return true, "Token refresh request sent"
    end
    
    -- Fallback to HTTP if WebSocket is not available
    local url = Config.API_BASE_URL .. "/api/v1/auth/refresh"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            userId = UserManager:GetUserId()
        })
    }
    
    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)
    
    if success and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.token then
            UserManager:SetAuthToken(data.token)
            print("🔄 Authentication token refreshed")
            return true, "Token refreshed"
        end
    end
    
    return false, "Failed to refresh token"
end

function NetworkManager:HandleConnectionFailure()
    if networkState.reconnectAttempts < Config.MAX_RECONNECT_ATTEMPTS then
        networkState.reconnectAttempts = networkState.reconnectAttempts + 1
        
        print("🔄 Attempting to reconnect (" .. networkState.reconnectAttempts .. "/" .. Config.MAX_RECONNECT_ATTEMPTS .. ")")
        
        spawn(function()
            wait(Config.RECONNECT_DELAY)
            if networkState.currentServer then
                self:ConnectToServer(networkState.currentServer, networkState.sessionToken)
            end
        end)
    else
        print("❌ Max reconnection attempts reached")
        self:TriggerEvent("onError", "Max reconnection attempts reached")
    end
end

function NetworkManager:StartMessageQueueProcessor()
    spawn(function()
        while true do
            wait(1)
            
            if networkState.isConnected and #networkState.messageQueue > 0 then
                local queuedMessage = table.remove(networkState.messageQueue, 1)
                
                if queuedMessage.type == "message" then
                    self:SendMessage(queuedMessage.data)
                elseif queuedMessage.type == "private_message" then
                    self:SendPrivateMessage(queuedMessage.data)
                end
            end
        end
    end)
end

function NetworkManager:GetExecutorInfo()
    -- Detect executor
    local executors = {
        ["Delta"] = function() return identifyexecutor and identifyexecutor():find("Delta") end,
        ["Synapse"] = function() return syn and syn.request end,
        ["Krnl"] = function() return krnl and krnl.request end,
        ["Fluxus"] = function() return fluxus and fluxus.request end,
        ["Oxygen"] = function() return oxygen and oxygen.request end,
        ["Script-Ware"] = function() return isscriptware and isscriptware() end,
        ["Sentinel"] = function() return SENTINEL_V2 end,
        ["ProtoSmasher"] = function() return is_protosmasher_caller and is_protosmasher_caller() end,
        ["Sirhurt"] = function() return sirhurt and sirhurt.request end,
        ["Electron"] = function() return iselectron and iselectron() end,
        ["Calamari"] = function() return iscalamari and iscalamari() end,
        ["Coco"] = function() return COCO_LOADED end,
        ["WeAreDevs"] = function() return WeAreDevs end,
        ["JJSploit"] = function() return jjsploit end,
        ["Proxo"] = function() return isvm and isvm() end,
        ["Nihon"] = function() return nihon end,
        ["Vega"] = function() return vega end,
        ["Trigon"] = function() return trigon end
    }
    
    for name, detector in pairs(executors) do
        if detector() then
            return name
        end
    end
    
    -- Fallback detection
    if identifyexecutor then
        local executor = identifyexecutor()
        if executor and executor ~= "" then
            return executor:gsub("%s+", "-")
        end
    end
    
    return "Unknown"
end

function NetworkManager:GetPlatformInfo()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    else
        return "PC"
    end
end

function NetworkManager:TriggerEvent(eventType, ...)
    local callbacks = eventCallbacks[eventType]
    if callbacks then
        for _, callback in ipairs(callbacks) do
            callback(...)
        end
    end
end

function NetworkManager:On(eventType, callback)
    if not eventCallbacks[eventType] then
        eventCallbacks[eventType] = {}
    end
    table.insert(eventCallbacks[eventType], callback)
end

function NetworkManager:Off(eventType, callback)
    local callbacks = eventCallbacks[eventType]
    if callbacks then
        for i, cb in ipairs(callbacks) do
            if cb == callback then
                table.remove(callbacks, i)
                break
            end
        end
    end
end

function NetworkManager:GetConnectionStatus()
    return {
        isConnected = networkState.isConnected,
        currentServer = networkState.currentServer,
        lastPing = networkState.lastPing,
        reconnectAttempts = networkState.reconnectAttempts,
        queuedMessages = #networkState.messageQueue
    }
end

-- ============================================================================
-- FRIENDS SYSTEM NETWORK METHODS
-- ============================================================================

function NetworkManager:SendFriendRequest(username)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/friends/request"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            username = username
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 201, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:AcceptFriendRequest(friendId)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/friends/accept"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            friendId = friendId
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:DeclineFriendRequest(friendId)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/friends/decline"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            friendId = friendId
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:RemoveFriend(friendId)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/friends/" .. tostring(friendId)
    local requestData = {
        Url = url,
        Method = "DELETE",
        Headers = {
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        }
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:GetUserProfile()
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/user/profile"
    local requestData = {
        Url = url,
        Method = "GET",
        Headers = {
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        }
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

-- ============================================================================
-- USER PREFERENCES NETWORK METHODS
-- ============================================================================

function NetworkManager:SaveUserPreferences(preferences)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/user/preferences"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode(preferences)
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:GetUserPreferences()
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/user/preferences"
    local requestData = {
        Url = url,
        Method = "GET",
        Headers = {
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        }
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

-- ============================================================================
-- CHAT HISTORY NETWORK METHODS
-- ============================================================================

function NetworkManager:SaveChatHistory(channelId, messageData)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/chat/history"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            channelId = channelId,
            messageData = messageData
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 201, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:GetChatHistory(channelId, limit, offset)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/chat/history/" .. channelId
    if limit or offset then
        url = url .. "?limit=" .. (limit or 100) .. "&offset=" .. (offset or 0)
    end

    local requestData = {
        Url = url,
        Method = "GET",
        Headers = {
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        }
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:ClearChatHistory(channelId)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    local url = Config.API_BASE_URL .. "/api/v1/chat/history/" .. channelId
    local requestData = {
        Url = url,
        Method = "DELETE",
        Headers = {
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        }
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

-- ============================================================================
-- BLOCKING NETWORK METHODS
-- ============================================================================

function NetworkManager:BlockUser(username)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    -- First, send a WebSocket notification about the block
    if networkState.websocket then
        local blockNotification = {
            type = "user_block",
            username = username,
            userId = UserManager:GetUserId()
        }
        
        pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(blockNotification))
        end)
    end

    -- Then make the API call to persist the block
    local url = Config.API_BASE_URL .. "/api/v1/users/block"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            username = username
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:UnblockUser(username)
    if not UserManager:IsAuthenticated() then
        return false, "Not authenticated"
    end

    -- First, send a WebSocket notification about the unblock
    if networkState.websocket then
        local unblockNotification = {
            type = "user_unblock",
            username = username,
            userId = UserManager:GetUserId()
        }
        
        pcall(function()
            networkState.websocket:Send(HttpService:JSONEncode(unblockNotification))
        end)
    end

    -- Then make the API call to persist the unblock
    local url = Config.API_BASE_URL .. "/api/v1/users/unblock"
    local requestData = {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. UserManager:GetAuthToken()
        },
        Body = HttpService:JSONEncode({
            username = username
        })
    }

    local success, response = pcall(function()
        return self.httpRequest(requestData)
    end)

    if success and response then
        local responseData = HttpService:JSONDecode(response.Body)
        return response.StatusCode == 200, responseData
    else
        return false, "Network error"
    end
end

function NetworkManager:Cleanup()
    self:DisconnectFromServer()
    networkState.messageQueue = {}
    eventCallbacks = {
        onConnected = {},
        onDisconnected = {},
        onMessage = {},
        onError = {},
        onReconnecting = {},
        onAuthResponse = {},
        onPrivateMessageSent = {}
    }
    print("🌐 Network Manager cleaned up")
end

-- ============================================================================
-- EMOJI MANAGER MODULE
-- ============================================================================

local EmojiManager = {}

-- Emoji database with Unicode support (simplified for space)
local EMOJI_DATABASE = {
    ["Smileys & Emotion"] = {
        {code = "😀", name = "grinning face", keywords = {"happy", "smile", "grin"}},
        {code = "😃", name = "grinning face with big eyes", keywords = {"happy", "smile", "joy"}},
        {code = "😄", name = "grinning face with smiling eyes", keywords = {"happy", "smile", "joy"}},
        {code = "😁", name = "beaming face with smiling eyes", keywords = {"happy", "smile", "grin"}},
        {code = "😆", name = "grinning squinting face", keywords = {"happy", "laugh", "haha"}},
        {code = "😅", name = "grinning face with sweat", keywords = {"happy", "sweat", "relief"}},
        {code = "🤣", name = "rolling on the floor laughing", keywords = {"laugh", "lol", "rofl"}},
        {code = "😂", name = "face with tears of joy", keywords = {"laugh", "cry", "joy"}},
        {code = "🙂", name = "slightly smiling face", keywords = {"smile", "happy"}},
        {code = "😉", name = "winking face", keywords = {"wink", "flirt"}},
        {code = "😊", name = "smiling face with smiling eyes", keywords = {"happy", "smile", "blush"}},
        {code = "😍", name = "smiling face with heart-eyes", keywords = {"love", "heart", "eyes"}},
        {code = "😘", name = "face blowing a kiss", keywords = {"kiss", "love"}},
        {code = "😋", name = "face savoring food", keywords = {"yum", "tongue", "taste"}},
        {code = "😛", name = "face with tongue", keywords = {"tongue", "silly"}},
        {code = "😜", name = "winking face with tongue", keywords = {"tongue", "wink", "silly"}},
        {code = "🤪", name = "zany face", keywords = {"crazy", "silly", "goofy"}},
        {code = "😝", name = "squinting face with tongue", keywords = {"tongue", "silly"}},
        {code = "🤑", name = "money-mouth face", keywords = {"money", "rich", "dollar"}},
        {code = "🤗", name = "hugging face", keywords = {"hug", "love", "care"}},
        {code = "🤔", name = "thinking face", keywords = {"think", "hmm", "consider"}},
        {code = "😐", name = "neutral face", keywords = {"neutral", "meh"}},
        {code = "😑", name = "expressionless face", keywords = {"blank", "meh"}},
        {code = "😏", name = "smirking face", keywords = {"smirk", "smug"}},
        {code = "😒", name = "unamused face", keywords = {"annoyed", "meh"}},
        {code = "🙄", name = "face with rolling eyes", keywords = {"eye", "roll", "annoyed"}},
        {code = "😬", name = "grimacing face", keywords = {"grimace", "awkward"}},
        {code = "😔", name = "pensive face", keywords = {"sad", "think"}},
        {code = "😪", name = "sleepy face", keywords = {"tired", "sleep"}},
        {code = "😴", name = "sleeping face", keywords = {"sleep", "zzz"}},
        {code = "😷", name = "face with medical mask", keywords = {"sick", "mask", "covid"}},
        {code = "🤒", name = "face with thermometer", keywords = {"sick", "fever"}},
        {code = "🤕", name = "face with head-bandage", keywords = {"hurt", "injured"}},
        {code = "🤢", name = "nauseated face", keywords = {"sick", "gross"}},
        {code = "🤮", name = "face vomiting", keywords = {"sick", "puke"}},
        {code = "🥵", name = "hot face", keywords = {"hot", "heat", "sweat"}},
        {code = "🥶", name = "cold face", keywords = {"cold", "freeze"}},
        {code = "😵", name = "dizzy face", keywords = {"dizzy", "confused"}},
        {code = "🤯", name = "exploding head", keywords = {"mind", "blown", "wow"}},
        {code = "🤠", name = "cowboy hat face", keywords = {"cowboy", "hat"}},
        {code = "🥳", name = "partying face", keywords = {"party", "celebrate"}},
        {code = "😎", name = "smiling face with sunglasses", keywords = {"cool", "sunglasses"}},
        {code = "🤓", name = "nerd face", keywords = {"nerd", "geek", "smart"}},
        {code = "😕", name = "confused face", keywords = {"confused", "sad"}},
        {code = "😟", name = "worried face", keywords = {"worried", "sad"}},
        {code = "🙁", name = "slightly frowning face", keywords = {"sad", "frown"}},
        {code = "😮", name = "face with open mouth", keywords = {"wow", "surprised"}},
        {code = "😯", name = "hushed face", keywords = {"quiet", "surprised"}},
        {code = "😲", name = "astonished face", keywords = {"wow", "surprised"}},
        {code = "😳", name = "flushed face", keywords = {"blush", "embarrassed"}},
        {code = "🥺", name = "pleading face", keywords = {"puppy", "eyes", "please"}},
        {code = "😦", name = "frowning face with open mouth", keywords = {"sad", "worried"}},
        {code = "😧", name = "anguished face", keywords = {"sad", "pain"}},
        {code = "😨", name = "fearful face", keywords = {"scared", "fear"}},
        {code = "😰", name = "anxious face with sweat", keywords = {"worried", "sweat"}},
        {code = "😥", name = "sad but relieved face", keywords = {"sad", "relief"}},
        {code = "😢", name = "crying face", keywords = {"cry", "sad", "tear"}},
        {code = "😭", name = "loudly crying face", keywords = {"cry", "sob", "sad"}},
        {code = "😱", name = "face screaming in fear", keywords = {"scream", "scared"}},
        {code = "😖", name = "confounded face", keywords = {"confused", "sad"}},
        {code = "😣", name = "persevering face", keywords = {"struggle", "persevere"}},
        {code = "😞", name = "disappointed face", keywords = {"sad", "disappointed"}},
        {code = "😓", name = "downcast face with sweat", keywords = {"sad", "sweat"}},
        {code = "😩", name = "weary face", keywords = {"tired", "weary"}},
        {code = "😫", name = "tired face", keywords = {"tired", "exhausted"}},
        {code = "🥱", name = "yawning face", keywords = {"tired", "yawn", "bored"}},
        {code = "😤", name = "face with steam from nose", keywords = {"angry", "mad"}},
        {code = "😡", name = "pouting face", keywords = {"angry", "mad", "red"}},
        {code = "😠", name = "angry face", keywords = {"angry", "mad"}},
        {code = "🤬", name = "face with symbols on mouth", keywords = {"swear", "angry"}},
        {code = "😈", name = "smiling face with horns", keywords = {"devil", "evil"}},
        {code = "👿", name = "angry face with horns", keywords = {"devil", "angry"}},
        {code = "💀", name = "skull", keywords = {"death", "skull"}},
        {code = "☠️", name = "skull and crossbones", keywords = {"death", "danger"}},
        {code = "💩", name = "pile of poo", keywords = {"poop", "shit"}},
        {code = "🤡", name = "clown face", keywords = {"clown", "funny"}},
        {code = "👹", name = "ogre", keywords = {"monster", "ogre"}},
        {code = "👺", name = "goblin", keywords = {"monster", "goblin"}},
        {code = "👻", name = "ghost", keywords = {"ghost", "boo"}},
        {code = "👽", name = "alien", keywords = {"alien", "ufo"}},
        {code = "👾", name = "alien monster", keywords = {"alien", "game"}},
        {code = "🤖", name = "robot", keywords = {"robot", "ai"}},
        {code = "😺", name = "grinning cat", keywords = {"cat", "happy"}},
        {code = "😸", name = "grinning cat with smiling eyes", keywords = {"cat", "happy"}},
        {code = "😹", name = "cat with tears of joy", keywords = {"cat", "laugh"}},
        {code = "😻", name = "smiling cat with heart-eyes", keywords = {"cat", "love"}},
        {code = "😼", name = "cat with wry smile", keywords = {"cat", "smirk"}},
        {code = "😽", name = "kissing cat", keywords = {"cat", "kiss"}},
        {code = "🙀", name = "weary cat", keywords = {"cat", "scared"}},
        {code = "😿", name = "crying cat", keywords = {"cat", "sad"}},
        {code = "😾", name = "pouting cat", keywords = {"cat", "angry"}}
    },
    
    ["People & Body"] = {
        {code = "👋", name = "waving hand", keywords = {"wave", "hello", "hi"}},
        {code = "🤚", name = "raised back of hand", keywords = {"hand", "stop"}},
        {code = "🖐️", name = "hand with fingers splayed", keywords = {"hand", "five"}},
        {code = "✋", name = "raised hand", keywords = {"hand", "stop", "high five"}},
        {code = "🖖", name = "vulcan salute", keywords = {"spock", "star trek"}},
        {code = "👌", name = "OK hand", keywords = {"ok", "perfect"}},
        {code = "🤏", name = "pinching hand", keywords = {"small", "tiny"}},
        {code = "✌️", name = "victory hand", keywords = {"peace", "victory"}},
        {code = "🤞", name = "crossed fingers", keywords = {"luck", "hope"}},
        {code = "🤟", name = "love-you gesture", keywords = {"love", "rock"}},
        {code = "🤘", name = "sign of the horns", keywords = {"rock", "metal"}},
        {code = "🤙", name = "call me hand", keywords = {"call", "phone"}},
        {code = "👈", name = "backhand index pointing left", keywords = {"left", "point"}},
        {code = "👉", name = "backhand index pointing right", keywords = {"right", "point"}},
        {code = "👆", name = "backhand index pointing up", keywords = {"up", "point"}},
        {code = "🖕", name = "middle finger", keywords = {"middle", "finger", "rude"}},
        {code = "👇", name = "backhand index pointing down", keywords = {"down", "point"}},
        {code = "☝️", name = "index pointing up", keywords = {"up", "point", "one"}},
        {code = "👍", name = "thumbs up", keywords = {"good", "yes", "like"}},
        {code = "👎", name = "thumbs down", keywords = {"bad", "no", "dislike"}},
        {code = "✊", name = "raised fist", keywords = {"fist", "power"}},
        {code = "👊", name = "oncoming fist", keywords = {"fist", "punch"}},
        {code = "🤛", name = "left-facing fist", keywords = {"fist", "bump"}},
        {code = "🤜", name = "right-facing fist", keywords = {"fist", "bump"}},
        {code = "👏", name = "clapping hands", keywords = {"clap", "applause"}},
        {code = "🙌", name = "raising hands", keywords = {"celebration", "praise"}},
        {code = "👐", name = "open hands", keywords = {"hands", "hug"}},
        {code = "🤲", name = "palms up together", keywords = {"prayer", "please"}},
        {code = "🤝", name = "handshake", keywords = {"shake", "deal"}},
        {code = "🙏", name = "folded hands", keywords = {"prayer", "thanks", "please"}},
        {code = "✍️", name = "writing hand", keywords = {"write", "pen"}},
        {code = "💅", name = "nail polish", keywords = {"nails", "beauty"}},
        {code = "🤳", name = "selfie", keywords = {"selfie", "camera"}},
        {code = "💪", name = "flexed biceps", keywords = {"muscle", "strong"}},
        {code = "🦾", name = "mechanical arm", keywords = {"robot", "prosthetic"}},
        {code = "🦿", name = "mechanical leg", keywords = {"robot", "prosthetic"}},
        {code = "🦵", name = "leg", keywords = {"leg", "kick"}},
        {code = "🦶", name = "foot", keywords = {"foot", "kick"}},
        {code = "👂", name = "ear", keywords = {"ear", "listen"}},
        {code = "🦻", name = "ear with hearing aid", keywords = {"hearing", "aid"}},
        {code = "👃", name = "nose", keywords = {"nose", "smell"}},
        {code = "🧠", name = "brain", keywords = {"brain", "smart"}},
        {code = "🫀", name = "anatomical heart", keywords = {"heart", "organ"}},
        {code = "🫁", name = "lungs", keywords = {"lungs", "breathe"}},
        {code = "🦷", name = "tooth", keywords = {"tooth", "dental"}},
        {code = "🦴", name = "bone", keywords = {"bone", "skeleton"}},
        {code = "👀", name = "eyes", keywords = {"eyes", "look"}},
        {code = "👁️", name = "eye", keywords = {"eye", "see"}},
        {code = "👅", name = "tongue", keywords = {"tongue", "taste"}},
        {code = "👄", name = "mouth", keywords = {"mouth", "lips"}}
    },
    
    ["Objects"] = {
        {code = "⌚", name = "watch", keywords = {"watch", "time"}},
        {code = "📱", name = "mobile phone", keywords = {"phone", "mobile"}},
        {code = "📲", name = "mobile phone with arrow", keywords = {"phone", "call"}},
        {code = "💻", name = "laptop", keywords = {"laptop", "computer"}},
        {code = "⌨️", name = "keyboard", keywords = {"keyboard", "type"}},
        {code = "🖥️", name = "desktop computer", keywords = {"computer", "desktop"}},
        {code = "🖨️", name = "printer", keywords = {"printer", "print"}},
        {code = "🖱️", name = "computer mouse", keywords = {"mouse", "click"}},
        {code = "🖲️", name = "trackball", keywords = {"trackball", "mouse"}},
        {code = "🕹️", name = "joystick", keywords = {"joystick", "game"}},
        {code = "🗜️", name = "clamp", keywords = {"clamp", "tool"}},
        {code = "💽", name = "computer disk", keywords = {"disk", "storage"}},
        {code = "💾", name = "floppy disk", keywords = {"floppy", "save"}},
        {code = "💿", name = "optical disk", keywords = {"cd", "disk"}},
        {code = "📀", name = "dvd", keywords = {"dvd", "disk"}},
        {code = "🧮", name = "abacus", keywords = {"abacus", "calculate"}},
        {code = "🎥", name = "movie camera", keywords = {"camera", "movie"}},
        {code = "🎞️", name = "film frames", keywords = {"film", "movie"}},
        {code = "📽️", name = "film projector", keywords = {"projector", "movie"}},
        {code = "🎬", name = "clapper board", keywords = {"movie", "action"}},
        {code = "📺", name = "television", keywords = {"tv", "television"}},
        {code = "📷", name = "camera", keywords = {"camera", "photo"}},
        {code = "📸", name = "camera with flash", keywords = {"camera", "flash"}},
        {code = "📹", name = "video camera", keywords = {"video", "camera"}},
        {code = "📼", name = "videocassette", keywords = {"vhs", "tape"}},
        {code = "🔍", name = "magnifying glass tilted left", keywords = {"search", "zoom"}},
        {code = "🔎", name = "magnifying glass tilted right", keywords = {"search", "zoom"}},
        {code = "🕯️", name = "candle", keywords = {"candle", "light"}},
        {code = "💡", name = "light bulb", keywords = {"bulb", "idea"}},
        {code = "🔦", name = "flashlight", keywords = {"flashlight", "torch"}},
        {code = "🏮", name = "red paper lantern", keywords = {"lantern", "light"}},
        {code = "🪔", name = "diya lamp", keywords = {"lamp", "oil"}},
        {code = "📔", name = "notebook with decorative cover", keywords = {"notebook", "book"}},
        {code = "📕", name = "closed book", keywords = {"book", "read"}},
        {code = "📖", name = "open book", keywords = {"book", "read"}},
        {code = "📗", name = "green book", keywords = {"book", "green"}},
        {code = "📘", name = "blue book", keywords = {"book", "blue"}},
        {code = "📙", name = "orange book", keywords = {"book", "orange"}},
        {code = "📚", name = "books", keywords = {"books", "library"}},
        {code = "📓", name = "notebook", keywords = {"notebook", "notes"}},
        {code = "📒", name = "ledger", keywords = {"ledger", "book"}},
        {code = "📃", name = "page with curl", keywords = {"page", "document"}},
        {code = "📜", name = "scroll", keywords = {"scroll", "document"}},
        {code = "📄", name = "page facing up", keywords = {"page", "document"}},
        {code = "📰", name = "newspaper", keywords = {"newspaper", "news"}},
        {code = "🗞️", name = "rolled-up newspaper", keywords = {"newspaper", "news"}},
        {code = "📑", name = "bookmark tabs", keywords = {"bookmark", "tabs"}},
        {code = "🔖", name = "bookmark", keywords = {"bookmark", "save"}},
        {code = "🏷️", name = "label", keywords = {"label", "tag"}},
        {code = "💰", name = "money bag", keywords = {"money", "bag"}},
        {code = "🪙", name = "coin", keywords = {"coin", "money"}},
        {code = "💴", name = "yen banknote", keywords = {"yen", "money"}},
        {code = "💵", name = "dollar banknote", keywords = {"dollar", "money"}},
        {code = "💶", name = "euro banknote", keywords = {"euro", "money"}},
        {code = "💷", name = "pound banknote", keywords = {"pound", "money"}},
        {code = "💸", name = "money with wings", keywords = {"money", "fly"}},
        {code = "💳", name = "credit card", keywords = {"card", "credit"}},
        {code = "🧾", name = "receipt", keywords = {"receipt", "bill"}},
        {code = "💎", name = "gem stone", keywords = {"gem", "diamond"}}
    }
}

-- Recently used emojis
local recentEmojis = {}

function EmojiManager:Initialize()
    print("😀 Emoji Manager initialized")
    self:LoadRecentEmojis()
end

function EmojiManager:GetEmojisByCategory(category)
    return EMOJI_DATABASE[category] or {}
end

function EmojiManager:GetAllCategories()
    local categories = {}
    for category, _ in pairs(EMOJI_DATABASE) do
        table.insert(categories, category)
    end
    return categories
end

function EmojiManager:SearchEmojis(query)
    query = query:lower()
    local results = {}
    
    for category, emojis in pairs(EMOJI_DATABASE) do
        for _, emoji in ipairs(emojis) do
            -- Search in name
            if emoji.name:lower():find(query, 1, true) then
                table.insert(results, emoji)
            else
                -- Search in keywords
                for _, keyword in ipairs(emoji.keywords) do
                    if keyword:lower():find(query, 1, true) then
                        table.insert(results, emoji)
                        break
                    end
                end
            end
        end
    end
    
    return results
end

function EmojiManager:GetRecentEmojis()
    return recentEmojis
end

function EmojiManager:AddToRecent(emoji)
    -- Remove if already exists
    for i, recentEmoji in ipairs(recentEmojis) do
        if recentEmoji.code == emoji.code then
            table.remove(recentEmojis, i)
            break
        end
    end
    
    -- Add to beginning
    table.insert(recentEmojis, 1, emoji)
    
    -- Limit to 20 recent emojis
    if #recentEmojis > 20 then
        table.remove(recentEmojis, #recentEmojis)
    end
    
    self:SaveRecentEmojis()
end

function EmojiManager:GetPopularEmojis()
    -- Return most commonly used emojis
    return {
        EMOJI_DATABASE["Smileys & Emotion"][1], -- 😀
        EMOJI_DATABASE["Smileys & Emotion"][8], -- 😂
        EMOJI_DATABASE["Smileys & Emotion"][12], -- 😍
        EMOJI_DATABASE["Smileys & Emotion"][13], -- 😘
        EMOJI_DATABASE["People & Body"][29], -- 👍
        EMOJI_DATABASE["People & Body"][30], -- 👎
        EMOJI_DATABASE["People & Body"][35], -- 👏
        EMOJI_DATABASE["People & Body"][37], -- 🙌
        EMOJI_DATABASE["People & Body"][41], -- 🙏
        EMOJI_DATABASE["Smileys & Emotion"][21] -- 🤔
    }
end

function EmojiManager:CreateEmojiPicker(parent, onEmojiSelected)
    local picker = Instance.new("Frame")
    picker.Name = "EmojiPicker"
    picker.Size = UDim2.new(0, 350, 0, 400)
    picker.Position = UDim2.new(0.5, -175, 0.5, -200)
    picker.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    picker.BorderSizePixel = 0
    picker.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = picker
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    header.BorderSizePixel = 0
    header.Parent = picker
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Fix header corners
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 12)
    headerFix.Position = UDim2.new(0, 0, 1, -12)
    headerFix.BackgroundColor3 = header.BackgroundColor3
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Emoji"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        picker:Destroy()
    end)
    
    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -30, 0, 35)
    searchBox.Position = UDim2.new(0, 15, 0, 60)
    searchBox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    searchBox.BorderSizePixel = 1
    searchBox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search emojis..."
    searchBox.TextColor3 = ThemeManager:GetCurrentTheme().text
    searchBox.PlaceholderColor3 = ThemeManager:GetCurrentTheme().textMuted
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = picker
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox
    
    -- Category tabs
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -30, 0, 40)
    tabContainer.Position = UDim2.new(0, 15, 0, 105)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = picker
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Emoji grid
    local emojiGrid = Instance.new("ScrollingFrame")
    emojiGrid.Name = "EmojiGrid"
    emojiGrid.Size = UDim2.new(1, -30, 1, -155)
    emojiGrid.Position = UDim2.new(0, 15, 0, 155)
    emojiGrid.BackgroundTransparency = 1
    emojiGrid.BorderSizePixel = 0
    emojiGrid.ScrollBarThickness = 8
    emojiGrid.ScrollBarImageColor3 = ThemeManager:GetCurrentTheme().accent
    emojiGrid.Parent = picker
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 40, 0, 40)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = emojiGrid
    
    -- Current category
    local currentCategory = "Smileys & Emotion"
    
    -- Function to populate emojis
    local function populateEmojis(emojis)
        -- Clear existing emojis
        for _, child in pairs(emojiGrid:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add emojis
        for i, emoji in ipairs(emojis) do
            local emojiButton = Instance.new("TextButton")
            emojiButton.Name = "Emoji_" .. i
            emojiButton.Size = UDim2.new(0, 35, 0, 35)
            emojiButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
            emojiButton.BorderSizePixel = 0
            emojiButton.Text = emoji.code
            emojiButton.TextSize = 20
            emojiButton.Font = Enum.Font.SourceSans
            emojiButton.LayoutOrder = i
            emojiButton.Parent = emojiGrid
            
            local emojiCorner = Instance.new("UICorner")
            emojiCorner.CornerRadius = UDim.new(0, 6)
            emojiCorner.Parent = emojiButton
            
            emojiButton.MouseButton1Click:Connect(function()
                self:AddToRecent(emoji)
                onEmojiSelected(emoji)
                picker:Destroy()
            end)
            
            -- Hover effect
            emojiButton.MouseEnter:Connect(function()
                emojiButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
            end)
            
            emojiButton.MouseLeave:Connect(function()
                emojiButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
            end)
        end
        
        -- Update canvas size
        gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            emojiGrid.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)
        end)
    end
    
    -- Create category tabs
    local categories = {"Recent", "Popular", "Smileys & Emotion", "People & Body", "Objects"}
    for i, category in ipairs(categories) do
        local tab = Instance.new("TextButton")
        tab.Name = "Tab_" .. category
        tab.Size = UDim2.new(0, 60, 1, 0)
        tab.BackgroundColor3 = category == currentCategory and ThemeManager:GetCurrentTheme().accent or ThemeManager:GetCurrentTheme().secondary
        tab.BorderSizePixel = 0
        tab.Text = category == "Recent" and "🕒" or category == "Popular" and "⭐" or category == "Smileys & Emotion" and "😀" or category == "People & Body" and "👋" or "📱"
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.TextSize = 16
        tab.Font = Enum.Font.SourceSans
        tab.LayoutOrder = i
        tab.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tab
        
        tab.MouseButton1Click:Connect(function()
            -- Update tab appearance
            for _, otherTab in pairs(tabContainer:GetChildren()) do
                if otherTab:IsA("TextButton") then
                    otherTab.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
                end
            end
            tab.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
            
            currentCategory = category
            
            -- Load emojis for category
            local emojis
            if category == "Recent" then
                emojis = self:GetRecentEmojis()
            elseif category == "Popular" then
                emojis = self:GetPopularEmojis()
            else
                emojis = self:GetEmojisByCategory(category)
            end
            
            populateEmojis(emojis)
        end)
    end
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text
        if query and query ~= "" then
            local results = self:SearchEmojis(query)
            populateEmojis(results)
        else
            -- Show current category
            local emojis
            if currentCategory == "Recent" then
                emojis = self:GetRecentEmojis()
            elseif currentCategory == "Popular" then
                emojis = self:GetPopularEmojis()
            else
                emojis = self:GetEmojisByCategory(currentCategory)
            end
            populateEmojis(emojis)
        end
    end)
    
    -- Initial load
    populateEmojis(self:GetEmojisByCategory(currentCategory))
    
    return picker
end

function EmojiManager:SaveRecentEmojis()
    Utils:SaveData("recent_emojis", recentEmojis)
end

function EmojiManager:LoadRecentEmojis()
    recentEmojis = Utils:LoadData("recent_emojis", {})
end

function EmojiManager:Cleanup()
    self:SaveRecentEmojis()
    print("😀 Emoji Manager cleaned up")
end

-- ============================================================================
-- MAIN SYSTEM INITIALIZATION
-- ============================================================================

-- Create loading screen
local function createLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatLoader"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Crown logo (simplified)
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 0, 60)
    logo.Position = UDim2.new(0.5, -30, 0, 20)
    logo.BackgroundTransparency = 1
    logo.Text = "👑"
    logo.TextSize = 48
    logo.Font = Enum.Font.SourceSans
    logo.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 85)
    title.BackgroundTransparency = 1
    title.Text = "Global Executor Chat"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0, 0, 0, 125)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by BDG Software"
    subtitle.TextColor3 = Color3.fromRGB(185, 187, 190)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 25)
    status.Position = UDim2.new(0, 20, 0, 160)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(114, 137, 218)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, -40, 0, 6)
    progressBar.Position = UDim2.new(0, 20, 0, 190)
    progressBar.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    local progressCorner1 = Instance.new("UICorner")
    progressCorner1.CornerRadius = UDim.new(0, 3)
    progressCorner1.Parent = progressBar
    
    local progressCorner2 = Instance.new("UICorner")
    progressCorner2.CornerRadius = UDim.new(0, 3)
    progressCorner2.Parent = progressFill
    
    return screenGui, status, progressFill
end

-- Detect executor
function GlobalChat:DetectExecutor()
    local executors = {
        ["Delta"] = function() return identifyexecutor and identifyexecutor():find("Delta") end,
        ["Synapse"] = function() return syn and syn.request end,
        ["Krnl"] = function() return krnl and krnl.request end,
        ["Fluxus"] = function() return fluxus and fluxus.request end,
        ["Oxygen"] = function() return oxygen and oxygen.request end,
        ["Script-Ware"] = function() return isscriptware and isscriptware() end,
        ["Sentinel"] = function() return SENTINEL_V2 end,
        ["ProtoSmasher"] = function() return is_protosmasher_caller and is_protosmasher_caller() end,
        ["Sirhurt"] = function() return sirhurt and sirhurt.request end,
        ["Electron"] = function() return iselectron and iselectron() end,
        ["Calamari"] = function() return iscalamari and iscalamari() end,
        ["Coco"] = function() return COCO_LOADED end,
        ["WeAreDevs"] = function() return WeAreDevs end,
        ["JJSploit"] = function() return jjsploit end,
        ["Proxo"] = function() return isvm and isvm() end,
        ["Nihon"] = function() return nihon end,
        ["Vega"] = function() return vega end,
        ["Trigon"] = function() return trigon end
    }
    
    for name, detector in pairs(executors) do
        if detector() then
            return name
        end
    end
    
    -- Fallback detection methods
    if identifyexecutor then
        local executor = identifyexecutor()
        if executor and executor ~= "" then
            return executor:gsub("%s+", "-")
        end
    end
    
    return "Unknown-Executor"
end

-- Detect platform
function GlobalChat:DetectPlatform()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        return "PC"
    else
        -- Fallback detection
        local screenSize = GuiService:GetScreenResolution()
        
        if screenSize.X < 1024 or screenSize.Y < 768 then
            return "Mobile"
        else
            return "PC"
        end
    end
end

-- Create setup wizard
function GlobalChat:CreateSetupWizard()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatSetup"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "SetupContainer"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Global Executor Chat Setup"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -40, 1, -120)
    contentFrame.Position = UDim2.new(0, 20, 0, 70)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Button container
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "Buttons"
    buttonFrame.Size = UDim2.new(1, -40, 0, 40)
    buttonFrame.Position = UDim2.new(0, 20, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        contentFrame = contentFrame,
        buttonFrame = buttonFrame,
        currentStep = 1,
        totalSteps = 4
    }
end

-- Create simple chat interface
function GlobalChat:CreateSimpleChatInterface(userConfig)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatInterface"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local platform = userConfig.platform or self:DetectPlatform()
    
    if platform == "Mobile" then
        self:CreateMobileInterface(screenGui, userConfig)
    else
        self:CreateDesktopInterface(screenGui, userConfig)
    end
    
    return screenGui
end

-- Create mobile interface
function GlobalChat:CreateMobileInterface(parent, userConfig)
    -- Floating button
    local floatingButton = Instance.new("TextButton")
    floatingButton.Name = "FloatingButton"
    floatingButton.Size = Config.MOBILE.FLOATING_BUTTON_SIZE
    floatingButton.Position = Config.MOBILE.FLOATING_BUTTON_POSITION
    floatingButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
    floatingButton.BorderSizePixel = 0
    floatingButton.Text = "💬"
    floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingButton.TextSize = 24
    floatingButton.Font = Enum.Font.GothamBold
    floatingButton.Parent = parent
    
    -- Make it circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = floatingButton
    
    -- Chat window (initially hidden)
    local chatWindow = Instance.new("Frame")
    chatWindow.Name = "ChatWindow"
    chatWindow.Size = Config.MOBILE.CHAT_WINDOW_SIZE
    chatWindow.Position = UDim2.new(0.025, 0, 0.1, 0)
    chatWindow.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    chatWindow.BorderSizePixel = 0
    chatWindow.Visible = false
    chatWindow.Parent = parent
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 12)
    windowCorner.Parent = chatWindow
    
    -- Toggle functionality
    local isOpen = false
    floatingButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        chatWindow.Visible = isOpen
        
        if isOpen then
            Utils:SlideIn(chatWindow, "up")
        end
    end)
    
    -- Add settings button to mobile interface
    local mobileSettingsButton = Instance.new("TextButton")
    mobileSettingsButton.Name = "SettingsButton"
    mobileSettingsButton.Size = UDim2.new(0, 40, 0, 40)
    mobileSettingsButton.Position = UDim2.new(1, -50, 0, 10)
    mobileSettingsButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
    mobileSettingsButton.BorderSizePixel = 0
    mobileSettingsButton.Text = "⚙️"
    mobileSettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileSettingsButton.TextSize = 18
    mobileSettingsButton.Font = Enum.Font.GothamBold
    mobileSettingsButton.Parent = chatWindow
    
    local mobileSettingsCorner = Instance.new("UICorner")
    mobileSettingsCorner.CornerRadius = UDim.new(0.5, 0)
    mobileSettingsCorner.Parent = mobileSettingsButton
    
    -- Connect settings button
    mobileSettingsButton.MouseButton1Click:Connect(function()
        showSettingsMenu()
    end)
    
    -- Add basic chat elements
    self:AddChatElements(chatWindow, userConfig)
end

-- Create desktop interface
function GlobalChat:CreateDesktopInterface(parent, userConfig)
    -- Main window
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = UDim2.new(0, Config.DESKTOP.WINDOW_DEFAULT_SIZE.X, 0, Config.DESKTOP.WINDOW_DEFAULT_SIZE.Y)
    mainWindow.Position = UDim2.new(0.5, -Config.DESKTOP.WINDOW_DEFAULT_SIZE.X/2, 0.5, -Config.DESKTOP.WINDOW_DEFAULT_SIZE.Y/2)
    mainWindow.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainWindow.BorderSizePixel = 1
    mainWindow.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    mainWindow.Parent = parent
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 8)
    windowCorner.Parent = mainWindow
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Settings button
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 30, 0, 30)
    settingsButton.Position = UDim2.new(1, -40, 0.5, -15)
    settingsButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
    settingsButton.BorderSizePixel = 0
    settingsButton.Text = "⚙️"
    settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsButton.TextSize = 16
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Parent = titleBar
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsButton
    
    -- Connect settings button
    settingsButton.MouseButton1Click:Connect(function()
        showSettingsMenu()
    end)
    
    -- Fix title bar corners
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = titleBar.BackgroundColor3
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Window title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Global Executor Chat - " .. (userConfig.language or "English")
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 25)
    closeButton.Position = UDim2.new(1, -40, 0.5, -12.5)
    closeButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        parent:Destroy()
    end)
    
    -- Add basic chat elements
    self:AddChatElements(mainWindow, userConfig)
end

-- Add basic chat elements
function GlobalChat:AddChatElements(parent, userConfig)
    -- Chat area
    local chatArea = Instance.new("ScrollingFrame")
    chatArea.Name = "ChatArea"
    chatArea.Size = UDim2.new(1, -20, 1, -100)
    chatArea.Position = UDim2.new(0, 10, 0, 50)
    chatArea.BackgroundTransparency = 1
    chatArea.BorderSizePixel = 0
    chatArea.ScrollBarThickness = 8
    chatArea.ScrollBarImageColor3 = ThemeManager:GetCurrentTheme().accent
    chatArea.Parent = parent
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 5)
    chatLayout.Parent = chatArea
    
    -- Input area
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -20, 0, 40)
    inputFrame.Position = UDim2.new(0, 10, 1, -50)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = parent
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -60, 1, 0)
    inputBox.Position = UDim2.new(0, 0, 0, 0)
    inputBox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    inputBox.Text = ""
    inputBox.PlaceholderText = "Type a message..."
    inputBox.TextColor3 = ThemeManager:GetCurrentTheme().text
    inputBox.PlaceholderColor3 = ThemeManager:GetCurrentTheme().textMuted
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = inputFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputBox
    
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 50, 1, 0)
    sendButton.Position = UDim2.new(1, -50, 0, 0)
    sendButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 14
    sendButton.Font = Enum.Font.GothamBold
    sendButton.Parent = inputFrame
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 6)
    sendCorner.Parent = sendButton
    
    -- Send message functionality
    local function sendMessage()
        local message = inputBox.Text
        if message and Utils:Trim(message) ~= "" then
            -- Check rate limit
            local canSend, error = RateLimiter:CanPerformAction(UserManager:GetUserId(), "message")
            if not canSend then
                self:ShowNotification("Rate Limited", error, "error")
                return
            end
            
            -- Send message
            local success, messageId = ChatManager:SendMessage(message)
            if success then
                RateLimiter:RecordAction(UserManager:GetUserId(), "message")
                UserManager:IncrementMessageCount()
                inputBox.Text = ""
                
                -- Add message to chat area
                self:AddMessageToChat(chatArea, {
                    id = messageId,
                    content = message,
                    username = UserManager:GetUsername(),
                    timestamp = os.time(),
                    type = Config.MESSAGE_TYPES.NORMAL
                })
            else
                self:ShowNotification("Send Failed", messageId, "error")
            end
        end
    end
    
    sendButton.MouseButton1Click:Connect(sendMessage)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    -- Welcome message
    self:AddMessageToChat(chatArea, {
        id = "welcome",
        content = "Welcome to Global Executor Chat! 🎉",
        username = "System",
        timestamp = os.time(),
        type = Config.MESSAGE_TYPES.SYSTEM
    })
end

-- Add message to chat area
function GlobalChat:AddMessageToChat(chatArea, messageData)
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "Message_" .. messageData.id
    messageFrame.Size = UDim2.new(1, 0, 0, 0)
    messageFrame.BackgroundTransparency = 1
    messageFrame.LayoutOrder = #chatArea:GetChildren()
    messageFrame.Parent = chatArea
    
    local messageLayout = Instance.new("UIListLayout")
    messageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    messageLayout.Padding = UDim.new(0, 2)
    messageLayout.Parent = messageFrame
    
    -- Username and timestamp
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Name = "Header"
    headerLabel.Size = UDim2.new(1, 0, 0, 20)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = messageData.username .. " • " .. Utils:FormatTimestamp(messageData.timestamp)
    headerLabel.TextColor3 = ThemeManager:GetCurrentTheme().textMuted
    headerLabel.TextSize = 12
    headerLabel.Font = Enum.Font.Gotham
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.LayoutOrder = 1
    headerLabel.Parent = messageFrame
    
    -- Message content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = messageData.content
    contentLabel.TextColor3 = messageData.type == Config.MESSAGE_TYPES.SYSTEM and ThemeManager:GetCurrentTheme().accent or ThemeManager:GetCurrentTheme().text
    contentLabel.TextSize = 14
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.LayoutOrder = 2
    contentLabel.Parent = messageFrame
    
    -- Calculate text height
    local textBounds = Utils:GetTextSize(messageData.content, contentLabel.Font, contentLabel.TextSize, chatArea.AbsoluteSize.X - 20)
    contentLabel.Size = UDim2.new(1, 0, 0, textBounds.Y)
    
    -- Update message frame size
    messageFrame.Size = UDim2.new(1, 0, 0, 25 + textBounds.Y)
    
    -- Update canvas size
    messageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        chatArea.CanvasSize = UDim2.new(0, 0, 0, messageLayout.AbsoluteContentSize.Y)
        chatArea.CanvasPosition = Vector2.new(0, messageLayout.AbsoluteContentSize.Y)
    end)
end

-- Show notification
function GlobalChat:ShowNotification(title, message, type)
    local success, result = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = message;
            Duration = 3;
        })
    end)
    
    if not success then
        print("🔔 " .. title .. ": " .. message)
    end
end

-- Initialize the system
function GlobalChat:Initialize()
    print("🚀 Starting Global Executor Chat Platform...")
    
    -- Show loading screen
    local loadingGui, statusLabel, progressFill = createLoadingScreen()
    
    -- Detect executor and set branding
    local executorName = self:DetectExecutor()
    local brandName = executorName .. "-Global-Chat by BDG Software"
    
    statusLabel.Text = "🎯 Initializing " .. executorName .. "-Global-Chat..."
    
    -- Initialize core systems
    statusLabel.Text = "Loading core modules..."
    progressFill:TweenSize(UDim2.new(0.2, 0, 1, 0), "Out", "Quad", 0.3, true)
    wait(0.3)
    
    Config:Initialize(brandName)
    Utils:Initialize()
    
    statusLabel.Text = "Loading managers..."
    progressFill:TweenSize(UDim2.new(0.4, 0, 1, 0), "Out", "Quad", 0.3, true)
    wait(0.3)
    
    ThemeManager:Initialize()
    UserManager:Initialize()
    
    statusLabel.Text = "Loading chat system..."
    progressFill:TweenSize(UDim2.new(0.6, 0, 1, 0), "Out", "Quad", 0.3, true)
    wait(0.3)
    
    RateLimiter:Initialize()
    NetworkManager:Initialize()
    
    statusLabel.Text = "Loading features..."
    progressFill:TweenSize(UDim2.new(0.8, 0, 1, 0), "Out", "Quad", 0.3, true)
    wait(0.3)
    
    NotificationManager:Initialize()
    EmojiManager:Initialize()
    
    statusLabel.Text = "Finalizing..."
    progressFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.3, true)
    wait(0.3)
    
    statusLabel.Text = "✅ All modules loaded successfully!"
    statusLabel.TextColor3 = Color3.fromRGB(67, 181, 129)
    wait(1)
    
    -- Start setup process
    self:StartSetupProcess(loadingGui)
end

-- Start setup process
function GlobalChat:StartSetupProcess(loadingGui)
    -- Check if user has existing configuration and authentication
    local existingConfig = UserManager:GetUserConfig()
    local authToken = UserManager:GetAuthToken()
    
    if existingConfig and existingConfig.setupComplete and authToken then
        -- User has completed setup and is authenticated, load directly
        loadingGui:Destroy()
        self:LoadChatInterface(existingConfig)
    else
        -- Start setup flow: Platform → Country → Language → Authentication
        loadingGui:Destroy()
        self:ShowPlatformSelection()
    end
end

--- Show platform selection screen
function GlobalChat:ShowPlatformSelection()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatPlatformSelection"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "PlatformContainer"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Global Executor Chat"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 40)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "What device are you using?"
    subtitle.TextColor3 = ThemeManager:GetCurrentTheme().textMuted
    subtitle.TextSize = 18
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = mainFrame

    -- Mobile button
    local mobileButton = Instance.new("TextButton")
    mobileButton.Name = "MobileButton"
    mobileButton.Size = UDim2.new(0, 200, 0, 80)
    mobileButton.Position = UDim2.new(0.5, -100, 0, 140)
    mobileButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    mobileButton.BorderSizePixel = 1
    mobileButton.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    mobileButton.Text = "📱 Mobile"
    mobileButton.TextColor3 = ThemeManager:GetCurrentTheme().text
    mobileButton.TextSize = 20
    mobileButton.Font = Enum.Font.GothamBold
    mobileButton.Parent = mainFrame

    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 8)
    mobileCorner.Parent = mobileButton

    -- PC button
    local pcButton = Instance.new("TextButton")
    pcButton.Name = "PCButton"
    pcButton.Size = UDim2.new(0, 200, 0, 80)
    pcButton.Position = UDim2.new(0.5, -100, 0, 240)
    pcButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    pcButton.BorderSizePixel = 1
    pcButton.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    pcButton.Text = "💻 PC"
    pcButton.TextColor3 = ThemeManager:GetCurrentTheme().text
    pcButton.TextSize = 20
    pcButton.Font = Enum.Font.GothamBold
    pcButton.Parent = mainFrame

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 8)
    pcCorner.Parent = pcButton

    -- Button hover effects
    local function addHoverEffect(button)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
            button.TextColor3 = ThemeManager:GetCurrentTheme().text
        end)
    end

    addHoverEffect(mobileButton)
    addHoverEffect(pcButton)

    -- Add entrance animation
    mainFrame.Position = UDim2.new(0.5, -250, 1.5, -200)
    local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -250, 0.5, -200)
    })
    entranceTween:Play()

    -- Event handlers
    mobileButton.MouseButton1Click:Connect(function()
        UserManager:SetUserPlatform("Mobile")
        
        -- Exit animation
        local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -250, -0.5, -200)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            screenGui:Destroy()
            self:ShowCountrySelectionScreen()
        end)
    end)

    pcButton.MouseButton1Click:Connect(function()
        UserManager:SetUserPlatform("PC")
        
        -- Exit animation
        local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -250, -0.5, -200)
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            screenGui:Destroy()
            self:ShowCountrySelectionScreen()
        end)
    end)
end

--- Show country selection screen
function GlobalChat:ShowCountrySelectionScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatCountrySelection"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CountryContainer"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Country"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -40, 0, 40)
    searchBox.Position = UDim2.new(0, 20, 0, 70)
    searchBox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    searchBox.BorderSizePixel = 1
    searchBox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    searchBox.Text = ""
    searchBox.PlaceholderText = "🔍 Search countries..."
    searchBox.TextColor3 = ThemeManager:GetCurrentTheme().text
    searchBox.PlaceholderColor3 = ThemeManager:GetCurrentTheme().textMuted
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = mainFrame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox

    -- Countries scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "CountriesScroll"
    scrollFrame.Size = UDim2.new(1, -40, 1, -180)
    scrollFrame.Position = UDim2.new(0, 20, 0, 120)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = ThemeManager:GetCurrentTheme().accent
    scrollFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame

    -- Create country buttons
    local countryButtons = {}
    for i, country in ipairs(Config.COUNTRIES) do
        local countryButton = Instance.new("TextButton")
        countryButton.Name = "Country_" .. country.code
        countryButton.Size = UDim2.new(1, -16, 0, 50)
        countryButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
        countryButton.BorderSizePixel = 1
        countryButton.BorderColor3 = ThemeManager:GetCurrentTheme().accent
        countryButton.Text = country.flag .. " " .. country.name
        countryButton.TextColor3 = ThemeManager:GetCurrentTheme().text
        countryButton.TextSize = 16
        countryButton.Font = Enum.Font.Gotham
        countryButton.TextXAlignment = Enum.TextXAlignment.Left
        countryButton.LayoutOrder = i
        countryButton.Parent = scrollFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = countryButton

        -- Add padding
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = countryButton

        -- Hover effect
        countryButton.MouseEnter:Connect(function()
            countryButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
            countryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        countryButton.MouseLeave:Connect(function()
            countryButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
            countryButton.TextColor3 = ThemeManager:GetCurrentTheme().text
        end)

        -- Click handler
        countryButton.MouseButton1Click:Connect(function()
            UserManager:SetUserCountry(country.code)
            
            -- Exit animation
            local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -300, -0.5, -250)
            })
            exitTween:Play()
            exitTween.Completed:Connect(function()
                screenGui:Destroy()
                self:ShowLanguageSelectionScreen(country.code)
            end)
        end)

        table.insert(countryButtons, {button = countryButton, country = country})
    end

    -- Search functionality
    searchBox.Changed:Connect(function()
        local searchText = searchBox.Text:lower()
        for _, countryData in ipairs(countryButtons) do
            local countryName = countryData.country.name:lower()
            local isVisible = searchText == "" or countryName:find(searchText, 1, true)
            countryData.button.Visible = isVisible
        end
    end)

    -- Update scroll canvas size
    layout.Changed:Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    -- Add entrance animation
    mainFrame.Position = UDim2.new(0.5, -300, 1.5, -250)
    local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -300, 0.5, -250)
    })
    entranceTween:Play()
end

--- Show language selection screen
function GlobalChat:ShowLanguageSelectionScreen(countryCode)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatLanguageSelection"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "LanguageContainer"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Language"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

    -- Get languages for selected country
    local selectedCountry = Config:GetCountryByCode(countryCode)
    local languages = selectedCountry and selectedCountry.languages or {"English"}

    -- Languages container
    local languagesFrame = Instance.new("Frame")
    languagesFrame.Name = "LanguagesFrame"
    languagesFrame.Size = UDim2.new(1, -40, 1, -120)
    languagesFrame.Position = UDim2.new(0, 20, 0, 80)
    languagesFrame.BackgroundTransparency = 1
    languagesFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = languagesFrame

    -- Create language buttons
    for i, language in ipairs(languages) do
        local langButton = Instance.new("TextButton")
        langButton.Name = "Language_" .. language
        langButton.Size = UDim2.new(0, 300, 0, 60)
        langButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
        langButton.BorderSizePixel = 1
        langButton.BorderColor3 = ThemeManager:GetCurrentTheme().accent
        langButton.Text = language
        langButton.TextColor3 = ThemeManager:GetCurrentTheme().text
        langButton.TextSize = 18
        langButton.Font = Enum.Font.GothamBold
        langButton.LayoutOrder = i
        langButton.Parent = languagesFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = langButton

        -- Hover effect
        langButton.MouseEnter:Connect(function()
            langButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
            langButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        langButton.MouseLeave:Connect(function()
            langButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
            langButton.TextColor3 = ThemeManager:GetCurrentTheme().text
        end)

        -- Click handler
        langButton.MouseButton1Click:Connect(function()
            UserManager:SetUserLanguage(language)
            
            -- Exit animation
            local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -250, -0.5, -200)
            })
            exitTween:Play()
            exitTween.Completed:Connect(function()
                screenGui:Destroy()
                self:ShowAuthenticationScreen()
            end)
        end)
    end

    -- Add entrance animation
    mainFrame.Position = UDim2.new(0.5, -250, 1.5, -200)
    local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -250, 0.5, -200)
    })
    entranceTween:Play()
end

-- Show setup wizard
function GlobalChat:ShowSetupWizard()
    local setupUI = self:CreateSetupWizard()
    
    -- Step 1: Platform Detection
    local platform = self:DetectPlatform()
    UserManager:SetUserPlatform(platform)
    
    -- Step 2: Country Selection
    self:ShowCountrySelection(setupUI, function(selectedCountry)
        UserManager:SetUserCountry(selectedCountry)
        
        -- Step 3: Language Selection
        self:ShowLanguageSelection(setupUI, selectedCountry, function(selectedLanguage)
            UserManager:SetUserLanguage(selectedLanguage)
            
            -- Step 4: Theme Selection
            self:ShowThemeSelection(setupUI, function(selectedTheme)
                UserManager:SetUserTheme(selectedTheme)
                ThemeManager:SetTheme(selectedTheme)
                
                -- Complete setup
                UserManager:CompleteSetup()
                setupUI.gui:Destroy()
                
                -- Load chat interface
                local userConfig = UserManager:GetUserConfig()
                self:LoadChatInterface(userConfig)
            end)
        end)
    end)
end

-- Show country selection
function GlobalChat:ShowCountrySelection(setupUI, callback)
    -- Clear content
    for _, child in pairs(setupUI.contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = setupUI.contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    -- Add countries
    for i, country in ipairs(Config.COUNTRIES) do
        local countryButton = Instance.new("TextButton")
        countryButton.Size = UDim2.new(1, -10, 0, 40)
        countryButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
        countryButton.BorderSizePixel = 0
        countryButton.Text = country.flag .. " " .. country.name
        countryButton.TextColor3 = ThemeManager:GetCurrentTheme().text
        countryButton.TextSize = 16
        countryButton.Font = Enum.Font.Gotham
        countryButton.Parent = scrollFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = countryButton
        
        countryButton.MouseButton1Click:Connect(function()
            callback(country.code)
        end)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
end

-- Show language selection
function GlobalChat:ShowLanguageSelection(setupUI, countryCode, callback)
    -- Clear content
    for _, child in pairs(setupUI.contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    local languages = Config:GetLanguagesForCountry(countryCode)
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = setupUI.contentFrame
    
    for i, language in ipairs(languages) do
        local langButton = Instance.new("TextButton")
        langButton.Size = UDim2.new(0, 200, 0, 50)
        langButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
        langButton.BorderSizePixel = 0
        langButton.Text = language
        langButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        langButton.TextSize = 18
        langButton.Font = Enum.Font.GothamBold
        langButton.Parent = setupUI.contentFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = langButton
        
        langButton.MouseButton1Click:Connect(function()
            callback(language)
        end)
    end
end

-- Show theme selection
function GlobalChat:ShowThemeSelection(setupUI, callback)
    -- Clear content
    for _, child in pairs(setupUI.contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0, 120, 0, 80)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = setupUI.contentFrame
    
    local themes = {"Dark", "Light", "AMOLED", "Synthwave", "Ocean"}
    
    for i, themeName in ipairs(themes) do
        local theme = Config:GetThemeByName(themeName)
        
        local themeButton = Instance.new("TextButton")
        themeButton.Size = UDim2.new(0, 110, 0, 70)
        themeButton.BackgroundColor3 = theme.primary
        themeButton.BorderSizePixel = 2
        themeButton.BorderColor3 = theme.accent
        themeButton.Text = themeName
        themeButton.TextColor3 = theme.text
        themeButton.TextSize = 14
        themeButton.Font = Enum.Font.GothamBold
        themeButton.Parent = setupUI.contentFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = themeButton
        
        themeButton.MouseButton1Click:Connect(function()
            callback(themeName)
        end)
    end
end

-- Load chat interface
function GlobalChat:LoadChatInterface(userConfig)
    if not userConfig then
        userConfig = {
            platform = self:DetectPlatform(),
            country = "US",
            language = "English",
            theme = "Dark",
            setupComplete = true
        }
    end
    
    print("🚀 Loading chat interface for platform: " .. userConfig.platform)
    
    -- Initialize chat manager with user config
    ChatManager:Initialize(userConfig)
    
    -- Create chat interface
    local chatInterface = self:CreateSimpleChatInterface(userConfig)
    
    -- Connect to server with authentication token
    local authToken = UserManager:GetAuthToken()
    NetworkManager:ConnectToServer(Config.SERVER_URL, authToken or UserManager:GetSessionId())
    
    local executorName = self:DetectExecutor()
    print("✅ " .. executorName .. "-Global-Chat by BDG Software loaded successfully!")
    print("📱 Platform: " .. userConfig.platform)
    print("🌍 Country: " .. userConfig.country)
    print("🗣️ Language: " .. userConfig.language)
    print("🎨 Theme: " .. userConfig.theme)
    
    -- Show welcome notification
    NotificationManager:ShowSystemNotification({
        content = "Welcome to Global Executor Chat! You're now connected to the " .. userConfig.language .. " server.",
        username = "System",
        timestamp = os.time(),
        type = Config.MESSAGE_TYPES.SYSTEM
    })
end

-- Show authentication screen
function GlobalChat:ShowAuthenticationScreen()
    -- Check for saved credentials first
    local savedCredentials = UserManager:GetSavedCredentials()
    if savedCredentials then
        print("🔑 Found saved credentials for user: " .. savedCredentials.username)
        
        -- Attempt auto-login with saved credentials
        local function attemptAutoLogin()
            -- Set up auth response handler
            NetworkManager:On("onAuthResponse", function(success, data)
                if success then
                    print("✅ Auto-login successful!")
                    UserManager:LoginSuccess(data)
                    
                    -- Setup should already be complete, load chat interface
                    UserManager:CompleteSetup()
                    local userConfig = UserManager:GetUserConfig()
                    GlobalChat:LoadChatInterface(userConfig)
                else
                    print("❌ Auto-login failed, showing login screen")
                    -- Clear saved credentials as they might be invalid
                    UserManager:ClearSavedCredentials()
                    -- Show the regular login screen
                    GlobalChat:ShowAuthenticationScreen()
                end
            end)
            
            -- Send authentication request
            NetworkManager:SendAuthRequest(savedCredentials.username, savedCredentials.password, false)
        end
        
        -- Try auto-login
        spawn(attemptAutoLogin)
        return
    end
    
    -- Regular authentication screen if no saved credentials
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlobalChatAuth"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "AuthContainer"
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = ThemeManager:GetCurrentTheme().primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Global Executor Chat"
    title.TextColor3 = ThemeManager:GetCurrentTheme().text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 40)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Sign in or create an account to continue"
    subtitle.TextColor3 = ThemeManager:GetCurrentTheme().textMuted
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = mainFrame
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -60, 1, -180)
    contentFrame.Position = UDim2.new(0, 30, 0, 120)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Username input
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, 0, 0, 30)
    usernameLabel.Position = UDim2.new(0, 0, 0, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "Username:"
    usernameLabel.TextColor3 = ThemeManager:GetCurrentTheme().text
    usernameLabel.TextSize = 16
    usernameLabel.Font = Enum.Font.GothamSemibold
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = contentFrame
    
    local usernameBox = Instance.new("TextBox")
    usernameBox.Name = "UsernameBox"
    usernameBox.Size = UDim2.new(1, 0, 0, 50)
    usernameBox.Position = UDim2.new(0, 0, 0, 35)
    usernameBox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    usernameBox.BorderSizePixel = 1
    usernameBox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    usernameBox.Text = ""
    usernameBox.PlaceholderText = "Enter your username"
    usernameBox.TextColor3 = ThemeManager:GetCurrentTheme().text
    usernameBox.PlaceholderColor3 = ThemeManager:GetCurrentTheme().textMuted
    usernameBox.TextSize = 16
    usernameBox.Font = Enum.Font.Gotham
    usernameBox.Parent = contentFrame
    
    local usernameCorner = Instance.new("UICorner")
    usernameCorner.CornerRadius = UDim.new(0, 8)
    usernameCorner.Parent = usernameBox
    
    -- Password input
    local passwordLabel = Instance.new("TextLabel")
    passwordLabel.Size = UDim2.new(1, 0, 0, 30)
    passwordLabel.Position = UDim2.new(0, 0, 0, 100)
    passwordLabel.BackgroundTransparency = 1
    passwordLabel.Text = "Password:"
    passwordLabel.TextColor3 = ThemeManager:GetCurrentTheme().text
    passwordLabel.TextSize = 16
    passwordLabel.Font = Enum.Font.GothamSemibold
    passwordLabel.TextXAlignment = Enum.TextXAlignment.Left
    passwordLabel.Parent = contentFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, 0, 0, 50)
    passwordBox.Position = UDim2.new(0, 0, 0, 135)
    passwordBox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    passwordBox.BorderSizePixel = 1
    passwordBox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    passwordBox.Text = ""
    passwordBox.PlaceholderText = "Enter your password"
    passwordBox.TextColor3 = ThemeManager:GetCurrentTheme().text
    passwordBox.PlaceholderColor3 = ThemeManager:GetCurrentTheme().textMuted
    passwordBox.TextSize = 16
    passwordBox.Font = Enum.Font.Gotham
    passwordBox.TextScaled = false
    passwordBox.Parent = contentFrame
    
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, 8)
    passwordCorner.Parent = passwordBox
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = contentFrame
    
    -- Remember Me checkbox
    local rememberMeFrame = Instance.new("Frame")
    rememberMeFrame.Name = "RememberMeFrame"
    rememberMeFrame.Size = UDim2.new(1, 0, 0, 30)
    rememberMeFrame.Position = UDim2.new(0, 0, 0, 200)
    rememberMeFrame.BackgroundTransparency = 1
    rememberMeFrame.Parent = contentFrame
    
    local rememberMeCheckbox = Instance.new("ImageButton")
    rememberMeCheckbox.Name = "RememberMeCheckbox"
    rememberMeCheckbox.Size = UDim2.new(0, 20, 0, 20)
    rememberMeCheckbox.Position = UDim2.new(0, 0, 0, 5)
    rememberMeCheckbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rememberMeCheckbox.BorderSizePixel = 0
    rememberMeCheckbox.Parent = rememberMeFrame
    
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = rememberMeCheckbox
    
    local checkmark = Instance.new("ImageLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
    checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://6031094667" -- Checkmark icon
    checkmark.ImageColor3 = ThemeManager:GetCurrentTheme().accent
    checkmark.Visible = false
    checkmark.Parent = rememberMeCheckbox
    
    local rememberMeLabel = Instance.new("TextLabel")
    rememberMeLabel.Name = "RememberMeLabel"
    rememberMeLabel.Size = UDim2.new(0, 200, 0, 20)
    rememberMeLabel.Position = UDim2.new(0, 30, 0, 5)
    rememberMeLabel.BackgroundTransparency = 1
    rememberMeLabel.Text = "Remember me on this device"
    rememberMeLabel.TextColor3 = ThemeManager:GetCurrentTheme().textPrimary
    rememberMeLabel.TextSize = 14
    rememberMeLabel.Font = Enum.Font.Gotham
    rememberMeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rememberMeLabel.Parent = rememberMeFrame
    
    -- Remember Me toggle functionality
    local rememberMeEnabled = false
    rememberMeCheckbox.MouseButton1Click:Connect(function()
        rememberMeEnabled = not rememberMeEnabled
        checkmark.Visible = rememberMeEnabled
    end)
    
    -- Login button
    local loginButton = Instance.new("TextButton")
    loginButton.Name = "LoginButton"
    loginButton.Size = UDim2.new(0.48, 0, 0, 50)
    loginButton.Position = UDim2.new(0, 0, 0, 240)
    loginButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().accent
    loginButton.BorderSizePixel = 0
    loginButton.Text = "🔑 Sign In"
    loginButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginButton.TextSize = 18
    loginButton.Font = Enum.Font.GothamBold
    loginButton.Parent = contentFrame
    
    local loginCorner = Instance.new("UICorner")
    loginCorner.CornerRadius = UDim.new(0, 8)
    loginCorner.Parent = loginButton
    
    -- Register button
    local registerButton = Instance.new("TextButton")
    registerButton.Name = "RegisterButton"
    registerButton.Size = UDim2.new(0.48, 0, 0, 50)
    registerButton.Position = UDim2.new(0.52, 0, 0, 240)
    registerButton.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    registerButton.BorderSizePixel = 1
    registerButton.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    registerButton.Text = "✨ Create Account"
    registerButton.TextColor3 = ThemeManager:GetCurrentTheme().text
    registerButton.TextSize = 18
    registerButton.Font = Enum.Font.GothamBold
    registerButton.Parent = contentFrame
    
    local registerCorner = Instance.new("UICorner")
    registerCorner.CornerRadius = UDim.new(0, 8)
    registerCorner.Parent = registerButton
    
    -- Remember Me checkbox
    local rememberMeFrame = Instance.new("Frame")
    rememberMeFrame.Name = "RememberMeFrame"
    rememberMeFrame.Size = UDim2.new(1, 0, 0, 30)
    rememberMeFrame.Position = UDim2.new(0, 0, 0, 300)
    rememberMeFrame.BackgroundTransparency = 1
    rememberMeFrame.Parent = contentFrame
    
    local rememberMeCheckbox = Instance.new("TextButton")
    rememberMeCheckbox.Name = "RememberMeCheckbox"
    rememberMeCheckbox.Size = UDim2.new(0, 20, 0, 20)
    rememberMeCheckbox.Position = UDim2.new(0, 0, 0.5, -10)
    rememberMeCheckbox.BackgroundColor3 = ThemeManager:GetCurrentTheme().secondary
    rememberMeCheckbox.BorderSizePixel = 1
    rememberMeCheckbox.BorderColor3 = ThemeManager:GetCurrentTheme().accent
    rememberMeCheckbox.Text = ""
    rememberMeCheckbox.Parent = rememberMeFrame
    
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = rememberMeCheckbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = ThemeManager:GetCurrentTheme().accent
    checkmark.TextSize = 16
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = false
    checkmark.Parent = rememberMeCheckbox
    
    local rememberMeLabel = Instance.new("TextLabel")
    rememberMeLabel.Name = "RememberMeLabel"
    rememberMeLabel.Size = UDim2.new(1, -30, 1, 0)
    rememberMeLabel.Position = UDim2.new(0, 30, 0, 0)
    rememberMeLabel.BackgroundTransparency = 1
    rememberMeLabel.Text = "Remember Me"
    rememberMeLabel.TextColor3 = ThemeManager:GetCurrentTheme().text
    rememberMeLabel.TextSize = 14
    rememberMeLabel.Font = Enum.Font.Gotham
    rememberMeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rememberMeLabel.Parent = rememberMeFrame
    
    -- Remember Me state
    local rememberMeEnabled = false
    
    rememberMeCheckbox.MouseButton1Click:Connect(function()
        rememberMeEnabled = not rememberMeEnabled
        checkmark.Visible = rememberMeEnabled
    end)
    
    -- Skip button (for offline mode)
    local skipButton = Instance.new("TextButton")
    skipButton.Name = "SkipButton"
    skipButton.Size = UDim2.new(1, 0, 0, 40)
    skipButton.Position = UDim2.new(0, 0, 0, 340)
    skipButton.BackgroundTransparency = 1
    skipButton.Text = "Continue without account (Limited features)"
    skipButton.TextColor3 = ThemeManager:GetCurrentTheme().textMuted
    skipButton.TextSize = 14
    skipButton.Font = Enum.Font.Gotham
    skipButton.Parent = contentFrame
    
    -- Event handlers
    local function showStatus(message, isError)
        statusLabel.Text = message
        statusLabel.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    end
    
    local function performAuth(isSignup)
        local username = usernameBox.Text:gsub("%s+", "")
        local password = passwordBox.Text
        
        if username == "" or password == "" then
            showStatus("Please enter both username and password", true)
            return
        end
        
        if username:len() < 3 then
            showStatus("Username must be at least 3 characters", true)
            return
        end
        
        if password:len() < 6 then
            showStatus("Password must be at least 6 characters", true)
            return
        end
        
        showStatus("Authenticating...", false)
        loginButton.Text = "Signing In..."
        registerButton.Text = "Creating Account..."
        
        -- Set up auth response handler
        NetworkManager:On("onAuthResponse", function(success, data)
            if success then
                showStatus("Authentication successful!", false)
                
                -- Save credentials if "Remember Me" is checked and not signing up
                if rememberMeEnabled and not isSignup then
                    UserManager:SaveCredentials(username, password, true)
                end
                
                UserManager:LoginSuccess(data)
                
                -- Setup should already be complete, load chat interface
                UserManager:CompleteSetup()
                screenGui:Destroy()
                local userConfig = UserManager:GetUserConfig()
                GlobalChat:LoadChatInterface(userConfig)
            else
                showStatus("Error: " .. tostring(data), true)
                loginButton.Text = "🔑 Sign In"
                registerButton.Text = "✨ Create Account"
            end
        end)
        
        -- Send auth request
        NetworkManager:SendAuthRequest(username, password, isSignup)
    end
    
    loginButton.MouseButton1Click:Connect(function()
        performAuth(false)
    end)
    
    registerButton.MouseButton1Click:Connect(function()
        performAuth(true)
    end)
    
    skipButton.MouseButton1Click:Connect(function()
        -- Continue without authentication (limited features)
        screenGui:Destroy()
        -- Set default values and load chat interface
        UserManager:SetUserPlatform(GlobalChat:DetectPlatform())
        UserManager:SetUserCountry("US")
        UserManager:SetUserLanguage("English")
        UserManager:CompleteSetup()
        local userConfig = UserManager:GetUserConfig()
        GlobalChat:LoadChatInterface(userConfig)
    end)
    
    -- Enter key support
    usernameBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            passwordBox:CaptureFocus()
        end
    end)
    
    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            performAuth(false)
        end
    end)
    
    -- Add entrance animation
    mainFrame.Position = UDim2.new(0.5, -250, 1.5, -300)
    local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -250, 0.5, -300)
    })
    entranceTween:Play()

    -- Focus username box initially after animation
    entranceTween.Completed:Connect(function()
        usernameBox:CaptureFocus()
    end)
end

-- Cleanup function
function GlobalChat:Cleanup()
    print("🔄 Shutting down Global Executor Chat Platform...")
    
    -- Cleanup all modules
    if ChatManager and ChatManager.Cleanup then ChatManager:Cleanup() end
    if NetworkManager and NetworkManager.Cleanup then NetworkManager:Cleanup() end
    if NotificationManager and NotificationManager.Cleanup then NotificationManager:Cleanup() end
    if RateLimiter and RateLimiter.Cleanup then RateLimiter:Cleanup() end
    if EmojiManager and EmojiManager.Cleanup then EmojiManager:Cleanup() end
    if UserManager and UserManager.Cleanup then UserManager:Cleanup() end
    if Utils and Utils.Cleanup then Utils:Cleanup() end
    
    print("✅ Shutdown complete")
end

-- Store modules for external access
GlobalChat.modules = {
    Config = Config,
    Utils = Utils,
    ThemeManager = ThemeManager,
    UserManager = UserManager,
    ChatManager = ChatManager,
    NetworkManager = NetworkManager,
    NotificationManager = NotificationManager,
    RateLimiter = RateLimiter,
    EmojiManager = EmojiManager
}

-- Auto-initialize when script is loaded
-- Check for saved credentials first
local savedCredentials = UserManager:GetSavedCredentials()
if savedCredentials then
    print("🔄 Found saved credentials for user: " .. savedCredentials.username)
    print("🔑 Attempting auto-login...")
end

GlobalChat:Initialize()

-- Return the main object for external access
return GlobalChat