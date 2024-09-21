local lib = {}

function lib:init()
    self.active_keys = {}
    self.flower_positions = {
        {34, 679},
        {94, 939},
        {269, 489},
        {0, 319},
        {209, 34},
        {1734, 0},
        {1829, 359},
        {1789, 709},
        {1584, 1049}
    }
    self.idle_time = RUNTIME * 1000
    self.idle = false
end

function lib:onKeyPressed(key, is_repeat)
    if not is_repeat then
        self.active_keys[key] = true
    end
end

function lib:onKeyReleased(key)
    self.active_keys[key] = nil
end

function lib:postUpdate(dt)
    if Utils.equal(self.active_keys, {}, false) then
        self.idle_time = 0
        self.idle = false
    else
        if not self.idle then
            self.idle_time = RUNTIME * 1000
        end
        self.idle = true
    end
end

function lib:onBorderDraw(border_sprite)
    if border_sprite == "undertale/sepia" then
        local idle_min = 300000
        local idle_time = 0
        local current_time = RUNTIME * 1000
        if (self.idle and current_time >= (self.idle_time + idle_min)) then
            idle_time = (current_time - (self.idle_time + idle_min))
        end

        local idle_frame = (math.floor((idle_time / 100)) % 3)

        if idle_frame > 0 then
            for index, pos in pairs(self.flower_positions) do
                local x, y = (pos[1] * BORDER_SCALE), (pos[2] * BORDER_SCALE) - 1
                local round = Utils.round
                love.graphics.setBlendMode("replace")
                local flower = Assets.getTexture("borders_addons/undertale/sepia/" .. tostring(index) .. ((idle_frame == 1) and "a" or "b"))
                love.graphics.setColor(1, 1, 1, BORDER_ALPHA)
                love.graphics.draw(flower, round(x), round(y), 0, BORDER_SCALE, BORDER_SCALE)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("alpha")
            end
        end
    end
    if border_sprite == "battle" then
        love.graphics.setColor(0, 0, 0, BORDER_ALPHA)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)

        love.graphics.setLineStyle("rough")
        love.graphics.setLineWidth(2)

        local offset = (Kristal.getTime() * 30) % 100

        for i = 2, 22 do
            if Game:isLight() then
                love.graphics.setColor(0, 61 / 255, 17 / 255, BORDER_ALPHA / 2)
            else
                love.graphics.setColor(66 / 255, 0, 66 / 255, BORDER_ALPHA / 2)
            end
            love.graphics.line(0, -210 + (i * 50) + math.floor(offset / 2), BORDER_WIDTH * BORDER_SCALE, -210 + (i * 50) + math.floor(offset / 2))
            love.graphics.line(-200 + (i * 50) + math.floor(offset / 2), 0, -200 + (i * 50) + math.floor(offset / 2), BORDER_HEIGHT * BORDER_SCALE)
        end

        for i = 3, 23 do
            if Game:isLight() then
                love.graphics.setColor(0, 61 / 255, 17 / 255, BORDER_ALPHA)
            else
                love.graphics.setColor(66 / 255, 0, 66 / 255, BORDER_ALPHA)
            end
            love.graphics.line(0, -100 + (i * 50) - math.floor(offset), BORDER_WIDTH * BORDER_SCALE, -100 + (i * 50) - math.floor(offset))
            love.graphics.line(-100 + (i * 50) - math.floor(offset), 0, -100 + (i * 50) - math.floor(offset), BORDER_HEIGHT * BORDER_SCALE)
        end

        love.graphics.setColor(0, 1, 0, BORDER_ALPHA)

        local width = 5

        love.graphics.setLineWidth(width)

        local left = 160 - width / 2
        local top = 30 - width / 2

        love.graphics.rectangle("line", left, top, 640 + width, 480 + width)
    end
    if border_sprite == "glow" then
        love.graphics.setColor(0, 0, 0, BORDER_ALPHA)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)

        local offset = (Kristal.getTime() * 30)
        for i = 1, 8 do
            local width = (1 + math.sin(offset / 30)) * i * 8

            love.graphics.setLineWidth(width)
            love.graphics.setColor(0.5, 0.5, 0.5, 0.1 * BORDER_ALPHA)

            local left = 160 - width / 2
            local top = 30 - width / 2

            love.graphics.rectangle("line", left, top, 640 + width, 480 + width)
        end
    end
end

function lib:registerDebugOptions(debug)
    local borders = {
        "battle",
        "glow",
    }
    
    -- for _,border in ipairs(borders) do
        -- debug:registerOption("border_menu", border, "Switch to the border \"" .. border .. "\".", function() Game:setBorder(border) end)
    -- end
end


return lib