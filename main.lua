player = require("src.player")
utils = require("src.utils")
bullet = require("src.bullet")
starfield = require("src.starfield")
particle = require("src.particle")
alien_base = require("src.alien_base")
alien_figure_eight = require("src.alien_figure_eight")

-- globals
screen_width, screen_height = 128, 128 
lives = 3
debug_draw = false
screenshake = 0

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
    bullet_sprites = utils.load_multiple_sprites({"bullet_1", "bullet_2"})
    green_guy_sprites = utils.load_multiple_sprites({"green_guy_1", "green_guy_2"})
end

function set_callbacks()
    Player.on_shoot = function(x, y, rot)
        --screenshake = screenshake + 2
        create_explosion(x, y-8, {
            color_mode = utils.MODE_SINGLE,
            single_color = utils.colors.LIGHTGREY,
            amount = 3,
            shake = 2,
            lifetime = 1,
            radius = 2
        })
        local new_bullet = bullet(x, y, rot)
        table.insert(bullets, new_bullet)
    end

    Player.on_move = function(x, y)
        create_particle(x, y, {})
    end
end

function love.load()
    window_setup()
    load_sprites()

    Player = player(screen_width/2, screen_height/2)

    starfield.init()
    bullets = {}
    particles = {}
    aliens = {}

    -- Spawn figure-8 aliens at different positions
    for i = 1, 4, 1 do
        local center_x = 32 + (i - 1) * 24
        local center_y = 40 + math.random(-10, 10)
        local alien = alien_figure_eight(center_x, center_y, 20, 15, 0.8 + math.random() * 0.8)
        alien:set_erratic(2 + math.random() * 3, 3 + math.random(0, 5))
        alien.particle_on_move = function(x, y, options)
            create_particle(x, y, options)
        end
        alien.particle_on_death = function(x,y)
            create_explosion(x,y)
        end
        table.insert(aliens, alien)
    end

    set_callbacks()
end

function love.update()
    starfield.update()

    if screenshake > 10 then
        screenshake = screenshake * 0.8 
    end

    if screenshake > 0 then
        screenshake = screenshake - 1
    else
        screenshake = 0
    end

    for i = #particles, 1, -1 do
        local p = particles[i]
        if (p.flag_for_deletion) then
            table.remove(particles, i)
        else
            p:update()
        end
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

    for i = #aliens, 1, -1 do
        local a = aliens[i]

        if (a.flag_for_deletion) then
            table.remove(aliens, i)
        else
            a:update()
        end
    end

    utils.check_all_collisions()
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

    for i = #aliens, 1, -1 do
        aliens[i]:draw()
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

    local shakeX = (love.math.random() * screenshake) - screenshake / 2
    local shakeY = (love.math.random() * screenshake) - screenshake / 2
    
    love.graphics.translate(offset_x + shakeX, offset_y + shakeY)

    draw_background()
    draw_foreground()

    --stop drawing
    love.graphics.pop()
end

function create_particle(x, y, options)
    local new_part = particle(x, y, options)
    table.insert(particles, new_part)
end

function create_explosion(x, y, explosion_options)
    explosion_options = explosion_options or {}

    local amount = explosion_options.amount or 20
    local shake = explosion_options.shake or 4

    screenshake = screenshake + shake
    --utils.play_sound(boom_sfx)
    
    for i = 1, amount, 1 do
        create_particle(x, y, {
            use_force = true,
            speed_x = love.math.random() * 2 - 1,
            speed_y = love.math.random() * 2 - 1,
            radius = explosion_options.radius or love.math.random(1, 4),
            lifetime = explosion_options.lifetime or 5,
            color_mode = explosion_options.color_mode or utils.MODE_FADE,
            possible_colors = explosion_options.colors or utils.PALETTE_DEFAULT,
            single_color = explosion_options.single_color or utils.colors.WHITE
        })
    end
end