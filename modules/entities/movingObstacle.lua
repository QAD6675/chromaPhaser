local MovingObstacle = {}
MovingObstacle.__index = MovingObstacle

function MovingObstacle.new(x, y, width, height, moveSpeedY, moveRangeY)
    local self = setmetatable({}, MovingObstacle)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.moveSpeedY = moveSpeedY or 50  -- Default vertical movement speed
    self.moveRangeY = moveRangeY or 100 -- Default vertical movement range (total distance up and down from initial Y)
    self.startY = y                     -- Store the initial Y position
    self.directionY = 1                 -- 1 for moving down, -1 for moving up
    return self
end

function MovingObstacle:update(dt, gameSpeed)
    -- Move horizontally with the game speed
    self.x = self.x - gameSpeed * dt

    -- Update vertical position
    self.y = self.y + self.moveSpeedY * self.directionY * dt

    -- Check if the obstacle has reached its vertical limits and reverse direction
    if self.directionY == 1 then -- Moving down
        if self.y >= self.startY + self.moveRangeY / 2 then
            self.directionY = -1 -- Change to moving up
        end
    else -- Moving up
        if self.y <= self.startY - self.moveRangeY / 2 then
            self.directionY = 1 -- Change to moving down
        end
    end

    -- Return true to keep the obstacle active as long as it's on screen
    return self.x > -self.width
end

function MovingObstacle:draw()
    -- Set color for the moving obstacle (e.g., a solid color)
    love.graphics.setColor(0.8, 0.4, 0) -- Orange color
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function MovingObstacle:checkCollision(player)
    -- Check for collision with the player
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

return MovingObstacle
