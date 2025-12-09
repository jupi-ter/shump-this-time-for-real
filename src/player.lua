utils = require("src.utils")
player = {}

player.states = {
    ALIVE = "alive",
    DYING = "dying",
    DEAD = "dead"
}

function player.new_player(x, y)
    local p = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        spd = 2,
        rotation_deg = 0,
        upward_angle = 270,
        shoot_cooldown = 7,
        counter = 0,
        bbox = hc.rectangle(0, 0, 6, 6),
        type = utils.object_types.PLAYER,
        state = player.states.ALIVE,
        is_invulnerable = false,
        invuln_duration = 120,
        invuln_counter = 0,
        part_counter = 0
    }

    function p:init()
        self.bbox.owner = self
        self.sprite = player_sprite
    end

    function p:update()
        if self.state == player.states.DEAD then
            return
        end

        if self.invuln_counter > 0 then
            self.invuln_counter = self.invuln_counter - 1
        elseif self.state ~= player.states.ALIVE then
            self.invuln_counter = 0
            self.state = player.states.ALIVE
            self.is_invulnerable = false
        end

        if self.counter > 0 then
            self.counter = self.counter - 1
        end

        local move_right = love.keyboard.isDown("right")
        local move_left = love.keyboard.isDown("left")
        local move_up = love.keyboard.isDown("up")
        local move_down = love.keyboard.isDown("down")
        local shoot_button = love.keyboard.isDown("space")

        if move_right then
            self.x = self.x + self.spd
            self.rotation_deg = self.upward_angle + 5
        end

        if move_left then
            self.x = self.x - self.spd
            self.rotation_deg = self.upward_angle - 5
        end

        if move_up then
            self.y = self.y - self.spd
        end

        if move_down then
            self.y = self.y + self.spd
        end

        if not move_left and not move_right then
            self.rotation_deg = self.upward_angle
        end

        self.part_counter = self.part_counter + 1

        if move_up or move_down or move_left or move_right then
            if self.on_move and (self.part_counter > 0 and self.part_counter % 2 == 0) then
                self.part_counter = 0
                self.on_move(self.x + math.random(-2, 2), self.y)
            end
        end

        if shoot_button and self.counter <= 0 then
            self.counter = self.shoot_cooldown

            if self.on_shoot then
                self.on_shoot(self.x, self.y, math.rad(self.upward_angle))
            end
        end

        if self.bbox ~= nil then
            self.bbox:moveTo(self.x,self.y)
        end

        -- screen clamping
        local half_size = 4
        self.x = math.max(half_size, math.min(screen_width - half_size, self.x))
        self.y = math.max(half_size, math.min(screen_height - half_size, self.y))
    end

    function p:draw()
        if self.state == player.states.DEAD then
            return
        end

        if self.invuln_counter % 4 == 0 and self.invuln_counter ~= 0 then
            return
        end

        utils.draw_sprite(self.sprite, self.x, self.y, math.rad(self.rotation_deg), 1, 1, true)

        if self.bbox ~= nil then
            utils.draw_bboxes(self.bbox)
        end
    end

    function p:is_alive()
        return self.state == player.states.ALIVE
    end

    function p:die()
        if self.on_hit then
            self.on_hit(self.x, self.y)
        end

        if lives > 0 then
            self.invuln_counter = self.invuln_duration
            self.state = player.states.DYING
            self.is_invulnerable = true
        else
            self.state = player.states.DEAD
        end
    end

    return p
end

return player