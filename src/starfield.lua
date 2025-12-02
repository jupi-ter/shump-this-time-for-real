local starfield = {}
local utils = require("src.utils")

local star_colors = {
    utils.colors.DARKBLUE,
    utils.colors.DARKGREY,
    utils.colors.LIGHTGREY,
    utils.colors.WHITE
}

local warp_factor = 2
local stars = {}

function starfield.init()
    stars = {}

    -- create starfield with depth layers
    for i = 1, #star_colors do
        for j = 1, 10 do
            local star = {
                x = math.random() * screen_width,
                y = math.random() * screen_height,
                z = i,  -- depth layer (1-4, determines speed)
                c = star_colors[i],
                size = 1
            }
            table.insert(stars, star)
        end
    end
end

function starfield.update()
    -- move stars horizontally, speed based on depth
    for i = #stars, 1, -1 do
        local star = stars[i]
        star.y = star.y + (star.z * warp_factor) / 10

        -- wrap star around screen
        if star.y > screen_width then
            star.y = 0
            star.x = math.random() * screen_height
        end
    end
end

function starfield.draw()
    -- draw all stars as small rectangles
    for i = #stars, 1, -1 do
        local star = stars[i]
        utils.set_draw_color(star.c)
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end

    -- reset color
    utils.reset_draw_color()
end

return starfield