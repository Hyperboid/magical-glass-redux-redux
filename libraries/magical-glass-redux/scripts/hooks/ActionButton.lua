---@class ActionButton : ActionButton
local ActionButton, super = Utils.hookScript(ActionButton)

function ActionButton:update()
    local battle_leader
    for i,battler in ipairs(Game.battle.party) do
        if not battler.is_down and not battler.sleeping and not (Game.battle:getActionBy(battler) and Game.battle:getActionBy(battler).action == "AUTOATTACK")then
            battle_leader = battler.chara.id
            break
        end
    end
    
    local reload_buttons = 0
    if not self.battler.already_has_flee_button and Game.battle.encounter.can_flee then
        if Game.battle:getPartyIndex(battle_leader) == Game.battle.current_selecting and (Input.pressed("up") or Input.pressed("down")) then
            if self.hovered then
                local last_type = self.type
                if last_type == "spare" then
                    self.battler.flee_button = true
                    reload_buttons = 1
                    Game.battle.ui_move:stop()
                    Game.battle.ui_move:play()
                end
                if last_type == "flee" then
                    self.battler.flee_button = false
                    reload_buttons = 1
                    Game.battle.ui_move:stop()
                    Game.battle.ui_move:play()
                end
            end
        end
        if self.type == "flee" and Game.battle:getPartyIndex(self.battler.chara.id) ~= Game.battle.current_selecting then
            self.battler.flee_button = false
            reload_buttons = 2
        end
    end
    
    if not self.battler.already_has_save_button and Game.battle:getPartyIndex(self.battler.chara.id) == Game.battle.current_selecting then
        if self.battler.has_save then
            if self.type == "act" then
                self.battler.save_button = true
                reload_buttons = 1
            end
        else
            if self.type == savebutton().type then
                self.battler.save_button = false
                reload_buttons = 1
            end
        end
    end
    
    if reload_buttons == 1 then
        Game.battle.battle_ui.action_boxes[Game.battle.current_selecting]:createButtons()
    elseif reload_buttons == 2 then
        Game.battle.battle_ui.action_boxes[Game.battle:getPartyIndex(battle_leader)]:createButtons()
    end
    
    super.update(self)        
end

return ActionButton
