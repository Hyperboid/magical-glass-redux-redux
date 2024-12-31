TweenManager             = libRequire("magical-glass", "scripts/tweenmanager")
LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightPartyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightpartybattler")
LightEnemyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightenemybattler")
LightEnemySprite         = libRequire("magical-glass", "scripts/lightbattle/lightenemysprite")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")
LightSoul                = libRequire("magical-glass", "scripts/lightbattle/lightsoul")
LightWave                = libRequire("magical-glass", "scripts/lightbattle/lightwave")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/ui/lightbattleui")
HelpWindow               = libRequire("magical-glass", "scripts/lightbattle/ui/helpwindow")
LightDamageNumber        = libRequire("magical-glass", "scripts/lightbattle/ui/lightdamagenumber")
LightGauge               = libRequire("magical-glass", "scripts/lightbattle/ui/lightgauge")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/ui/lighttensionbar")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbox")
LightAttackBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbox")
LightAttackBar           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbar")
LightStatusDisplay       = libRequire("magical-glass", "scripts/lightbattle/ui/lightstatusdisplay")
LightShop                = libRequire("magical-glass", "scripts/lightshop")
RandomEncounter          = libRequire("magical-glass", "scripts/randomencounter")

MagicalGlassLib = {}
local lib = MagicalGlassLib
-- Mod.libs["magical-glass"]

function lib:unload()
    MagicalGlassLib          = nil
    MG_PALETTE               = nil
    TweenManager             = nil
    LightBattle              = nil
    LightPartyBattler        = nil
    LightEnemyBattler        = nil
    LightEnemySprite         = nil
    LightArena               = nil
    LightEncounter           = nil
    LightSoul                = nil
    LightWave                = nil
    LightBattleUI            = nil
    HelpWindow               = nil
    LightDamageNumber        = nil
    LightGauge               = nil
    LightTensionBar          = nil
    LightActionButton        = nil
    LightActionBox           = nil
    LightAttackBox           = nil
    LightAttackBar           = nil
    LightStatusDisplay       = nil
    RandomEncounter          = nil
    LightShop                = nil
end

function lib:save(data)
    data.magical_glass = {}
    data.magical_glass["kills"] = lib.kills
    data.magical_glass["serious_mode"] = lib.serious_mode
    data.magical_glass["spare_color"] = lib.spare_color
    data.magical_glass["spare_color_name"] = lib.spare_color_name
    data.magical_glass["lw_save_lv"] = Game.party[1] and Game.party[1]:getLightLV() or 0
    data.magical_glass["in_light_shop"] = lib.in_light_shop
    data.magical_glass["current_battle_system"] = lib.current_battle_system
    data.magical_glass["random_encounter"] = lib.random_encounter
    data.magical_glass["light_battle_shake_text"] = lib.light_battle_shake_text
    data.magical_glass["rearrange_cell_calls"] = lib.rearrange_cell_calls
    data.magical_glass["lightmenu_calls"] = Game.world.calls
end

function lib:load(data, new_file)
    if not love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        love.filesystem.write("saves/" .. Mod.info.id .. "/global.json", self:initGlobalSave())
    end
    
    Game.light = Kristal.getLibConfig("magical-glass", "default_battle_system")[2] or false
    
    if new_file then
        lib.kills = 0
        lib.serious_mode = false
        lib.spare_color = COLORS.yellow
        lib.spare_color_name = "YELLOW"
        lib.lw_save_lv = 0
        lib.in_light_shop = false
        self:setGameOvers(0)
        lib.light_battle_shake_text = 0
        lib.rearrange_cell_calls = false
        
        lib.initialize_armor_conversion = true
    else
        data.magical_glass = data.magical_glass or {}
        lib.kills = data.magical_glass["kills"] or 0
        self:setGameOvers(self:getGameOvers() or 0)
        lib.serious_mode = data.magical_glass["serious_mode"] or false
        lib.spare_color = data.magical_glass["spare_color"] or COLORS.yellow
        lib.spare_color_name = data.magical_glass["spare_color_name"] or "YELLOW"
        lib.lw_save_lv = data.magical_glass["lw_save_lv"] or 0
        lib.in_light_shop = data.magical_glass["in_light_shop"] or false
        lib.current_battle_system = data.magical_glass["current_battle_system"] or nil
        lib.random_encounter = data.magical_glass["random_encounter"] or lib.random_encounter or nil
        lib.light_battle_shake_text = data.magical_glass["light_battle_shake_text"] or 0
        lib.rearrange_cell_calls = data.magical_glass["rearrange_cell_calls"] or false
        if lib.rearrange_cell_calls and data.magical_glass["lightmenu_calls"] then
            Game.world.timer:after(1/30, function()
                Game.world.calls = data.magical_glass["lightmenu_calls"]
            end)
        end
        
        for _,party in pairs(Game.party_data) do -- Fixes a crash with existing saves
            if not party.lw_stats["magic"] then
                party:reloadLightStats()
            end
        end
        
    end
end

-- GLOBAL SAVE

local read = love.filesystem.read
local write = love.filesystem.write

function lib:initGlobalSave()
    local data = {}

    data["global"] = {}

    data["files"] = {}
    for i = 1, 3 do
        data["files"][i] = {}
    end

    return JSON.encode(data)
end

function lib:setGameOvers(amount)
    lib.game_overs = amount
    lib:writeToGlobalSaveFile("game_overs", lib.game_overs)
end

function lib:getGameOvers()
    return lib:readFromGlobalSaveFile("game_overs")
end

function lib:writeToGlobalSaveFile(key, data, file)
    file = file or Game.save_id
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        global_data.files[file][key] = data
        write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
    end
end

function lib:writeToGlobalSave(key, data)
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        global_data.global[key] = data
        write("saves/" .. Mod.info.id .. "/global.json", JSON.encode(global_data))
    end
end

function lib:readFromGlobalSaveFile(key, file)
    file = file or Game.save_id
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        return global_data.files[file][key]
    end
end

function lib:readFromGlobalSave(key)
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        local global_data = JSON.decode(read("saves/" .. Mod.info.id .. "/global.json"))
        return global_data.global[key]
    end
end

function lib:clearGlobalSave()
    if love.filesystem.getInfo("saves/" .. Mod.info.id .. "/global.json") then
        love.filesystem.write("saves/" .. Mod.info.id .. "/global.json", self:initGlobalSave())
    end
end

function lib:preInit()
    MG_PALETTE = {
        ["tension_maxtext"] = PALETTE["tension_maxtext"],
        ["tension_back"] = PALETTE["tension_back"],
        ["tension_decrease"] = PALETTE["tension_decrease"],
        ["tension_fill"] = PALETTE["tension_fill"],
        ["tension_max"] = PALETTE["tension_max"],
        
        ["tension_desc"] = PALETTE["tension_desc"],
        
        ["action_health_bg"] = COLORS.red,
        ["action_health"] = COLORS.lime,
        ["action_health_text"] = PALETTE["action_health_text"],
        ["battle_mercy_bg"] = PALETTE["battle_mercy_bg"],
        ["battle_mercy_text"] = PALETTE["battle_mercy_text"],
        
        ["pink_spare"] = {255/255, 187/255, 212/255, 1},
        
        ["player_health_bg"] = COLORS.red,
        ["player_health"] = COLORS.yellow,
        ["player_karma_health_bg"] = {192/255, 0, 0, 1},
        ["player_karma_health"] = COLORS.fuchsia,
        
        ["player_health_bg_dark"] = PALETTE["action_health_bg"],
        ["player_karma_health_dark"] = COLORS.silver,
        
        ["player_defending_text"] = COLORS.aqua,
        ["player_action_text"] = COLORS.yellow,
        ["player_down_text"] = COLORS.red,
        ["player_sleeping_text"] = COLORS.blue,
        ["player_karma_text"] = COLORS.fuchsia,
        
        ["light_world_dark_battle_color"] = COLORS.white,
        ["light_world_dark_battle_color_attackbar"] = COLORS.lime,
        ["light_world_dark_battle_color_attackbox"] = {0.5, 0, 0, 1},
        ["light_world_dark_battle_color_damage_single"] = COLORS.white,
    }
    
    self.random_encounters = {}
    self.light_encounters = {}
    self.light_enemies = {}
    self.light_waves = {}
    self.light_shops = {}

    for _,path,rnd_enc in Registry.iterScripts("battle/randomencounters") do
        assert(rnd_enc ~= nil, '"randomencounters/'..path..'.lua" does not return value')
        rnd_enc.id = rnd_enc.id or path
        self.random_encounters[rnd_enc.id] = rnd_enc
    end

    for _,path,light_enc in Registry.iterScripts("battle/lightencounters") do
        assert(light_enc ~= nil, '"lightencounters/'..path..'.lua" does not return value')
        light_enc.id = light_enc.id or path
        self.light_encounters[light_enc.id] = light_enc
    end

    for _,path,light_enemy in Registry.iterScripts("battle/lightenemies") do
        assert(light_enemy ~= nil, '"lightenemies/'..path..'.lua" does not return value')
        light_enemy.id = light_enemy.id or path
        self.light_enemies[light_enemy.id] = light_enemy
    end
    
    for _,path,light_wave in Registry.iterScripts("battle/lightwaves") do
        assert(light_wave ~= nil, '"lightwaves/'..path..'.lua" does not return value')
        light_wave.id = light_wave.id or path
        self.light_waves[light_wave.id] = light_wave
    end

    for _,path,light_shop in Registry.iterScripts("lightshops") do
        assert(light_shop ~= nil, '"lightshops/'..path..'.lua" does not return value')
        light_shop.id = light_shop.id or path
        self.light_shops[light_shop.id] = light_shop
    end
end

function lib:init()

    print("Loaded Magical Glass: Redux " .. self.info.version .. "!")

    self.encounters_enabled = false
    self.steps_until_encounter = nil
    
    Utils.hook(Arena, "init", function(orig, self, x, y, shape)
        orig(self, x, y, shape)
        if Game:isLight() then
            self.color = {1, 1, 1}
        end
    end)
    
    Utils.hook(LightCellMenu, "runCall", function(orig, self, call)
        orig(self, call)
        if lib.rearrange_cell_calls then
            table.insert(Game.world.calls, 1, Utils.removeFromTable(Game.world.calls, call))
        end
    end)
    
    Utils.hook(Choicebox, "clearChoices", function(orig, self)
        orig(self)
        if Game.battle and Game.battle.light then
            for i = 1, 2 do
                Game.battle.battle_ui.choice_option[i]:setText("")
            end
            self.current_choice = 1
            Input.clear("confirm")
        end
    end)
    
    Utils.hook(Choicebox, "update", function(orig, self)
        if Game.battle and Game.battle.light then
            local old_choice = self.current_choice
            if Input.pressed("left") or Input.pressed("right") then
                Game.battle:playMoveSound()
                if self.current_choice == 1 then
                    self.current_choice = 2
                else
                    self.current_choice = 1
                end
            end

            if self.current_choice > #self.choices then
                self.current_choice = old_choice
            end

            if Input.pressed("confirm") then
                if self.current_choice ~= 0 then
                    self.selected_choice = self.current_choice

                    self.done = true
                    Game.battle:toggleSoul(false)

                    if not self.battle_box then
                        self:remove()
                        if Game.world:hasCutscene() then
                            Game.world.cutscene.choice = self.selected_choice
                            Game.world.cutscene:tryResume()
                        end
                    else
                        self:clearChoices()
                        self.active = false
                        self.visible = false
                        Game.battle.battle_ui.encounter_text.active = true
                        Game.battle.battle_ui.encounter_text.visible = true
                        if Game.battle:hasCutscene() then
                            Game.battle.cutscene.choice = self.selected_choice
                            Game.battle.cutscene:tryResume()
                        end
                    end
                end
            end
            Object.update(self)
        else
            orig(self)
        end
    end)
    
    Utils.hook(Choicebox, "draw", function(orig, self)
        if Game.battle and Game.battle.light then
            Object.draw(self)
            love.graphics.setFont(self.font)
            if self.choices[1] then
                Game.battle.battle_ui.choice_option[1]:setPosition(48, 30 - (select(2, string.gsub(self.choices[1], "\n", "")) >= 2 and love.graphics.getFont():getHeight() or 0))
                Game.battle.battle_ui.choice_option[1]:setText("[shake:"..MagicalGlassLib.light_battle_shake_text.."]" .. self.choices[1])
            end
            if self.choices[2] then
                Game.battle.battle_ui.choice_option[2]:setPosition(304, 30 - (select(2, string.gsub(self.choices[2], "\n", "")) >= 2 and love.graphics.getFont():getHeight() or 0))
                Game.battle.battle_ui.choice_option[2]:setText("[shake:"..MagicalGlassLib.light_battle_shake_text.."]" .. self.choices[2])
            end

            local soul_positions = {
                --[[ Left:   ]] {80, 318},
                --[[ Right:  ]] {340, 318},
            }

            local heart_x = soul_positions[self.current_choice][1]
            local heart_y = soul_positions[self.current_choice][2]

            Game.battle:toggleSoul(true)
            Game.battle.soul:setPosition(heart_x, heart_y)
        else
            orig(self)
        end
    end)
    
    Utils.hook(DebugSystem, "update", function(orig, self)
        orig(self)
        if self:isMenuOpen() then
            for state,menus in pairs(self.exclusive_battle_menus) do
                if state == "DARKBATTLE" then
                    state = false
                elseif state == "LIGHTBATTLE" then
                    state = true
                end
                if Utils.containsValue(menus, self.current_menu) and type(state) == "boolean" and Game.battle and Game.battle.light ~= state then
                    self:refresh()
                end
            end
            for state,menus in pairs(self.exclusive_world_menus) do
                if state == "DARKWORLD" then
                    state = false
                elseif state == "LIGHTWORLD" then
                    state = true
                end
                if Utils.containsValue(menus, self.current_menu) and type(state) == "boolean" and Game:isLight() ~= state then
                    self:refresh()
                end
            end
        end
    end)
    
    Utils.hook(World, "transitionMusic", function(orig, self, next, fade_out)
        if self.music.current ~= "toomuch" then
            orig(self, next, fade_out)
        end
    end)
    
    Utils.hook(World, "mapTransition", function(orig, self, ...)
        orig(self, ...)
        lib.map_transitioning = true
        lib.steps_until_encounter = nil
        if lib.initiating_random_encounter then
            Game.lock_movement = false
            lib.initiating_random_encounter = nil
        end
    end)
    
    Utils.hook(World, "loadMap", function(orig, self, ...) -- Punch Card Exploit Emulation
        if lib.exploit then
            self:stopCutscene()
        end
        orig(self, ...)
        lib.map_transitioning = false
        if lib.viewing_image then
            local facing = Game.world.player and Game.world.player.facing or "down"
            for _,party in ipairs(Utils.mergeMultiple(Game.stage:getObjects(Player), Game.stage:getObjects(Follower))) do
                party:remove()
            end
            self:spawnParty("spawn", nil, nil, facing)
        end
        lib.viewing_image = false
    end)
    
    Utils.hook(Game, "enterShop", function(orig, self, shop, options, light)
        if lib.in_light_shop or light then
            MagicalGlassLib:enterLightShop(shop, options)
        else
            orig(self, shop, options)
        end
    end)

    Utils.hook(World, "lightShopTransition", function(orig, self, shop, options)
        self:fadeInto(function()
            MagicalGlassLib:enterLightShop(shop, options)
        end)
    end)
    
    Utils.hook(WorldCutscene, "showShop", function(orig, self)
        if Game:isLight() then
            if self.shopbox then self.shopbox:remove() end

            self.shopbox = LightShopbox()
            self.shopbox.layer = WORLD_LAYERS["textbox"]
            self.world:addChild(self.shopbox)
            self.shopbox:setParallax(0, 0)
        else
            orig(self)
        end
    end)
    
    Utils.hook(Battle, "init", function(orig, self)
        orig(self)
        self.light = false
        self.soul_speed_bonus = 0
    end)
    
    Utils.hook(Battle, "postInit", function(orig, self, state, encounter)
        orig(self, state, encounter)
        if not Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") and Game:isLight() then
            self.tension_bar:remove()
            self.tension_bar = nil
        end
    end)
    
    Utils.hook(Battle, "onKeyPressed", function(orig, self, key)
        if Kristal.Config["debug"] and Input.ctrl() then
            if key == "y" and Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN"}, self.state) and Game:isLight() then
                Game.battle:setState("DEFENDINGEND", "NONE")
            end
        end
        orig(self, key)
    end)
    
    Utils.hook(Battle, "drawBackground", function(orig, self)
        if Game:isLight() then
            Draw.setColor(0, 0, 0, self.transition_timer / 10)
            love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)

            love.graphics.setLineStyle("rough")
            love.graphics.setLineWidth(1)

            for i = 2, 16 do
                Draw.setColor(0, 61 / 255, 17 / 255, (self.transition_timer / 10) / 2)
                love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
                love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
            end

            for i = 3, 16 do
                Draw.setColor(0, 61 / 255, 17 / 255, self.transition_timer / 10)
                love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
                love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
            end
        else
            orig(self)
        end
    end)
    
    Utils.hook(Battle, "nextTurn", function(orig, self)
        self.turn_count = self.turn_count + 1
        if self.turn_count > 1 then
            for _,party in ipairs(self.party) do
                if party.chara:onTurnEnd() then
                    return
                end
            end
        end
        self.turn_count = self.turn_count - 1
        return orig(self)
    end)
    
    Utils.hook(Battle, "onStateChange", function(orig, self, old, new)
        local result = self.encounter:beforeStateChange(old,new)
        if result or self.state ~= new then
            return
        end
        if new == "VICTORY" and Game:isLight() then
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

            if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") then
                self.money = self.money + (math.floor((Game:getTension() * 2.5) / 30))
            end

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

            Game.lw_money = Game.lw_money + self.money

            if (Game.lw_money < 0) then
                Game.lw_money = 0
            end

            local win_text = "* You won!\n* Got " .. self.xp .. " EXP and " .. self.money .. " "..Game:getConfig("lightCurrency"):lower().."."
            -- if (in_dojo) then
            --     win_text == "* You won the battle!"
            -- end
            
            for _,member in ipairs(self.party) do
                local lv = member.chara:getLightLV()
                member.chara:addLightEXP(self.xp)

                if lv ~= member.chara:getLightLV() then
                    win_text = "* You won!\n* Got " .. self.xp .. " EXP and " .. self.money .. " "..Game:getConfig("lightCurrency"):lower()..".\n* Your "..Kristal.getLibConfig("magical-glass", "light_level_name").." increased."
                    Assets.stopAndPlaySound("levelup")
                end
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
        else
            orig(self, old, new)
        end
    end)
    
    Utils.hook(Soul, "onDamage", function(orig, self, bullet, amount)
        for _,party in ipairs(Game.battle.party) do
            for _,equip in ipairs(party.chara:getEquipment()) do
                if equip.applyInvBonus then
                    self.inv_timer = equip:applyInvBonus(self.inv_timer)
                end
            end
        end
        orig(self, bullet, amount)
    end)
    
    Utils.hook(Soul, "init", function(orig, self, x, y, color)
        orig(self, x, y, color)
        self.speed = self.speed + Game.battle.soul_speed_bonus
        if not Kristal.getLibConfig("magical-glass", "light_world_dark_battle_tension") and Game:isLight() then
            self.graze_collider.collidable = false
        end
    end)

    Utils.hook(TensionItem, "onBattleSelect", function(orig, self, user, target)
        if Game.battle.light then
            self.tension_given = Game:giveTension(self:getTensionAmount())

            local sound = Assets.newSound("cardrive")
            sound:setPitch(1.4)
            sound:setVolume(0.8)
            sound:play()
        else
            orig(self, user, target)
        end
    end)

    Utils.hook(Actor, "init", function(orig, self)
        orig(self)

        self.use_light_battler_sprite = false
        self.light_battler_parts = {}
    end)

    Utils.hook(Actor, "getWidth", function(orig, self)
        if Game.battle and Game.battle.light and not Game.battle.ended and self.use_light_battler_sprite and self.light_battle_width then
            return self.light_battle_width
        else
            return orig(self)
        end
    end)

    Utils.hook(Actor, "getHeight", function(orig, self)
        if Game.battle and Game.battle.light and not Game.battle.ended and self.use_light_battler_sprite and self.light_battle_height then
            return self.light_battle_height
        else
            return orig(self)
        end
    end)

    Utils.hook(Actor, "addLightBattlerPart", function(orig, self, id, data)
        if type(data) == "string" then
            self.light_battler_parts[id] = {["create_sprite"] = self.path.."/"..data}
        else
            self.light_battler_parts[id] = data
        end
    end)

    Utils.hook(Actor, "getLightBattlerPart", function(orig, self, part)
        return self.light_battler_parts[part]
    end)

    Utils.hook(Actor, "createLightBattleSprite", function(orig, self, enemy)
        return LightEnemySprite(self, enemy)
    end)

    Utils.hook(ActorSprite, "init", function(orig, self, actor)
        orig(self, actor)
        
        self.run_away_light = false
    end)

    Utils.hook(ActorSprite, "update", function(orig, self)
        orig(self)
    
        if self.run_away_light then
            self.run_away_timer = self.run_away_timer + DTMULT
        end
    end)
    
    Utils.hook(ActorSprite, "draw", function(orig, self)
        if self.actor:preSpriteDraw(self) then
            return
        end
        
        if self.texture and self.run_away_light then
            local r,g,b,a = self:getDrawColor()
            for i = 0, 80 do
                local alph = a * 0.4
                Draw.setColor(r,g,b, ((alph - (self.run_away_timer / 8)) + (i / 200)))
                Draw.draw(self.texture, i * 4, 0)
            end
            return
        end
        
        orig(self)
    end)

    Utils.hook(Game, "encounter", function(orig, self, encounter, transition, enemy, context, light)
        if lib.current_battle_system then
            if lib.current_battle_system == "undertale" then
                Game:encounterLight(encounter, transition, enemy, context)
            else
                orig(self, encounter, transition, enemy, context)
            end
        elseif context and isClass(context) and context:includes(ChaserEnemy) then
            if context.light_encounter then
                lib.current_battle_system = "undertale"
                Game:encounterLight(encounter, transition, enemy, context)
            else
                lib.current_battle_system = "deltarune"
                orig(self, encounter, transition, enemy, context)
            end
        elseif light ~= nil then
            if light then
                lib.current_battle_system = "undertale"
                Game:encounterLight(encounter, transition, enemy, context)
            else
                lib.current_battle_system = "deltarune"
                orig(self, encounter, transition, enemy, context)
            end
        else
            if Kristal.getLibConfig("magical-glass", "default_battle_system")[1] == "undertale" then
                lib.current_battle_system = "undertale"
                Game:encounterLight(encounter, transition, enemy, context)
            else
                lib.current_battle_system = "deltarune"
                orig(self, encounter, transition, enemy, context)
            end
        end
    end)

    Utils.hook(Game, "encounterLight", function(orig, self, encounter, transition, enemy, context)
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
    end)

    Utils.hook(ChaserEnemy, "init", function(orig, self, actor, x, y, properties)
        orig(self, actor, x, y, properties)

        self.sprite.aura = nil
        self.light_encounter = properties["lightencounter"]
        self.light_enemy = properties["lightenemy"]
    
        if properties["aura"] == nil then
            Game.world.timer:after(1/30, function()
                if Game:isLight() then
                    self.sprite.aura = Kristal.getLibConfig("magical-glass", "light_enemy_auras")
                else
                    self.sprite.aura = Game:getConfig("enemyAuras")
                end
            end)
        else
            self.sprite.aura = properties["aura"]
        end

    end)

    Utils.hook(ChaserEnemy, "onCollide", function(orig, self, player)
        if self.encounter and self.light_encounter then
            error("ChaserEnemy cannot have both encounter and lightencounter.")
        elseif not self.light_encounter then
            orig(self, player)
        else
            if self:isActive() and player:includes(Player) then
                self.encountered = true
                local encounter = self.light_encounter
                if not encounter and MagicalGlassLib:getLightEnemy(self.enemy or self.actor.id) then
                    encounter = LightEncounter()
                    encounter:addEnemy(self.actor.id)
                end
                if encounter then
                    self.world.encountering_enemy = true
                    self.sprite:setAnimation("hurt")
                    self.sprite.aura = false
                    Game.lock_movement = true
                    self.world.timer:script(function(wait)
                        Assets.playSound("tensionhorn")
                        wait(8/30)
                        local src = Assets.playSound("tensionhorn")
                        src:setPitch(1.1)
                        wait(12/30)
                        self.world.encountering_enemy = false
                        Game.lock_movement = false
                        local enemy_target = self
                        if self.enemy then
                            enemy_target = {{self.enemy, self}}
                        end
                        Game:encounter(encounter, true, enemy_target, self)
                    end)
                end
            end
        end
    end)

    Utils.hook(Battle, "postInit", function(orig, self, state, encounter)
        local local_encounter
        if type(encounter) == "string" then
            local_encounter = Registry.getEncounter(encounter)
        else
            local_encounter = encounter
        end
        
        if local_encounter:includes(LightEncounter) then
            error("Attempted to use LightEncounter in a DarkBattle. Convert the encounter file to an Encounter.")
        end
        
        orig(self, state, encounter)
    end)
    
    Utils.hook(Battle, "setWaves", function(orig, self, waves, allow_duplicates)
        for i,wave in ipairs(waves) do
            if type(wave) == "string" then
                wave = Registry.getWave(wave)
            end
            if wave:includes(LightWave) then
                error("Attempted to use LightWave in a DarkBattle. Convert '"..waves[i].."' to a Wave.")
            end
        end
        return orig(self, waves, allow_duplicates)
    end)

    Utils.hook(Battle, "returnToWorld", function(orig, self)
        orig(self)
        lib.current_battle_system = nil
    end)

    Utils.hook(Item, "init", function(orig, self)
    
        orig(self)
        -- Short name for the light battle item menu
        self.short_name = nil
        -- Serious name for the light battle item menu
        self.serious_name = nil

        self.tags = {}

        -- How this item is used on you (ate, drank, eat, etc.)
        self.use_method = "used"
        -- How this item is used on other party members (eats, etc.)
        self.use_method_other = nil
        
        -- Displays magic stats for weapons and armors in light shops
        self.shop_magic = false
        -- Doesn't display stats for weapons and armors in light shops
        self.shop_dont_show_change = false
        
        -- Prevents the overworld selection for an item (Light World Only)
        self.skip_overworld_selection = false
        
        -- Whether this equipment item can convert on light change
        self.equip_can_convert = nil
    end)
    
    Utils.hook(Item, "getName", function(orig, self)
        if self.light and #orig(self) > 15 and Game.state == "BATTLE" and not Game.battle.light and self.short_name then
            return self.short_name
        else
            return orig(self)
        end
    end)
    
    Utils.hook(Item, "getUseName", function(orig, self)
        if self.light and Game.state == "BATTLE" and not Game.battle.light and self:getName() == self.short_name then
            return self.use_name and self.use_name:upper() or self.name:upper()
        elseif (Game.state == "OVERWORLD" and Game:isLight()) or (Game.state == "BATTLE" and Game.battle.light)  then
            return self.use_name or self:getName()
        else
            return self.light and self.use_name and self.use_name:upper() or orig(self)
        end
    end)
    
    Utils.hook(Item, "canEquip", function(orig, self, character, slot_type, slot_index)
        if self.light then
            return self.can_equip[character.id] ~= false
        else
            return orig(self, character, slot_type, slot_index)
        end
    end)
    
    if not Kristal.getLibConfig("magical-glass", "key_item_conversion") then
        -- Don't give the ball of junk
        Utils.hook(LightInventory, "getDarkInventory", function(orig, self)
            return Game.dark_inventory
        end)
        
        -- Prevent items conversion
        Utils.hook(DarkInventory, "convertToLight", function(orig, self)
            local new_inventory = LightInventory()

            local was_storage_enabled = new_inventory.storage_enabled
            new_inventory.storage_enabled = true
            
            for k,storage in pairs(self:getLightInventory().storages) do
                for i = 1, storage.max do
                    if storage[i] then
                        if not new_inventory:addItemTo(storage.id, i, storage[i]) then
                            new_inventory:addItem(storage[i])
                        end
                    end
                end
            end

            Kristal.callEvent(KRISTAL_EVENT.onConvertToLight, new_inventory)

            new_inventory.storage_enabled = was_storage_enabled
            
            Game.dark_inventory = self

            return new_inventory
        end)
        
        Utils.hook(LightInventory, "convertToDark", function(orig, self)
            local new_inventory = DarkInventory()

            local was_storage_enabled = new_inventory.storage_enabled
            new_inventory.storage_enabled = true

            for k,storage in pairs(self:getDarkInventory().storages) do
                for i = 1, storage.max do
                    if storage[i] then
                        if not new_inventory:addItemTo(storage.id, i, storage[i]) then
                            new_inventory:addItem(storage[i])
                        end
                    end
                end
            end

            Kristal.callEvent(KRISTAL_EVENT.onConvertToDark, new_inventory)

            new_inventory.storage_enabled = was_storage_enabled
            
            Game.light_inventory = self

            return new_inventory
        end)
        
        Utils.hook(LightInventory, "tryGiveItem", function(orig, self, item, ignore_dark)
            if Game.inventory:hasItem("light/ball_of_junk") then
                return orig(self, item, ignore_dark)
            else
                if type(item) == "string" then
                    item = Registry.createItem(item)
                end
                if ignore_dark or item.light then
                    return Inventory.tryGiveItem(self, item, ignore_dark)
                else
                    local dark_inv = self:getDarkInventory()
                    local result = dark_inv:addItem(item)
                    if result then
                        return true, "* ([color:yellow]"..item:getName().."[color:reset] was added to your [color:yellow]DARK ITEMs[color:reset].)"
                    else
                        return false, "* (You have too many [color:yellow]DARK ITEMs[color:reset] to take [color:yellow]"..item:getName().."[color:reset].)"
                    end
                end
            end
        end)
    end
    Utils.hook(LightEquipItem, "convertToDark", function(orig, self, inventory) return false end)
    
    Utils.hook(Item, "getLightBattleText", function(orig, self, user, target)
        if self.target == "ally" then
            return "* " .. target.chara:getNameOrYou() .. " "..self:getUseMethod(target.chara).." the " .. self:getUseName() .. "."
        elseif self.target == "party" then
            if #Game.battle.party > 1 then
                return "* Everyone "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
            else
                return "* You "..self:getUseMethod("self").." the " .. self:getUseName() .. "."
            end
        elseif self.target == "enemy" then
            return "* " .. target.name .. " "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
        elseif self.target == "enemies" then
            return "* The enemies "..self:getUseMethod("other").." the " .. self:getUseName() .. "."
        end
    end)
    
    Utils.hook(Item, "getLightBattleHealingText", function(orig, self, user, target, amount)
        if target then
            if self.target == "ally" then
                maxed = target.chara:getHealth() >= target.chara:getStat("health") or amount >= math.huge
            elseif self.target == "enemy" then
                maxed = target.health >= target.max_health or amount >= math.huge
            end
        end

        local message
        if self.target == "ally" then
            if select(2, target.chara:getNameOrYou()) and maxed then
                message = "* Your HP was maxed out."
            elseif maxed then
                message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
            else
                message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "party" then
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
        elseif self.target == "enemy" then
            if maxed then
                message = "* " .. target.name .. "'s HP was maxed out."
            else
                message = "* " .. target.name .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "enemies" then
            message = "* The enemies all recovered " .. amount .. " HP."
        end
        return message
    end)

    Utils.hook(Item, "getLightShopDescription", function(orig, self)
        return self.shop
    end)
    
    Utils.hook(Item, "getLightShopShowMagic", function(orig, self)
        return self.shop_magic
    end)
    
    Utils.hook(Item, "getLightShopDontShowChange", function(orig, self)
        return self.shop_dont_show_change
    end)

    Utils.hook(Item, "getLightTypeName", function(orig, self)
        if self.type == "weapon" then
            if self:getLightShopShowMagic() then
                return "Weapon: " .. self:getStatBonus("magic") .. "MG"
            else
                return "Weapon: " .. self:getStatBonus("attack") .. "AT"
            end
        elseif self.type == "armor" then
            if self:getLightShopShowMagic() then
                return "Armor: " .. self:getStatBonus("magic") .. "MG"
            else
                return "Armor: " .. self:getStatBonus("defense") .. "DF"
            end
        end
        return ""
    end)

    Utils.hook(Item, "getShortName", function(orig, self) return self.short_name or self:getName() end)
    Utils.hook(Item, "getSeriousName", function(orig, self) return self.serious_name or self:getShortName() end)

    Utils.hook(Item, "getUseMethod", function(orig, self, target)
        if type(target) == "string" then
            if target == "other" and self.use_method_other then
                return self.use_method_other
            elseif target == "self" and self.use_method_self then
                return self.use_method
            else
                return self.use_method
            end
        elseif isClass(target) then
            if (target.id ~= Game.party[1].id and self.use_method_other and self.target ~= "party") or force_other then
                return self.use_method_other
            else
                return self.use_method
            end
        end
    end)
    
    Utils.hook(Item, "battleUseSound", function(orig, self, user, target) end)

    Utils.hook(Item, "onLightBattleUse", function(orig, self, user, target)
        self:battleUseSound(user, target)
        if self:getLightBattleText(user, target) then
            Game.battle:battleText(self:getLightBattleText(user, target))
        else
            Game.battle:battleText("* "..user.chara:getNameOrYou().." used the "..self:getUseName()..".")
        end
    end)
    
    Utils.hook(Item, "onLightAttack", function(orig, self, battler, enemy, damage, stretch)
        if damage <= 0 then
            enemy:onDodge(battler, true)
        end
        -- local src = Assets.stopAndPlaySound(self.getLightAttackSound and self:getLightAttackSound() or "laz_c")
        local src = Assets.stopAndPlaySound(Game:isLight() and (self.getLightAttackSound and self:getLightAttackSound() or "laz_c") or battler.chara:getAttackSound() or "laz_c")
        -- src:setPitch(self.getLightAttackPitch and self:getLightAttackPitch() or 1)
        src:setPitch(Game:isLight() and (self.getLightAttackPitch and self:getLightAttackPitch() or 1) or battler.chara:getAttackPitch() or 1)
        -- local sprite = Sprite(self.getLightAttackSprite and self:getLightAttackSprite() or "effects/attack/strike")
        local sprite = Sprite(Game:isLight() and (self.getLightAttackSprite and self:getLightAttackSprite() or "effects/attack/strike") or battler.chara:getAttackSprite() or "effects/attack/cut") -- dark stuff here
        sprite.battler_id = battler and Game.battle:getPartyIndex(battler.chara.id) or nil
        table.insert(enemy.dmg_sprites, sprite)
        sprite:setOrigin(0.5)
        if Game:isLight() then -- dark stuff here
            sprite:setScale(stretch * 2 - 0.5)
            sprite.color = {battler.chara:getLightAttackColor()}
        else
            sprite:setScale(2)
        end
        local relative_pos_x, relative_pos_y = enemy:getRelativePos((enemy.width / 2) - (#Game.battle.attackers - 1) * 5 / 2 + (Utils.getIndex(Game.battle.attackers, battler) - 1) * 5, (enemy.height / 2) - 8)
        sprite:setPosition(relative_pos_x + enemy.dmg_sprite_offset[1], relative_pos_y + enemy.dmg_sprite_offset[2])
        sprite.layer = BATTLE_LAYERS["above_ui"] + 5
        enemy.parent:addChild(sprite)
        -- sprite:play((stretch^(1/1.5) / 4) / 1.5, false, function(this)
        sprite:play(Game:isLight() and ((stretch^(1/1.5) / 4) / 1.5) or 1/8, false, function(this) -- dark stuff here
            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" and (damage > 0 or enemy.always_play_damage_sound) then
                Assets.stopAndPlaySound(sound)
            end
            enemy:hurt(damage, battler)

            if Game:isLight() then -- dark stuff here
                battler.chara:onLightAttackHit(enemy, damage)
            else
                battler.chara:onAttackHit(enemy, damage)
            end
            this:remove()
            Utils.removeFromTable(enemy.dmg_sprites, this)

            Game.battle:finishActionBy(battler)
        end)

        return false
    end)

    Utils.hook(Item, "onLightMiss", function(orig, self, battler, enemy, anim, attacked)
        enemy:hurt(0, battler, nil, nil, anim, attacked)
    end)

    Utils.hook(Item, "onActionSelect", function(orig, self, battler) end)

    Utils.hook(Textbox, "init", function(orig, self, x, y, width, height, default_font, default_font_size, battle_box)
        Object.init(self, x, y, width, height)

        self.box = UIBox(0, 0, width, height)
        self.box.layer = -1
        self.box.debug_select = false
        self:addChild(self.box)
    
        self.battle_box = battle_box
        if battle_box then
            self.box.visible = false
        end

        if battle_box then
            if Game.battle.light then
                self.face_x = 6
                self.face_y = -2
        
                self.text_x = 0
                self.text_y = -2 
            else
                self.face_x = -4
                self.face_y = 2
        
                self.text_x = 0
                self.text_y = -2 -- TODO: This was changed 2px lower with the new font, but it was 4px offset. Why? (Used to be 0)
            end
        elseif Game:isLight() then
            self.face_x = 13
            self.face_y = 6
    
            self.text_x = 2
            self.text_y = -4
        else
            self.face_x = 18
            self.face_y = 6
    
            self.text_x = 2
            self.text_y = -4  -- TODO: This was changed with the new font but it's accurate anyways
        end
    
        self.actor = nil
    
        self.default_font = default_font or "main_mono"
        self.default_font_size = default_font_size
    
        self.font = self.default_font
        self.font_size = self.default_font_size
    
        self.face = Sprite(nil, self.face_x, self.face_y, nil, nil, "face")
        self.face:setScale(2)
        self.face.getDebugOptions = function(self2, context)
            context = Object.getDebugOptions(self2, context)
            if Kristal.DebugSystem then
                context:addMenuItem("Change", "Change this portrait to a different one", function()
                    Kristal.DebugSystem:setState("FACES", self)
                end)
            end
            return context
        end
        self:addChild(self.face)
    
        -- Added text width for autowrapping
        self.wrap_add_w = battle_box and 0 or 14
    
        self.text = DialogueText("", self.text_x, self.text_y, width + self.wrap_add_w, SCREEN_HEIGHT)
        self:addChild(self.text)
    
        self.reactions = {}
        self.reaction_instances = {}
    
        self.text:registerCommand("face", function(text, node, dry)
            if self.actor and self.actor:getPortraitPath() then
                self.face.path = self.actor:getPortraitPath()
            end
            self:setFace(node.arguments[1], tonumber(node.arguments[2]), tonumber(node.arguments[3]))
        end)
        self.text:registerCommand("facec", function(text, node, dry)
            self.face.path = "face"
            local ox, oy = tonumber(node.arguments[2]), tonumber(node.arguments[3])
            if self.actor then
                local actor_ox, actor_oy = self.actor:getPortraitOffset()
                ox = (ox or 0) - actor_ox
                oy = (oy or 0) - actor_oy
            end
            self:setFace(node.arguments[1], ox, oy)
        end)
    
        self.text:registerCommand("react", function(text, node, dry)
            local react_data
            if #node.arguments > 1 then
                react_data = {
                    text = node.arguments[1],
                    x = tonumber(node.arguments[2]) or (self.battle_box and self.REACTION_X_BATTLE[node.arguments[2]] or self.REACTION_X[node.arguments[2]]),
                    y = tonumber(node.arguments[3]) or (self.battle_box and self.REACTION_Y_BATTLE[node.arguments[3]] or self.REACTION_Y[node.arguments[3]]),
                    face = node.arguments[4],
                    actor = node.arguments[5] and Registry.createActor(node.arguments[5]),
                }
            else
                react_data = tonumber(node.arguments[1]) and self.reactions[tonumber(node.arguments[1])] or self.reactions[node.arguments[1]]
            end
            local reaction = SmallFaceText(react_data.text, react_data.x, react_data.y, react_data.face, react_data.actor)
            reaction.layer = 0.1 + (#self.reaction_instances) * 0.01
            self:addChild(reaction)
            table.insert(self.reaction_instances, reaction)
        end, {instant = false})
        
        self.minifaces = {}
        self.miniface_path = "face/mini"

        self.text:registerCommand("miniface", function(text, node, dry)
            local ox = tonumber(node.arguments[2]) or 0
            local oy = tonumber(node.arguments[3]) or 0
            if self.actor then
                local actor_ox, actor_oy = self.actor:getMinifaceOffset()
                ox = actor_ox
                oy = actor_oy
            end
            local x_scale = tonumber(node.arguments[4]) or 2
            local y_scale = tonumber(node.arguments[5]) or 2
            local speed = tonumber(node.arguments[6]) or (4/30)
            local y = self.text.state.current_y
            if (not dry) then
                local miniface = Sprite(nil, 0 + ox, y + oy)
                miniface:setScale(x_scale, y_scale)
                miniface:setSprite(self.miniface_path.. "/" ..node.arguments[1])
                miniface:play(speed)
                if #self.minifaces > 0 then
                    local last_face = self.minifaces[#self.minifaces]
                    last_face:stop()
                end
                self:addChild(miniface)
                table.insert(self.minifaces, miniface)
                if self.actor and self.actor:getMiniface() then
                    self.miniface_path = self.actor:getMiniface()
                else
                    self.miniface_path = "face/mini"
                end
                self.text.state.indent_mode = true
                self.text.state.indent_length = miniface.width * miniface.scale_x + 15
                self.text.state.current_x = self.text.state.indent_length + self.text.state.spacing
            end
        end)
    
        self.advance_callback = nil
    end)

    Utils.hook(DialogueText, "init", function(orig, self, text, x, y, w, h, options)
        orig(self, text, x, y, w, h, options)
        options = options or {}
        self.default_sound = options["default_sound"] or "default"
        self.no_sound_overlap = options["no_sound_overlap"] or false
    end)

    Utils.hook(DialogueText, "resetState", function(orig, self)
        Text.resetState(self)
        self.state["typing_sound"] = self.default_sound
    end)

    Utils.hook(DialogueText, "playTextSound", function(orig, self, current_node)
        if self.state.skipping and (Input.down("cancel") or self.played_first_sound) then
            return
        end
    
        if current_node.type ~= "character" then
            return
        end
    
        local no_sound = {"\n", " ", "^", "!", ".", "?", ",", ":", "/", "\\", "|", "*"}
    
        if (Utils.containsValue(no_sound, current_node.character)) then
            return
        end
    
        if (self.state.typing_sound ~= nil) and (self.state.typing_sound ~= "") then
            self.played_first_sound = true
            if Kristal.callEvent(KRISTAL_EVENT.onTextSound, self.state.typing_sound, current_node) then
                return
            end
            if self.no_sound_overlap then
                Assets.stopAndPlaySound("voice/"..self.state.typing_sound)
            else
                Assets.playSound("voice/"..self.state.typing_sound)
            end
        end
    end)

    Utils.hook(DialogueText, "update", function(orig, self)
        local speed = self.state.speed

        if not OVERLAY_OPEN then

            if Kristal.getLibConfig("magical-glass", "undertale_text_skipping") == true then

                local input = self.can_advance and (Input.pressed("confirm") or (Input.down("menu") and self.fast_skipping_timer >= 1))

                if input or self.auto_advance or self.should_advance then
                    self.should_advance = false
                    if not self.state.typing then
                        self:advance()
                    end
                end
        
                if self.skippable and (Input.pressed("cancel") and not self.state.noskip) then
                    if not self.skip_speed then
                        self.state.skipping = true
                    else
                        speed = speed * 2
                    end
                end

            else
                if Input.pressed("menu") then
                    self.fast_skipping_timer = 1
                end
        
                local input = self.can_advance and (Input.pressed("confirm") or (Input.down("menu") and self.fast_skipping_timer >= 1))
        
                if input or self.auto_advance or self.should_advance then
                    self.should_advance = false
                    if not self.state.typing then
                        self:advance()
                    end
                end
        
                if Input.down("menu") then
                    if self.fast_skipping_timer < 1 then
                        self.fast_skipping_timer = self.fast_skipping_timer + DTMULT
                    end
                else
                    self.fast_skipping_timer = 0
                end
                
                if self.skippable and ((Input.down("cancel") and not self.state.noskip) or (Input.down("menu") and not self.state.noskip)) then
                    if not self.skip_speed then
                        self.state.skipping = true
                    else
                        speed = speed * 2
                    end
                end
            end
    
        end
    
        if self.state.waiting == 0 then
            self.state.progress = self.state.progress + (DT * 30 * speed)
        else
            self.state.waiting = math.max(0, self.state.waiting - DT)
        end
    
        if self.state.typing then
            self:drawToCanvas(function()
                while (math.floor(self.state.progress) > self.state.typed_characters) or self.state.skipping do
                    local current_node = self.nodes[self.state.current_node]
    
                    if current_node == nil then
                        self.state.typing = false
                        break
                    end
    
                    self:playTextSound(current_node)
                    self:processNode(current_node, false)
    
                    if self.state.skipping then
                        self.state.progress = self.state.typed_characters
                    end
    
                    self.state.current_node = self.state.current_node + 1
                end
            end)
        end
    
        self:updateTalkSprite(self.state.talk_anim and self.state.typing)
    
        Text.update(self)
    
        self.last_talking = self.state.talk_anim and self.state.typing
    end)

    Utils.hook(Bullet, "init", function(orig, self, x, y, texture)
        orig(self, x, y, texture)
        if Game:isLight() then
            self.inv_timer = 1
        end
        self.bonus_damage = true -- Whether the bullet deals bonus damage when having more HP (Light Battles only)
        self.remove_outside_of_arena = false
    end)
    
    Utils.hook(Bullet, "onDamage", function(orig, self, soul)
        lib.bonus_damage = self.bonus_damage
        local battlers = orig(self, soul)
        lib.bonus_damage = nil
        return battlers
    end)

    Utils.hook(Bullet, "update", function(orig, self)
        orig(self)
        if self.remove_outside_of_arena then
            if self.x < Game.battle.arena.left then
                self:remove()
            elseif self.x > Game.battle.arena.right then
                self:remove()
            elseif self.y > Game.battle.arena.bottom then
                self:remove()
            elseif self.y < Game.battle.arena.top then
                self:remove()
            end
        end
    end)

    Utils.hook(LightItemMenu, "init", function(orig, self)
    
        orig(self)

        -- States: ITEMSELECT, ITEMOPTION, PARTYSELECT

        if Mod.libs["moreparty"] and #Game.party > 3 then
            if not Kristal.getLibConfig("moreparty", "classic_mode") then
                self.party_select_bg = UIBox(-97, 242, 492, #Game.party == 4 and 52 or 90)
            else
                self.party_select_bg = UIBox(-37, 242, 372, 90)
            end
        else
            self.party_select_bg = UIBox(-37, 242, 372, 52)
        end
        self.party_select_bg.visible = false
        self.party_select_bg.layer = -1
        self.party_selecting = 1
        self:addChild(self.party_select_bg)

    end)
    
    Utils.hook(LightItemMenu, "update", function(orig, self)
        if self.state == "ITEMOPTION" then
            if Input.pressed("cancel") then
                self.state = "ITEMSELECT"
                return
            end
    
            local old_selecting = self.option_selecting
    
            if Input.pressed("left") then
                self.option_selecting = self.option_selecting - 1
            end
            if Input.pressed("right") then
                self.option_selecting = self.option_selecting + 1
            end
    
            self.option_selecting = Utils.clamp(self.option_selecting, 1, 3)
    
            if self.option_selecting ~= old_selecting then
                self.ui_move:stop()
                self.ui_move:play()
            end
    
            if Input.pressed("confirm") then
                local item = Game.inventory:getItem(self.storage, self.item_selecting)
                if self.option_selecting == 1 and (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
                    self.party_selecting = 1
                    if #Game.party > 1 and not item.skip_overworld_selection and item.target == "ally" then
                        self.ui_select:stop()
                        self.ui_select:play()
                        self.party_select_bg.visible = true
                        self.state = "PARTYSELECT"
                    else
                        self:useItem(item)
                    end
                elseif self.option_selecting == 2 then
                    item:onCheck()
                elseif self.option_selecting == 3 then
                    self:dropItem(item)
                end
            end
        elseif self.state == "PARTYSELECT" then
            if Input.pressed("cancel") then
                self.party_select_bg.visible = false
                self.state = "ITEMOPTION"
                return
            end
    
            local old_selecting = self.party_selecting

            if Input.pressed("right") then
                self.party_selecting = self.party_selecting + 1
            end
    
            if Input.pressed("left") then
                self.party_selecting = self.party_selecting - 1
            end

            self.party_selecting = Utils.clamp(self.party_selecting, 1, #Game.party)

            if self.party_selecting ~= old_selecting then
                self.ui_move:stop()
                self.ui_move:play()
            end

            if Input.pressed("confirm") then
                local item = Game.inventory:getItem(self.storage, self.item_selecting)
                self:useItem(item)
            end

        else
            orig(self)
        end

    end)

    Utils.hook(LightItemMenu, "draw", function(orig, self)
        love.graphics.setFont(self.font)

        local inventory = Game.inventory:getStorage(self.storage)
    
        for index, item in ipairs(inventory) do
            if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_text_unusable"])
            end
            if self.state == "PARTYSELECT" then
                local function party_box_area()
                    local party_box = self.party_select_bg
                    love.graphics.rectangle("fill", party_box.x - 24, party_box.y - 24, party_box.width + 48, party_box.height + 48)
                end
                love.graphics.stencil(party_box_area, "replace", 1)
                love.graphics.setStencilTest("equal", 0)
            end
            love.graphics.print(item:getName(), 20, -28 + (index * 32))
            love.graphics.setStencilTest()
        end

        if self.state ~= "PARTYSELECT" then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            if (item.usable_in == "world" or item.usable_in == "all") and not (item.target == "enemy" or item.target == "enemies") then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_gray"])
            end
            love.graphics.print("USE" , 20 , 284)
            Draw.setColor(PALETTE["world_text"])
            love.graphics.print("INFO", 116, 284)
            love.graphics.print("DROP", 230, 284)
        end
    
        Draw.setColor(Game:getSoulColor())
        if self.state == "ITEMSELECT" then
            Draw.draw(self.heart_sprite, -4, -20 + (32 * self.item_selecting), 0, 2, 2)
        elseif self.state == "ITEMOPTION" then
            if self.option_selecting == 1 then
                Draw.draw(self.heart_sprite, -4, 292, 0, 2, 2)
            elseif self.option_selecting == 2 then
                Draw.draw(self.heart_sprite, 92, 292, 0, 2, 2)
            elseif self.option_selecting == 3 then
                Draw.draw(self.heart_sprite, 206, 292, 0, 2, 2)
            end
        elseif self.state == "PARTYSELECT" then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            Draw.setColor(PALETTE["world_text"])
            
            local z = Mod.libs["moreparty"] and Kristal.getLibConfig("moreparty", "classic_mode") and 3 or 4
            
            Draw.printAlign("Use " .. item:getName() .. " on", 150, 231, "center")

            for i,party in ipairs(Game.party) do
                if i <= z then
                    love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 269)
                else
                    love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 269 + 38)
                end
            end

            Draw.setColor(Game:getSoulColor())
            for i,party in ipairs(Game.party) do
                if i == self.party_selecting then
                    if i <= z then
                        Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 277, 0, 2, 2)
                    else
                        Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 277 + 38, 0, 2, 2)
                    end
                end
            end
        end

        Object.draw(self)

    end)

    Utils.hook(LightItemMenu, "useItem", function(orig, self, item)
        local result
        if item.target == "ally" then
            result = item:onWorldUse(Game.party[self.party_selecting])
        else
            result = item:onWorldUse(Game.party)
        end
        
        if result then
            if item:hasResultItem() then
                Game.inventory:replaceItem(item, item:createResultItem())
            else
                Game.inventory:removeItem(item)
            end
        end
    end)

    Utils.hook(World, "heal", function(orig, self, target, amount, text, item)
        if Game:isLight() then
            lib.heal_amount = amount
            if type(target) == "string" then
                target = Game:getPartyMember(target)
            end

            local maxed = target:heal(amount, false)
            local message
            if item and item.getLightWorldHealingText then
                message = item:getLightWorldHealingText(target, amount, maxed)
            end

            if text and message then
                message = text .. "\n" .. message
            end
            
            if message or text then
                if not Game.world:hasCutscene() then
                    Game.world:showText(message or text)
                end
            else
                Assets.stopAndPlaySound("power")
            end
        else
            orig(self, target, amount, text, item)
        end
    end)
    
    Utils.hook(WorldCutscene, "startLightEncounter", function(orig, self, encounter, transition, enemy, options)
        options = options or {}
        transition = transition ~= false
        Game:encounter(encounter, transition, enemy, nil, true)
        if options.on_start then
            if transition and (type(transition) == "boolean" or transition == "TRANSITION") then
                Game.battle.timer:script(function(wait)
                    while Game.battle.state == "TRANSITION" do
                        wait()
                    end
                    options.on_start()
                end)
            else
                options.on_start()
            end
        end

        local battle_encounter = Game.battle.encounter
        local function waitForEncounter(self) return (Game.battle == nil), battle_encounter end

        if options.wait == false then
            return waitForEncounter, battle_encounter
        else
            return self:wait(waitForEncounter)
        end
    end)
    
    Utils.hook(BattleCutscene, "text", function(orig, self, text, portrait, actor, options)
        orig(self, Game.battle.light and ("[shake:"..MagicalGlassLib.light_battle_shake_text.."]" .. text) or text, portrait, actor, options)
    end)

    if not Mod.libs["widescreen"] then
        Utils.hook(WorldCutscene, "text", function(orig, self, text, portrait, actor, options)
            local function waitForTextbox(self) return not self.textbox or self.textbox:isDone() end
            if type(actor) == "table" and not isClass(actor) then
                options = actor
                actor = nil
            end
            if type(portrait) == "table" then
                options = portrait
                portrait = nil
            end
        
            options = options or {}
        
            self:closeText()
        
            local width, height = 529, 103
            if Game:isLight() then
                width, height = 530, 104
            end
        
            self.textbox = Textbox(56, 344, width, height)
            self.textbox.text.hold_skip = false
            self.textbox.layer = WORLD_LAYERS["textbox"]
            Game.world:addChild(self.textbox)
            self.textbox:setParallax(0, 0)
        
            local speaker = self.textbox_speaker
            if not speaker and isClass(actor) and actor:includes(Character) then
                speaker = actor.sprite
            end
        
            if options["talk"] ~= false then
                self.textbox.text.talk_sprite = speaker
            end
        
            actor = actor or self.textbox_actor
            if isClass(actor) and actor:includes(Character) then
                actor = actor.actor
            end
            if actor then
                self.textbox:setActor(actor)
            end
        
            if options["top"] == nil and self.textbox_top == nil then
                local _, player_y = Game.world.player:localToScreenPos()
                options["top"] = player_y > 260
            end
            if options["top"] or (options["top"] == nil and self.textbox_top) then
            local bx, by = self.textbox:getBorder()
            self.textbox.y = by + 2
            end
        
            self.textbox.active = true
            self.textbox.visible = true
            self.textbox:setFace(portrait, options["x"], options["y"])
        
            if options["reactions"] then
                for id,react in pairs(options["reactions"]) do
                    self.textbox:addReaction(id, react[1], react[2], react[3], react[4], react[5])
                end
            end
        
            if options["functions"] then
                for id,func in pairs(options["functions"]) do
                    self.textbox:addFunction(id, func)
                end
            end
        
            if options["font"] then
                if type(options["font"]) == "table" then
                    -- {font, size}
                    self.textbox:setFont(options["font"][1], options["font"][2])
                else
                    self.textbox:setFont(options["font"])
                end
            end
        
            if options["align"] then
                self.textbox:setAlign(options["align"])
            end
        
            self.textbox:setSkippable(options["skip"] or options["skip"] == nil)
            self.textbox:setAdvance(options["advance"] or options["advance"] == nil)
            self.textbox:setAuto(options["auto"])
        
            if false then -- future feature
                self.textbox:setText("[wait:2]"..text, function()
                    self.textbox:remove()
                    self:tryResume()
                end)
            else
                self.textbox:setText(text, function()
                    self.textbox:remove()
                    self:tryResume()
                end)
            end
        
            local wait = options["wait"] or options["wait"] == nil
            if not self.textbox.text.can_advance then
                wait = options["wait"] -- By default, don't wait if the textbox can't advance
            end
        
            if wait then
                return self:wait(waitForTextbox)
            else
                return waitForTextbox, self.textbox
            end
        end)
    end
    
    Utils.hook(PartyBattler, "calculateDamage", function(orig, self, amount)
        if Game:isLight() then
            local def = self.chara:getStat("defense")
            local hp = self.chara:getHealth()
            
            local bonus = lib.bonus_damage ~= false and hp > 20 and math.min(1 + math.floor((hp - 20) / 10), 8) or 0
            amount = Utils.round(amount / 5 + bonus - def / 5)
            
            return math.max(amount, 1)
        else
            return orig(self, amount)
        end
    end)
    
    Utils.hook(EnemyBattler, "getAttackDamage", function(orig, self, damage, battler, points)
        if damage > 0 then
            return damage
        end
        if Game:isLight() then
            return ((battler.chara:getStat("attack") * points) / 68) - (self.defense * 2.2)
        else
            return orig(self, damage, battler, points)
        end
    end)
    
    Utils.hook(EnemyBattler, "freeze", function(orig, self)
        if Game:isLight() then
            Game.battle.money = Game.battle.money - 24 + 2
        end
        orig(self)
    end)
    
    Utils.hook(EnemyBattler, "defeat", function(orig, self, reason, violent)
        orig(self, reason, violent)
        if violent then
            if MagicalGlassLib.random_encounter and MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter).population then
                MagicalGlassLib:createRandomEncounter(MagicalGlassLib.random_encounter):addFlag("violent", 1)
            end
        end
    end)

    Utils.hook(PartyMember, "init", function(orig, self)
        orig(self)

        self.short_name = nil
        
        self.undertale_movement = false
        
        self.lw_stats_bonus = {
            health = 0,
            attack = 0,
            defense = 0,
            magic = 0
        }

        -- Light Stat Menu stuff
        self.lw_stat_text = nil
        self.lw_portrait = nil

        -- Main Color
        self.light_color = nil
        
        -- Light Battle Colors
        self.light_dmg_color = nil
        self.light_miss_color = nil
        self.light_attack_color = nil
        self.light_multibolt_attack_color = nil
        self.light_attack_bar_color = nil
        self.light_xact_color = nil
        
        -- Light Battle Colors in the dark world
        self.light_dmg_color_dw = nil
        self.light_miss_color_dw = nil
        self.light_attack_color_dw = nil
        self.light_multibolt_attack_dw = nil
        self.light_attack_bar_color_dw = nil
        self.light_xact_color_dw = nil
        
        -- Dark Battle Colors in the light world
        self.dmg_color_lw = nil
        self.attack_bar_color_lw = nil
        self.attack_box_color_lw = nil
        self.xact_color_lw = nil

        self.lw_stats["magic"] = 0
        
        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            Game.stage.timer:after(1/30, function()
                if not Game:isLight() and MagicalGlassLib.initialize_armor_conversion then
                    for i = 1, 2 do
                        if self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) == self.lw_armor_default then
                            self:setFlag("converted_light_armor", "light/bandage")
                            break
                        end
                    end
                end
            end)
        end
    end)

    Utils.hook(PartyMember, "heal", function(orig, self, amount, playsound)
        if Game:isLight() then
            if playsound == nil or playsound then
                Assets.stopAndPlaySound("power")
            end
            if self:getHealth() < self:getStat("health") then
                self:setHealth(math.min(self:getStat("health"), self:getHealth() + amount))
            end
            return self:getStat("health") == self:getHealth()
        else
            return orig(self, amount, playsound)
        end
    end)
    
    Utils.hook(PartyMember, "convertToLight", function(orig, self)
        local last_weapon = self:getWeapon() and self:getWeapon().id or false
        local last_armors = {self:getArmor(1) and self:getArmor(1).id or false, self:getArmor(2) and self:getArmor(2).id or false}
        
        self.equipped = {weapon = nil, armor = {}}
        
        if self:getFlag("light_weapon") then
            self.equipped.weapon = Registry.createItem(self:getFlag("light_weapon"))
        end
        if self:getFlag("light_armor") then
            self.equipped.armor[1] = Registry.createItem(self:getFlag("light_armor"))
        end
        
        if self:getFlag("light_weapon") == nil then
            self.equipped.weapon = self.lw_weapon_default and Registry.createItem(self.lw_weapon_default) or nil
        end
        if self:getFlag("light_armor") == nil then
            self.equipped.armor[1] = self.lw_armor_default and Registry.createItem(self.lw_armor_default) or nil
        end
        
        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            if last_weapon then
                local result = Registry.createItem(last_weapon):convertToLightEquip(self)
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) and self:canEquip(result) and self.equipped.weapon and self.equipped.weapon.dark_item and self.equipped.weapon.equip_can_convert ~= false then
                        self.equipped.weapon = result
                    end
                end
            end
            local converted = false
            for i = 1, 2 do
                if last_armors[i] then
                    local result = Registry.createItem(last_armors[i]):convertToLightEquip(self)
                    if result then
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) and self:canEquip(result) and (self.equipped.armor[1] and (self.equipped.armor[1].equip_can_convert or self.equipped.armor[1].id == result.id) or not self.equipped.armor[1]) then
                            if self:getFlag("converted_light_armor") == nil then
                                if self.equipped.armor[1] and self.equipped.armor[1].id == result.id then
                                    self:setFlag("converted_light_armor", "light/bandage")
                                else
                                    self:setFlag("converted_light_armor", self.equipped.armor[1] and self.equipped.armor[1].id or "light/bandage")
                                end
                            end
                            converted = true
                            self.equipped.armor[1] = result
                            break
                        end
                    end
                end
            end
            if not converted and self:getFlag("converted_light_armor") ~= nil then
                self.equipped.armor[1] = self:getFlag("converted_light_armor") and Registry.createItem(self:getFlag("converted_light_armor")) or nil
                self:setFlag("converted_light_armor", nil)
            end
        end
        
        self:setFlag("dark_weapon", last_weapon)
        self:setFlag("dark_armors", last_armors)
    end)
    
    Utils.hook(PartyMember, "convertToDark", function(orig, self)
        local last_weapon = self:getWeapon() and self:getWeapon().id or false
        local last_armor = self:getArmor(1) and self:getArmor(1).id or false
        
        self.equipped = {weapon = nil, armor = {}}
        
        if self:getFlag("dark_weapon") then
            self.equipped.weapon = Registry.createItem(self:getFlag("dark_weapon"))
        end
        for i = 1, 2 do
            if self:getFlag("dark_armors") and self:getFlag("dark_armors")[i] then
                self.equipped.armor[i] = Registry.createItem(self:getFlag("dark_armors")[i])
            end
        end
        
        if Kristal.getLibConfig("magical-glass", "equipment_conversion") then
            if last_weapon then
                local result = Registry.createItem(last_weapon).dark_item
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) and self:canEquip(result) and self.equipped.weapon and self.equipped.weapon:convertToLightEquip(self) and self.equipped.weapon.equip_can_convert ~= false then
                        self.equipped.weapon = result
                    end
                end
            end
            if last_armor then
                local result = Registry.createItem(last_armor).dark_item
                if result then
                    if type(result) == "string" then
                        result = Registry.createItem(result)
                    end
                    if isClass(result) and self:canEquip(result) then
                        if self:getFlag("converted_light_armor") == nil then
                            self:setFlag("converted_light_armor", "light/bandage")
                        end
                        local already_equipped = false
                        for i = 1, 2 do
                            if self.equipped.armor[i] and (self.equipped.armor[i].id == result.id or self.equipped.armor[i].equip_can_convert == false) then
                                already_equipped = true
                            end
                        end
                        if not already_equipped then
                            for i = 1, 2 do
                                if self.equipped.armor[i] then
                                    Game.inventory:addItem(self.equipped.armor[i].id)
                                end
                            end
                            self.equipped.armor[1] = result
                            self.equipped.armor[2] = nil
                        end
                    end
                else
                    for i = 1, 2 do
                        if self:getFlag("converted_light_armor") ~= nil and self.equipped.armor[i] and self.equipped.armor[i]:convertToLightEquip(self) then
                            self.equipped.armor[i] = nil
                            self:setFlag("converted_light_armor", nil)
                            break
                        end
                    end
                end
            end
        end
        
        self:setFlag("light_weapon", last_weapon)
        self:setFlag("light_armor", last_armor)
    end)

    Utils.hook(PartyMember, "getLightEXP", function(orig, self)
        return self.lw_exp
    end)
    
    Utils.hook(PartyMember, "getShortName", function(orig, self)
        return self.short_name or string.sub(self:getName(), 1, 6)
    end)

    Utils.hook(PartyMember, "onActionSelect", function(orig, self, battler, undo)
        if Game.battle.turn_count == 1 and not undo then
            for _,equip in ipairs(self:getEquipment()) do
                if equip.onActionSelect() then
                    equip:onActionSelect(self)
                end
            end
        end
    end)
    
    Utils.hook(PartyMember, "onTurnEnd", function(orig, self, battler)
        for _,equip in ipairs(self:getEquipment()) do
            if equip.onTurnEnd then
                equip:onTurnEnd(self)
            end
        end
    end)

    Utils.hook(PartyMember, "getNameOrYou", function(orig, self, lower)
        if Game.party[1] and self.id == Game.party[1].id and not (not Kristal.getLibConfig("magical-glass", "multi_leader_mentioned_as_you") and (Game.battle and Game.battle.multi_mode or not Game.battle and #Game.party > 1)) then
            if lower then
                return "you", true
            else
                return "You", true
            end
        else
            return self:getName(), false
        end
    end)

    Utils.hook(PartyMember, "onLightLevelUp", function(orig, self)
        if self:getLightLV() < #self.lw_exp_needed or self:getLightEXPNeeded(#self.lw_exp_needed) >= self.lw_exp then
            local old_lv = self:getLightLV()

            local new_lv = 1
            for lv, exp in pairs(self.lw_exp_needed) do
                if self:getLightEXP() >= exp then
                    new_lv = lv
                end
            end
            if old_lv < 1 and self:getLightEXP() < self.lw_exp_needed[1] then
                new_lv = old_lv
            end

            if old_lv ~= new_lv and new_lv <= #self.lw_exp_needed then
                self:setLightLV(new_lv, false)
            end
        end
    end)

    Utils.hook(PartyMember, "setLightEXP", function(orig, self, exp)
        self.lw_exp = exp

        self:onLightLevelUp()
    end)

    Utils.hook(PartyMember, "addLightEXP", function(orig, self, exp)
        if self:getLightEXP() >= self.lw_exp_needed[1] and self:getLightEXP() <= self.lw_exp_needed[#self.lw_exp_needed] then
            self:setLightEXP(Utils.clamp(self:getLightEXP() + exp, self.lw_exp_needed[1], self.lw_exp_needed[#self.lw_exp_needed]))
        else
            self:setLightEXP(self:getLightEXP() + exp)
        end
    end)

    Utils.hook(PartyMember, "setLightLV", function(orig, self, level, force_exp)
        self.lw_lv = level

        if force_exp ~= false then
            if self.lw_lv > #self.lw_exp_needed then
                self.lw_exp = self.lw_exp_needed[#self.lw_exp_needed] + 1
            elseif self.lw_exp_needed[level] then
                self.lw_exp = self:getLightEXPNeeded(level)
            else
                self.lw_exp = 0
            end
        end
        
        self:lightLVStats()
        for stat,amount in pairs(self.lw_stats_bonus) do
            self.lw_stats[stat] = self.lw_stats[stat] + amount
        end
    end)
    
    Utils.hook(PartyMember, "reloadLightStats", function(orig, self)
        self:setLightLV(self:getLightLV(), false)
    end)
    
    Utils.hook(PartyMember, "lightLVStats", function(orig, self)
        self.lw_stats = {
            health = self:getLightLV() == 20 and 99 or 16 + self:getLightLV() * 4,
            attack = 8 + self:getLightLV() * 2,
            defense = 9 + math.ceil(self:getLightLV() / 4),
            magic = 0
        }
    end)
    
    Utils.hook(PartyMember, "increaseStat", function(orig, self, stat, amount, max)
        if Game:isLight() and amount == "reset" then
            self.lw_stats_bonus[stat] = 0
            self:reloadLightStats()
            return
        end
        local pre_bonus = self:getBaseStats()[stat]
        orig(self, stat, amount, max)
        local post_bonus = self:getBaseStats()[stat]
        if Game:isLight() then
            self.lw_stats_bonus[stat] = self.lw_stats_bonus[stat] + post_bonus - pre_bonus
        end
    end)

    Utils.hook(PartyMember, "getLightStatText", function(orig, self) return self.lw_stat_text end)
    Utils.hook(PartyMember, "getLightPortrait", function(orig, self) return self.lw_portrait end)
    
    -- Main Color
    Utils.hook(PartyMember, "getColor", function(orig, self)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() and Game.battle and not Game.battle.light then
            return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color"])
        elseif self.light_color and Game:isLight() then
            return Utils.unpackColor(self.light_color)
        else
            return orig(self)
        end
    end)
    
    -- Dark Battle Colors
    Utils.hook(PartyMember, "getAttackBarColor", function(orig, self)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() then
            return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_attackbar"])
        else
            return orig(self)
        end
    end)

    Utils.hook(PartyMember, "getAttackBoxColor", function(orig, self)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() then
            return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_attackbox"])
        else
            return orig(self)
        end
    end)
    
    Utils.hook(PartyMember, "getDamageColor", function(orig, self)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") == true and Game:isLight() and #Game.battle.party == 1 then
            return Utils.unpackColor(MG_PALETTE["light_world_dark_battle_color_damage_single"])
        else
            return orig(self)
        end
    end)
    
    Utils.hook(ActionBox, "init", function(orig, self, x, y, index, battler)
        orig(self, x, y, index, battler)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
            self.head_sprite:addFX(ShaderFX(lib:colorShader(MG_PALETTE["light_world_dark_battle_color"])))
        end
    end)
    
    Utils.hook(AttackBox, "init", function(orig, self, battler, offset, index, x, y)
        orig(self, battler, offset, index, x, y)
        if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
            self.head_sprite:addFX(ShaderFX(lib:colorShader(MG_PALETTE["light_world_dark_battle_color"])))
        end
    end)

    -- Light Battle Colors
    Utils.hook(PartyMember, "getLightDamageColor", function(orig, self)
        if Game.battle and not Game.battle.multi_mode then
            return Utils.unpackColor(COLORS.red)
        elseif self.light_dmg_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_dmg_color_dw)
        elseif self.light_dmg_color and Game:isLight() then
            return Utils.unpackColor(self.light_dmg_color)
        else
            return self:getColor()
        end
    end)

    Utils.hook(PartyMember, "getLightMissColor", function(orig, self)
        if Game.battle and not Game.battle.multi_mode then
            return Utils.unpackColor(COLORS.silver)
        elseif self.light_miss_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_miss_color_dw)
        elseif self.light_miss_color and Game:isLight() then
            return Utils.unpackColor(self.light_miss_color)
        else
            return self:getColor()
        end
    end)

    Utils.hook(PartyMember, "getLightAttackColor", function(orig, self)
        if Game.battle and not Game.battle.multi_mode then
            return Utils.unpackColor({1, 105/255, 105/255})
        elseif self.light_attack_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_attack_color_dw)
        elseif self.light_attack_color and Game:isLight() then
            return Utils.unpackColor(self.light_attack_color)
        else
            return self:getColor()
        end
    end)
    
    Utils.hook(PartyMember, "getLightMultiboltAttackColor", function(orig, self)
        if Game.battle and not Game.battle.multi_mode then
            return Utils.unpackColor(COLORS.white)
        elseif self.light_multibolt_attack_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_multibolt_attack_color_dw)
        elseif self.light_multibolt_attack_color and Game:isLight() then
            return Utils.unpackColor(self.light_multibolt_attack_color)
        else
            return self:getColor()
        end
    end)

    Utils.hook(PartyMember, "getLightAttackBarColor", function(orig, self)
        if Game.battle and not Game.battle.multi_mode then
            return Utils.unpackColor(COLORS.white)
        elseif self.light_attack_bar_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_attack_bar_color_dw)
        elseif self.light_attack_bar_color and Game:isLight() then
            return Utils.unpackColor(self.light_attack_bar_color)
        else
            return self:getColor()
        end
    end)

    Utils.hook(PartyMember, "getLightXActColor", function(orig, self)
        if self.light_xact_color_dw and not Game:isLight() then
            return Utils.unpackColor(self.light_xact_color_dw)
        elseif self.light_xact_color and Game:isLight() then
            return Utils.unpackColor(self.light_xact_color)
        else
            return self:getXActColor()
        end
    end)
    
    
    -- Dark Battle Colors
    Utils.hook(PartyMember, "getDamageColor", function(orig, self)
        if self.dmg_color_lw and Game:isLight() then
            return Utils.unpackColor(self.dmg_color_lw)
        else
            return orig(self)
        end
    end)
    
    Utils.hook(PartyMember, "getAttackBarColor", function(orig, self)
        if self.attack_bar_color_lw and Game:isLight() then
            return Utils.unpackColor(self.attack_bar_color_lw)
        else
            return orig(self)
        end
    end)
    
    Utils.hook(PartyMember, "getAttackBoxColor", function(orig, self)
        if self.attack_box_color_lw and Game:isLight() then
            return Utils.unpackColor(self.attack_box_color_lw)
        else
            return orig(self)
        end
    end)
    
    Utils.hook(PartyMember, "getXActColor", function(orig, self)
        if self.xact_color_lw and Game:isLight() then
            return Utils.unpackColor(self.xact_color_lw)
        else
            return orig(self)
        end
    end)
    
    Utils.hook(PartyMember, "onLightAttackHit", function(orig, self, enemy, damage) end)
    
    Utils.hook(PartyMember, "onSave", function(orig, self, data)
        orig(self, data)
        data.lw_stat_text = self.lw_stat_text
        data.lw_portrait = self.lw_portrait
        data.lw_stats_bonus = self.lw_stats_bonus
    end)
    
    Utils.hook(PartyMember, "onLoad", function(orig, self, data)
        orig(self, data)
        self.lw_stat_text = data.lw_stat_text or self.lw_stat_text
        self.lw_portrait = data.lw_portrait or self.lw_portrait
        self.lw_stats_bonus = data.lw_stats_bonus or self.lw_stats_bonus
    end)

    Utils.hook(LightMenu, "draw", function(orig, self)
        Object.draw(self)
        
        if self.box and self.box.state == "PARTYSELECT" then
            local function party_box_area()
                local party_box = self.box.party_select_bg
                love.graphics.rectangle("fill", party_box.x + 188, party_box.y + 52, party_box.width + 48, party_box.height + 48)
            end
            love.graphics.stencil(party_box_area, "replace", 1)
            love.graphics.setStencilTest("equal", 0)
        end

        local offset = 0
        if self.top then
            offset = 270
        end

        local chara = Game.party[1]

        love.graphics.setFont(self.font)
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print(chara:getName(), 46, 60 + offset)

        love.graphics.setFont(self.font_small)
        love.graphics.print(Kristal.getLibConfig("magical-glass", "light_level_name_short").."  "..chara:getLightLV(), 46, 100 + offset)
        love.graphics.print("HP  "..chara:getHealth().."/"..chara:getStat("health"), 46, 118 + offset)
        if Kristal.getLibConfig("magical-glass", "undertale_menu_display") then
            love.graphics.print(Game:getConfig("lightCurrencyShort"), 46, 136 + offset)
            love.graphics.print(Game.lw_money, 82, 136 + offset)
        else
            love.graphics.print(Utils.padString(Game:getConfig("lightCurrencyShort"), 4)..Game.lw_money, 46, 136 + offset)
        end

        love.graphics.setFont(self.font)
        if Game.inventory:getItemCount(self.storage, false) <= 0 then
            Draw.setColor(PALETTE["world_gray"])
        else
            Draw.setColor(PALETTE["world_text"])
        end
        love.graphics.print("ITEM", 84, 188 + (36 * 0))
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print("STAT", 84, 188 + (36 * 1))
        if Game:getFlag("has_cell_phone", false) then
            if #Game.world.calls > 0 then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_gray"])
            end
            love.graphics.print("CELL", 84, 188 + (36 * 2))
            
            if Mod.libs["light_menu_talk"] then
                if Kristal.getLibConfig("light_menu_talk", "have_talk_when_alone") or not Kristal.getLibConfig("light_menu_talk", "have_talk_when_alone") and #Game.party > 1 then
                    Draw.setColor(PALETTE["world_text"])
                    love.graphics.print("TALK", 84, 188 + (36 * 3))
                end
            end
        else
            if Mod.libs["light_menu_talk"] then
                Draw.setColor(PALETTE["world_text"])
                love.graphics.print("TALK", 84, 188 + (36 * 2))
            end
        end

        if self.state == "MAIN" then
            Draw.setColor(Game:getSoulColor())
            Draw.draw(self.heart_sprite, 56, 160 + (36 * self.current_selecting), 0, 2, 2)
        end
        
        love.graphics.setStencilTest()
    end)

    Utils.hook(LightStatMenu, "init", function(orig, self)
        orig(self)
        
        self.state = "STATS"
        self.party_selecting = 1
        self.spell_selecting = 1
        self.option_selecting = 1
        self.heart_sprite = Assets.getTexture("player/heart_menu")
        self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")
        self.font_small = Assets.getFont("small")
        self.scroll_y = 1
        
        if Mod.libs["moreparty"] and #Game.party > 3 then
            if not Kristal.getLibConfig("moreparty", "classic_mode") then
                self.party_select_bg = UIBox(-97, 242 + (#Game.party == 4 and 56 or 18), 492, #Game.party == 4 and 52 or 90)
            else
                self.party_select_bg = UIBox(-37, 242 + 18, 372, 90)
            end
        else
            self.party_select_bg = UIBox(-37, 242 + 56, 372, 52)
        end
        self.party_select_bg.visible = false
        self.party_select_bg.layer = -1
        self.party_selecting_spell = 1
        self:addChild(self.party_select_bg)
    end)

    Utils.hook(LightStatMenu, "update", function(orig, self)
        self.undertale_stat_display = Kristal.getLibConfig("magical-glass", "undertale_menu_display")
        
        local show_magic = false
        for _,party in pairs(Game.party) do
            if party:getBaseStats()["magic"] > 0 then
                show_magic = true
            end
        end
        self.show_magic = Kristal.getLibConfig("magical-glass", "always_show_magic") or show_magic and self.undertale_stat_display
    
        local old_selecting_party        = self.party_selecting
        local old_selecting_spell        = self.spell_selecting
        local old_selecting_option       = self.option_selecting
        local old_selecting_party_spell  = self.party_selecting_spell
    
        if not OVERLAY_OPEN or TextInput.active then
            if self.state == "PARTYSELECT" then
                if Input.pressed("right") then
                    self.party_selecting_spell = self.party_selecting_spell + 1
                end

                if Input.pressed("left") then
                    self.party_selecting_spell = self.party_selecting_spell - 1
                end
            elseif self.state == "USINGSPELL" then
                if Input.pressed("right") then
                    self.option_selecting = self.option_selecting + 1
                end

                if Input.pressed("left") then
                    self.option_selecting = self.option_selecting - 1
                end
            elseif self.state ~= "SELECTINGSPELL" then
                if Input.pressed("right") then
                    self.party_selecting = self.party_selecting + 1
                end

                if Input.pressed("left") then
                    self.party_selecting = self.party_selecting - 1
                end
            else
                if Input.pressed("down") then
                    self.spell_selecting = self.spell_selecting + 1
                end
                
                if Input.pressed("up") then
                    self.spell_selecting = self.spell_selecting - 1
                end
            end
        end
        
        self.party_selecting = Utils.clamp(self.party_selecting, 1, #Game.party)
        self.spell_selecting = Utils.clamp(self.spell_selecting, 1, #self:getSpells())
        self.option_selecting = Utils.clamp(self.option_selecting, 1, 2)
        self.party_selecting_spell = Utils.clamp(self.party_selecting_spell, 1, #Game.party)

        if self.party_selecting ~= old_selecting_party or self.spell_selecting ~= old_selecting_spell or self.option_selecting ~= old_selecting_option or old_selecting_party_spell ~= self.party_selecting_spell then
            self.ui_move:stop()
            self.ui_move:play()
        end
        
        if self.spell_selecting ~= old_selecting_spell then
            local spell_limit = self:getSpellLimit()
            local min_scroll = math.max(1, self.spell_selecting - (spell_limit - 1))
            local max_scroll = math.min(math.max(1, #self:getSpells() - (spell_limit - 1)), self.spell_selecting)
            self.scroll_y = Utils.clamp(self.scroll_y, min_scroll, max_scroll)
        end
        
        local spell = self:getSpells()[self.spell_selecting]
        local function has_cutscene() return not Game.world:hasCutscene() end
        if Input.pressed("confirm") and (not OVERLAY_OPEN or TextInput.active) then
            if self.state == "STATS" and self.show_magic then
                self.ui_select:stop()
                self.ui_select:play()
                
                if #Game.party > 1 then
                    self.state = "SPELLS"
                elseif #self:getSpells() > 0 then
                    self.scroll_y = 1
                    self.spell_selecting = 1
                    self.state = "SELECTINGSPELL"
                end
            elseif self.state == "SPELLS" then
                self.ui_select:stop()
                self.ui_select:play()
                
                self.scroll_y = 1
                self.spell_selecting = 1
                if #self:getSpells() > 0 then
                    self.state = "SELECTINGSPELL"
                end
            elseif self.state == "SELECTINGSPELL" then
                self.ui_select:stop()
                self.ui_select:play()
                
                self.option_selecting = 1
                self.state = "USINGSPELL"
            elseif self.state == "USINGSPELL" then
                if self.option_selecting == 1 and self:canCast(spell) then
                    if spell.target == "ally" and #Game.party > 1 then
                        self.ui_select:stop()
                        self.ui_select:play()
                    
                        self.party_select_bg.visible = true
                        self.party_selecting_spell = 1
                        self.state = "PARTYSELECT"
                    else
                        Game:removeTension(spell:getTPCost())
                        spell:onLightWorldStart(Game.party[self.party_selecting], spell.target == "ally" and Game.party[1] or spell.target == "party" and Game.party or nil)
                        Game.world.menu:closeBox()
                        Game.world.menu.state = "SPELLUSAGE"
                        Game.world.timer:afterCond(has_cutscene, function() Game.world:closeMenu() end)
                    end
                elseif self.option_selecting == 2 then
                    spell:onCheck()
                    Game.world.menu:closeBox()
                    Game.world.menu.state = "SPELLUSAGE"
                    Game.world.timer:afterCond(has_cutscene, function() Game.world:closeMenu() end)
                end
            elseif self.state == "PARTYSELECT" then
                Game:removeTension(spell:getTPCost())
                spell:onLightWorldStart(Game.party[self.party_selecting], Game.party[self.party_selecting_spell])
                Game.world.menu:closeBox()
                Game.world.menu.state = "SPELLUSAGE"
                Game.world.timer:afterCond(has_cutscene, function() Game.world:closeMenu() end)
            end
        end

        if Input.pressed("cancel") and (not OVERLAY_OPEN or TextInput.active) then
            self.ui_move:stop()
            self.ui_move:play()
            if self.state == "PARTYSELECT" then
                self.party_select_bg.visible = false
                self.state = "USINGSPELL"
            elseif self.state == "USINGSPELL" then
                self.state = "SELECTINGSPELL"
            elseif self.state == "SELECTINGSPELL" then
                self.scroll_y = 1
                if #Game.party > 1 then
                    self.state = "SPELLS"
                else
                    self.state = "STATS"
                end
            elseif self.state == "SPELLS" then
                self.state = "STATS"
            elseif self.state == "STATS" then
                Game.world.menu:closeBox()
            end
            return
        end

        Object.update(self)

    end)

    Utils.hook(LightStatMenu, "getSpells", function(orig, self)
        local spells = {}
        local party = Game.party[self.party_selecting]
        if party:hasAct() then
            table.insert(spells, Registry.createSpell("_act"))
        end
        for _,spell in ipairs(party:getSpells()) do
            table.insert(spells, spell)
        end
        return spells
    end)
    
    Utils.hook(LightStatMenu, "getSpellLimit", function(orig, self)
        return 6
    end)
    
    Utils.hook(LightStatMenu, "canCast", function(orig, self, spell)
        if not Game:getConfig("overworldSpells") then return false end
        if Game:getTension() < spell:getTPCost(Game.party[self.party_selecting]) then return false end

        return (spell:hasWorldUsage(Game.party[self.party_selecting]))
    end)

    Utils.hook(LightStatMenu, "draw", function(orig, self)
        love.graphics.setFont(self.font)
        Draw.setColor(PALETTE["world_text"])
        
        local party = Game.party[self.party_selecting]
        
        if self.state == "PARTYSELECT" then
            local function party_box_area()
                local party_box = self.party_select_bg
                love.graphics.rectangle("fill", party_box.x - 24, party_box.y - 24, party_box.width + 48, party_box.height + 48)
            end
            love.graphics.stencil(party_box_area, "replace", 1)
            love.graphics.setStencilTest("equal", 0)
        end
        
        love.graphics.print("\"" .. party:getName() .. "\"", 4, 8)
        if party:getLightStatText() and not party:getLightPortrait() then
            love.graphics.print(party:getLightStatText(), 172, 8)
        end
        
        local ox, oy = party.actor:getPortraitOffset()
        if party:getLightPortrait() then
            Draw.draw(Assets.getTexture(party:getLightPortrait()), 179 + ox, 7 + oy, 0, 2, 2)
        end

        if #Game.party > 1 then
            if self.state == "STATS" or self.state == "SPELLS" then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, 212, 124, 0, 2, 2)
            end
            
            Draw.setColor(PALETTE["world_text"])
            love.graphics.print("<                >", 162, 116)
        end

        Draw.setColor(PALETTE["world_text"])
        
        love.graphics.print(Kristal.getLibConfig("magical-glass", "light_level_name_short").."  "..party:getLightLV(), 4, 68)
        love.graphics.print("HP  "..party:getHealth().." / "..party:getStat("health"), 4, 100)

        if self.state == "STATS" then
            local exp_needed = math.max(0, party:getLightEXPNeeded(party:getLightLV() + 1) - party:getLightEXP())
        
            local at = party:getBaseStats()["attack"]
            local df = party:getBaseStats()["defense"]
            local mg = party:getBaseStats()["magic"]
            
            if self.undertale_stat_display then
                at = at - 10
                df = df - 10
            end

            local offset = 0
            if self.show_magic then
                offset = 16
                love.graphics.print("MG  ", 4, 228 - offset)
                love.graphics.print(mg  .. " ("..party:getEquipmentBonus("magic")   .. ")", 44, 228 - offset) -- alinging the numbers with the rest of the stats
            end
            love.graphics.print("AT  "  .. at  .. " ("..party:getEquipmentBonus("attack")  .. ")", 4, 164 - offset)
            love.graphics.print("DF  "  .. df  .. " ("..party:getEquipmentBonus("defense") .. ")", 4, 196 - offset)
            love.graphics.print("EXP: " .. party:getLightEXP(), 172, 164)
            love.graphics.print("NEXT: ".. exp_needed, 172, 196)
        
            local weapon_name = "None"
            local armor_name = "None"

            if party:getWeapon() then
                weapon_name = party:getWeapon().getEquipDisplayName and party:getWeapon():getEquipDisplayName() or party:getWeapon():getName()
            end

            if party:getArmor(1) then
                armor_name = party:getArmor(1).getEquipDisplayName and party:getArmor(1):getEquipDisplayName() or party:getArmor(1):getName()
            end
            
            love.graphics.print("WEAPON: "..weapon_name, 4, 256)
            love.graphics.print("ARMOR: "..armor_name, 4, 288)
        
            love.graphics.print(Game:getConfig("lightCurrency"):upper()..": "..Game.lw_money, 4, 328)
            if MagicalGlassLib.kills > 20 then
                love.graphics.print("KILLS: "..MagicalGlassLib.kills, 172, 328)
            end
            
            if self.show_magic then
                love.graphics.setFont(self.font_small)
                if Input.usingGamepad() then
                    Draw.printAlign("PRESS    TO VIEW SPELLS", 150, 368, "center")
                    Draw.draw(Input.getTexture("confirm"), 100, 366)
                else
                    Draw.printAlign("PRESS " .. Input.getText("confirm") .. " TO VIEW SPELLS", 150, 368, "center")
                end
            end
        else
            local spells = self:getSpells()
            local spell_limit = self:getSpellLimit()
            
            love.graphics.setFont(self.font_small)
            Draw.setColor(PALETTE["world_gray"])
            love.graphics.print(Kristal.getLibConfig("magical-glass", "light_battle_tp_name"), 21, 138)
            
            love.graphics.setFont(self.font)
            Draw.setColor(PALETTE["world_text"])
            for i = self.scroll_y, math.min(#spells, self.scroll_y + (spell_limit - 1)) do
                local spell = spells[i]
                local offset = i - self.scroll_y
                
                love.graphics.print(tostring(spell:getTPCost(party)).."%", 20, 148 + offset * 32)
                love.graphics.print(spell:getName(), 90, 148 + offset * 32)
            end
            
            Draw.setColor(Game:getSoulColor())
            if self.state == "SELECTINGSPELL" then
                Draw.draw(self.heart_sprite, -4, 156 + 32 * (self.spell_selecting - self.scroll_y), 0, 2, 2)
            elseif self.state == "USINGSPELL" then
                if self.option_selecting == 1 then
                    Draw.draw(self.heart_sprite, -4 + 32, 348, 0, 2, 2)
                elseif self.option_selecting == 2 then
                    Draw.draw(self.heart_sprite, 206 - 32, 348, 0, 2, 2)
                end
            end
            
            -- Draw scroll arrows if needed
            if #spells > spell_limit then
                Draw.setColor(1, 1, 1)

                -- Move the arrows up and down only if we're in the spell selection state
                local sine_off = 0
                if self.state == "SELECTINGSPELL" then
                    sine_off = math.sin((Kristal.getTime()*30)/12) * 3
                end

                if self.scroll_y > 1 then
                    -- up arrow
                    Draw.draw(self.arrow_sprite, 294 - 4, (148 + 25 - 3) - sine_off, 0, 1, -1)
                end
                if self.scroll_y + spell_limit <= #spells then
                    -- down arrow
                    Draw.draw(self.arrow_sprite, 294 - 4, (148 + (32 * spell_limit) - 19) + sine_off)
                end
            end
            
            -- Draw scrollbar if needed (unless the spell limit is 2, in which case the scrollbar is too small)
            if self.state == "SELECTINGSPELL" and spell_limit > 2 and #spells > spell_limit then
                local scrollbar_height = (spell_limit - 2) * 32 + 7
                Draw.setColor(0.25, 0.25, 0.25)
                love.graphics.rectangle("fill", 294, 148 + 30, 6, scrollbar_height)
                local percent = (self.scroll_y - 1) / (#spells - spell_limit)
                Draw.setColor(1, 1, 1)
                love.graphics.rectangle("fill", 294, 148 + 30 + math.floor(percent * (scrollbar_height-6)), 6, 6)
            end
            
            if self.state == "PARTYSELECT" then
                love.graphics.setStencilTest()
                Draw.setColor(PALETTE["world_text"])
                
                local z = Mod.libs["moreparty"] and Kristal.getLibConfig("moreparty", "classic_mode") and 3 or 4
                
                Draw.printAlign("Use " .. spells[self.spell_selecting]:getName() .. " on", 150, 231 + (#Game.party > z and 18 or 56), "center")

                for i,party in ipairs(Game.party) do
                    if i <= z then
                        love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 269 + (#Game.party > z and 18 or 56))
                    else
                        love.graphics.print(party:getShortName(), 63 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 269 + 38 + (#Game.party > z and 18 or 56))
                    end
                end

                Draw.setColor(Game:getSoulColor())
                for i,party in ipairs(Game.party) do
                    if i == self.party_selecting_spell then
                        if i <= z then
                            Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party,z) - 2) * 70 + (i - 1) * 122, 277 + (#Game.party > z and 18 or 56), 0, 2, 2)
                        else
                            Draw.draw(self.heart_sprite, 39 - (math.min(#Game.party - z,z) - 2) * 70 + (i - 1 - z) * 122, 277 + 38 + (#Game.party > z and 18 or 56), 0, 2, 2)
                        end
                    end
                end
            else
                Draw.setColor(PALETTE["world_text"])
                if self.state ~= "SPELLS" and not self:canCast(spells[self.spell_selecting]) then
                    Draw.setColor(PALETTE["world_gray"])
                end
                love.graphics.print("USE" , 20 + 32 , 340)
                Draw.setColor(PALETTE["world_text"])
                love.graphics.print("INFO", 230 - 32, 340)
            end
        end
    end)

    Utils.hook(World, "spawnPlayer", function(orig, self, ...)
        local args = {...}

        local x, y = 0, 0
        local chara = self.player and self.player.actor
        local party
        if #args > 0 then
            if type(args[1]) == "number" then
                x, y = args[1], args[2]
                chara = args[3] or chara
                party = args[4]
            elseif type(args[1]) == "string" then
                x, y = self.map:getMarker(args[1])
                chara = args[2] or chara
                party = args[3]
            end
        end

        if type(chara) == "string" then
            chara = Registry.createActor(chara)
        end

        local facing = "down"

        if self.player then
            facing = self.player.facing
            self:removeChild(self.player)
        end
        if self.soul then
            self:removeChild(self.soul)
        end
        
        if Game.party[1].undertale_movement then
            self.player = UnderPlayer(chara, x, y)
        else
            self.player = Player(chara, x, y)
        end
        self.player.layer = self.map.object_layer
        self.player:setFacing(facing)
        self:addChild(self.player)
        
        if party then
            self.player.party = party
        end

        self.soul = OverworldSoul(self.player:getRelativePos(self.player.actor:getSoulOffset()))
        self.soul:setColor(Game:getSoulColor())
        if Mod.libs["multiplayer"] and Game.party[1] then
            self.soul:setColor(Game.party[1]:getColor())
            if Game.party[1].soul_priority < 2 then
                self.soul.rotation = math.pi
            end
        end
        
        self.soul.layer = WORLD_LAYERS["soul"]
        self:addChild(self.soul)

        if self.camera.attached_x then
            self.camera:setPosition(self.player.x, self.camera.y)
        end
        if self.camera.attached_y then
            self.camera:setPosition(self.camera.x, self.player.y - (self.player.height * 2)/2)
        end
    end)

    Utils.hook(Savepoint, "init", function(orig, self, x, y, properties)
        orig(self, x, y, properties)
        Game.world.timer:after(1/30, function()
            if Game:isLight() then
                self:setSprite("world/events/lightsavepoint", 1/6)
            end
        end)
    end)
    
    Utils.hook(Savepoint, "onTextEnd", function(orig, self)
        if not Game:isLight() then
            orig(self)
        else
            if not self.world then return end

            if self.heals then
                for _,party in pairs(Game.party_data) do
                    party:heal(math.huge, false)
                end
            end
            
            if self.simple_menu or (self.simple_menu == nil and not Kristal.getLibConfig("magical-glass", "expanded_light_save_menu")) then
                self.world:openMenu(LightSaveMenu(Game.save_id, self.marker))
            else
                self.world:openMenu(LightSaveMenuExpanded(self.marker))
            end
        end
    end)

    Utils.hook(LightSaveMenu, "update", function(orig, self)
        if self.state == "MAIN" and (Input.pressed("left") or Input.pressed("right")) then
            Assets.stopAndPlaySound("ui_move")
        end
        orig(self)
    end)

    Utils.hook(LightSaveMenu, "draw", function(orig, self)
        love.graphics.setFont(self.font)

        if self.state == "SAVED" then
            Draw.setColor(PALETTE["world_text_selected"])
        else
            Draw.setColor(PALETTE["world_text"])
        end
    
        local data      = self.saved_file        or {}
        local mg        = data.magical_glass     or {}

        local name      = data.name              or "EMPTY"
        local level     = mg.lw_save_lv          or 0
        local playtime  = data.playtime          or 0
        local room_name = data.room_name         or "--"
    
        love.graphics.print(name,         self.box.x + 8,        self.box.y - 10 + 8)
        love.graphics.print(Kristal.getLibConfig("magical-glass", "light_level_name_short").." "..level, self.box.x + 210 - 42, self.box.y - 10 + 8)
    
        local minutes = math.floor(playtime / 60)
        local seconds = math.floor(playtime % 60)
        local time_text = string.format("%d:%02d", minutes, seconds)
        love.graphics.printf(time_text, self.box.x - 280 + 148, self.box.y - 10 + 8, 500, "right")
    
        love.graphics.print(room_name, self.box.x + 8, self.box.y + 38)
    
        if self.state == "MAIN" then
            love.graphics.print("Save",   self.box.x + 30  + 8, self.box.y + 98)
            love.graphics.print("Return", self.box.x + 210 + 8, self.box.y + 98)
    
            Draw.setColor(Game:getSoulColor())
            Draw.draw(self.heart_sprite, self.box.x + 10 + (self.selected_x - 1) * 180, self.box.y + 96 + 8, 0, 2, 2)
        elseif self.state == "SAVED" then
            love.graphics.print("File saved.", self.box.x + 30 + 8, self.box.y + 98)
        end
    
        Draw.setColor(1, 1, 1)
    
        Object.draw(self)
    end)
    
    Utils.hook(Spell, "init", function(orig, self)
        orig(self)
        
        self.check = "Example info"
    end)
    
    Utils.hook(Spell, "getCheck", function(orig, self)
        return self.check
    end)
    
    Utils.hook(Spell, "onCheck", function(orig, self)
        if type(self:getCheck()) == "table" then
            local text
            for i, check in ipairs(self:getCheck()) do
                if i > 1 then
                    if text == nil then
                        text = {}
                    end
                    table.insert(text, check)
                end
            end
            Game.world:showText({{"* \""..self:getName().."\" - "..(self:getCheck()[1] or "")}, text})
        else
            Game.world:showText("* \""..self:getName().."\" - "..self:getCheck())
        end
    end)

    Utils.hook(Spell, "onLightStart", function(orig, self, user, target)
        lib.heal_amount = nil
        if Utils.containsValue(self.tags, "damage") then
            if isClass(target) then
                if target:includes(LightEnemyBattler) and target.immune_to_damage then
                    target:onDodge(user, true)
                end
            else
                for _,enemy in ipairs(target) do
                    if enemy:includes(LightEnemyBattler) and enemy.immune_to_damage then
                        enemy:onDodge(user, true)
                    end
                end
            end
        end
        local result = self:onLightCast(user, target)
        Game.battle:battleText(self:getLightCastMessage(user, target))
        if result or result == nil then
            Game.battle:finishActionBy(user)
        end
    end)

    Utils.hook(Spell, "onLightCast", function(orig, self, user, target)
        return self:onCast(user, target)
    end)

    Utils.hook(Spell, "getLightCastMessage", function(orig, self, user, target)
        return "* "..user.chara:getNameOrYou().." cast "..self:getName().."."..(Utils.containsValue(self.tags, "heal") and "\n"..self:getHealMessage(user, target, lib.heal_amount) or "")
    end)
    
    Utils.hook(Spell, "onLightWorldStart", function(orig, self, user, target)
        lib.heal_amount = nil
        self:onLightWorldCast(target)
        Game.world:showText(self:getLightWorldCastMessage(user, target))
    end)
    
    Utils.hook(Spell, "onLightWorldCast", function(orig, self, target)
        self:onWorldCast(target)
    end)
    
    Utils.hook(Spell, "getLightWorldCastMessage", function(orig, self, user, target)
        return "* "..user:getNameOrYou().." cast "..self:getName().."."..(Utils.containsValue(self.tags, "heal") and "\n"..self:getWorldHealMessage(user, target, lib.heal_amount) or "")
    end)
    
    Utils.hook(Spell, "getWorldHealMessage", function(orig, self, user, target, amount) 
        local maxed = false
        if self.target == "ally" then
            maxed = target:getHealth() >= target:getStat("health") or amount == math.huge
        end
        local message = ""
        if self.target == "ally" then
            if select(2, target:getNameOrYou()) and maxed then
                message = "* Your HP was maxed out."
            elseif maxed then
                message = "* " .. target:getNameOrYou() .. "'s HP was maxed out."
            else
                message = "* " .. target:getNameOrYou() .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "party" then
            if #Game.battle.party > 1 then
                message = "* Everyone recovered " .. amount .. " HP."
            else
                message = "* You recovered " .. amount .. " HP."
            end
        end
        return message
    end)
    
    Utils.hook(SnowGraveSpell, "update", function(orig, self)
        if Game.battle.light then
            Object.update(self)
            self.timer = self.timer + DTMULT
            self.since_last_snowflake = self.since_last_snowflake + DTMULT

            if self.hurt_enemies then
                self.hurt_enemies = false
                for i, enemy in ipairs(Game.battle.enemies) do
                    if enemy then
                        enemy.hit_count = 0
                        enemy:hurt(self.damage + Utils.round(math.random(100)), self.caster)
                        enemy:flash()
                        if enemy.health <= 0 then
                            enemy.can_die = true
                        end
                    end
                end
            end
        else
            orig(self)
        end
    end)

    Utils.hook(SnowGraveSpell, "createSnowflake", function(orig, self, x, y)
        if Game.battle.light then
            local snowflake = SnowGraveSnowflake(x, y)
            snowflake.physics.gravity = 2
            snowflake.physics.gravity_direction = math.rad(0)
            snowflake.physics.speed_x = -(math.sin(self.timer / 2) * 0.5)
            snowflake.siner = self.timer / 2
            snowflake.rotation = math.rad(90)
            self:addChild(snowflake)
            return snowflake
        else
            return orig(self, x, y)
        end
    end)

    Utils.hook(SnowGraveSpell, "draw", function(orig, self)
        if Game.battle.light then
            Object.draw(self)

            Draw.setColor(1, 1, 1, self.bgalpha)
            Draw.draw(self.bg)

            self:drawTiled((self.snowspeed / 1.5), (self.timer * 6), self.bgalpha)
            self:drawTiled((self.snowspeed), (self.timer * 8), self.bgalpha * 2)

            if ((self.timer <= 10) and (self.timer >= 0)) then
                if (self.bgalpha < 0.5) then
                    self.bgalpha = self.bgalpha + 0.05 * DTMULT
                end
            end

            if (self.timer >= 0) then
                self.snowspeed = self.snowspeed + (20 + (self.timer / 5)) * DTMULT
            end

            if ((self.timer >= 20) and (self.timer <= 75)) then
                self.stimer = self.stimer + 1 * DTMULT

                if self.reset_once then
                    self.reset_once = false
                    self.since_last_snowflake = 1
                end

                if self.since_last_snowflake > 1 then
                    self:createSnowflake(-40, 120 + 55)
                    self:createSnowflake(-120, 120 + 0)
                    self:createSnowflake(-80, 120 - 45)
                    self.since_last_snowflake = self.since_last_snowflake - 1
                end

                if (self.stimer >= 8) then
                    self.stimer = 0
                end
            end


            if ((not self.hurt) and ((self.timer >= 95) and (self.damage > 0))) then
                self.hurt = true
                self.hurt_enemies = true
            end

            if (self.timer >= 90) then
                if (self.bgalpha > 0) then
                    self.bgalpha = self.bgalpha - 0.02 * DTMULT
                end
            end
            if (self.timer >= 120) then
                Game.battle:finishAction()
                self:remove()
            end
        else
            orig(self)
        end
    end)
    
    Utils.hook(Spell, "getHealMessage", function(orig, self, user, target, amount) 
        local maxed = false
        if self.target == "ally" then
            maxed = target.chara:getHealth() >= target.chara:getStat("health") or amount == math.huge
        elseif self.target == "enemy" then
            maxed = target.health >= target.max_health or amount == math.huge
        end
        local message = ""
        if self.target == "ally" then
            if select(2, target.chara:getNameOrYou()) and maxed then
                message = "* Your HP was maxed out."
            elseif maxed then
                message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
            else
                message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "party" then
            if #Game.battle.party > 1 then
                message = "* Everyone recovered " .. amount .. " HP."
            else
                message = "* You recovered " .. amount .. " HP."
            end
        elseif self.target == "enemy" then
            if maxed then
                message = "* " .. target.name .. "'s HP was maxed out."
            else
                message = "* " .. target.name .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "enemies" then
            message = "* The enemies recovered " .. amount .. " HP."
        end
        return message
    end)

    Utils.hook(SpeechBubble, "init", function(orig, self, text, x, y, options, speaker)
        orig(self, text, x, y, options, speaker)
        if Game.battle and Game.battle.light then
            self.text.no_sound_overlap = options["no_sound_overlap"] or true
        end
    end)

    Utils.hook(SpeechBubble, "draw", function(orig, self)
        if Game.battle and Game.battle.light and not self.auto then
            if self.right then
                local width = self:getSpriteSize()
                Draw.draw(self:getSprite(), width - 12, 0, 0, -1, 1)
            else
                Draw.draw(self:getSprite(), 0, 0)
            end
            Object.draw(self)
        else
            orig(self)
        end
    end)

    Utils.hook(Game, "gameOver", function(orig, self, x, y)
        orig(self, x, y)
        lib:setGameOvers((lib:getGameOvers() or 0) + 1)
    end)
    
    Utils.hook(GameOver, "init", function(orig, self, x, y)
        orig(self, x, y)
        if not Kristal.getLibConfig("magical-glass", "gameover_skipping")[1] and not Game:isLight() or not Kristal.getLibConfig("magical-glass", "gameover_skipping")[2] and Game:isLight() then
            self.skipping = -math.huge
        end
        if Game.battle then -- Battle type correction
            if Game.battle.light then
                self.screenshot = nil
                self.timer = 28
            else
                self.screenshot = love.graphics.newImage(SCREEN_CANVAS:newImageData())
                self.timer = 0
            end
        end
    end)
    
    Utils.hook(ActionBoxDisplay, "draw", function(orig, self) -- Fixes an issue with HP higher than normal
        if Game:isLight() and #Game.battle.party <= 3 then
            if Game.battle.current_selecting == self.actbox.index then
                Draw.setColor(self.actbox.battler.chara:getColor())
            else
                Draw.setColor(PALETTE["action_strip"], 1)
            end

            love.graphics.setLineWidth(2)
            love.graphics.line(0  , Game:getConfig("oldUIPositions") and 2 or 1, 213, Game:getConfig("oldUIPositions") and 2 or 1)

            love.graphics.setLineWidth(2)
            if Game.battle.current_selecting == self.actbox.index then
                love.graphics.line(1  , 2, 1,   36)
                love.graphics.line(212, 2, 212, 36)
            end

            Draw.setColor(PALETTE["action_fill"])
            love.graphics.rectangle("fill", 2, Game:getConfig("oldUIPositions") and 3 or 2, 209, Game:getConfig("oldUIPositions") and 34 or 35)

            Draw.setColor(Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and MG_PALETTE["player_health_bg"] or PALETTE["action_health_bg"])
            love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, 76, 9)

            local health = (self.actbox.battler.chara:getHealth() / self.actbox.battler.chara:getStat("health")) * 76

            if health > 0 then
                if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") then
                    Draw.setColor(MG_PALETTE["player_health"])
                else
                    Draw.setColor(self.actbox.battler.chara:getColor())
                end
                love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, math.min(math.ceil(health), 76), 9) -- here
            end


            local color = PALETTE["action_health_text"]
            if health <= 0 then
                color = PALETTE["action_health_text_down"]
            elseif (self.actbox.battler.chara:getHealth() <= (self.actbox.battler.chara:getStat("health") / 4)) then
                color = PALETTE["action_health_text_low"]
            else
                color = PALETTE["action_health_text"]
            end


            local health_offset = 0
            health_offset = (#tostring(self.actbox.battler.chara:getHealth()) - 1) * 8

            Draw.setColor(color)
            love.graphics.setFont(self.font)
            love.graphics.print(self.actbox.battler.chara:getHealth(), 152 - health_offset, 9 - self.actbox.data_offset)
            Draw.setColor(PALETTE["action_health_text"])
            love.graphics.print("/", 161, 9 - self.actbox.data_offset)
            local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
            Draw.setColor(color)
            love.graphics.print(self.actbox.battler.chara:getStat("health"), 205 - string_width, 9 - self.actbox.data_offset)

            Object.draw(self)
        else
            orig(self)
        end
    end)
end

function lib:registerRandomEncounter(id, class)
    self.random_encounters[id] = class
end

function lib:getRandomEncounter(id)
    return self.random_encounters[id]
end

function lib:createRandomEncounter(id, ...)
    if self.random_encounters[id] then
        return self.random_encounters[id](...)
    else
        error("Attempt to create non existent random encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightEncounter(id, class)
    self.light_encounters[id] = class
end

function lib:getLightEncounter(id)
    return self.light_encounters[id]
end

function lib:createLightEncounter(id, ...)
    if self.light_encounters[id] then
        return self.light_encounters[id](...)
    else
        error("Attempt to create non existent light encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightEnemy(id, class)
    self.light_enemies[id] = class
end

function lib:getLightEnemy(id)
    return self.light_enemies[id]
end

function lib:createLightEnemy(id, ...)
    if self.light_enemies[id] then
        return self.light_enemies[id](...)
    else
        error("Attempt to create non existent light enemy \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightWave(id, class)
    self.light_waves[id] = class
end

function lib:getLightWave(id)
    return self.light_waves[id]
end

function lib:createLightWave(id, ...)
    if self.light_waves[id] then
        return self.light_waves[id](...)
    else
        error("Attempt to create non existent light wave \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightShop(id, class)
    self.light_shops[id] = class
end

function lib:getLightShop(id)
    return self.light_shops[id]
end

function lib:createLightShop(id, ...)
    if self.light_shops[id] then
        return self.light_shops[id](...)
    else
        error("Attempt to create non existent light shop \"" .. tostring(id) .. "\"")
    end
end

function lib:registerDebugOptions(debug)
    debug.exclusive_battle_menus = {}
    debug.exclusive_battle_menus["LIGHTBATTLE"] = {"light_wave_select"}
    debug.exclusive_battle_menus["DARKBATTLE"] = {"wave_select"}
    debug.exclusive_world_menus = {}
    debug.exclusive_world_menus["LIGHTWORLD"] = {"light_select_shop"}
    debug.exclusive_world_menus["DARKWORLD"] = {"dark_select_shop"}

    debug:registerMenu("encounter_select", "Encounter Select")
    
    debug:registerOption("encounter_select", "Start Dark Encounter", "Start a dark encounter.", function()
        debug:enterMenu("dark_encounter_select", 0)
    end)
    debug:registerOption("encounter_select", "Start Light Encounter", "Start a light encounter.", function()
        debug:enterMenu("light_encounter_select", 0)
    end)

    debug:registerMenu("dark_encounter_select", "Select Dark Encounter", "search")
    for id,_ in pairs(Registry.encounters) do
        if id ~= "_nobody" or Kristal.getLibConfig("magical-glass", "debug") then
            debug:registerOption("dark_encounter_select", id, "Start this encounter.", function()
                Game:encounter(id, true, nil, nil, false)
                debug:closeMenu()
            end)
        end
    end

    debug:registerMenu("light_encounter_select", "Select Light Encounter", "search")
    for id,_ in pairs(self.light_encounters) do
        if id ~= "_nobody" or Kristal.getLibConfig("magical-glass", "debug") then
            debug:registerOption("light_encounter_select", id, "Start this encounter.", function()
                Game:encounter(id, true, nil, nil, true)
                debug:closeMenu()
            end)
        end
    end

    debug:registerMenu("light_wave_select", "Wave Select", "search")
    
    debug:registerOption("light_wave_select", "[Stop Current Wave]", "Stop the current playing wave.", function ()
        if Game.battle:getState() == "DEFENDING" then
            Game.battle.encounter:onWavesDone()
        end
        debug:closeMenu()
    end)

    local waves_list = {}
    for id,_ in pairs(self.light_waves) do
        if id ~= "_none" and id ~= "_story" or Kristal.getLibConfig("magical-glass", "debug") then
            table.insert(waves_list, id)
        end
    end

    table.sort(waves_list, function(a, b)
        return a < b
    end)

    for _,id in ipairs(waves_list) do
        debug:registerOption("light_wave_select", id, "Start this wave.", function ()
            if Game.battle:getState() == "ACTIONSELECT" then
                Game.battle.debug_wave = true
                Game.battle:setState("ENEMYDIALOGUE", {id})
            end
            debug:closeMenu()
        end)
    end

    debug:registerMenu("light_select_shop", "Enter Light Shop", "search")
    for id,_ in pairs(self.light_shops) do
        debug:registerOption("light_select_shop", id, "Enter this shop.", function()
            Game:enterShop(id, nil, true)
            debug:closeMenu()
        end)
    end

    debug:registerMenu("dark_select_shop", "Enter Dark Shop", "search")
    for id,_ in pairs(Registry.shops) do
        debug:registerOption("dark_select_shop", id, "Enter this shop.", function()
            Game:enterShop(id, nil, false)
            debug:closeMenu()
        end)
    end
    
    local in_game = function () return Kristal.getState() == Game end
    local in_overworld = function () return in_game() and Game.state == "OVERWORLD" end
    local in_dark_battle = function () return in_game() and Game.state == "BATTLE" and not Game.battle.light end
    local in_light_battle = function () return in_game() and Game.state == "BATTLE" and Game.battle.light end
    local in_dark_world = function () return in_game() and not Game:isLight() end
    local in_light_world = function () return in_game() and Game:isLight() end
    
    local index = 1
    for i = #debug.menus["main"].options, 1, -1 do
        local option = debug.menus["main"].options[i]
        if option.name == "Enter Shop" then -- Gets the index of the "Enter Shop" in the main debug menu
            index = i
        end
        if Utils.containsValue({"Start Wave", "End Battle", "Enter Shop"}, option.name) then
            table.remove(debug.menus["main"].options, i)
        end
    end
    
    debug:registerOption("main", "Enter Shop", "Enter a dark shop.", function()
        debug:enterMenu("dark_select_shop", 0)
    end, function() return in_overworld() and in_dark_world() end)
    
    debug:registerOption("main", "Enter Shop", "Enter a light shop.", function()
        debug:enterMenu("light_select_shop", 0)
    end, function() return in_overworld() and in_light_world() end)
    
    for i,option in ipairs(debug.menus["main"].options) do -- Positions the "Enter Shop" at the usual place (both of them)
        if option.name == "Enter Shop" then
            table.insert(debug.menus["main"].options, index, table.remove(debug.menus["main"].options, i))
        end
    end
    
    debug:registerOption("main", "Start Wave", "Start a wave.", function ()
        debug:enterMenu("wave_select", 0)
    end, in_dark_battle)

    debug:registerOption("main", "End Battle", "Instantly complete a battle.", function ()
        if Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN"}, Game.battle.state) and Game:isLight() then
            Game.battle:setState("DEFENDINGEND", "NONE")
        end
        Game.battle:setState("VICTORY")
        debug:closeMenu()
    end, in_dark_battle)
                        
    debug:registerOption("main", "Start Wave", "Start a wave.", function ()
        debug:enterMenu("light_wave_select", 0)
    end, in_light_battle)

    debug:registerOption("main", "End Battle", "Instantly complete a battle.", function ()
        Game.battle.forced_victory = true
        if Utils.containsValue({"DEFENDING", "DEFENDINGBEGIN", "ENEMYDIALOGUE"}, Game.battle.state) then
            Game.battle.encounter:onWavesDone()
        end
        Game.battle:setState("VICTORY")
        debug:closeMenu()
    end, in_light_battle)
    
    debug:addToExclusiveMenu("OVERWORLD", {"dark_encounter_select", "light_encounter_select", "dark_select_shop", "light_select_shop"})
    debug:addToExclusiveMenu("BATTLE", "light_wave_select")
end

function lib:setupLightShop(shop)
    if Game.shop then
        error("Attempt to enter shop while already in shop")
    end

    if type(shop) == "string" then
        shop = MagicalGlassLib:createLightShop(shop)
    end

    if shop == nil then
        error("Attempt to enter shop with nil shop")
    end

    Game.shop = shop
    Game.shop:postInit()
end

function lib:enterLightShop(shop, options)
    -- Add the shop to the stage and enter it.
    if Game.shop then
        Game.shop:leaveImmediate()
    end

    lib:setupLightShop(shop)

    if options then
        Game.shop.leave_options = options
    end

    if Game.world and Game.shop.shop_music then
        Game.world.music:stop()
    end

    Game.state = "SHOP"
    
    lib.in_light_shop = true

    Game.stage:addChild(Game.shop)
    Game.shop:onEnter()
end

function lib:setLightBattleShakingText(v)
    if v == true then
        lib.light_battle_shake_text = 0.501
    elseif v == false then
        lib.light_battle_shake_text = 0
    elseif type(v) == "number" then
        lib.light_battle_shake_text = v
    end
end

function lib:setLightBattleSpareColor(value, color_name)
    if value == "pink" then
        lib.spare_color, lib.spare_color_name = MG_PALETTE["pink_spare"], "PINK"
    elseif type(value) == "table" then
        lib.spare_color, lib.spare_color_name = value, "SPAREABLE"
    else
        for name,color in pairs(COLORS) do
            if value == name then
                lib.spare_color, lib.spare_color_name = color, name:upper()
                if value == "white" and color_name ~= true then
                    lib.spare_color_name = lib.spare_color_name .. "?"
                end
                break
            end
        end
    end
    if type(color_name) == "string" then
        lib.spare_color_name = color_name:upper()
    end
end

function lib:setCellCallsRearrangement(v)
    lib.rearrange_cell_calls = v
end

function lib:setSeriousMode(v)
    lib.serious_mode = v
end

function lib:onFootstep(char, num)
    if self.encounters_enabled and self.in_encounter_zone and Game.world.player and char:includes(Player) then
        local amount = 1
        if Mod.libs["multiplayer"] then
            amount = amount / (#Game.world.other_players + 1) / 0.75
        end
        self.steps_until_encounter = self.steps_until_encounter - amount
    end
end

function lib:setLightEXP(exp)
    for _,party in pairs(Game.party_data) do
        party:setLightEXP(exp)
    end
end

function lib:setLightLV(level)
    for _,party in pairs(Game.party_data) do
        party:setLightLV(level)
    end
end

function lib:gameNotOver(x, y)
    Kristal.hideBorder(0)
    
    local reload
    local encounter = Game.battle and Game.battle.encounter and Game.battle.encounter.id
    local shop = Game.shop and Game.shop.id
    if encounter then
        reload = {"BATTLE", encounter}
    elseif shop then
        reload = {"SHOP", shop}
    end

    Game.state = "GAMEOVER"
    if Game.battle   then Game.battle  :remove() end
    if Game.world    then Game.world   :remove() end
    if Game.shop     then Game.shop    :remove() end
    if Game.gameover then Game.gameover:remove() end
    if Game.legend   then Game.legend  :remove() end

    Game.gameover = GameNotOver(x or 0, y or 0, reload)
    Game.stage:addChild(Game.gameover)
end

function lib:colorShader(color)
    local targetColor = color or {1, 1, 1, 1}
    local nonBlackToColorShader = love.graphics.newShader([[
        extern vec4 targetColor;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 texcolor = Texel(texture, texture_coords);
            if (texcolor.r > 0.0 || texcolor.g > 0.0 || texcolor.b > 0.0) {
                return targetColor * color; // Non-black pixels to target color
            } else {
                return texcolor * color; // Keep black pixels unchanged
            }
        }
    ]])
    nonBlackToColorShader:send("targetColor", targetColor)
    return nonBlackToColorShader
end

function lib:postUpdate()
    Game.lw_xp = nil
    for _,party in pairs(Game.party_data) do -- Gets the party with the most Light EXP
        if not Game.lw_xp or party:getLightEXP() > Game.lw_xp then
            Game.lw_xp = party:getLightEXP()
        end
    end
    if Kristal.getLibConfig("magical-glass", "shared_light_exp") then
        for _,party in pairs(Game.party_data) do
            if party:getLightEXP() ~= Game.lw_xp then
                party:setLightEXP(Game.lw_xp)
            end
        end
    end
    if not Game.battle then
        if lib.random_encounter then
            lib:createRandomEncounter(lib.random_encounter):resetSteps(false)
            lib.random_encounter = nil
        end
    end
end

return lib