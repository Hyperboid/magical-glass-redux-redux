---@class Savepoint : Savepoint
local Savepoint, super = Utils.hookScript(Savepoint)

function Savepoint:onTextEnd()
    if not Game:isLight() then
        super.onTextEnd(self)
    else
        if not self.world then return end
        if self.heals then
            for _,party in pairs(Game.party_data) do
                party:heal(math.huge, false)
            end
        end
        
        if Kristal.getLibConfig("magical-glass", "savepoint_style") ~= "undertale" then
            self.world:openMenu(LightSaveMenu(Game.save_id, self.marker))
        elseif self.simple_menu or (self.simple_menu == nil and not Kristal.getLibConfig("magical-glass", "expanded_light_save_menu")) then
            self.world:openMenu(LightSaveMenuNormal(Game.save_id, self.marker))
        else
            self.world:openMenu(LightSaveMenuExpanded(self.marker))
        end
    end
end

function Savepoint:update()
    if Kristal.getLibConfig("magical-glass", "savepoint_style") == "undertale" then
        return Interactable.update(self)
    end
    return super.update(self)
end

function Savepoint:init(x, y, properties)
    super.init(self, x, y, properties)
    Game.world.timer:after(1/30, function()
        if Game:isLight() and Kristal.getLibConfig("magical-glass", "savepoint_style") == "undertale" then
            self:setSprite("world/events/lightsavepoint", 1/6)
        end
    end)
end

return Savepoint
