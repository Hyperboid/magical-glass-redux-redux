---@class Recruit : Recruit
local Recruit, super = Utils.hookScript(Recruit)

function Recruit:getHidden()
    if self.light ~= nil and not super.getHidden(self) then
        if self.light and Game:isLight() then
            return false
        elseif not self.light and not Game:isLight() then
            return false
        end
        return true
    end
    return super.getHidden(self)
end

function Recruit:init()
    super.init(self)
    
    self.light = nil
end

return Recruit
