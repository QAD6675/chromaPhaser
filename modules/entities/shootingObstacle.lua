local ShootingObstacle = {}
ShootingObstacle.__index = ShootingObstacle

function ShootingObstacle.new(x, y, width, height, detectionRange)
    local self = setmetatable({}, ShootingObstacle)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.detectionRange = detectionRange
    self.hasDetected = false
    self.isCharging = false
    self.hasShot = false
    self.isProjectile = false
    self.velocityX = 0
    self.velocityY = 0
    self.chargeTimer = 0
    self.chargeDuration = 1.0  -- Seconds to charge before shooting
    return self
end

function ShootingObstacle:update(dt, gameSpeed, player)
    if self.isProjectile then
        self.x = self.x + self.velocityX * dt
        self.y = self.y + self.velocityY * dt
        return self.x > -self.width
    else
        self.x = self.x - gameSpeed * dt

        if not self.hasDetected and self:playerInRange(player) then
            self.hasDetected = true
            self.isCharging = true
        end

        if self.isCharging then
            self.chargeTimer = self.chargeTimer + dt
            if self.chargeTimer >= self.chargeDuration then
                self:shoot(player)
                self.isCharging = false
            end
        end

        return true
    end
end

function ShootingObstacle:playerInRange(player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    return dx > 0 and dx < self.detectionRange
end

function ShootingObstacle:shoot(player)
    self.hasShot = true
    self.isProjectile = true
    local dx = player.x - self.x
    local dy = player.y - self.y
    local length = math.sqrt(dx * dx + dy * dy)
    self.velocityX = (dx / length) * 300  -- Adjusted speed to be dodgeable
    self.velocityY = (dy / length) * 300
end

function ShootingObstacle:draw()
    if not self.isProjectile and not self.hasShot then
        -- Faint red pulse when detecting
        love.graphics.setColor(1, 0, 0, 0.1)
        love.graphics.rectangle("fill", self.x, 0, self.detectionRange, love.graphics.getHeight())

        if self.isCharging then
            -- Flash red when charging
            local alpha = 0.3 + 0.2 * math.sin(love.timer.getTime() * 10)
            love.graphics.setColor(1, 0, 0, alpha)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        else
            love.graphics.setColor(0.8, 0.4, 0)
        end
    else
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function ShootingObstacle:checkCollision(player)
    return player.x < self.x + self.width and
           player.x + player.width > self.x and
           player.y < self.y + self.height and
           player.y + player.height > self.y
end

return ShootingObstacle