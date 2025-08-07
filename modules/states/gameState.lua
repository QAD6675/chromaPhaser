local Player = require("modules.entities.player")
local ColorArea = require("modules.entities.colorArea")
local Obstacle = require("modules.entities.obstacle")

local gameState = {}
gameState.__index = gameState

function gameState.new()
    local self = setmetatable({}, gameState)
    self.player = Player.new(100, 300)
    self.score = 0
    self.gameSpeed = 200 -- pixels per second
    self.areas = {}
    self.obstacles = {}
    self.gameOver = false
    
    -- Initialize game objects
    self:spawnInitialObjects()
    
    return self
end

function gameState:spawnInitialObjects()
    -- Add initial color areas
    table.insert(self.areas, ColorArea.new(400, 0, 100, 600, "red"))
    table.insert(self.areas, ColorArea.new(600, 0, 100, 600, "blue"))
    table.insert(self.areas, ColorArea.new(800, 0, 100, 600, "green"))
    
    -- Add initial obstacles
    table.insert(self.obstacles, Obstacle.new(500, 200))
    table.insert(self.obstacles, Obstacle.new(700, 400))
end

function gameState:update(dt)
    if self.gameOver then 
        return nil -- explicitly return nil when no state change
    end
    
    self.player:update(dt)
    
    -- Move areas and obstacles left
    for _, area in ipairs(self.areas) do
        area:update(dt, self.gameSpeed)
    end
    
    for _, obstacle in ipairs(self.obstacles) do
        obstacle:update(dt, self.gameSpeed)
    end
    
    -- Check collisions
    self:checkCollisions()
    
    -- Remove off-screen objects
    self:cleanupObjects()
    
    -- Spawn new objects if needed
    self:spawnNewObjects()
    
    -- Update score
    self.score = self.score + dt * 10
    
    return nil -- explicitly return nil when no state change
end

-- Modify the keypressed method to handle state transitions:
function gameState:keypressed(key)
    if self.gameOver then
        if key == "r" then
            return "game" -- return "game" to restart
        elseif key == "m" then
            return "menu" -- return "menu" to go to menu
        end
        return nil
    end
    
    self.player:keypressed(key)
    
    -- Add escape key to return to menu
    if key == "escape" then
        return "menu"
    end
    
    return nil
end

function gameState:checkCollisions()
    -- Check color area collisions
    for _, area in ipairs(self.areas) do
        if area:checkCollision(self.player) then
            if self.player.currentColor ~= area.color then
                self:endGame()
                return
            end
        end
    end
    
    -- Check obstacle collisions
    for _, obstacle in ipairs(self.obstacles) do
        if obstacle:checkCollision(self.player) then
            self:endGame()
            return
        end
    end
end

function gameState:cleanupObjects()
    -- Remove off-screen areas
    for i = #self.areas, 1, -1 do
        if self.areas[i].x + self.areas[i].width < 0 then
            table.remove(self.areas, i)
        end
    end
    
    -- Remove off-screen obstacles
    for i = #self.obstacles, 1, -1 do
        if self.obstacles[i].x + self.obstacles[i].width < 0 then
            table.remove(self.obstacles, i)
        end
    end
end

function gameState:spawnNewObjects()
    -- Spawn new areas if needed
    if #self.areas < 3 then
        local lastArea = self.areas[#self.areas]
        local colors = {"red", "blue", "green"}
        local randomColor = colors[love.math.random(#colors)]
        table.insert(self.areas, ColorArea.new(
            lastArea.x + lastArea.width + 100,
            0,
            100,
            600,
            randomColor
        ))
    end
    
    -- Spawn new obstacles if needed
    if #self.obstacles < 3 then
        local x = love.graphics.getWidth() + 100
        local y = love.math.random(50, love.graphics.getHeight() - 50)
        table.insert(self.obstacles, Obstacle.new(x, y))
    end
end

function gameState:draw()
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw areas
    for _, area in ipairs(self.areas) do
        area:draw()
    end
    
    -- Draw obstacles
    for _, obstacle in ipairs(self.obstacles) do
        obstacle:draw()
    end
    
    -- Draw player
    self.player:draw()
    
    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. math.floor(self.score), 10, 10)
    
    -- Draw game over screen
    if self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(
            "Game Over!\nScore: " .. math.floor(self.score) .. "\nPress R to restart\nPress M for menu",
            love.graphics.getWidth() / 2 - 100,
            love.graphics.getHeight() / 2 - 40,
            0,
            2,
            2
        )
    end
end

function gameState:keypressed(key)
    if self.gameOver then
        if key == "r" then
            self = gameState.new()
        end
        return
    end
    
    self.player:keypressed(key)
end

function gameState:endGame()
    self.gameOver = true
    -- TODO: Check and update high score
end

return gameState