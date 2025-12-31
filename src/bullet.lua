local Class = require("src.class")
local utils = require("src.utils")

local Bullet = Class:extend("Bullet")

function Bullet:init(x, y, rotation_rad)
    self.x = x
    self.y = y
    self.rotation_rad = rotation_rad
    self.accel = 5.0
    self.vx = 0
    self.vy = 0
    self.bbox = hc.rectangle(0, 0, 8, 4)
    self.type = utils.object_types.BULLET
    self.anim_counter = 0
    self.animation_speed = 0.9
    self.animation_index = 1
    self.animation_frames = {}

    -- set animation frames
    self.animation_frames = bullet_sprites
    self.bbox.owner = self
    self.vx = math.cos(self.rotation_rad) * self.accel
    self.vy = math.sin(self.rotation_rad) * self.accel
end

function Bullet:update()
    self.x = self.x + self.vx
    self.y = self.y + self.vy

    self.anim_counter = self.anim_counter + self.animation_speed
    self.animation_index = math.floor(self.anim_counter) + 1

    -- Clamp to last frame (non-looping animation)
    if self.animation_index > #self.animation_frames then
        self.animation_index = #self.animation_frames
    end

    self.sprite_index = self.animation_frames[self.animation_index]

    if self.bbox ~= nil then
        self.bbox:moveTo(self.x, self.y)
        self.bbox:setRotation(self.rotation_rad, self.x, self.y)
    end
end

function Bullet:draw()
    utils.draw_sprite(self.sprite_index, self.x, self.y, self.rotation_rad, 1, 1, true)

    if self.bbox ~= nil then
        utils.draw_bboxes(self.bbox)
    end
end

function Bullet:is_offscreen()
    return (self.x < 0 or self.x > screen_width or self.y < 0 or self.y > screen_height)
end

return Bullet
