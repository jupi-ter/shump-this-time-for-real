local Class = require("src.class")
local utils = require("src.utils")

local Player = Class:extend("Player")

-- Static states
Player.states = {
    ALIVE = "alive",
    DYING = "dying",
    DEAD = "dead"
}

function Player:init(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.spd = 2
    self.rotation_deg = 0
    self.upward_angle = 270
    self.shoot_cooldown = 7
    self.counter = 0
    self.bbox = hc.rectangle(0, 0, 6, 6)
    self.type = utils.object_types.PLAYER
    self.state = Player.states.ALIVE
    self.is_invulnerable = false
    self.invuln_duration = 120
    self.invuln_counter = 0
    self.part_counter = 0

    self.bbox.owner = self
    self.sprite = player_sprite
end

function Player:update()
    if self.state == Player.states.DEAD then
        return
    end

    if self.invuln_counter > 0 then
        self.invuln_counter = self.invuln_counter - 1
    elseif self.state ~= Player.states.ALIVE then
        self.invuln_counter = 0
        self.state = Player.states.ALIVE
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
        self.bbox:moveTo(self.x, self.y)
    end

    -- screen clamping
    local half_size = 4
    self.x = math.max(half_size, math.min(screen_width - half_size, self.x))
    self.y = math.max(half_size, math.min(screen_height - half_size, self.y))
end

function Player:draw()
    if self.state == Player.states.DEAD then
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

function Player:is_alive()
    return self.state == Player.states.ALIVE
end

function Player:die()
    if self.on_hit then
        self.on_hit(self.x, self.y)
    end

    if lives > 0 then
        self.invuln_counter = self.invuln_duration
        self.state = Player.states.DYING
        self.is_invulnerable = true
    else
        self.state = Player.states.DEAD
    end
end

return Player
