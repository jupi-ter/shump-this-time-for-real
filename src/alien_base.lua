local Class = require("src.class")
local utils = require("src.utils")
local shaders = require("src.shaders")

local AlienBase = Class:extend("AlienBase")

function AlienBase:init(x, y)
    self.position = {x = x, y = y}
    self.velocity = {x = 0, y = 0}
    self.xscale = 1
    self.yscale = 1
    self.rotation_deg = 0
    self.anim_counter = 0
    self.animation_speed = 0.05
    self.animation_index = 1
    self.animation_frames = {}
    self.xspd = 0
    self.yspd = 0.5
    self.bbox = hc.rectangle(0, 0, 8, 8)
    self.supertype = utils.object_types.ALIEN
    self.subtype = utils.alien_subtypes.BASE
    self.hp = 1
    self.flag_for_deletion = false
    self.flash_timer = 0
    self.score_yield = 10

    -- set animation frames
    self.animation_frames = green_guy_sprites
    self.bbox.owner = self
end

function AlienBase:update()
    self.anim_counter = self.anim_counter + self.animation_speed

    if (self.anim_counter > #self.animation_frames) then
        self.anim_counter = 0
    end

    self.animation_index = math.floor(self.anim_counter) + 1

    self.sprite_index = self.animation_frames[self.animation_index]

    if self.flash_timer > 0 then
        self.flash_timer = self.flash_timer - 1
    end

    if self.bbox ~= nil then
        self.bbox:moveTo(self.position.x, self.position.y)
    end

    utils.screen_wrap(self)
end

function AlienBase:draw()
    if self.sprite_index then
        if self.flash_timer > 0 then
            love.graphics.setShader(shaders.white_flash)
        else
            love.graphics.setShader()
        end
        utils.draw_sprite(self.sprite_index, self.position.x, self.position.y, math.rad(self.rotation_deg), self.xscale, self.yscale, true)
        love.graphics.setShader()
    end

    if self.bbox ~= nil then
        utils.draw_bboxes(self.bbox)
    end
end

function AlienBase:take_damage(amount)
    amount = amount or 1
    self.hp = self.hp - amount
    self.flash_timer = 5

    if self.hp <= 0 then
        self.flag_for_deletion = true
        self:destroy()
    end
end

function AlienBase:destroy()
    if self.bbox ~= nil then
        hc.remove(self.bbox)
        self.bbox = nil
    end
    if self.particle_on_death then
        self.particle_on_death(self.position.x, self.position.y)
    end
end

return AlienBase
