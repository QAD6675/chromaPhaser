-- conf.lua
function love.conf(t)
    -- Game Identity
    t.identity = "chromaphaser"     -- Save directory name
    t.version = "11.5"              -- LÖVE version
    t.appendidentity = false

    -- Window
    t.window.title = "Chromaphaser"
    t.window.icon = nil             -- You can add assets/images/icon.png later
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.vsync = 1
    t.window.msaa = 0               -- No anti-aliasing by default
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"

    -- Modules (disable unused for performance)
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end
