function love.conf(t)
    t.title = "ChromaPhaser"
    t.version = "11.4"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = 1
    t.window.msaa = 8
    
    -- Enable console for debugging
    t.console = true
    
    -- Modules we're using
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.window = true
    
    -- Modules we're not using
    t.modules.joystick = false
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end