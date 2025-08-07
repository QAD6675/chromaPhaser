_G.love = require("love")
local menu         = require("modules.menu")
local player       = require("modules.player")
local colorManager = require("modules.colorManager")

-- Game state variables
local state = "menu"       -- "menu", "game", "settings" (settings coming later)
local score = 0
local highScore = 0
local showDebug = true

function love.load()
    -- Background
    love.graphics.setBackgroundColor(0.05, 0.05, 0.05)

    -- Load modules
    menu.load(highScore)
    player.load()
    colorManager.load()
end

function love.update(dt)
    if state == "game" then
        -- Game logic
        player.update(dt)
        score = score + dt * 10 -- Time-based scoring
    elseif state == "menu" then
        -- Menu logic
        menu.update(dt)
    elseif state == "settings" then
        -- Settings logic will go here later
    end
end

function love.draw()
    if state == "game" then
        -- Draw game elements
        colorManager.draw()
        player.draw()

        -- Debug info
        if showDebug then
            drawDebug()
        end

    elseif state == "menu" then
        -- Draw menu
        menu.draw()

    elseif state == "settings" then
        -- Settings screen (placeholder for now)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Settings Menu (WIP)\n[ESC] Back to Menu", 0, 200, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if state == "game" then
        if key == "space" then
            colorManager.nextColor()
        elseif key == "d" then
            showDebug = not showDebug
        elseif key == "escape" then
            -- End game and go back to menu
            if score > highScore then
                highScore = math.floor(score)
                menu.load(highScore)
            end
            score = 0
            state = "menu"
        end

    elseif state == "settings" then
        if key == "escape" then
            state = "menu"
        end
    end
end

function love.mousepressed(x, y, button)
    if state == "menu" then
        local newState = menu.mousepressed(x, y, button)
        if newState then
            state = newState
            if state == "game" then
                -- Reset score when starting a new game
                score = 0
            end
        end
    end
end

-- Debug overlay
function drawDebug()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        string.format(
            "FPS: %d\nScore: %d\nColor Index: %d\nPlayer: (%.0f, %.0f)",
            love.timer.getFPS(),
            math.floor(score),
            colorManager.current,
            player.x,
            player.y
        ),
        10, 10
    )
end
