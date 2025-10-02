local FleeButton, super = Class(ActionButton)

function FleeButton:init()
    super.init(self, "flee")
    
    self.disabled = not Game.battle.encounter.can_flee
end

return FleeButton