local utils = {}
hc = require("HC")

-- global enums
utils.object_types = {
    PLAYER = "player",
    BULLET = "bullet",
    ALIEN = "alien",
}

utils.alien_subtypes = {
    BASE = "alien_base",
    FIGURE_EIGHT = "alien_figure_eight",
}

utils.colors = {
    BLACK = {0.0, 0.0, 0.0},
    DARKBLUE = {0.114, 0.169, 0.325},
    DARKPURPLE = {0.494, 0.145, 0.325},
    DARKGREEN = {0.0, 0.529, 0.318},
    BROWN = {0.671, 0.322, 0.212},
    DARKGREY = {0.373, 0.341, 0.31},
    LIGHTGREY = {0.761, 0.765, 0.78},
    WHITE = {1.0, 0.945, 0.91},
    RED = {1.0, 0.0, 0.302},
    ORANGE = {1.0, 0.639, 0.0},
    YELLOW = {1.0, 0.925, 0.153},
    GREEN = {0.0, 0.894, 0.212},
    BLUE = {0.161, 0.678, 1.0},
    LAVENDER = {0.514, 0.463, 0.612},
    PINK = {1.0, 0.467, 0.659},
    LIGHTPEACH = {1.0, 0.8, 0.667}
}

-- Color modes
utils.MODE_FADE = "fade"      -- Cycle through color palette based on lifetime
utils.MODE_SINGLE = "single"  -- Single color throughout lifetime

-- Default color palettes
utils.PALETTE_DEFAULT = {
    utils.colors.DARKGREY,
    utils.colors.ORANGE,
    utils.colors.YELLOW,
    utils.colors.WHITE
}
--

function utils.draw_sprite(sprite, x, y, rotation, image_xscale, image_yscale, draw_from_origin)
    if sprite ~= nil then
        if draw_from_origin then
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, sprite.getWidth(sprite) / 2, sprite.getHeight(sprite) / 2)
        else
            love.graphics.draw(sprite, x, y, rotation, image_xscale, image_yscale, 0, 0)
        end
    end
end

local sprite_path = "assets/sprites/"

function utils.load_sprite(sprite_name)
    --concatenation is with ..
    return love.graphics.newImage(sprite_path .. sprite_name .. ".png")
end

function utils.load_multiple_sprites(names)
    local sprites = {}
    for i = 1, #names, 1 do
        local sprite = utils.load_sprite(names[i])
        table.insert(sprites, sprite)
    end

    return sprites
end

function utils.screen_wrap(object)
    if object.sprite_index and object.position then
        local half_sw = object.sprite_index.getWidth(object.sprite_index) / 2
        local half_sh = object.sprite_index.getHeight(object.sprite_index) / 2

        if object.position.x + half_sw < 0 then
            object.position.x = screen_width + half_sw
        elseif object.position.x - half_sw > screen_width then
            object.position.x = -half_sw
        end

        if object.position.y + half_sh < 0 then
            object.position.y = screen_height + half_sh
        elseif object.position.y - half_sh > screen_height then
            object.position.y = -half_sh
        end
    end
end

function utils.check_all_collisions()
    --check player vs aliens
    if Player:is_alive() and not Player.is_invulnerable then
        for shape, delta in pairs(hc.collisions(Player.bbox)) do
            if shape.owner and shape.owner.supertype == utils.object_types.ALIEN then
                Player:die()
                break
            end
        end
    end

    --check bullets vs aliens
    for i = #bullets, 1, -1 do
        if not bullets[i].flag_for_deletion then
            for shape, delta in pairs(hc.collisions(bullets[i].bbox)) do
                if shape.owner and shape.owner.supertype == utils.object_types.ALIEN then
                    -- destroy bullet
                    bullets[i].flag_for_deletion = true

                    --remove from collision system
                    if bullets[i].bbox then
                        hc.remove(bullets[i].bbox)
                        bullets[i].bbox = nil
                    end

                    -- damage alien
                    shape.owner:take_damage()
                    break
                end
            end
        end
    end
end

function utils.play_sound(sound)
    sound:stop()
    local pitchMod = love.math.random(0.8, 1.2)
    sound:setPitch(pitchMod)
    sound:play()
end

function utils.load_sound(soundfile_name, volume)
    local sound = love.audio.newSource("assets/audio/" .. soundfile_name .. ".wav", "static")
    sound:setVolume(volume)
    return sound
end

--pass in a color from our palette
function utils.set_draw_color(color)
    love.graphics.setColor(color[1], color[2], color[3], 1.0)
end

function utils.reset_draw_color()
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

function utils.draw_bboxes(bbox)
    if bbox ~= nil and debug_draw then
        utils.set_draw_color(utils.colors.PINK)
        bbox:draw('fill')
        utils.reset_draw_color()
    end
end

return utils