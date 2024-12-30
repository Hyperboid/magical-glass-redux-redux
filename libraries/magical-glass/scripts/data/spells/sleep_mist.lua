local spell, super = Class("sleep_mist", true)

function spell:init()
    super.init(self)
    
    self.check = "A cold mist sweeps through, sparing all TIRED enemies."
end

return spell