---@class Encounter : Encounter
local Encounter, super = Utils.hookScript(Encounter)

function Encounter:onFlee()
    Game.battle:setState("VICTORY", "FLEE")
    
    Assets.playSound("defeatrun")
    for _,party in ipairs(Game.battle.party) do
        party:setSprite("battle/hurt")
        local sweat = Sprite("effects/defeat/sweat")
        sweat:setOrigin(1.5, 0.5)
        sweat:setScale(-1, 1)
        sweat:play(5/30, true)
        sweat.layer = 100
        party:addChild(sweat)
        
        local counter_start = 0
        local counter_end = 0
        Game.battle.timer:doWhile(function() return counter_end >= 0 end, function()
            counter_end = counter_end + DTMULT
            
            if counter_end >= 30 or Game.battle.state == "TRANSITIONOUT" then
                if counter_start < 0 then
                    party.x = -200
                end
                party:getActiveSprite().run_away_party = false
                counter_end = -1
            end
        end)
        Game.battle.timer:doWhile(function() return counter_start >= 0 end, function()
            counter_start = counter_start + DTMULT
            
            if counter_start >= 15 or Game.battle.state == "TRANSITIONOUT" then
                sweat:remove()
                if counter_end >= 0 then
                    party:getActiveSprite().run_away_party = true
                end
                counter_start = -1
            end
        end)
    end
end

function Encounter:getFleeMessage()
    return self.flee_messages[math.min(Utils.random(1, 20, 1), #self.flee_messages)]
end

function Encounter:getVictoryText(text, money, xp)
    if Game.battle.state_reason == "FLEE" then
        if money ~= 0 or xp ~= 0 or Game.battle.used_violence and Game:getConfig("growStronger") and not Game:isLight() then
            if Game:isLight() then
                return "* Ran away with " .. xp .. " EXP\nand " .. money .. " " .. Game:getConfig("lightCurrency"):upper() .. "."
            else
                if Game.battle.used_violence and Game:getConfig("growStronger") then
                    local stronger = "You"
                    
                    for _,battler in ipairs(Game.battle.party) do
                        if Game:getConfig("growStrongerChara") and battler.chara.id == Game:getConfig("growStrongerChara") then
                            stronger = battler.chara:getName()
                            break
                        end
                    end
                    
                    if xp == 0 then
                        return "* Ran away with " .. money .. " " .. Game:getConfig("darkCurrencyShort") .. ".\n* "..stronger.." became stronger."
                    else
                        return "* Ran away with " .. xp .. " EXP and " .. money .. " " .. Game:getConfig("darkCurrencyShort") .. ".\n* "..stronger.." became stronger."
                    end
                else
                    return "* Ran away with " .. xp .. " EXP and " .. money .. " " .. Game:getConfig("darkCurrencyShort") .. "."
                end
            end
        else
            return self:getFleeMessage()
        end
    else
        return super.getVictoryText(self, text, money, xp)
    end
end

function Encounter:onTurnEnd()
    super.onTurnEnd(self)
    self.flee_chance = self.flee_chance + 10
end

function Encounter:onFleeFail()
end

function Encounter:init()
    super.init(self)
    
    -- Whether Karma (KR) UI changes will appear.
    self.karma_mode = false
    
    -- Whether "* But it refused." will replace the game over and revive the player.
    self.invincible = false
    -- Whether the flee command is available at the mercy button
    self.can_flee = Game:isLight()
    -- The chance of successful flee (increases by 10 every turn)
    self.flee_chance = 50
    
    self.flee_messages = {
        "* I'm outta here.", -- 1/20
        "* I've got better to do.", --1/20
        "* Don't slow me down.", --1/20
        "* Escaped..." --17/20
    }
end

return Encounter
