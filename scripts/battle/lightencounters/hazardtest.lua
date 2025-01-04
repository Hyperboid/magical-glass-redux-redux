local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.music = false
    
    self.event = true
    self.background = false
    
    self.fast_transition = true
end

function encounter:eventWave()
    return "basic"
end

return encounter