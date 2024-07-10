local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* Holy FUCK 2.0"

    self.music = "battle2ut"
    
    for i = 1, 100 do
        local frog = self:addEnemy("froggit", Utils.random(SCREEN_WIDTH), Utils.random(SCREEN_HEIGHT/2) + 50)
        frog:addFX(ColorMaskFX({Utils.random(),Utils.random(),Utils.random()},0.9))
    end

end

return encounter