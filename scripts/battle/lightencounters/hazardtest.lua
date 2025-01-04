local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.music = false
    
    self.story = true
    self.background = false
    
    self.fast_transition = true
end

function encounter:storyWave()
    return "basic"
end

return encounter