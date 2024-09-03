local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* You tripped into a line of Moldsmals."

    self.music = "battleut"

    self:addEnemy("moldsmal", SCREEN_WIDTH/2 - 255, 234)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2 - 53, 234)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2 + 151, 234)
end

return encounter