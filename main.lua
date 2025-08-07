_G.love = love

local gameState = require("modules.states.gameState")
local menuState = require("modules.states.menuState")
local fonts = require("modules.fonts")
local windowManager = require("modules.windowManager")
local saveSystem = require("modules.saveSystem")

-- Global game state
local currentState

function love.load()
    -- Initialize window management
    windowManager.init()
    
    -- Load fonts with proper scaling
    fonts.load()
    
    -- Load saved data
    saveSystem.load()
    
    -- Initialize starting state
    currentState = menuState.new()
    
    -- Disable mouse cursor
    love.mouse.setVisible(false)
end

function love.update(dt)
    if currentState and currentState.update then
        local nextState = currentState:update(dt)
        if nextState then
            if nextState == "game" then
                currentState = gameState.new()
            elseif nextState == "menu" then
                currentState = menuState.new()
            end
        end
    end
end

function love.draw()
    -- Start scaled drawing
    windowManager.start()
    
    if currentState and currentState.draw then
        currentState:draw()
    end
    
    -- End scaled drawing
    windowManager.finish()
end

function love.keypressed(key)
    -- Add fullscreen toggle with Alt+Enter
    if key == "return" and love.keyboard.isDown("lalt") then
        local _, _, flags = love.window.getMode()
        love.window.setFullscreen(not flags.fullscreen)
        windowManager.init() -- Recalculate scaling
        return
    end
    
    -- Add quit shortcut
    if key == "escape" and love.keyboard.isDown("lshift") then
        love.event.quit()
        return
    end
    
    if currentState and currentState.keypressed then
        local nextState = currentState:keypressed(key)
        if nextState then
            if nextState == "game" then
                currentState = gameState.new()
            elseif nextState == "menu" then
                currentState = menuState.new()
            end
        end
    end
end

function love.resize(w, h)
    windowManager.init()
end