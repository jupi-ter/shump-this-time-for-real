local AlienBase = require("src.alien_base")
local utils = require("src.utils")

local AlienFigureEight = AlienBase:extend("AlienFigureEight")

function AlienFigureEight:init(center_x, center_y, amplitude_x, amplitude_y, speed)
    -- Default values
    center_x = center_x or screen_width / 2
    center_y = center_y or screen_height / 2
    amplitude_x = amplitude_x or 30
    amplitude_y = amplitude_y or 20
    speed = speed or 1

    -- Clamp center point to keep figure-8 within screen bounds
    local margin_x = amplitude_x + 5
    local margin_y = amplitude_y + 5
    center_x = math.max(margin_x, math.min(screen_width - margin_x, center_x))
    center_y = math.max(margin_y, math.min(screen_height - margin_y, center_y))

    -- Call parent constructor
    AlienFigureEight.super.init(self, center_x, center_y)

    -- Figure-8 parameters
    self.center_x = center_x
    self.center_y = center_y
    self.amplitude_x = amplitude_x
    self.amplitude_y = amplitude_y
    self.speed = speed

    -- Time parameter for parametric equations
    self.t = math.random() * math.pi * 2  -- Random starting phase

    -- Erratic movement parameters
    self.erratic_strength = 3  -- Max pixels of erratic offset
    self.erratic_speed = 5     -- How fast the erratic movement changes
    self.erratic_offset_x = 0
    self.erratic_offset_y = 0
    self.erratic_target_x = 0
    self.erratic_target_y = 0
    self.erratic_timer = 0

    -- Particle spawning
    self.part_counter = 0
    self.particle_options = {
        color_mode = utils.MODE_SINGLE,
        single_color = utils.colors.GREEN
    }

    -- Overrides
    self.subtype = utils.alien_subtypes.FIGURE_EIGHT
    self.hp = 3
    self.score_yield = 30
end

function AlienFigureEight:update()
    -- Update time parameter
    self.t = self.t + 0.02 * self.speed

    -- Calculate figure-8 position using parametric equations
    -- x = sin(t), y = sin(2t) creates a figure-8 (lemniscate-like curve)
    local base_x = self.center_x + self.amplitude_x * math.sin(self.t)
    local base_y = self.center_y + self.amplitude_y * math.sin(self.t * 2)

    -- Update erratic movement
    self:update_erratic()

    -- Apply erratic offset to position
    self.position.x = base_x + self.erratic_offset_x
    self.position.y = base_y + self.erratic_offset_y

    -- spawn particles
    self.part_counter = self.part_counter + 1
    if self.particle_on_move and (self.part_counter > 0 and self.part_counter % 2 == 0) then
        self.part_counter = 0
        self.particle_on_move(self.position.x + math.random(-2, 2), self.position.y, self.particle_options)
    end

    -- Call parent update
    AlienFigureEight.super.update(self)
end

function AlienFigureEight:update_erratic()
    -- Smoothly interpolate toward erratic target
    local lerp_speed = 0.1
    self.erratic_offset_x = self.erratic_offset_x + (self.erratic_target_x - self.erratic_offset_x) * lerp_speed
    self.erratic_offset_y = self.erratic_offset_y + (self.erratic_target_y - self.erratic_offset_y) * lerp_speed

    -- Periodically pick a new erratic target
    self.erratic_timer = self.erratic_timer + 1
    if self.erratic_timer >= self.erratic_speed then
        self.erratic_timer = 0
        self.erratic_target_x = (math.random() * 2 - 1) * self.erratic_strength
        self.erratic_target_y = (math.random() * 2 - 1) * self.erratic_strength
    end
end

function AlienFigureEight:set_center(x, y)
    -- Clamp center point to keep figure-8 within screen bounds
    local margin_x = self.amplitude_x + 5
    local margin_y = self.amplitude_y + 5
    self.center_x = math.max(margin_x, math.min(screen_width - margin_x, x))
    self.center_y = math.max(margin_y, math.min(screen_height - margin_y, y))
end

function AlienFigureEight:set_erratic(strength, speed)
    self.erratic_strength = strength or self.erratic_strength
    self.erratic_speed = speed or self.erratic_speed
end

return AlienFigureEight
