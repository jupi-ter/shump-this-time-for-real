player = require("src.player")
utils = require("src.utils")
bullet = require("src.bullet")
starfield = require("src.starfield")
particle = require("src.particle")
alien_base = require("src.alien_base")

-- globals
screen_width, screen_height = 128, 128
lives = 3
debug_draw = false

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- Fixed timestep variables
    local fps = 60
    local frame_time = 1 / fps
    local lag = 0
    local last_time = love.timer.getTime()

    -- We don't want the first frame's dt to include time taken by love.load
    if love.timer then love.timer.step() end

    -- Main loop - return a function that gets called each frame
    return function()
        -- Calculate delta time
        local now = love.timer.getTime()
        local dt = now - last_time
        last_time = now

        -- Cap dt to prevent "spiral of death"
        if dt > 0.25 then
            dt = 0.25
        end

        lag = lag + dt

        -- Process events
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Update at fixed timestep
        while lag >= frame_time do
            if love.update then
                love.update(frame_time)
            end
            lag = lag - frame_time
        end

        -- Draw
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw()
            end

            love.graphics.present()
        end

        -- Lock framerate
        local elapsed = love.timer.getTime() - now
        if elapsed < frame_time then
            love.timer.sleep(frame_time - elapsed)
        end
    end
end

function window_setup()
    --setup window
    love.window.setMode(screen_width, screen_height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        minwidth = 512,
        minheight = 512
    })

    --scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
end

function load_sprites()
    player_sprite = utils.load_sprite("ship")
    bullet_sprite = utils.load_sprite("bullet_2")

    green_guy_sprites = utils.load_multiple_sprites({"green_guy_1", "green_guy_2"})
end

function set_callbacks()
    Player.on_shoot = function(x, y, rot) 
        local new_bullet = bullet.new_bullet(x, y, rot)
        table.insert(bullets, new_bullet)
        new_bullet:init()
    end

    Player.on_move = function(x, y)
        create_particle(x, y)
    end
end

function love.load()
    window_setup()
    load_sprites()

    Player = player.new_player(screen_width/2, screen_height/2)
    Player:init()

    starfield.init()
    bullets = {}
    particles = {}
    boids = {}

    for i = 1, 16, 1 do
        local alien = new_alien_base(math.random(0, screen_width), math.random(0, screen_height))
        alien:init()
        table.insert(boids, alien)
    end

    set_callbacks()
end

function run_boids()
    for i, boid in ipairs(boids) do
        local force = {x = 0, y = 0}

        local vc = cohesion(boid, i)
        local vs = separation(boid, i)
        local va = alignment(boid, i)

        local rv = {x = 0, y = 0}
        if va and vs and vc then
            rv.x = va.x + vs.x + vc.x
            rv.y = va.y + vs.y + vc.y
        end

        boid.velocity.x = boid.velocity.x + rv.x
        boid.velocity.y = boid.velocity.y + rv.y

        --limit speed
        local speed_limit = 0.5
        local speed = math.sqrt(boid.velocity.x^2 + boid.velocity.y^2)
        if speed > speed_limit then
            boid.velocity.x = (boid.velocity.x / speed) * speed_limit
            boid.velocity.y = (boid.velocity.y / speed) * speed_limit
        end

        boid.position.x = boid.position.x + boid.velocity.x
        boid.position.y = boid.position.y + boid.velocity.y
    end
end

function cohesion(boid_i, i)
    local center = { x = 0, y = 0 }
    for j, boid_j in ipairs(boids) do
        if j ~= i then
            center.x = center.x + boid_j.position.x
            center.y = center.y + boid_j.position.y
        end
    end

    center.x = center.x / #boids
    center.y = center.y / #boids

    local factor = 200
    return {x = (center.x - boid_i.position.x) / factor, y = (center.y - boid_i.position.y) / factor}
end

function separation(boid_i, i)
    local c = { x = 0, y = 0} -- what the fuck is c
    local min_distance = 10

    for j, boid_j in ipairs(boids) do
        if  j ~= i then
            local diff = {x = boid_i.position.x - boid_j.position.x, y = boid_i.position.y - boid_j.position.y}
            local magnitude = math.sqrt((math.pow(diff.x, 2) + math.pow(diff.y, 2)))
            if magnitude < min_distance and magnitude > 0 then
                c.x = c.x + diff.x
                c.y = c.y + diff.y
            end
        end
    end

    return c
end

function alignment(boid_i, i)
    local pvi = {x = 0, y = 0} -- perceived velocity of boid i

    for j, boid_j in ipairs(boids) do
        if j ~= i then
            pvi.x = pvi.x + boid_j.velocity.x
            pvi.y = pvi.y + boid_j.velocity.y
        end
    end

    pvi.x = pvi.x / #boids
    pvi.y = pvi.y / #boids

    local factor = 8
    return {x = (pvi.x - boid_i.velocity.x) / factor, y = (pvi.y - boid_i.velocity.y) / factor} 
end

function love.update()
    starfield.update()

    for i = #particles, 1, -1 do
        particles[i]:update()
    end

    Player:update()

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        if (b:is_offscreen()) then
            table.remove(bullets, i)
        else
            b:update()
        end
    end

    run_boids()

    for i = #boids, 1, -1 do
        boids[i]:update()
    end
end

function draw_background()
    starfield.draw()
end

function draw_foreground()
    for i = #particles, 1, -1 do
        particles[i]:draw()
    end
    
    for i = #bullets, 1, -1 do
        bullets[i]:draw()
    end

    Player:draw()

    for i = #boids, 1, -1 do
        boids[i]:draw()
    end
end

function love.draw()
    local win_w, win_h = love.graphics.getDimensions()
    local scale_x = win_w / screen_width
    local scale_y = win_h / screen_height

    -- uniform scaling (preserves aspect ratio, no stretching)
    local scale = math.min(scale_x, scale_y)

    --start drawing
    love.graphics.push()
    love.graphics.scale(scale, scale)

    -- center the game world in the window
    local offset_x = (win_w/scale - screen_width) / 2
    local offset_y = (win_h/scale - screen_height) / 2

    love.graphics.translate(offset_x, offset_y)

    draw_background()
    draw_foreground()

    --stop drawing
    love.graphics.pop()
end

function create_particle(x, y)
    local new_part = particle.new_particle(x, y, false)
    new_part:init()
    table.insert(particles, new_part)
end