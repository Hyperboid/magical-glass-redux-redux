local spell, super = Class("snowgrave", true)

function spell:init()
    super.init(self)
    
    self.check = "Deals the fatal damage to all of the enemies."
end

return spell