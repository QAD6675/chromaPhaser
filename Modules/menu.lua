-- modules/menu.lua
local menu = {}

-- Local state
local buttons = {}
local title = "CHROMAPHASER"
local description = "Change colors to survive.\nMatch your color to the zones.\nAvoid obstacles.\n\nControls:\n[UP/DOWN] Move\n[SPACE] Switch color\n[D] Toggle Debug\n[ESC] Quit"
local highScore = 0

function menu.load(savedHighScore)
    highScore = savedHighScore or 0

    -- Buttons (x, y, width, height, label, callback)
    buttons = {
        { 300, 300, 200, 40, "Play", function() return "game" end },
        { 300, 350, 200, 40, "Settings", function() return "settings" end },
        { 300, 400, 200, 40, "Quit", function() love.event.quit() end }
    }
end

function menu.update(dt)
    -- Could add hover effects or animations here later
end

function menu.draw()
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf(title, 0, 80, love.graphics.getWidth(), "center")

    -- Description
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(description, 0, 150, love.graphics.getWidth(), "center")

    -- High score
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("High Score: " .. highScore, 0, 260, love.graphics.getWidth(), "center")

    -- Buttons
    for _, btn in ipairs(buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", btn[1], btn[2], btn[3], btn[4], 8, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn[5], btn[1], btn[2] + 10, btn[3], "center")
    end
end

function menu.mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(buttons) do
            if x > btn[1] and x < btn[1] + btn[3] and y > btn[2] and y < btn[2] + btn[4] then
                return btn[6]() -- Call button action, return new state
            end
        end
    end
end

return menu
