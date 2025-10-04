---@class ActionBox : ActionBox
local ActionBox, super = Utils.hookScript(ActionBox)

function ActionBox:init(x, y, index, battler)
    super.init(self, x, y, index, battler)
    if Kristal.getLibConfig("magical-glass", "light_world_dark_battle_color_override") and Game:isLight() then
        self.head_sprite:addFX(ShaderFX("color", {targetColor = MG_PALETTE["light_world_dark_battle_color"]}))
    end
    
    self.hp_sprite_karma = false
end

function ActionBox:update()
    super.update(self)
    
    if Game.battle.encounter.karma_mode then
        if not self.hp_sprite_karma then
            self.hp_sprite:setSprite("ui/hp_kr")
            self.hp_sprite_karma = true
        end
    else
        if self.hp_sprite_karma then
            self.hp_sprite:setSprite("ui/hp")
            self.hp_sprite_karma = false
        end
    end
end

function ActionBox:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end
    self.buttons = {}
    local btn_types = {"fight", "act", "magic", "item", "spare", "defend"}
    if Mod.libs["moreparty"] then
        if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
        if not self.battler.chara:hasSpells() or self.battler.chara:hasAct() and not Kristal.getLibConfig("moreparty", "classic_mode") and #Game.battle.party > 3 and self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "magic") end
    else
        if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
        if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "magic") end
    end
    for lib_id,_ in Kristal.iterLibraries() do
        btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types
    btn_types = MagicalGlassLib:modifyActionButtons(self.battler, btn_types) or btn_types
    local start_x = (213 / 2) - ((#btn_types-1) * 35 / 2) - 1
    if (#btn_types <= 5) and Game:getConfig("oldUIPositions") then
        start_x = start_x - 5.5
    end
    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            local button = ActionButton(btn, self.battler, math.floor(start_x + ((i - 1) * 35)) + 0.5, 21)
            button.actbox = self
            table.insert(self.buttons, button)
            self:addChild(button)
        elseif type(btn) ~= "boolean" then -- nothing if a boolean value, used to create an empty space
            btn:setPosition(math.floor(start_x + ((i - 1) * 35)) + 0.5, 21)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            self:addChild(btn)
        end
    end
    self.selected_button = Utils.clamp(self.selected_button, 1, #self:getSelectableButtons())
end

return ActionBox
