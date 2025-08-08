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
    self.chargeDuration = 1.0  
    return self
end

function ShootingObstacle:update(dt, gameSpeed, player)
    if self.isProjectile then
        self.x = self.x + self.velocityX * dt
        self.y = self.y + self.velocityY * dt
        return self.x > -self.width and self.x < 1280 + self.width -- Assuming windowWidth=1280
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
        return self.x > -self.width -- Stay until off-screen
    end
end

function ShootingObstacle:playerInRange(player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    return distance < self.detectionRange
end

function ShootingObstacle:shoot(player)
    self.hasShot = true
    self.isProjectile = true
    local dx = player.x - self.x
    local dy = player.y - self.y
    local length = math.sqrt(dx * dx + dy * dy)
    self.velocityX = (dx / length) * 300
    self.velocityY = (dy / length) * 300
end

function ShootingObstacle:draw()
    if not self.isProjectile then
        if self.isCharging then
            local alpha = 0.3 + 0.2 * math.sin(love.timer.getTime() * 10)
            love.graphics.setColor(1, 0, 0, alpha)
        else
            love.graphics.setColor(1, 0, 1)
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