local ColorArea = {}
ColorArea.__index = ColorArea

function ColorArea.new(x, y, width, height, color)
    local self = setmetatable({}, ColorArea)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = color
    return self
end

function ColorArea:update(dt, speed)
    self.x = self.x - speed * dt
end

function ColorArea:draw()
    if self.color == "red" then
        love.graphics.setColor(1, 0.3, 0.3, 0.3)
    elseif self.color == "blue" then
        love.graphics.setColor(0.3, 0.3, 1, 0.3)
    elseif self.color == "green" then
        love.graphics.setColor(0.3, 1, 0.3, 0.3)
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function ColorArea:checkCollision(player)
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

return ColorArea