local lib = {}

function lib:init()
end

function lib:onRegisterItems()
    if MagicalGlassLib then
        Registry.items["light/stick"] = nil
    end
end

return lib