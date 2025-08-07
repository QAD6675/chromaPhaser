local Player = require("modules.entities.player")
local ColorArea = require("modules.entities.colorArea")
local Obstacle = require("modules.entities.obstacle")
local saveSystem = require("modules.saveSystem")
local windowManager = require("modules.windowManager")
local fonts = require("modules.fonts")

local gameState = {}
gameState.__index = gameState

-- Game difficulty configuration
local DIFFICULTY = {
    SPEED_INCREASE_RATE = 20,    -- How fast the game speeds up
    BASE_SPEED = 200,           -- Starting speed
    MAX_SPEED = 800,            -- Maximum speed
    OBSTACLE_MIN_SIZE = 20,     -- Minimum obstacle size
    OBSTACLE_MAX_SIZE = 60,     -- Maximum obstacle size
    MULTI_AREA_CHANCE = 0.4,    -- Chance of spawning multiple areas
    MAX_AREAS_SIDE = 3,         -- Maximum areas side by side
    AREA_MIN_WIDTH = 150,       -- Minimum area width
    AREA_MAX_WIDTH = 300        -- Maximum area width
}

function gameState.new()
    local self = setmetatable({}, gameState)
    
    -- Window dimensions
    self.windowWidth = windowManager.baseWidth
    self.windowHeight = windowManager.baseHeight
    
    -- Game state
    self.player = Player.new(100, self.windowHeight/2)
    self.score = 0
    self.gameSpeed = DIFFICULTY.BASE_SPEED
    self.gameOver = false
    self.isPaused = false
    self.newHighScore = false
    
    -- Progression tracking
    self.difficulty = 1.0
    self.distanceTraveled = 0
    
    -- Game objects
    self.areas = {}
    self.obstacles = {}
    
    -- Initialize game objects
    self:spawnInitialObjects()
    
    return self
end

function gameState:spawnInitialObjects()
    -- Initial color areas
    self:spawnColorAreaGroup(400)
    self:spawnColorAreaGroup(800)
    
    -- Initial obstacles
    self:spawnObstacle(700)
    self:spawnObstacle(1000)
end

function gameState:spawnColorAreaGroup(startX)
    local colors = {"red", "blue", "green"}
    local numAreas = love.math.random() < self.difficulty * DIFFICULTY.MULTI_AREA_CHANCE and 
                    love.math.random(2, DIFFICULTY.MAX_AREAS_SIDE) or 1
    
    local totalWidth = 0
    local areaGroup = {}
    
    -- Generate areas
    for i = 1, numAreas do
        local width = love.math.random(
            DIFFICULTY.AREA_MIN_WIDTH,
            DIFFICULTY.AREA_MAX_WIDTH
        )
        
        local area = {
            width = width,
            color = colors[love.math.random(#colors)]
        }
        
        -- Ensure different colors for adjacent areas
        if i > 1 then
            while area.color == areaGroup[i-1].color do
                area.color = colors[love.math.random(#colors)]
            end
        end
        
        totalWidth = totalWidth + width
        table.insert(areaGroup, area)
    end
    
    -- Place areas
    local currentX = startX
    for _, area in ipairs(areaGroup) do
        table.insert(self.areas, ColorArea.new(
            currentX,
            0,
            area.width,
            self.windowHeight,
            area.color
        ))
        currentX = currentX + area.width
    end
end

function gameState:spawnObstacle(x)
    -- Random size based on difficulty
    local size = love.math.random(
        DIFFICULTY.OBSTACLE_MIN_SIZE,
        DIFFICULTY.OBSTACLE_MIN_SIZE + 
        (DIFFICULTY.OBSTACLE_MAX_SIZE - DIFFICULTY.OBSTACLE_MIN_SIZE) * self.difficulty
    )
    
    -- Random y position
    local y = love.math.random(size, self.windowHeight - size)
    
    -- Create obstacle with random size
    table.insert(self.obstacles, Obstacle.new(x, y))
end

function gameState:update(dt)
    if self.gameOver or self.isPaused then
        return nil
    end
    
    -- Update player
    self.player:update(dt)
    
    -- Update game speed and difficulty
    self.distanceTraveled = self.distanceTraveled + self.gameSpeed * dt
    self.difficulty = math.min(2.0, 1.0 + self.distanceTraveled / 10000)
    self.gameSpeed = math.min(
        DIFFICULTY.MAX_SPEED,
        DIFFICULTY.BASE_SPEED + (self.distanceTraveled / DIFFICULTY.SPEED_INCREASE_RATE)
    )
    
    -- Update areas
    for _, area in ipairs(self.areas) do
        area:update(dt, self.gameSpeed)
    end
    
    -- Update obstacles
    for _, obstacle in ipairs(self.obstacles) do
        obstacle:update(dt, self.gameSpeed)
    end
    
    -- Check collisions
    self:checkCollisions()
    
    -- Clean up off-screen objects
    self:cleanupObjects()
    
    -- Spawn new objects
    self:spawnNewObjects()
    
    -- Update score
    self.score = self.score + dt * (10 + self.difficulty * 5)
    
    return nil
end

function gameState:checkCollisions()
    -- Check color areas
    for _, area in ipairs(self.areas) do
        if area:checkCollision(self.player) then
            if self.player.currentColor ~= area.color then
                self:endGame()
                return
            end
        end
    end
    
    -- Check obstacles
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
    -- Find rightmost area
    local rightmostX = 0
    for _, area in ipairs(self.areas) do
        rightmostX = math.max(rightmostX, area.x + area.width)
    end
    
    -- Spawn new areas if needed
    if rightmostX < self.windowWidth + 200 then
        self:spawnColorAreaGroup(rightmostX + love.math.random(100, 300))
    end
    
    -- Find rightmost obstacle
    local rightmostObstacleX = 0
    for _, obstacle in ipairs(self.obstacles) do
        rightmostObstacleX = math.max(rightmostObstacleX, obstacle.x + obstacle.width)
    end
    
    -- Spawn new obstacles if needed
    if rightmostObstacleX < self.windowWidth + 100 then
        local spacing = love.math.random(300, 600) / self.difficulty
        self:spawnObstacle(rightmostObstacleX + spacing)
    end
end

function gameState:draw()
    -- Draw background
    love.graphics.setColor(0.06, 0.06, 0.08)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    
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
    
    -- Draw UI
    self:drawUI()
    
    -- Draw pause/game over screens
    if self.isPaused then
        self:drawPauseScreen()
    elseif self.gameOver then
        self:drawGameOverScreen()
    end
end

function gameState:drawUI()
    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.heading)
    love.graphics.printf(
        math.floor(self.score),
        0,
        50,
        self.windowWidth,
        "center"
    )
    
    -- Draw difficulty indicator
    love.graphics.setFont(fonts.description)
    love.graphics.printf(
        string.format("Speed: %.0f%%", (self.gameSpeed / DIFFICULTY.BASE_SPEED) * 100),
        self.windowWidth - 200,
        50,
        150,
        "right"
    )
end

function gameState:drawPauseScreen()
    -- Darkened overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    
    -- Pause text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.printf(
        "PAUSED",
        0,
        self.windowHeight/2 - 100,
        self.windowWidth,
        "center"
    )
    
    -- Instructions
    love.graphics.setFont(fonts.description)
    love.graphics.printf(
        "Press ESC to resume\nPress M for menu",
        0,
        self.windowHeight/2 + 50,
        self.windowWidth,
        "center"
    )
end

function gameState:drawGameOverScreen()
    -- Darkened overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    
    -- Game Over text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.printf(
        "GAME OVER",
        0,
        self.windowHeight/3,
        self.windowWidth,
        "center"
    )
    
    -- Score
    love.graphics.setFont(fonts.heading)
    love.graphics.printf(
        "Score: " .. math.floor(self.score),
        0,
        self.windowHeight/2,
        self.windowWidth,
        "center"
    )
    
    -- New high score notification
    if self.newHighScore then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(
            "NEW HIGH SCORE!",
            0,
            self.windowHeight/2 + 70,
            self.windowWidth,
            "center"
        )
    end
    
    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.description)
    love.graphics.printf(
        "Press R to restart\nPress M for menu",
        0,
        self.windowHeight/2 + 150,
        self.windowWidth,
        "center"
    )
end

function gameState:endGame()
    self.gameOver = true
    self.newHighScore = saveSystem.updateHighScore(math.floor(self.score))
end

function gameState:keypressed(key)
    if self.gameOver then
        if key == "r" then
            return "game"
        elseif key == "m" then
            return "menu"
        end
    elseif self.isPaused then
        if key == "escape" then
            self.isPaused = false
        elseif key == "m" then
            return "menu"
        end
    else
        if key == "escape" then
            self.isPaused = true
        else
            self.player:keypressed(key)
        end
    end
    return nil
end

return gameState