local MovingObstacle = {}
MovingObstacle.__index = MovingObstacle

function MovingObstacle.new(x, y, width, height, moveSpeedY, moveRangeY)
    local self = setmetatable({}, MovingObstacle)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.moveSpeedY = moveSpeedY or 50
    self.moveRangeY = moveRangeY or 100
    self.startY = y                
    self.directionY = 1          
    return self
end

function MovingObstacle:update(dt, gameSpeed)
    self.x = self.x - gameSpeed * dt

    self.y = self.y + self.moveSpeedY * self.directionY * dt

    if self.directionY == 1 then
        if self.y >= self.startY + self.moveRangeY / 2 then
            self.directionY = -1
        end
    else -- Moving up
        if self.y <= self.startY - self.moveRangeY / 2 then
            self.directionY = 1
        end
    end

    return self.x > -self.width
end

function MovingObstacle:draw()
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function MovingObstacle:checkCollision(player)
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

return MovingObstacle
