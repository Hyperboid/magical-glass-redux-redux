---@class PartyBattler : PartyBattler
local PartyBattler, super = Utils.hookScript(PartyBattler)

function PartyBattler:addKarma(amount)
    self.karma = self.karma + amount
end

function PartyBattler:calculateDamage(amount)
    if Game:isLight() then
        local def = self.chara:getStat("defense")
        local hp = self.chara:getHealth()
        
        local bonus = (MagicalGlassLib.bonus_damage ~= false and self.bonus_damage ~= false) and hp > 20 and math.min(1 + math.floor((hp - 20) / 10), 8) or 0
        amount = Utils.round(amount + bonus - def / 5)
        
        return math.max(amount, 1)
    else
        return super.calculateDamage(self, amount)
    end
end

function PartyBattler:toggleSaveButton(value)
    if value == nil then
        self.has_save = not self.has_save
    else
        self.has_save = value
    end
end

function PartyBattler:hurt(amount, exact, color, options)
    if type(exact) == "string" then
        exact = false
        self.bonus_damage = false
    end
    super.hurt(self, amount, exact, color, options)
    self.bonus_damage = nil
end

function PartyBattler:calculateDamageSimple(amount)
    if Game:isLight() then
        return math.ceil(amount - (self.chara:getStat("defense") / 5))
    else
        return super.calculateDamageSimple(self, amount)
    end
end

function PartyBattler:update()
    super.update(self)
    
    -- Karma (KR) calculations
    self.karma = Utils.clamp(self.karma, 0, 40)
    if self.karma >= self.chara:getHealth() and self.chara:getHealth() > 0 then
        self.karma = self.chara:getHealth() - 1
    end
    if self.karma > 0 and self.chara:getHealth() > 1 then
        self.karma_timer = self.karma_timer + DTMULT
        if self.prev_health == self.chara:getHealth() then
            self.karma_bonus = 0
            self.inv_bonus = 0
            for _,equip in ipairs(self.chara:getEquipment()) do
                if equip.getInvBonus then
                    self.inv_bonus = self.inv_bonus + equip:getInvBonus()
                end
            end
            if self.inv_bonus >= 15/30 then
                self.karma_bonus = Utils.pick({0,1})
            end
            if self.inv_bonus >= 30/30 then
                self.karma_bonus = Utils.pick({0,1,1})
            end
            if self.inv_bonus >= 45/30 then
                self.karma_bonus = 1
            end
            
            local function hurtKarma()
                self.karma_timer = 0
                self.chara:setHealth(self.chara:getHealth() - 1)
                self.karma = self.karma - 1
            end
            
            if self.karma_timer >= (1 + self.karma_bonus) and self.karma >= 40 then
                hurtKarma()
            end
            if self.karma_timer >= (2 + self.karma_bonus * 2) and self.karma >= 30 then
                hurtKarma()
            end
            if self.karma_timer >= (5 + self.karma_bonus * 3) and self.karma >= 20 then
                hurtKarma()
            end
            if self.karma_timer >= (15 + self.karma_bonus * 5) and self.karma >= 10 then
                hurtKarma()
            end
            if self.karma_timer >= (30 + self.karma_bonus * 10) then
                hurtKarma()
            end
            if self.chara:getHealth() <= 0 then
                self.chara:setHealth(1)
            end
        end
        self.prev_health = self.chara:getHealth()
    end
end

function PartyBattler:init(chara, x, y)
    super.init(self, chara, x, y)
    
    self.already_has_flee_button = false
    self.flee_button = nil
    
    self.has_save = false
    self.already_has_save_button = false
    self.save_button = nil
    
    -- Karma (KR) calculations
    self.karma = 0
    self.karma_timer = 0
    self.karma_bonus = 0
    self.prev_health = 0
    self.inv_bonus = 0
end

return PartyBattler
