local fonts = {}

function fonts.load()
    local defaultFont = love.graphics.getFont()
    
    fonts.title = love.graphics.newFont(48)
    fonts.heading = love.graphics.newFont(32)
    fonts.button = love.graphics.newFont(24)
    fonts.description = love.graphics.newFont(16)
    fonts.small = love.graphics.newFont(14)
    
    love.graphics.setFont(fonts.description)
end

return fonts