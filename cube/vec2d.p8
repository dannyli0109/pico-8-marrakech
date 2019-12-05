pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function new_vec2d(u, v)
    local vt = {}
    vt.u = u
    vt.v = v
    vt.w = 1
    return vt
end
