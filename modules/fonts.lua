local fonts = {}

function fonts.load()
    -- Using default LÖVE font as fallback
    fonts.title = love.graphics.newFont(72)
    fonts.heading = love.graphics.newFont(48)
    fonts.button = love.graphics.newFont(36)
    fonts.description = love.graphics.newFont(24)
    fonts.small = love.graphics.newFont(20)
    
    -- Set default font
    love.graphics.setFont(fonts.description)
end

return fonts