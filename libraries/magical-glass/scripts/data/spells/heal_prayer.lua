local spell, super = Class("heal_prayer", true)

function spell:onLightCast(user, target)
    self.amount = math.ceil(Game:isLight() and user.chara:getStat("magic") * 2.5 or user.chara:getStat("magic") * 5)
    target:heal(self.amount, false, true)
end

function spell:getLightCastMessage(user, target)
    return super.getLightCastMessage(self, user, target).."\n"..self:getHealMessage(user, target, self.amount)
end

return spell