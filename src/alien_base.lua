utils = require("src.utils")

alien_base = {}
alien_base.__index = alien_base

function new_alien_base(x, y)
    local ab = setmetatable(
    {
        x = x,
        y = y,
        xscale = 1,
        yscale = 1,
        rotation_deg = 0,
        anim_counter = 0,
        animation_speed = 0.1,
        animation_index = 1,
        animation_frames = {}
    }, alien_base)
    return ab
end

function alien_base:init()
    -- set animation frames
    self.animation_frames = green_guy_sprites
end

function alien_base:update()
    self.anim_counter = self.anim_counter + self.animation_speed

    if (self.anim_counter > 0) then
        self.anim_counter = 0
    end
end

function alien_base:draw()
    utils.draw_sprite(self.animation_frames[math.floor(self.anim_counter)], self.x, self.y, math.rad(self.rotation_deg), self.xscale, self.yscale, true)
end

return alien_base