function love.conf(t)
    -- Basic window setup
    t.title = "Chroma Phaser"
    t.version = "11.4"
    t.identity = "ChromaPhaser"  -- Save directory name
    
    -- Disable unused modules
    t.modules.touch = false
    t.modules.mobile = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
    
    -- Window configuration
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 8
    t.window.depth = 0
    t.window.resizable = false
    t.window.minwidth = 1280
    t.window.minheight = 720
    
    -- Console for debugging
    t.console = true
end