local Player = require("modules.entities.player")
local ColorArea = require("modules.entities.colorArea")
local Obstacle = require("modules.entities.obstacle")
local MovingObstacle = require("modules.entities.movingObstacle")
local ShootingObstacle = require("modules.entities.shootingObstacle")
local saveSystem = require("modules.saveSystem")
local fonts = require("modules.fonts")

local gameState = {}
gameState.__index = gameState

local DIFFICULTY = {
    SPEED_INCREASE_RATE = 15,
    BASE_SPEED = 200,
    MAX_SPEED = 800,
    OBSTACLE_MIN_SIZE = 20,
    OBSTACLE_MAX_SIZE = 60,
    MULTI_AREA_CHANCE = 0.4,
    MAX_AREAS_SIDE = 3,
    AREA_MIN_WIDTH = 800,
    AREA_MAX_WIDTH = 1200,
    MOVING_OBSTACLE_CHANCE = 0.5,
    SHOOTING_OBSTACLE_CHANCE = 0.3,
    DETECTION_RANGE = 500,
    STARTUP_GRACE_PERIOD = 2.0
}

function gameState.new()
    local self = setmetatable({}, gameState)
    self.windowWidth = love.graphics.getWidth()
    self.windowHeight = love.graphics.getHeight()

    self.player = Player.new(100, self.windowHeight / 2)
    self.score = 0
    self.gameSpeed = DIFFICULTY.BASE_SPEED
    self.gameOver = false
    self.isPaused = false
    self.newHighScore = false

    self.difficulty = 1.0
    self.distanceTraveled = 0

    self.areas = {}
    self.obstacles = {}

    self.gracePeriod = DIFFICULTY.STARTUP_GRACE_PERIOD
    self.graceTimer = 0
    self.player.inputEnabled = false  -- Disable player controls

    self:spawnColorAreaGroup(0)

    return self
end

function gameState:spawnColorAreaGroup(startX)
    local colors = {"red", "blue", "green"}
    local numAreas = love.math.random() < self.difficulty * DIFFICULTY.MULTI_AREA_CHANCE
                     and love.math.random(2, DIFFICULTY.MAX_AREAS_SIDE) or 1

    local currentX = startX
    local lastColor = #self.areas > 0 and self.areas[#self.areas].color or nil

    for i = 1, numAreas do
        local width = i == numAreas and
            love.math.random(1200, 1600) or
            love.math.random(DIFFICULTY.AREA_MIN_WIDTH, DIFFICULTY.AREA_MAX_WIDTH)

        local color = colors[love.math.random(#colors)]
        while color == lastColor do
            color = colors[love.math.random(#colors)]
        end

        local newArea = ColorArea.new(currentX, 0, width, self.windowHeight, color)
        newArea.playerEntered = false
        table.insert(self.areas, newArea)

        lastColor = color
        currentX = currentX + width
    end
end


function gameState:update(dt)
    if self.gameOver or self.isPaused then return end

    -- Update grace timer
    if self.graceTimer < self.gracePeriod then
        self.graceTimer = self.graceTimer + dt
        if self.graceTimer >= self.gracePeriod then
            self.player.inputEnabled = true  -- Optional: already true
        end
    end

    -- Update player movement regardless of grace
    self.player:update(dt)

    -- Only increase speed and move world after grace period
    if self.graceTimer >= self.gracePeriod then
        self.distanceTraveled = self.distanceTraveled + self.gameSpeed * dt
        self.difficulty = math.min(2.0, 1.0 + self.distanceTraveled / 10000)
        self.gameSpeed = math.min(DIFFICULTY.MAX_SPEED, DIFFICULTY.BASE_SPEED + (self.distanceTraveled / DIFFICULTY.SPEED_INCREASE_RATE))

        -- Move world (areas and obstacles)
        for _, area in ipairs(self.areas) do
            area:update(dt, self.gameSpeed)
        end
        for i = #self.obstacles, 1, -1 do
            local obstacle = self.obstacles[i]
            if obstacle.update then
                local isActive = obstacle:update(dt, self.gameSpeed, self.player)
                if not isActive then table.remove(self.obstacles, i) end
            else
                obstacle:update(dt, self.gameSpeed)
            end
        end
    end

    -- Check collisions only after grace period
    if self.graceTimer >= self.gracePeriod then
        self:checkCollisions()
    end

    self:cleanupObjects()
    self:spawnNewObjects()

    self.score = self.score + dt * (10 + self.difficulty * 5)
end

function gameState:checkCollisions()
    for _, area in ipairs(self.areas) do
        local isColliding = area:checkCollision(self.player)
        if isColliding and not area.playerEntered then
            area.playerEntered = true
            if self.player.currentColor ~= area.color then
                self:endGame()
                return
            end
        elseif not isColliding then
            area.playerEntered = false
        end
    end

    for _, obstacle in ipairs(self.obstacles) do
        if obstacle:checkCollision(self.player) then
            self:endGame()
            return
        end
    end
end

function gameState:cleanupObjects()
    local keptAreas = {}
    for _, area in ipairs(self.areas) do
        if area.x + area.width > -10 then
            table.insert(keptAreas, area)
        end
    end
    self.areas = keptAreas

    local keptObstacles = {}
    for _, obstacle in ipairs(self.obstacles) do
        if obstacle.x + obstacle.width > -10 then
            table.insert(keptObstacles, obstacle)
        end
    end
    self.obstacles = keptObstacles
end

function gameState:spawnNewObjects()
    -- === SPAWN AREAS ===
    local rightmostX = 0
    for _, area in ipairs(self.areas) do
        rightmostX = math.max(rightmostX, area.x + area.width)
    end
    if rightmostX < self.windowWidth + 300 then
        self:spawnColorAreaGroup(rightmostX)
    end

    -- === SPAWN OBSTACLES ===
    local spawnZoneStart = self.windowWidth + 50
    local spawnZoneEnd = self.windowWidth + 300

    -- Only spawn if no obstacle exists in forward zone
    local shouldSpawn = true
    for _, obstacle in ipairs(self.obstacles) do
        if obstacle.x > spawnZoneStart and obstacle.x < spawnZoneEnd + 400 then
            shouldSpawn = false
            break
        end
    end

    if shouldSpawn and love.math.random() < 0.02 + self.difficulty * 0.01 then
        local x = spawnZoneStart + love.math.random() * 250
        local y = love.math.random(20, self.windowHeight - 20)
        local size = love.math.random(20, 40 + self.difficulty * 20)
        local typeRoll = love.math.random()

        if typeRoll < DIFFICULTY.SHOOTING_OBSTACLE_CHANCE then
            print("spawned shooting obstacle")
            table.insert(self.obstacles, ShootingObstacle.new(x, y, size, size, DIFFICULTY.DETECTION_RANGE))
        elseif typeRoll < DIFFICULTY.MOVING_OBSTACLE_CHANCE then
            print("spawned moving obstacle")
            table.insert(self.obstacles, MovingObstacle.new(x, y, size, size, self.gameSpeed * 0.3 * self.difficulty, self.windowHeight))
        else
            print("spawning lame object")
            table.insert(self.obstacles, Obstacle.new(x,y))
        end
    end
end
function gameState:draw()
    love.graphics.setColor(0.06, 0.06, 0.08)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)

    for _, area in ipairs(self.areas) do
        area:draw()
    end
    for _, obstacle in ipairs(self.obstacles) do
        obstacle:draw()
    end
    self.player:draw()

    self:drawUI()

    -- ✅ Draw countdown during grace period
    if self.graceTimer < self.gracePeriod then
        local remaining = math.ceil(self.gracePeriod - self.graceTimer)
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.setFont(fonts.title)
        love.graphics.printf(
            tostring(remaining),
            0, self.windowHeight / 2 - 50, self.windowWidth, "center"
        )
        love.graphics.setFont(fonts.description)
        love.graphics.printf(
            "GET READY!",
            0, self.windowHeight / 2 + 50, self.windowWidth, "center"
        )
    end

    if self.isPaused then
        self:drawPauseScreen()
    elseif self.gameOver then
        self:drawGameOverScreen()
    end
end

function gameState:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.heading)
    love.graphics.printf(math.floor(self.score), 0, 50, self.windowWidth, "center")

    love.graphics.setFont(fonts.description)
    love.graphics.printf(
        string.format("Speed: %.0f%%", (self.gameSpeed / DIFFICULTY.BASE_SPEED) * 100),
        self.windowWidth - 200, 50, 150, "right"
    )
end

function gameState:drawPauseScreen()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("PAUSED", 0, self.windowHeight/2 - 100, self.windowWidth, "center")
    love.graphics.setFont(fonts.description)
    love.graphics.printf("Press ESC to resume\nPress M for menu", 0, self.windowHeight/2 + 50, self.windowWidth, "center")
end

function gameState:drawGameOverScreen()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("GAME OVER", 0, self.windowHeight/3, self.windowWidth, "center")
    love.graphics.setFont(fonts.heading)
    love.graphics.printf("Score: " .. math.floor(self.score), 0, self.windowHeight/2, self.windowWidth, "center")
    if self.newHighScore then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("NEW HIGH SCORE!", 0, self.windowHeight/2 + 70, self.windowWidth, "center")
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.description)
    love.graphics.printf("Press R to restart\nPress M for menu", 0, self.windowHeight/2 + 150, self.windowWidth, "center")
end

function gameState:endGame()
    self.gameOver = true
    self.newHighScore = saveSystem.updateHighScore(math.floor(self.score))
end

function gameState:keypressed(key)
    if self.gameOver then
        if key == "r" then return "game"
        elseif key == "m" then return "menu" end
    elseif self.isPaused then
        if key == "escape" then self.isPaused = false
        elseif key == "m" then return "menu" end
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