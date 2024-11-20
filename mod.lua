function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:load(data, new_file)
    if new_file then
        Game.money = Kristal.getLibConfig("magical-glass", "debug") and 1000 or 0
        Game.lw_money = Kristal.getLibConfig("magical-glass", "debug") and 1000 or 0
        MagicalGlassLib:setLightBattleShakingText(true)
        MagicalGlassLib:setCellCallsRearrangement(true)
        -- local party = Game:getPartyMember("noelle")
        -- party:setLightEXP(69420)
        -- party.lw_health = party.lw_stats.health
    end
    Game.world:registerCall("Dimensional Box A", "cell.box_a", false)
    Game.world:registerCall("Dimensional Box B", "cell.box_b", false)
end

-- function Mod:getLightActionButtons(battler, buttons)
    -- return {"fight", "act"}
-- end