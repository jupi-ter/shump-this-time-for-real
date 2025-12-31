local Class = require("src.class")
local utils = require("src.utils")

local Particle = Class:extend("Particle")

function Particle:init(x, y, options)
    options = options or {}

    self.x = x
    self.y = y
    self.lifetime = options.lifetime or 5
    self.flag_for_deletion = false
    self.radius = options.radius or 3
    self.use_force = options.use_force or false
    self.speed_x = options.speed_x or 0
    self.speed_y = options.speed_y or 0

    -- Color mode: "fade" or "single"
    self.color_mode = options.color_mode or utils.MODE_FADE

    -- For fade mode: palette of colors to cycle through
    self.possible_colors = options.colors or utils.PALETTE_DEFAULT

    -- For single mode: the color to use
    self.single_color = options.single_color or utils.colors.WHITE

    self.rotation_rad = math.rad(math.random(359))
end

function Particle:update()
    if self.lifetime > 0 then
        self.lifetime = self.lifetime - 0.1
    else
        self.flag_for_deletion = true
    end

    self.color_index = math.max(1, math.floor(self.lifetime))

    if self.radius > 0 then
        self.radius = self.radius - 0.1

        if self.use_force then
            self.x = self.x + self.speed_x
            self.y = self.y + self.speed_y
        end
    end
end

function Particle:draw()
    if self.radius > 0 then
        if self.color_mode == utils.MODE_SINGLE then
            utils.set_draw_color(self.single_color)
        elseif self.color_index then
            utils.set_draw_color(self.possible_colors[self.color_index])
        end
        love.graphics.circle("fill", self.x, self.y, self.radius)
        utils.reset_draw_color()
    end
end

return Particle
