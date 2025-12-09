utils = require("src.utils")
particle = {}

function particle.new_particle(x, y, options)
    options = options or {}

    local p = {
        x = x,
        y = y,
        lifetime = options.lifetime or 5,
        flag_for_deletion = false,
        radius = options.radius or 3,
        use_force = options.use_force or false,
        speed_x = options.speed_x or 0,
        speed_y = options.speed_y or 0,

        -- Color mode: "fade" or "single"
        color_mode = options.color_mode or utils.MODE_FADE,

        -- For fade mode: palette of colors to cycle through
        possible_colors = options.colors or utils.PALETTE_DEFAULT,

        -- For single mode: the color to use
        single_color = options.single_color or utils.colors.WHITE
    }

    function p:init()
        self.rotation_rad = math.rad(math.random(359))
        --[[if self.use_force then
            self.vx = math.cos(self.rotation_rad) * self.speed_x
            self.vy = math.sin(self.rotation_rad) * self.speed_y
        end]]--
    end

    function p:update()
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

    function p:draw()
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

    return p
end

return particle
