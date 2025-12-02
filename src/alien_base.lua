utils = require("src.utils")

alien_base = {}
alien_base.__index = alien_base

function new_alien_base(x, y)
    local ab = setmetatable(
    {
        position = {x = x, y = y},
        velocity = {x = 0, y = 0},
        xscale = 1,
        yscale = 1,
        rotation_deg = 0,
        anim_counter = 0,
        animation_speed = 0.1,
        animation_index = 1,
        animation_frames = {},
        xspd = 0,
        yspd = 0.5
    }, alien_base)
    return ab
end

function alien_base:init()
    -- set animation frames
    self.animation_frames = green_guy_sprites
end

function alien_base:update()
    self.anim_counter = self.anim_counter + self.animation_speed

    if (self.anim_counter > #self.animation_frames) then
        self.anim_counter = 0
    end

    self.animation_index = math.floor(self.anim_counter) + 1

    self.sprite_index = self.animation_frames[self.animation_index]

    utils.screen_wrap(self)
end

function alien_base:draw()
    if self.sprite_index then
        utils.draw_sprite(self.sprite_index, self.position.x, self.position.y, math.rad(self.rotation_deg), self.xscale, self.yscale, true)
    end
end

return alien_base