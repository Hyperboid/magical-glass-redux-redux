local spell, super = Class("ultimate_heal", true)

function spell:onLightCast(user, target)
    self.amount = math.ceil(Game:isLight() and user.chara:getStat("magic") or user.chara:getStat("magic") + 1)
    target:heal(self.amount, false, true)
end

function spell:getLightCastMessage(user, target)
    return super.getLightCastMessage(self, user, target).."\n"..self:getHealMessage(user, target, self.amount)
end

return spell
