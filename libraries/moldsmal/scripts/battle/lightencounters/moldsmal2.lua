local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* Moldsmal and Moldsmal block\nthe way."

    self.music = "battleut"

    self:addEnemy("moldsmal", SCREEN_WIDTH/2 - 154, 234)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2 + 50, 234)
end

return encounter