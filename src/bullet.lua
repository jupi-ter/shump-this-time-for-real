utils = require("src.utils")
bullet = {}

function bullet.new_bullet(x, y, rotation_rad)
    local b = {
        x = x,
        y = y,
        rotation_rad = rotation_rad,
        accel = 5.0,
        vx = 0,
        vy = 0,
        bbox = hc.rectangle(0, 0, 8, 4),
        type = utils.object_types.BULLET,
        anim_counter = 0,
        animation_speed = 0.9,
        animation_index = 1,
        animation_frames = {},
    }

    function b:init()
        -- set animation frames
        self.animation_frames = bullet_sprites
        self.bbox.owner = self
        self.vx = math.cos(self.rotation_rad) * self.accel
        self.vy = math.sin(self.rotation_rad) * self.accel
    end

    function b:update()
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
            self.bbox:moveTo(self.x,self.y)
            self.bbox:setRotation(self.rotation_rad, self.x, self.y)
        end
    end

    function b:draw()
        utils.draw_sprite(self.sprite_index, self.x, self.y, self.rotation_rad, 1, 1, true)

        if self.bbox ~= nil then
            utils.draw_bboxes(self.bbox)
        end
    end

    function b:is_offscreen()
        return (self.x < 0 or self.x > screen_width or self.y < 0 or self.y > screen_height)
    end

    return b
end

return bullet