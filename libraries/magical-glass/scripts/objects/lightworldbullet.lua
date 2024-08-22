local LightWorldBullet, super = Class(WorldBullet, "LightWorldBullet")

function LightWorldBullet:getDebugInfo()
    local info = Object.getDebugInfo(self)
    table.insert(info, "Light Encounter: " .. self.light_hazard_encounter)
    table.insert(info, "Destroy on hit: " .. (self.destroy_on_hit and "True" or "False"))
    table.insert(info, "Remove when offscreen: " .. (self.remove_offscreen and "True" or "False"))
    return info
end

function LightWorldBullet:onCollide(soul)
    if self.light_hazard_encounter then
        if soul.inv_timer == 0 then
            soul.inv_timer = self.inv_timer
            if self.destroy_on_hit then
                self:remove()
            end
            Game:encounter(self.light_hazard_encounter, true, nil, nil, true)
        end
    elseif self.destroy_on_hit then
        self:remove()
    end
end

function LightWorldBullet:getDrawColor()
    return Object.getDrawColor(self)
end

return LightWorldBullet