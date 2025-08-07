local saveSystem = {
    filename = "save.dat",
    data = {
        highScore = 0,
        settings = {
            musicVolume = 1.0,
            sfxVolume = 1.0,
            colorblindMode = false,
            difficulty = "normal",
            lastPlayed = "Never"
        }
    }
}

function saveSystem.load()
    local success, contents = pcall(function()
        local file = love.filesystem.read(saveSystem.filename)
        if file then
            return love.data.decode('string', 'base64', file)
        end
        return nil
    end)
    
    if success and contents then
        local decoded = love.data.unpack('table', contents)
        saveSystem.data.highScore = decoded.highScore or 0
        saveSystem.data.settings = decoded.settings or saveSystem.data.settings
    else
        -- If load fails, keep default values and create new save file
        saveSystem.data.settings.lastPlayed = os.date("!%Y-%m-%d %H:%M:%S")
        saveSystem.save()
    end
end

function saveSystem.save()
    local success, encoded = pcall(function()
        -- Update last played time
        saveSystem.data.settings.lastPlayed = os.date("!%Y-%m-%d %H:%M:%S")
        
        local data = love.data.pack('string', 'table', {
            highScore = saveSystem.data.highScore,
            settings = saveSystem.data.settings
        })
        return love.data.encode('string', 'base64', data)
    end)
    
    if success then
        love.filesystem.write(saveSystem.filename, encoded)
    end
end

function saveSystem.updateHighScore(score)
    if score > saveSystem.data.highScore then
        saveSystem.data.highScore = score
        saveSystem.save()
        return true
    end
    return false
end

function saveSystem.getHighScore()
    return saveSystem.data.highScore
end

function saveSystem.getLastPlayed()
    return saveSystem.data.settings.lastPlayed
end

function saveSystem.updateSettings(newSettings)
    for key, value in pairs(newSettings) do
        saveSystem.data.settings[key] = value
    end
    saveSystem.save()
end

function saveSystem.getSettings()
    return saveSystem.data.settings
end

return saveSystem