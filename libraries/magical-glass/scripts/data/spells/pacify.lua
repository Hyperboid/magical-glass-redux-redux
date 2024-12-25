local spell, super = Class("pacify", true)

function spell:getLightCastMessage(user, target)
    local message = super.getLightCastMessage(self, user, target)
    if target.tired then
        return message
    elseif target.mercy < 100 then
        return message.."\n[wait:0.25s]* But the enemy wasn't [color:blue]TIRED[color:reset]..."
    else
        return message.."\n[wait:0.25s]* But the foe wasn't [color:blue]TIRED[color:reset]... try\n[color:"..Utils.rgbToHex(MagicalGlassLib.spare_color).."]SPARING[color:reset]."
    end
end

return spell