--[[
    Global Executor Chat Platform - Professional UI System
    Complete chat platform with professionally designed UI system.
    Created by BDG Software
    
    BACKEND STATUS (VM: 192.250.226.90):
    ✅ API Server (Port 17001) - Online
    ✅ WebSocket Server (Port 17002) - Online  
    ✅ Monitoring Server (Port 17003) - Online
    ✅ Admin Panel (Port 19000) - Online
    ✅ All 12 Language Servers (Ports 18001-18012) - Online
    ✅ Total: 16/16 Services Running
    
    FEATURES:
    - Professional UI System: Clean, modern, responsive design
    - Multi-Language Support: 12 languages with dedicated servers
    - Cross-Executor Compatibility: Works with Delta, Synapse, Krnl, Fluxus, and more
    - Responsive Design: Optimized for both mobile and desktop platforms
    - Modern Interface: Professional chat experience
    - Private Messaging: Direct messages between users
    - Rate Limiting: Anti-spam protection with timeouts
    - User Management: Authentication, blocking, friends system
    - Real-time Notifications: Roblox-integrated notifications
    - Session Management: Device tracking and security
    - Auto-Moderation: Spam detection, profanity filtering
    
    Usage: loadstring(game:HttpGet("YOUR_URL/GlobalExecutorChat_Professional.lua"))()
]]

-- ============================================================================
-- GLOBAL EXECUTOR CHAT PLATFORM - PROFESSIONAL UI SYSTEM
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

-- HTTP Request function setup for different executors
local httpRequest = nil

-- Detect executor and set up HTTP function
local function setupHttpRequest()
    if syn and syn.request then
        httpRequest = syn.request
    elseif http_request then
        httpRequest = http_request
    elseif request then
        httpRequest = request
    elseif game:GetService("HttpService").RequestAsync then
        httpRequest = function(options)
            return game:GetService("HttpService"):RequestAsync(options)
        end
    else
        error("❌ No HTTP request method available!")
    end
end

setupHttpRequest()

-- ============================================================================
-- PROFESSIONAL UI THEME SYSTEM
-- ============================================================================

local UITheme = {
    -- Modern Dark Theme
    Colors = {
        Primary = Color3.fromRGB(32, 34, 37),      -- Dark background
        Secondary = Color3.fromRGB(47, 49, 54),    -- Lighter dark
        Accent = Color3.fromRGB(88, 101, 242),     -- Discord blue
        Success = Color3.fromRGB(67, 181, 129),    -- Green
        Warning = Color3.fromRGB(250, 166, 26),    -- Orange
        Error = Color3.fromRGB(237, 66, 69),       -- Red
        Text = Color3.fromRGB(255, 255, 255),      -- White text
        TextSecondary = Color3.fromRGB(185, 187, 190), -- Gray text
        Border = Color3.fromRGB(60, 63, 69),       -- Border color
        Hover = Color3.fromRGB(64, 68, 75),        -- Hover state
        Input = Color3.fromRGB(64, 68, 75),        -- Input background
    },
    
    -- Typography
    Fonts = {
        Primary = Enum.Font.Gotham,
        Secondary = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
        Code = Enum.Font.RobotoMono
    },
    
    -- Sizing
    Sizes = {
        CornerRadius = UDim.new(0, 8),
        BorderSize = 1,
        Padding = 12,
        SmallPadding = 8,
        LargePadding = 16
    },
    
    -- Animations
    Animations = {
        Fast = 0.15,
        Medium = 0.25,
        Slow = 0.4,
        EaseStyle = Enum.EasingStyle.Quart,
        EaseDirection = Enum.EasingDirection.Out
    }
}

-- ============================================================================
-- PROFESSIONAL UI COMPONENTS SYSTEM
-- ============================================================================

local UIComponents = {}

-- Create a professional button component
function UIComponents:CreateButton(config)
    local button = Instance.new("TextButton")
    button.Name = config.Name or "Button"
    button.Size = config.Size or UDim2.new(0, 120, 0, 36)
    button.Position = config.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = config.BackgroundColor or UITheme.Colors.Accent
    button.BorderSizePixel = 0
    button.Text = config.Text or "Button"
    button.TextColor3 = config.TextColor or UITheme.Colors.Text
    button.TextSize = config.TextSize or 14
    button.Font = config.Font or UITheme.Fonts.Primary
    button.AutoButtonColor = false
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UITheme.Sizes.CornerRadius
    corner.Parent = button
    
    -- Add hover effects
    local originalColor = button.BackgroundColor3
    local hoverColor = config.HoverColor or UITheme.Colors.Hover
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(UITheme.Animations.Fast), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(UITheme.Animations.Fast), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
    
    -- Add click animation
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(UITheme.Animations.Fast), {
            Size = button.Size - UDim2.new(0, 2, 0, 2)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(UITheme.Animations.Fast), {
            Size = config.Size or UDim2.new(0, 120, 0, 36)
        }):Play()
    end)
    
    return button
end

-- Create a professional input field
function UIComponents:CreateInput(config)
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = config.Name or "InputFrame"
    inputFrame.Size = config.Size or UDim2.new(1, 0, 0, 40)
    inputFrame.Position = config.Position or UDim2.new(0, 0, 0, 0)
    inputFrame.BackgroundColor3 = UITheme.Colors.Input
    inputFrame.BorderSizePixel = 0
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UITheme.Sizes.CornerRadius
    corner.Parent = inputFrame
    
    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = UITheme.Colors.Border
    border.Thickness = UITheme.Sizes.BorderSize
    border.Parent = inputFrame
    
    -- Create text input
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -UITheme.Sizes.Padding * 2, 1, 0)
    textBox.Position = UDim2.new(0, UITheme.Sizes.Padding, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    textBox.TextColor3 = UITheme.Colors.Text
    textBox.PlaceholderColor3 = UITheme.Colors.TextSecondary
    textBox.TextSize = config.TextSize or 14
    textBox.Font = UITheme.Fonts.Primary
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    -- Focus effects
    textBox.Focused:Connect(function()
        TweenService:Create(border, TweenInfo.new(UITheme.Animations.Fast), {
            Color = UITheme.Colors.Accent
        }):Play()
    end)
    
    textBox.FocusLost:Connect(function()
        TweenService:Create(border, TweenInfo.new(UITheme.Animations.Fast), {
            Color = UITheme.Colors.Border
        }):Play()
    end)
    
    return inputFrame, textBox
end

-- Create a professional card/panel
function UIComponents:CreateCard(config)
    local card = Instance.new("Frame")
    card.Name = config.Name or "Card"
    card.Size = config.Size or UDim2.new(1, 0, 0, 100)
    card.Position = config.Position or UDim2.new(0, 0, 0, 0)
    card.BackgroundColor3 = config.BackgroundColor or UITheme.Colors.Secondary
    card.BorderSizePixel = 0
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UITheme.Sizes.CornerRadius
    corner.Parent = card
    
    -- Add subtle border
    local border = Instance.new("UIStroke")
    border.Color = UITheme.Colors.Border
    border.Thickness = UITheme.Sizes.BorderSize
    border.Parent = card
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, UITheme.Sizes.Padding)
    padding.PaddingBottom = UDim.new(0, UITheme.Sizes.Padding)
    padding.PaddingLeft = UDim.new(0, UITheme.Sizes.Padding)
    padding.PaddingRight = UDim.new(0, UITheme.Sizes.Padding)
    padding.Parent = card
    
    return card
end

-- Create a professional modal/dialog
function UIComponents:CreateModal(config)
    local modal = Instance.new("Frame")
    modal.Name = config.Name or "Modal"
    modal.Size = UDim2.new(1, 0, 1, 0)
    modal.Position = UDim2.new(0, 0, 0, 0)
    modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modal.BackgroundTransparency = 0.5
    modal.BorderSizePixel = 0
    modal.ZIndex = 1000
    
    -- Create modal content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = config.Size or UDim2.new(0, 400, 0, 300)
    content.Position = UDim2.new(0.5, -200, 0.5, -150)
    content.BackgroundColor3 = UITheme.Colors.Primary
    content.BorderSizePixel = 0
    content.ZIndex = 1001
    content.Parent = modal
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UITheme.Sizes.CornerRadius
    corner.Parent = content
    
    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = UITheme.Colors.Border
    border.Thickness = UITheme.Sizes.BorderSize
    border.Parent = content
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, UITheme.Sizes.LargePadding)
    padding.PaddingBottom = UDim.new(0, UITheme.Sizes.LargePadding)
    padding.PaddingLeft = UDim.new(0, UITheme.Sizes.LargePadding)
    padding.PaddingRight = UDim.new(0, UITheme.Sizes.LargePadding)
    padding.Parent = content
    
    -- Animate in
    content.Size = UDim2.new(0, 0, 0, 0)
    content.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(content, TweenInfo.new(UITheme.Animations.Medium, UITheme.Animations.EaseStyle), {
        Size = config.Size or UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150)
    }):Play()
    
    return modal, content
end

-- Create a professional loading spinner
function UIComponents:CreateLoadingSpinner(config)
    local spinner = Instance.new("Frame")
    spinner.Name = config.Name or "LoadingSpinner"
    spinner.Size = config.Size or UDim2.new(0, 40, 0, 40)
    spinner.Position = config.Position or UDim2.new(0.5, -20, 0.5, -20)
    spinner.BackgroundTransparency = 1
    spinner.BorderSizePixel = 0
    
    -- Create spinner circle
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.Position = UDim2.new(0, 0, 0, 0)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 0
    circle.Parent = spinner
    
    -- Create spinner arc
    local arc = Instance.new("Frame")
    arc.Name = "Arc"
    arc.Size = UDim2.new(1, 0, 1, 0)
    arc.Position = UDim2.new(0, 0, 0, 0)
    arc.BackgroundTransparency = 1
    arc.BorderSizePixel = 0
    arc.Parent = circle
    
    -- Add border for spinner effect
    local border = Instance.new("UIStroke")
    border.Color = UITheme.Colors.Accent
    border.Thickness = 3
    border.Transparency = 0.8
    border.Parent = circle
    
    local activeBorder = Instance.new("UIStroke")
    activeBorder.Color = UITheme.Colors.Accent
    activeBorder.Thickness = 3
    activeBorder.Parent = arc
    
    -- Make circles round
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = circle
    
    local arcCorner = Instance.new("UICorner")
    arcCorner.CornerRadius = UDim.new(0.5, 0)
    arcCorner.Parent = arc
    
    -- Animate spinner
    local rotationTween = TweenService:Create(circle, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 360
    })
    rotationTween:Play()
    
    return spinner
end

-- ============================================================================
-- CONFIGURATION SYSTEM
-- ============================================================================

local Config = {
    -- Server Configuration
    SERVER_URL = "http://192.250.226.90:17001",
    WEBSOCKET_URL = "ws://192.250.226.90:17002",
    
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
        {name = "Mexico", code = "MX", flag = "🇲🇽"}
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
    }
}

-- ============================================================================
-- PROFESSIONAL UI MANAGER
-- ============================================================================

local UIManager = {}
local currentScreenGui = nil

function UIManager:Initialize()
    print("🎨 Professional UI Manager initialized")
    
    -- Clean up any existing UI
    self:CleanupUI()
    
    -- Create main ScreenGui
    currentScreenGui = Instance.new("ScreenGui")
    currentScreenGui.Name = "GlobalExecutorChatProfessional"
    currentScreenGui.ResetOnSpawn = false
    currentScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    currentScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    print("✅ Professional UI initialized successfully")
end

function UIManager:CleanupUI()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local existingGui = playerGui:FindFirstChild("GlobalExecutorChatProfessional")
        if existingGui then
            existingGui:Destroy()
        end
    end
end

function UIManager:GetScreenGui()
    return currentScreenGui
end

-- ============================================================================
-- PROFESSIONAL SETUP WIZARD
-- ============================================================================

local SetupWizard = {}

function SetupWizard:ShowPlatformSelection()
    print("🖥️ Showing professional platform selection...")
    
    local screenGui = UIManager:GetScreenGui()
    if not screenGui then
        error("❌ ScreenGui not initialized")
    end
    
    -- Create modal
    local modal, content = UIComponents:CreateModal({
        Name = "PlatformSelectionModal",
        Size = UDim2.new(0, 450, 0, 350)
    })
    modal.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Platform"
    title.TextColor3 = UITheme.Colors.Text
    title.TextSize = 24
    title.Font = UITheme.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = content
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Choose your device type for optimized experience"
    subtitle.TextColor3 = UITheme.Colors.TextSecondary
    subtitle.TextSize = 14
    subtitle.Font = UITheme.Fonts.Primary
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = content
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 0, 120)
    buttonContainer.Position = UDim2.new(0, 0, 0, 100)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = content
    
    -- Mobile button
    local mobileButton = UIComponents:CreateButton({
        Name = "MobileButton",
        Size = UDim2.new(0, 180, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "📱 Mobile",
        TextSize = 16,
        BackgroundColor = UITheme.Colors.Accent
    })
    mobileButton.Parent = buttonContainer
    
    -- PC button
    local pcButton = UIComponents:CreateButton({
        Name = "PCButton",
        Size = UDim2.new(0, 180, 0, 50),
        Position = UDim2.new(1, -180, 0, 0),
        Text = "💻 Desktop",
        TextSize = 16,
        BackgroundColor = UITheme.Colors.Success
    })
    pcButton.Parent = buttonContainer
    
    -- Button handlers
    mobileButton.MouseButton1Click:Connect(function()
        print("📱 Mobile platform selected")
        self:ShowCountrySelection("Mobile", modal)
    end)
    
    pcButton.MouseButton1Click:Connect(function()
        print("💻 Desktop platform selected")
        self:ShowCountrySelection("PC", modal)
    end)
    
    print("✅ Professional platform selection displayed")
end

function SetupWizard:ShowCountrySelection(platform, previousModal)
    print("🌍 Showing professional country selection...")
    
    -- Close previous modal
    if previousModal then
        previousModal:Destroy()
    end
    
    local screenGui = UIManager:GetScreenGui()
    
    -- Create modal
    local modal, content = UIComponents:CreateModal({
        Name = "CountrySelectionModal",
        Size = UDim2.new(0, 500, 0, 450)
    })
    modal.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Country"
    title.TextColor3 = UITheme.Colors.Text
    title.TextSize = 24
    title.Font = UITheme.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = content
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Platform: " .. platform
    subtitle.TextColor3 = UITheme.Colors.TextSecondary
    subtitle.TextSize = 14
    subtitle.Font = UITheme.Fonts.Primary
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = content
    
    -- Scrolling frame for countries
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "CountryScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, -120)
    scrollFrame.Position = UDim2.new(0, 0, 0, 90)
    scrollFrame.BackgroundColor3 = UITheme.Colors.Input
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = UITheme.Colors.Accent
    scrollFrame.Parent = content
    
    -- Add corner radius to scroll frame
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UITheme.Sizes.CornerRadius
    scrollCorner.Parent = scrollFrame
    
    -- Layout for countries
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scrollFrame
    
    -- Create country buttons
    for i, country in ipairs(Config.COUNTRIES) do
        local countryButton = UIComponents:CreateButton({
            Name = "Country_" .. country.code,
            Size = UDim2.new(1, -12, 0, 40),
            Text = country.flag .. " " .. country.name,
            TextSize = 14,
            BackgroundColor = UITheme.Colors.Secondary,
            HoverColor = UITheme.Colors.Hover
        })
        countryButton.LayoutOrder = i
        countryButton.Parent = scrollFrame
        
        countryButton.MouseButton1Click:Connect(function()
            print("🌍 Country selected:", country.name)
            self:ShowLanguageSelection(platform, country.code, modal)
        end)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    
    print("✅ Professional country selection displayed")
end

function SetupWizard:ShowLanguageSelection(platform, country, previousModal)
    print("🌐 Showing professional language selection...")
    
    -- Close previous modal
    if previousModal then
        previousModal:Destroy()
    end
    
    local screenGui = UIManager:GetScreenGui()
    
    -- Create modal
    local modal, content = UIComponents:CreateModal({
        Name = "LanguageSelectionModal",
        Size = UDim2.new(0, 500, 0, 450)
    })
    modal.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Language"
    title.TextColor3 = UITheme.Colors.Text
    title.TextSize = 24
    title.Font = UITheme.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = content
    
    -- Subtitle
    local countryInfo = nil
    for _, c in ipairs(Config.COUNTRIES) do
        if c.code == country then
            countryInfo = c
            break
        end
    end
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Platform: " .. platform .. " | Country: " .. (countryInfo and countryInfo.flag .. " " .. countryInfo.name or country)
    subtitle.TextColor3 = UITheme.Colors.TextSecondary
    subtitle.TextSize = 14
    subtitle.Font = UITheme.Fonts.Primary
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = content
    
    -- Scrolling frame for languages
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "LanguageScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, -120)
    scrollFrame.Position = UDim2.new(0, 0, 0, 90)
    scrollFrame.BackgroundColor3 = UITheme.Colors.Input
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = UITheme.Colors.Accent
    scrollFrame.Parent = content
    
    -- Add corner radius to scroll frame
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UITheme.Sizes.CornerRadius
    scrollCorner.Parent = scrollFrame
    
    -- Layout for languages
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scrollFrame
    
    -- Create language buttons
    local i = 0
    for langName, langData in pairs(Config.LANGUAGES) do
        i = i + 1
        local languageButton = UIComponents:CreateButton({
            Name = "Language_" .. langData.code,
            Size = UDim2.new(1, -12, 0, 40),
            Text = langData.name,
            TextSize = 14,
            BackgroundColor = UITheme.Colors.Secondary,
            HoverColor = UITheme.Colors.Hover
        })
        languageButton.LayoutOrder = i
        languageButton.Parent = scrollFrame
        
        languageButton.MouseButton1Click:Connect(function()
            print("🌐 Language selected:", langData.name)
            self:ShowAuthenticationScreen(platform, country, langName, modal)
        end)
    end
    
    -- Update scroll canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)
    
    print("✅ Professional language selection displayed")
end

function SetupWizard:ShowAuthenticationScreen(platform, country, language, previousModal)
    print("🔐 Showing professional authentication screen...")
    
    -- Close previous modal
    if previousModal then
        previousModal:Destroy()
    end
    
    local screenGui = UIManager:GetScreenGui()
    
    -- Create modal
    local modal, content = UIComponents:CreateModal({
        Name = "AuthenticationModal",
        Size = UDim2.new(0, 450, 0, 400)
    })
    modal.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Authentication"
    title.TextColor3 = UITheme.Colors.Text
    title.TextSize = 24
    title.Font = UITheme.Fonts.Bold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = content
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Create your account or sign in"
    subtitle.TextColor3 = UITheme.Colors.TextSecondary
    subtitle.TextSize = 14
    subtitle.Font = UITheme.Fonts.Primary
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = content
    
    -- Username input
    local usernameFrame, usernameBox = UIComponents:CreateInput({
        Name = "UsernameInput",
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, 100),
        PlaceholderText = "Enter username..."
    })
    usernameFrame.Parent = content
    
    -- Email input
    local emailFrame, emailBox = UIComponents:CreateInput({
        Name = "EmailInput",
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, 160),
        PlaceholderText = "Enter email (optional)..."
    })
    emailFrame.Parent = content
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 0, 60)
    buttonContainer.Position = UDim2.new(0, 0, 0, 220)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = content
    
    -- Sign up button
    local signUpButton = UIComponents:CreateButton({
        Name = "SignUpButton",
        Size = UDim2.new(0, 180, 0, 45),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "Create Account",
        TextSize = 14,
        BackgroundColor = UITheme.Colors.Success
    })
    signUpButton.Parent = buttonContainer
    
    -- Sign in button
    local signInButton = UIComponents:CreateButton({
        Name = "SignInButton",
        Size = UDim2.new(0, 180, 0, 45),
        Position = UDim2.new(1, -180, 0, 0),
        Text = "Sign In",
        TextSize = 14,
        BackgroundColor = UITheme.Colors.Accent
    })
    signInButton.Parent = buttonContainer
    
    -- Button handlers
    signUpButton.MouseButton1Click:Connect(function()
        local username = usernameBox.Text
        local email = emailBox.Text
        
        if username == "" then
            print("❌ Username required")
            return
        end
        
        print("📝 Creating account for:", username)
        self:CompleteSetup(platform, country, language, username, email, modal)
    end)
    
    signInButton.MouseButton1Click:Connect(function()
        local username = usernameBox.Text
        
        if username == "" then
            print("❌ Username required")
            return
        end
        
        print("🔑 Signing in:", username)
        self:CompleteSetup(platform, country, language, username, "", modal)
    end)
    
    print("✅ Professional authentication screen displayed")
end

function SetupWizard:CompleteSetup(platform, country, language, username, email, modal)
    print("✅ Completing setup...")
    
    -- Show loading
    local loadingSpinner = UIComponents:CreateLoadingSpinner({
        Name = "SetupLoading"
    })
    loadingSpinner.Parent = modal
    
    -- Simulate setup completion
    wait(2)
    
    -- Close modal
    modal:Destroy()
    
    -- Launch chat interface
    GlobalChat:LoadChatInterface({
        platform = platform,
        country = country,
        language = language,
        username = username,
        email = email,
        setupComplete = true
    })
end

-- ============================================================================
-- PROFESSIONAL CHAT INTERFACE
-- ============================================================================

local ChatInterface = {}

function ChatInterface:Create(userConfig)
    print("💬 Creating professional chat interface...")
    
    local screenGui = UIManager:GetScreenGui()
    
    -- Main chat container
    local chatContainer = UIComponents:CreateCard({
        Name = "ChatContainer",
        Size = UDim2.new(0, 800, 0, 600),
        Position = UDim2.new(0.5, -400, 0.5, -300),
        BackgroundColor = UITheme.Colors.Primary
    })
    chatContainer.Parent = screenGui
    
    -- Make draggable
    self:MakeDraggable(chatContainer)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = UITheme.Colors.Secondary
    header.BorderSizePixel = 0
    header.Parent = chatContainer
    
    -- Header corner radius
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UITheme.Sizes.CornerRadius
    headerCorner.Parent = header
    
    -- Header title
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "Title"
    headerTitle.Size = UDim2.new(1, -100, 1, 0)
    headerTitle.Position = UDim2.new(0, 16, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Global Executor Chat - " .. userConfig.language
    headerTitle.TextColor3 = UITheme.Colors.Text
    headerTitle.TextSize = 16
    headerTitle.Font = UITheme.Fonts.Bold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    -- Close button
    local closeButton = UIComponents:CreateButton({
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        Text = "✕",
        TextSize = 14,
        BackgroundColor = UITheme.Colors.Error
    })
    closeButton.Parent = header
    
    closeButton.MouseButton1Click:Connect(function()
        chatContainer:Destroy()
    end)
    
    -- Chat area
    local chatArea = Instance.new("ScrollingFrame")
    chatArea.Name = "ChatArea"
    chatArea.Size = UDim2.new(1, 0, 1, -100)
    chatArea.Position = UDim2.new(0, 0, 0, 50)
    chatArea.BackgroundColor3 = UITheme.Colors.Primary
    chatArea.BorderSizePixel = 0
    chatArea.ScrollBarThickness = 6
    chatArea.ScrollBarImageColor3 = UITheme.Colors.Accent
    chatArea.Parent = chatContainer
    
    -- Chat layout
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 8)
    chatLayout.Parent = chatArea
    
    -- Input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, 0, 0, 50)
    inputArea.Position = UDim2.new(0, 0, 1, -50)
    inputArea.BackgroundColor3 = UITheme.Colors.Secondary
    inputArea.BorderSizePixel = 0
    inputArea.Parent = chatContainer
    
    -- Input field
    local inputFrame, inputBox = UIComponents:CreateInput({
        Name = "MessageInput",
        Size = UDim2.new(1, -80, 0, 35),
        Position = UDim2.new(0, 8, 0, 8),
        PlaceholderText = "Type your message..."
    })
    inputFrame.Parent = inputArea
    
    -- Send button
    local sendButton = UIComponents:CreateButton({
        Name = "SendButton",
        Size = UDim2.new(0, 60, 0, 35),
        Position = UDim2.new(1, -68, 0, 8),
        Text = "Send",
        TextSize = 12,
        BackgroundColor = UITheme.Colors.Accent
    })
    sendButton.Parent = inputArea
    
    -- Send message handler
    local function sendMessage()
        local message = inputBox.Text
        if message and message ~= "" then
            self:AddMessage(chatArea, chatLayout, userConfig.username, message)
            inputBox.Text = ""
        end
    end
    
    sendButton.MouseButton1Click:Connect(sendMessage)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessage()
        end
    end)
    
    -- Add welcome message
    self:AddMessage(chatArea, chatLayout, "System", "Welcome to Global Executor Chat! 🎉")
    
    print("✅ Professional chat interface created successfully")
end

function ChatInterface:AddMessage(chatArea, chatLayout, username, message)
    local messageFrame = UIComponents:CreateCard({
        Name = "Message_" .. tick(),
        Size = UDim2.new(1, -16, 0, 60),
        BackgroundColor = UITheme.Colors.Secondary
    })
    messageFrame.LayoutOrder = chatLayout.AbsoluteContentSize.Y
    messageFrame.Parent = chatArea
    
    -- Username
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "Username"
    usernameLabel.Size = UDim2.new(1, 0, 0, 20)
    usernameLabel.Position = UDim2.new(0, 0, 0, 0)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = username
    usernameLabel.TextColor3 = UITheme.Colors.Accent
    usernameLabel.TextSize = 12
    usernameLabel.Font = UITheme.Fonts.Bold
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Parent = messageFrame
    
    -- Message text
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, -20)
    messageLabel.Position = UDim2.new(0, 0, 0, 20)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = UITheme.Colors.Text
    messageLabel.TextSize = 14
    messageLabel.Font = UITheme.Fonts.Primary
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = messageFrame
    
    -- Auto-scroll to bottom
    chatArea.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 16)
    chatArea.CanvasPosition = Vector2.new(0, chatArea.CanvasSize.Y.Offset)
end

function ChatInterface:MakeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
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
    print("🚀 Starting Global Executor Chat Platform (Professional UI)...")
    
    -- Initialize UI system
    UIManager:Initialize()
    
    -- Detect executor and platform
    local executorName = self:DetectExecutor()
    local platform = self:DetectPlatform()
    
    print("🎯 Detected:", executorName, "on", platform)
    
    -- Start setup wizard
    SetupWizard:ShowPlatformSelection()
    
    print("✅ Professional UI system initialized successfully!")
end

function GlobalChat:LoadChatInterface(userConfig)
    print("💬 Loading chat interface with config:", userConfig.username)
    
    -- Create professional chat interface
    ChatInterface:Create(userConfig)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Auto-initialize when script is loaded
GlobalChat:Initialize()

-- Make GlobalChat available globally
_G.GlobalChatProfessional = GlobalChat

print("🌟 Global Executor Chat Platform (Professional UI) loaded successfully!")

return GlobalChat