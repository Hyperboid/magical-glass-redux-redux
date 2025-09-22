local lib = {}

function lib:init()
    Utils.hook(EnemyBattler, "setTired", function(orig, self, bool)
        local old_tired = self.tired
        self.tired = bool
        if self.tired then
            self.comment = "(Tired)"
            if not old_tired and Game:getConfig("tiredMessages") and self.health > 0 then
                -- Check for self.parent so setting Tired state in init doesn't crash
                if self.parent then
                    self:statusMessage("msg", "tired")
                    Assets.playSound("spellcast", 0.5, 0.9)
                end
            end
        else
            self.comment = ""
            if old_tired and Game:getConfig("awakeMessages") and self.health > 0 then
                if self.parent then self:statusMessage("msg", "awake") end
            end
        end
    end)
    
    -- Stops the camera shake.
    Utils.hook(Battle, "stopCameraShake", function(orig, self)
        self.camera:stopShake()
    end)
    
    Utils.hook(Battle, "hurt", function(orig, self, amount, exact, target, swoon)
        pcall(function() orig(self, amount, exact, target, swoon) end)
    end)
    
    Utils.hook(Battle, "checkGameOver", function(orig, self)
        self:stopCameraShake()
        return orig(self)
    end)
    
    Utils.hook(PartyBattler, "hurt", function(orig, self, amount, exact, color, options)
        Assets.playSound("hurt")

        self:shakeCamera()
        self:showHealthBars()

        if type(battler) == "number" then
            amount = battler
            battler = nil
        end

        local any_killed = false
        local any_alive = false
        for _,party in ipairs(Game.party) do
            if not battler or battler == party.id or battler == party then
                local current_health = party:getHealth()
                party:setHealth(party:getHealth() - amount)
                if party:getHealth() <= 0 then
                    party:setHealth(1)
                    any_killed = true
                else
                    any_alive = true
                end

                local dealt_amount = current_health - party:getHealth()

                if dealt_amount > 0 then
                    self:getPartyCharacterInParty(party):statusMessage("damage", dealt_amount)
                end
            elseif party:getHealth() > amount then
                any_alive = true
            end
        end

        if self.player then
            self.player.hurt_timer = 7
        end

        if any_killed and not any_alive then
            self:stopCameraShake()
            if not self.map:onGameOver() then
                Game:gameOver(self.soul:getScreenPos())
            end
            return true
        elseif battler then
            return any_killed
        end

        return false
    end)
    
    -- Stops the camera shake.
    Utils.hook(World, "stopCameraShake", function(orig, self)
        self.camera:stopShake()
    end)
    
    Utils.hook(World, "hurtParty", function(orig, self, battler, amount)
        Assets.playSound("hurt")

        self:shakeCamera()
        self:showHealthBars()

        if type(battler) == "number" then
            amount = battler
            battler = nil
        end

        local any_killed = false
        local any_alive = false
        for _,party in ipairs(Game.party) do
            if not battler or battler == party.id or battler == party then
                local current_health = party:getHealth()
                party:setHealth(party:getHealth() - amount)
                if party:getHealth() <= 0 then
                    party:setHealth(1)
                    any_killed = true
                else
                    any_alive = true
                end

                local dealt_amount = current_health - party:getHealth()

                if dealt_amount > 0 then
                    self:getPartyCharacterInParty(party):statusMessage("damage", dealt_amount)
                end
            elseif party:getHealth() > amount then
                any_alive = true
            end
        end

        if self.player then
            self.player.hurt_timer = 7
        end

        if any_killed and not any_alive then
            self:stopCameraShake()
            if not self.map:onGameOver() then
                Game:gameOver(self.soul:getScreenPos())
            end
            return true
        elseif battler then
            return any_killed
        end

        return false
    end)
    
    Utils.hook(Game, "gameOver", function(orig, self, x, y, redraw)
        if redraw or (redraw == nil and Game:isLight()) then
            love.draw() -- Redraw the frame so the screenshot will use an updated draw data
        end
        orig(self, x, y, redraw)
    end)
    
    Utils.hook(PartyMember, "init", function(orig, self)
        -- Message will show even if the member is the soul character
        self.force_gameover_message = false
        
        -- The number of times that this party member got stronger (saved to the save file)
        self.level_up_count = 0
        
        -- Battle soul position offset (optional)
        self.soul_offset = nil
        
        orig(self)
    end)
    
    Utils.hook(PartyMember, "getForceGameOverMessage", function(orig, self)
        return self.force_gameover_message
    end)
    
    Utils.hook(PartyMember, "getSoulOffset", function(orig, self)
        return unpack(self.soul_offset or {0, 0})
    end)
    
    Utils.hook(Encounter, "getSoulSpawnLocation", function(orig, self)
        local main_chara = Game:getSoulPartyMember()

        if main_chara and main_chara:getSoulPriority() >= 0 then
            local battler = Game.battle.party[Game.battle:getPartyIndex(main_chara.id)]

            if battler then
                local offset_x, offset_y = main_chara:getSoulOffset()
                return battler:localToScreenPos(battler.sprite.width/2 - 4.5 + offset_x, battler.sprite.height/2 + offset_y)
            end
        end
        return -9, -9
    end)
    
    Utils.hook(PartyMember, "autoHealAmount", function(orig, self)
        return math.ceil(self:getStat("health") / 8)
    end)
    
    Utils.hook(PartyMember, "onSave", function(orig, self, data)
        orig(self, data)
        data["level_up_count"] = self.level_up_count
    end)
    
    Utils.hook(PartyMember, "onLoad", function(orig, self, data)
        orig(self, data)
        self.level_up_count = data.level_up_count or self.level_up_count
    end)
    
    Utils.hook(PartyBattler, "calculateDamage", function(orig, self, amount)
        local def = self.chara:getStat("defense")
        local max_hp = self.chara:getStat("health")

        local threshold_a = (max_hp / 5)
        local threshold_b = (max_hp / 8)
        for i = 1, math.abs(def) do
            if amount > threshold_a then
                amount = amount + (def >= 0 and -3 or 3)
            elseif amount > threshold_b then
                amount = amount + (def >= 0 and -2 or 2)
            else
                amount = amount + (def >= 0 and -1 or 1)
            end
            if def >= 0 then
                if amount <= 0 or def == math.huge then
                    amount = 0
                    break
                end
            else
                if amount == math.huge or def == -math.huge then
                    amount = math.huge
                    break
                end
            end
        end

        return math.max(amount, 1)
    end)
    
    Utils.hook(Shop, "init", function(orig, self)
        orig(self)
        
        self.background = nil
        self.background_speed = 5/30
    end)
    
    Utils.hook(Shop, "postInit", function(orig, self)
        orig(self)
        
        if self.background and self.background ~= "" then 
            self.background_sprite:play(self.background_speed, true)
        end
    end)
    
    Utils.hook(Battle, "onStateChange", function(orig, self, old, new)
        local result = self.encounter:beforeStateChange(old,new)
        if result or self.state ~= new then
            return
        end
    
        if new == "VICTORY" then
            self.current_selecting = 0

            if self.tension_bar then
                self.tension_bar:hide()
            end

            for _,battler in ipairs(self.party) do
                battler:setSleeping(false)
                battler.defending = false
                battler.action = nil

                battler.chara:resetBuffs()

                if battler.chara:getHealth() <= 0 then
                    battler:revive()
                    battler.chara:setHealth(battler.chara:autoHealAmount())
                end

                battler:setAnimation("battle/victory")

                local box = self.battle_ui.action_boxes[self:getPartyIndex(battler.chara.id)]
                box:resetHeadIcon()
            end

            self.money = self.money + (math.floor(((Game:getTension() * 2.5) / 10)) * Game.chapter)

            for _,battler in ipairs(self.party) do
                for _,equipment in ipairs(battler.chara:getEquipment()) do
                    self.money = math.floor(equipment:applyMoneyBonus(self.money) or self.money)
                end
            end

            self.money = math.floor(self.money)

            self.money = self.encounter:getVictoryMoney(self.money) or self.money
            self.xp = self.encounter:getVictoryXP(self.xp) or self.xp
            -- if (in_dojo) then
            --     self.money = 0
            -- end

            Game.money = Game.money + self.money
            Game.xp = Game.xp + self.xp

            if (Game.money < 0) then
                Game.money = 0
            end

            local win_text = "* You won!\n* Got " .. self.xp .. " EXP and " .. self.money .. " "..Game:getConfig("darkCurrencyShort").."."
            -- if (in_dojo) then
            --     win_text == "* You won the battle!"
            -- end
            if self.used_violence and Game:getConfig("growStronger") then
                local stronger = "You"

                local party_to_lvl_up = {}
                for _,battler in ipairs(self.party) do
                    table.insert(party_to_lvl_up, battler.chara)
                    if Game:getConfig("growStrongerChara") and battler.chara.id == Game:getConfig("growStrongerChara") then
                        stronger = battler.chara:getName()
                    end
                    for _,id in pairs(battler.chara:getStrongerAbsent()) do
                        table.insert(party_to_lvl_up, Game:getPartyMember(id))
                    end
                end
                
                for _,party in ipairs(Utils.removeDuplicates(party_to_lvl_up)) do
                    party.level_up_count = party.level_up_count + 1
                    party:onLevelUp(party.level_up_count)
                end

                win_text = "* You won!\n* Got " .. self.money .. " "..Game:getConfig("darkCurrencyShort")..".\n* "..stronger.." became stronger."

                Assets.playSound("dtrans_lw", 0.7, 2)
                --scr_levelup()
            end

            win_text = self.encounter:getVictoryText(win_text, self.money, self.xp) or win_text

            if self.encounter.no_end_message then
                self:setState("TRANSITIONOUT")
                self.encounter:onBattleEnd()
            else
                self:battleText(win_text, function()
                    self:setState("TRANSITIONOUT")
                    self.encounter:onBattleEnd()
                    return true
                end)
            end
            
            
            -- List of states that should remove the arena.
            -- A whitelist is better than a blacklist in case the modder adds more states.
            -- And in case the modder adds more states and wants the arena to be removed, they can remove the arena themselves.
            local remove_arena = {"DEFENDINGEND", "TRANSITIONOUT", "ACTIONSELECT", "VICTORY", "INTRO", "ACTIONS", "ENEMYSELECT", "XACTENEMYSELECT", "PARTYSELECT", "MENUSELECT", "ATTACKING"}

            local should_end = true
            if Utils.containsValue(remove_arena, new) then
                for _,wave in ipairs(self.waves) do
                    if wave:beforeEnd() then
                        should_end = false
                    end
                end
                if should_end then
                    self:returnSoul()
                    if self.arena then
                        self.arena:remove()
                        self.arena = nil
                    end
                    for _,battler in ipairs(self.party) do
                        battler.targeted = false
                    end
                end
            end

            local ending_wave = self.state_reason == "WAVEENDED"

            if old == "DEFENDING" and new ~= "DEFENDINGBEGIN" and should_end then
                for _,wave in ipairs(self.waves) do
                    if not wave:onEnd(false) then
                        wave:clear()
                        wave:remove()
                    end
                end

                local function exitWaves()
                    for _,wave in ipairs(self.waves) do
                        wave:onArenaExit()
                    end
                    self.waves = {}
                end

                if self:hasCutscene() then
                    self.cutscene:after(function()
                        exitWaves()
                        if ending_wave then
                            self:nextTurn()
                        end
                    end)
                else
                    self.timer:after(15/30, function()
                        exitWaves()
                        if ending_wave then
                            self:nextTurn()
                        end
                    end)
                end
            end

            self.encounter:onStateChange(old,new)
        else
            orig(self, old, new)
        end
    end)
end

return lib