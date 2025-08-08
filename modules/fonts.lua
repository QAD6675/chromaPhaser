local fonts = {}

function fonts.load()
    -- Reduced font sizes for better screen fit
    fonts.title = love.graphics.newFont(48)    -- Was 72
    fonts.heading = love.graphics.newFont(36)  -- Was 48
    fonts.button = love.graphics.newFont(28)   -- Was 36
    fonts.description = love.graphics.newFont(14) -- Was 24
    fonts.small = love.graphics.newFont(16)    -- Was 20

    -- Set default font
    love.graphics.setFont(fonts.description)
end

return fonts