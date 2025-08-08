local Obstacle = {}
Obstacle.__index = Obstacle

function Obstacle.new(x, y)
    local self = setmetatable({}, Obstacle)
    self.x = x
    self.y = y
    self.width = 20
    self.height = 20
    self.rotation = 0
    return self
end

function Obstacle:update(dt, speed)
    self.x = self.x - speed * dt
    self.rotation = self.rotation + dt * 2
    return self.x > -self.width
end

function Obstacle:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.push()
    love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
    love.graphics.rotate(self.rotation)
    love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.pop()
end

function Obstacle:checkCollision(player)
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

return Obstacle