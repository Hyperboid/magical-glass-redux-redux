---@class Game : Game
local Game, super = Utils.hookScript(Game)

function Game:setupShop(shop)
    local check_shop
    if type(shop) == "string" then
        check_shop = Registry.getShop(shop)
    else
        check_shop = shop
    end
    
    
    super.setupShop(self, shop)
end

function Game:initRecruits()
    self.recruits_data = {}
    for id,_ in pairs(Registry.recruits) do
        if Registry.getRecruit(id) then
            self.recruits_data[id] = Registry.createRecruit(id)
            if self.recruits_data[id]:includes(LightRecruit) then
                error("Attempted to use LightRecruit in a Recruit. Convert the recruit \"" .. id .. "\" file to a Recruit")
            end
        else
            error("Attempted to create non-existent recruit \"" .. id .. "\"")
        end
    end
end

function Game:hasRecruitByData(recruit)
    return self:getAnyRecruitFromRecruitData(recruit):getRecruited() == true
end

function Game:convertToDark()
    if not Kristal.getLibConfig("magical-glass", "item_conversion") then
        local inventory = self.inventory
        self.inventory = inventory:convertToDark()
        for _,chara in pairs(self.party_data) do
            chara:convertToDark()
        end
    else
        return super.convertToDark(self)
    end
end

function Game:getLightRecruits(include_incomplete, include_hidden)
    local recruits = {}
    for id,recruit in pairs(self.light_recruits_data) do
        if (not recruit:getHidden() or include_hidden) and (recruit:getRecruited() == true or include_incomplete and type(recruit:getRecruited()) == "number" and recruit:getRecruited() > 0) then
            table.insert(recruits, recruit)
        end
    end
    table.sort(recruits, function(a,b) return a.index < b.index end)
    return recruits
end

function Game:encounter(encounter, transition, enemy, context, light)
    if MagicalGlassLib.current_battle_system then
        if MagicalGlassLib.current_battle_system == "undertale" then
            self:encounterLight(encounter, transition, enemy, context)
        else
            super.encounter(self, encounter, transition, enemy, context)
        end
    elseif context and isClass(context) and context:includes(ChaserEnemy) then
        if context.light_encounter then
            MagicalGlassLib.current_battle_system = "undertale"
            self:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    elseif light ~= nil then
        if light then
            MagicalGlassLib.current_battle_system = "undertale"
            self:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    else
        if Kristal.getLibConfig("magical-glass", "default_battle_system")[1] == "undertale" then
            MagicalGlassLib.current_battle_system = "undertale"
            self:encounterLight(encounter, transition, enemy, context)
        else
            MagicalGlassLib.current_battle_system = "deltarune"
            super.encounter(self, encounter, transition, enemy, context)
        end
    end
end

function Game:gameOver(x, y, redraw)
    if redraw == nil then
        if self.battle then -- Battle type correction
            if self.battle.light then
                redraw = true
            else
                redraw = false
            end
        end
    end
    super.gameOver(self, x, y, redraw)
    MagicalGlassLib:setGameOvers((MagicalGlassLib:getGameOvers() or 0) + 1)
end

function Game:hasLightRecruit(recruit)
    return self:getLightRecruit(recruit):getRecruited() == true
end

function Game:getAllRecruits(include_incomplete, include_hidden)
    local recruits = Utils.merge(self:getRecruits(include_incomplete, include_hidden), self:getLightRecruits(include_incomplete, include_hidden), true)
    table.sort(recruits, function(a,b) return a.index < b.index end)
    return recruits
end

function Game:encounterLight(encounter, transition, enemy, context)
    if transition == nil then transition = true end
    if self.battle then
        error("Attempt to enter light battle while already in battle")
    end
    
    if enemy and not isClass(enemy) then
        self.encounter_enemies = enemy
    else
        self.encounter_enemies = {enemy}
    end
    self.state = "BATTLE"
    self.battle = LightBattle()
    if context then
        self.battle.encounter_context = context
    end
    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "INTRO", encounter)
    end
    self.stage:addChild(self.battle)
end

function Game:enterShop(shop, options, light)
    if MagicalGlassLib.in_light_shop or light then
        MagicalGlassLib:enterLightShop(shop, options)
    else
        super.enterShop(self, shop, options)
    end
end

function Game:getAnyRecruitFromRecruitData(recruit)
    if recruit:includes(LightRecruit) then
        if self.light_recruits_data[recruit.id] then
            return self.light_recruits_data[recruit.id]
        end
    else
        if self.recruits_data[recruit.id] then
            return self.recruits_data[recruit.id]
        end
    end
end

function Game:getLightRecruit(id)
    if self.light_recruits_data[id] then
        return self.light_recruits_data[id]
    end
end

function Game:convertToLight()
    if not Kristal.getLibConfig("magical-glass", "item_conversion") then
        local inventory = self.inventory
        self.inventory = inventory:convertToLight()
        for _,chara in pairs(self.party_data) do
            chara:convertToLight()
        end
    else
        return super.convertToLight(self)
    end
end

return Game
