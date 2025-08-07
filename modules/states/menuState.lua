local fonts = require("modules.fonts")
local windowManager = require("modules.windowManager")
local saveSystem = require("modules.saveSystem")

local menuState = {}
menuState.__index = menuState

function menuState.new()
    local self = setmetatable({}, menuState)
    
    -- Base dimensions from windowManager
    self.windowWidth = windowManager.baseWidth
    self.windowHeight = windowManager.baseHeight
    
    -- Menu layout configuration
    self.layout = {
        -- Main menu section (left side)
        menu = {
            x = self.windowWidth * 0.2,
            width = self.windowWidth * 0.35,
            titleY = self.windowHeight * 0.15,
            buttonStartY = self.windowHeight * 0.35,
            buttonSpacing = 100,
            buttonWidth = 500,
            buttonHeight = 80
        },
        
        -- Info panel section (right side)
        panel = {
            x = self.windowWidth * 0.6,
            y = self.windowHeight * 0.15,
            width = self.windowWidth * 0.35,
            height = self.windowHeight * 0.7,
            padding = 50
        }
    }
    
    -- Button configuration
    self.selectedButton = 1
    self.buttons = {
        {
            text = "Play",
            action = function() return "game" end,
            description = "Start your color-matching adventure!"
        },
        {
            text = "Quit",
            action = function() love.event.quit() end,
            description = "Exit the game"
        }
    }
    
    -- Game description text
    self.gameDescription = {
        title = "Chroma Phaser",
        subtitle = "A Color-Matching Adventure",
        points = {
            "• Speed through a vibrant world of color zones",
            "• Switch colors to match and survive",
            "• Dodge obstacles and stay alive",
            "• Chase high scores and challenge yourself!"
        },
        controls = {
            "Controls:",
            "↑/↓ - Move Up/Down",
            "SPACE - Change Color",
            "ESC - Pause Game",
            "SHIFT + ESC - Quit Game"
        }
    }
    
    -- Load save data
    self.highScore = saveSystem.getHighScore()
    self.lastPlayed = saveSystem.getLastPlayed()
    
    return self
end

function menuState:draw()
    -- Draw background
    love.graphics.setColor(0.06, 0.06, 0.08)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    
    -- Draw title section
    self:drawTitle()
    
    -- Draw buttons
    self:drawButtons()
    
    -- Draw info panel
    self:drawInfoPanel()
    
    -- Draw high score and last played
    self:drawStats()
end

function menuState:drawTitle()
    -- Main title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    self:drawTextCentered(
        self.gameDescription.title,
        self.layout.menu.x,
        self.layout.menu.titleY
    )
    
    -- Subtitle
    love.graphics.setFont(fonts.heading)
    self:drawTextCentered(
        self.gameDescription.subtitle,
        self.layout.menu.x,
        self.layout.menu.titleY + fonts.title:getHeight() + 20
    )
end

function menuState:drawButtons()
    for i, button in ipairs(self.buttons) do
        local buttonY = self.layout.menu.buttonStartY + (i-1) * self.layout.menu.buttonSpacing
        
        -- Button background
        if i == self.selectedButton then
            -- Selected button glow effect
            love.graphics.setColor(0.3, 0.3, 0.4, 0.6)
            love.graphics.rectangle(
                "fill",
                self.layout.menu.x - self.layout.menu.buttonWidth/2 - 5,
                buttonY - 5,
                self.layout.menu.buttonWidth + 10,
                self.layout.menu.buttonHeight + 10,
                10
            )
            love.graphics.setColor(1, 1, 0)
        else
            -- Unselected button background
            love.graphics.setColor(0.2, 0.2, 0.25, 0.6)
            love.graphics.rectangle(
                "fill",
                self.layout.menu.x - self.layout.menu.buttonWidth/2,
                buttonY,
                self.layout.menu.buttonWidth,
                self.layout.menu.buttonHeight,
                8
            )
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        
        -- Button text
        love.graphics.setFont(fonts.button)
        self:drawTextCentered(
            button.text,
            self.layout.menu.x,
            buttonY + (self.layout.menu.buttonHeight - fonts.button:getHeight())/2
        )
    end
end

function menuState:drawInfoPanel()
    local panel = self.layout.panel
    
    -- Panel background
    love.graphics.setColor(0.12, 0.12, 0.15, 0.8)
    love.graphics.rectangle(
        "fill",
        panel.x,
        panel.y,
        panel.width,
        panel.height,
        20
    )
    
    -- Panel content
    local y = panel.y + panel.padding
    local x = panel.x + panel.padding
    local contentWidth = panel.width - panel.padding * 2
    
    -- Game description
    love.graphics.setColor(1, 1, 1)
    for _, point in ipairs(self.gameDescription.points) do
        love.graphics.setFont(fonts.description)
        love.graphics.printf(point, x, y, contentWidth, "left")
        y = y + fonts.description:getHeight() + 30
    end
    
    -- Separator
    y = y + 40
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.line(x, y, x + contentWidth, y)
    y = y + 40
    
    -- Controls
    love.graphics.setColor(1, 1, 1)
    for _, control in ipairs(self.gameDescription.controls) do
        love.graphics.setFont(fonts.description)
        love.graphics.printf(control, x, y, contentWidth, "left")
        y = y + fonts.description:getHeight() + 20
    end
    
    -- Selected button description
    if self.buttons[self.selectedButton].description then
        y = panel.y + panel.height - panel.padding - fonts.description:getHeight() * 2.5
        love.graphics.setColor(1, 1, 0, 0.8)
        love.graphics.printf(
            self.buttons[self.selectedButton].description,
            x,
            y,
            contentWidth,
            "left"
        )
    end
end

function menuState:drawStats()
    -- Draw high score
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.description)
    love.graphics.printf(
        "High Score: " .. self.highScore,
        50,
        self.windowHeight - 100,
        300,
        "left"
    )
    
    -- Draw last played
    love.graphics.printf(
        "Last Played: " .. self.lastPlayed,
        self.windowWidth - 350,
        self.windowHeight - 100,
        300,
        "right"
    )
end

function menuState:drawTextCentered(text, x, y)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    love.graphics.print(text, x - textWidth/2, y)
end

function menuState:update(dt)
    return nil
end

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
    return nil
end

return menuState