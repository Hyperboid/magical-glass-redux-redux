local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* Holy FUCK 2.0"

    self.music = Game:isLight() and "battle2_ut" or "battle2_dt"
    
    for i = 1, 100 do
        local frog = self:addEnemy("froggit", Utils.random(SCREEN_WIDTH), Utils.random(SCREEN_HEIGHT/2) + 50)
        frog:addFX(ShaderFX(MagicalGlassLib:colorShader({Utils.random(), Utils.random(), Utils.random(), 1})))
    end

end

return encounter