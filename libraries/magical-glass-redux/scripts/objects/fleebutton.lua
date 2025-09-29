local FleeButton, super = Class(ActionButton)

function FleeButton:init()
    super.init(self, "flee")
    
    self.usable = Game.battle.encounter.can_flee
end

return FleeButton