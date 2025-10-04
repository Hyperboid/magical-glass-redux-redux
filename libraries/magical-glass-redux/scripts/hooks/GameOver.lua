---@class GameOver : GameOver
local GameOver, super = Utils.hookScript(GameOver)

function GameOver:init(x, y)
    super.init(self, x, y)
    if not Kristal.getLibConfig("magical-glass", "gameover_skipping")[1] and not Game:isLight() or not Kristal.getLibConfig("magical-glass", "gameover_skipping")[2] and Game:isLight() then
        self.skipping = -math.huge
    end
    if Game.battle then -- Battle type correction
        if Game.battle.light then
            self.timer = 28
        else
            self.timer = 0
        end
    end
end

return GameOver
