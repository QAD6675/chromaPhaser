local windowManager = {
    -- Base resolution for scaling calculations
    baseWidth = 1920,
    baseHeight = 1080,
    
    -- Current scale factors
    scaleX = 1,
    scaleY = 1,
    
    -- Actual window dimensions
    width = 0,
    height = 0,
    
    -- Offset for centering
    offsetX = 0,
    offsetY = 0
}

function windowManager.init()
    -- Get the desktop dimensions
    local _, _, flags = love.window.getMode()
    local desktopW, desktopH = love.window.getDesktopDimensions(flags.display)
    
    -- Set actual window size
    windowManager.width = desktopW
    windowManager.height = desktopH
    
    -- Calculate scaling factors
    windowManager.scaleX = desktopW / windowManager.baseWidth
    windowManager.scaleY = desktopH / windowManager.baseHeight
    
    -- Calculate offsets for centered content
    windowManager.offsetX = (desktopW - windowManager.baseWidth * windowManager.scaleX) / 2
    windowManager.offsetY = (desktopH - windowManager.baseHeight * windowManager.scaleY) / 2
    
    -- Set up window
    love.window.setMode(desktopW, desktopH, {
        fullscreen = true,
        fullscreentype = "desktop",
        vsync = 1,
        msaa = 8
    })
end

function windowManager.start()
    love.graphics.push()
    love.graphics.translate(windowManager.offsetX, windowManager.offsetY)
    love.graphics.scale(windowManager.scaleX, windowManager.scaleY)
end

function windowManager.finish()
    love.graphics.pop()
end

function windowManager.toGameCoords(x, y)
    return (x - windowManager.offsetX) / windowManager.scaleX,
           (y - windowManager.offsetY) / windowManager.scaleY
end

return windowManager