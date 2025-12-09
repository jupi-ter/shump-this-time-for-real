alien_base = require("src.alien_base")

alien_figure_eight = {}
alien_figure_eight.__index = alien_figure_eight
setmetatable(alien_figure_eight, {__index = alien_base})

function new_alien_figure_eight(center_x, center_y, amplitude_x, amplitude_y, speed)
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

    local alien = new_alien_base(center_x, center_y)
    setmetatable(alien, alien_figure_eight)

    -- Figure-8 parameters
    alien.center_x = center_x
    alien.center_y = center_y
    alien.amplitude_x = amplitude_x
    alien.amplitude_y = amplitude_y
    alien.speed = speed

    -- Time parameter for parametric equations
    alien.t = math.random() * math.pi * 2  -- Random starting phase

    -- Erratic movement parameters
    alien.erratic_strength = 3  -- Max pixels of erratic offset
    alien.erratic_speed = 5     -- How fast the erratic movement changes
    alien.erratic_offset_x = 0
    alien.erratic_offset_y = 0
    alien.erratic_target_x = 0
    alien.erratic_target_y = 0
    alien.erratic_timer = 0

    -- Particle spawning
    alien.part_counter = 0
    alien.particle_options = {
        color_mode = utils.MODE_SINGLE,
        single_color = utils.colors.GREEN
    }--options to pass to particle generation

    -- Overrides
    alien.subtype = utils.alien_subtypes.FIGURE_EIGHT
    alien.hp = 3
    alien.score_yield = 30

    return alien
end

function alien_figure_eight:init()
    alien_base.init(self)
end

function alien_figure_eight:update()
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

    --spawn particles
    self.part_counter = self.part_counter + 1
    if self.particle_on_move and (self.part_counter > 0 and self.part_counter % 2 == 0) then
        self.part_counter = 0
        self.particle_on_move(self.position.x + math.random(-2, 2), self.position.y, self.particle_options)
    end

    alien_base.update(self)
end

function alien_figure_eight:update_erratic()
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

function alien_figure_eight:set_center(x, y)
    -- Clamp center point to keep figure-8 within screen bounds
    local margin_x = self.amplitude_x + 5
    local margin_y = self.amplitude_y + 5
    self.center_x = math.max(margin_x, math.min(screen_width - margin_x, x))
    self.center_y = math.max(margin_y, math.min(screen_height - margin_y, y))
end

function alien_figure_eight:set_erratic(strength, speed)
    self.erratic_strength = strength or self.erratic_strength
    self.erratic_speed = speed or self.erratic_speed
end

return alien_figure_eight
