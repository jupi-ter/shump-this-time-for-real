utils = require("src.utils")
shaders = require("src.shaders")

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
        animation_speed = 0.05,
        animation_index = 1,
        animation_frames = {},
        xspd = 0,
        yspd = 0.5,
        bbox = hc.rectangle(0, 0, 8, 8),
        supertype = utils.object_types.ALIEN,
        subtype = utils.alien_subtypes.BASE,
        hp = 1,
        flag_for_deletion = false,
        flash_timer = 0,
        score_yield = 10
    }, alien_base)
    return ab
end

function alien_base:init()
    -- set animation frames
    self.animation_frames = green_guy_sprites
    self.bbox.owner = self
end

function alien_base:update()
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

function alien_base:draw()
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

function alien_base:take_damage(amount)
    amount = amount or 1
    self.hp = self.hp - amount
    self.flash_timer = 5

    if self.hp <= 0 then
        self.flag_for_deletion = true
        self:destroy()
    end
end

function alien_base:destroy()
    if self.bbox ~= nil then
        hc.remove(self.bbox)
        self.bbox = nil
    end
    if self.particle_on_death then
        self.particle_on_death(self.position.x, self.position.y)
    end
end

return alien_base