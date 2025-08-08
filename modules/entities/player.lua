local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 30
    self.height = 30
    self.speed = 300
    self.colors = {"red", "blue", "green"}
    self.currentColorIndex = 1
    self.currentColor = self.colors[self.currentColorIndex]
    self.colorTransition = 0
    self.previousColor = self.currentColor
    return self
end

function Player:update(dt)
    if love.keyboard.isDown("up") then
        self.y = math.max(0, self.y - self.speed * dt)
    elseif love.keyboard.isDown("down") then
        self.y = math.min(love.graphics.getHeight() - self.height, self.y + self.speed * dt)
    end
    if self.colorTransition > 0 then
        self.colorTransition = math.max(0, self.colorTransition - dt * 5)
    end
end

function Player:draw()
    if self.colorTransition > 0 then
        self:setColorByName(self.previousColor, 1 * self.colorTransition)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    self:setColorByName(self.currentColor, 1 - self.colorTransition)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:keypressed(key)
    if key == "space" then
        self:cycleColor()
    end
end

function Player:cycleColor()
    self.previousColor = self.currentColor
    self.currentColorIndex = self.currentColorIndex % #self.colors + 1
    self.currentColor = self.colors[self.currentColorIndex]
    self.colorTransition = 1
end

function Player:setColorByName(colorName, alpha)
    if colorName == "red" then
        love.graphics.setColor(1, 0.3, 0.3, alpha)
    elseif colorName == "blue" then
        love.graphics.setColor(0.3, 0.3, 1, alpha)
    elseif colorName == "green" then
        love.graphics.setColor(0.3, 1, 0.3, alpha)
    end
end

return Player