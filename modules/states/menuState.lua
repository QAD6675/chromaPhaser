local fonts = require("modules.fonts")

local menuState = {}
menuState.__index = menuState

function menuState.new()
    local self = setmetatable({}, menuState)
    
    -- Load fonts if not already loaded
    if not fonts.title then
        fonts.load()
    end
    
    -- Window dimensions for easy reference
    self.windowWidth = love.graphics.getWidth()
    self.windowHeight = love.graphics.getHeight()
    
    -- Menu layout configuration
    self.menuX = self.windowWidth * 0.3
    self.menuWidth = self.windowWidth * 0.4
    self.titleY = 80
    
    -- Side panel configuration
    self.sidePanel = {
        x = self.windowWidth * 0.7,
        y = 80,
        width = self.windowWidth * 0.25,
        padding = 20
    }
    
    -- Button configuration
    self.selectedButton = 1
    self.buttonSpacing = 60
    self.buttonStartY = 250
    self.buttons = {
        {
            text = "Play",
            action = function() return "game" end,
            description = "Start your color-matching adventure!"
        },
        {
            text = "Settings",
            action = function() return "settings" end,
            description = "Adjust game options"
        },
        {
            text = "Quit",
            action = function() love.event.quit() end,
            description = "Exit the game"
        }
    }
    
    -- Game description text
    self.gameDescription = {
        title = "How to Play:",
        points = {
            "Navigate through colored zones",
            "Match your color with the zones",
            "Avoid white obstacles",
            "Survive as long as possible!",
        },
        controls = {
            "UP/DOWN - Move vertically",
            "SPACE - Change color",
            "ESC - Pause game"
        }
    }
    
    -- Load high score
    self.highScore = 0
    
    return self
end

function menuState:drawTextCentered(text, x, y, font)
    local currentFont = love.graphics.getFont()
    if font then
        love.graphics.setFont(font)
    end
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, x - textWidth/2, y)
    if font then
        love.graphics.setFont(currentFont)
    end
end

function menuState:drawWrappedText(text, x, y, width, font)
    local currentFont = love.graphics.getFont()
    if font then
        love.graphics.setFont(font)
    end
    love.graphics.printf(text, x, y, width, "left")
    if font then
        love.graphics.setFont(currentFont)
    end
end

function menuState:draw()
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    
    -- Draw title with title font
    love.graphics.setColor(1, 1, 1)
    self:drawTextCentered("Color Sidescroller", self.menuX, self.titleY, fonts.title)
    
    -- Draw buttons
    for i, button in ipairs(self.buttons) do
        local buttonY = self.buttonStartY + (i-1) * self.buttonSpacing
        
        -- Draw button background if selected
        if i == self.selectedButton then
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle(
                "fill",
                self.menuX - 100,
                buttonY - 5,
                200,
                40
            )
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        -- Draw button text with button font
        self:drawTextCentered(button.text, self.menuX, buttonY, fonts.button)
    end
    
    -- Draw side panel
    self:drawSidePanel()
    
    -- Draw high score with heading font
    love.graphics.setColor(1, 1, 1)
    self:drawTextCentered(
        "High Score: " .. self.highScore,
        self.menuX,
        self.windowHeight - 100,
        fonts.heading
    )
end

function menuState:drawSidePanel()
    local panel = self.sidePanel
    
    -- Draw panel background
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, self.windowHeight - panel.y * 2)
    
    -- Draw panel content
    love.graphics.setColor(1, 1, 1)
    local y = panel.y + panel.padding
    
    -- Draw description title with heading font
    love.graphics.setFont(fonts.heading)
    love.graphics.print(self.gameDescription.title, panel.x + panel.padding, y)
    y = y + fonts.heading:getHeight() + 20
    
    -- Draw game points with description font
    love.graphics.setFont(fonts.description)
    for _, point in ipairs(self.gameDescription.points) do
        self:drawWrappedText(
            "• " .. point,
            panel.x + panel.padding,
            y,
            panel.width - panel.padding * 2,
            fonts.description
        )
        y = y + fonts.description:getHeight() + 10
    end
    
    -- Draw controls section
    y = y + 20
    love.graphics.setFont(fonts.button)
    love.graphics.print("Controls:", panel.x + panel.padding, y)
    y = y + fonts.button:getHeight() + 10
    
    -- Draw control instructions
    love.graphics.setFont(fonts.description)
    for _, control in ipairs(self.gameDescription.controls) do
        self:drawWrappedText(
            control,
            panel.x + panel.padding,
            y,
            panel.width - panel.padding * 2,
            fonts.description
        )
        y = y + fonts.description:getHeight() + 5
    end
    
    -- Draw current button description
    if self.buttons[self.selectedButton].description then
        love.graphics.setColor(0.8, 0.8, 0.2)
        self:drawWrappedText(
            self.buttons[self.selectedButton].description,
            panel.x + panel.padding,
            self.windowHeight - 150,
            panel.width - panel.padding * 2,
            fonts.description
        )
    end
end

-- Keep the existing keypressed function as is
function menuState:keypressed(key)
    if key == "up" then
        self.selectedButton = ((self.selectedButton - 2) % #self.buttons) + 1
    elseif key == "down" then
        self.selectedButton = (self.selectedButton % #self.buttons) + 1
    elseif key == "return" or key == "space" then
        local action = self.buttons[self.selectedButton].action
        if action then
            return action()
        end
    end
end

function menuState:update(dt)
    -- Add any menu animations or effects here
    return nil -- explicitly return nil when no state change is needed
end
return menuState