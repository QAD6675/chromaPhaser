_G.love = love

local gameState = require("modules.states.gameState")
local menuState = require("modules.states.menuState")
local fonts = require("modules.fonts")
local saveSystem = require("modules.saveSystem")

local currentState

function love.load()
    fonts.load()
    saveSystem.load()
    currentState = menuState.new()
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
    if currentState and currentState.draw then
        currentState:draw()
    end
end

function love.keypressed(key)
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