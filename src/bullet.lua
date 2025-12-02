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
        type = utils.object_types.BULLET
    }

    function b:init()
        self.bbox.owner = self
        self.vx = math.cos(self.rotation_rad) * self.accel
        self.vy = math.sin(self.rotation_rad) * self.accel
    end

    function b:update()
        self.x = self.x + self.vx
        self.y = self.y + self.vy

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x,self.y)
            self.bbox:setRotation(self.rotation_rad, self.x, self.y)
        end
    end

    function b:draw()
        utils.draw_sprite(bullet_sprite, self.x, self.y, self.rotation_rad, 1, 1, true)

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