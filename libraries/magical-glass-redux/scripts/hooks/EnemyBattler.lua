---@class EnemyBattler : EnemyBattler
local EnemyBattler, super = Utils.hookScript(EnemyBattler)

function EnemyBattler:onDefeat(damage, battler)
    if self.exit_on_defeat then
        if self.can_die then
            if self.ut_death then
                self:onDefeatVaporized(damage, battler)
            else
                self:onDefeatFatal(damage, battler)
            end
        else
            self:onDefeatRun(damage, battler)
        end
    else
        self.sprite:setAnimation("defeat")
    end
end

function EnemyBattler:onActStart(battler, name)
    if name == "_SAVE" then
        local encounter_text = Game.battle.battle_ui.encounter_text
        battler:setAnimation("battle/act", function()
            if encounter_text.text.text == "" then
                encounter_text:advance()
            end
        end)
    else
        super.onActStart(self, battler, name)
    end
end

function EnemyBattler:init(actor, use_overlay)
    super.init(self, actor, use_overlay)
    
    -- Whether selecting the enemy using SAVE will skip the turn (similar to the end of the Asirel fight in UT)
    self.save_no_acts = false
    
    -- Whether this enemy can die, and whether it's the Undertale death or Deltarune death
    self.can_die = Game:isLight() and true or false
    self.ut_death = Game:isLight() and true or false
    
    -- Whether this enemy should use bigger dust particles upon death when ut_death is enabled.
    self.large_dust = false
    
    self.tired_percentage = Game:isLight() and 0 or 0.5
    self.spare_percentage = Game:isLight() and 0.25 or 0
    self.low_health_percentage = Game:isLight() and 0.25 or 0.5
    
    -- Whether the enemy deals bonus damage when having more HP (Light World only)
    self.bonus_damage = true
end

function EnemyBattler:onDefeatVaporized(damage, battler)
    self.hurt_timer = -1
    Assets.playSound("vaporized", 1.2)
    local sprite = self:getActiveSprite()
    sprite.visible = false
    sprite:stopShake()
    local death_x, death_y = sprite:getRelativePos(0, 0, self)
    local death
    if self.large_dust then
        death = DustEffectLarge(sprite:getTexture(), death_x, death_y, true, function() self:remove() end)
    else
        death = DustEffect(sprite:getTexture(), death_x, death_y, true, function() self:remove() end)
    end
        
    death:setColor(sprite:getDrawColor())
    death:setScale(sprite:getScale())
    self:addChild(death)
    self:defeat("KILLED", true)
end

function EnemyBattler:onSave(battler)
end

function EnemyBattler:onHurt(damage, battler)
    super.onHurt(self, damage, battler)
    
    if self.health <= (self.max_health * self.spare_percentage) then
        self.mercy = 100
    end
end

function EnemyBattler:freeze()
    if not self.can_freeze then
        self:onDefeat()
    else
        super.freeze(self)
        if Game:isLight() then
            Game.battle.money = Game.battle.money - 24 + 2
        end
    end
end

function EnemyBattler:getAttackDamage(damage, battler, points)
    if damage > 0 then
        return damage
    end
    if Game:isLight() then
        return ((battler.chara:getStat("attack") * points) / 68) - (self.defense * 2.2)
    else
        return super.getAttackDamage(self, damage, battler, points)
    end
end

function EnemyBattler:defeat(reason, violent)
    super.defeat(self, reason, violent)
    if violent then
        if Game:isLight() and (self.done_state == "KILLED" or self.done_state == "FROZEN") then
            MagicalGlassLib.kills = MagicalGlassLib.kills + 1
        end
        if MagicalGlassLib.random_encounter and MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter).population then
            MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter):addFlag("violent", 1)
        end
    end
end

return EnemyBattler
