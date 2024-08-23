local spell, super = Class("dual_heal", true)

function spell:onLightCast(user, target)
    self.amount = math.ceil(Game:isLight() and user.chara:getStat("magic") * 3 or user.chara:getStat("magic") * 5.5)
    for _,battler in ipairs(Game.battle.party) do
        battler:heal(self.amount, false, true)
    end
end

return spell