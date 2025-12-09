local shaders = {}

shaders.white_flash = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 pixel = Texel(tex, texture_coords);
        return vec4(1.0, 1.0, 1.0, pixel.a);
    }
]])

return shaders
