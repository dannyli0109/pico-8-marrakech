pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function new_vec3d(x,y,z,w)
    v = {}
    v.x = x
    v.y = y
    v.z = z
    v.w = w or 1
    v.to_matrix = function()
        local m = new_matrix(1,4)
        m.m[1][1] = v.x
        m.m[1][2] = v.y
        m.m[1][3] = v.z
        m.m[1][4] = v.w
        return m
    end

    v.normalize = function()
        local l = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        local x = l == 0 and 0 or x / l
        local y = l == 0 and 0 or y / l
        local z = l == 0 and 0 or z / l
        return new_vec3d(
            x,y,z,v.w
        )
    end

    v.add = function(other)
        return new_vec3d(
            v.x + other.x,
            v.y + other.y,
            v.z + other.z,
            v.w
        )
    end

    v.subtract = function(other)
        return new_vec3d(
            v.x - other.x,
            v.y - other.y,
            v.z - other.z,
            v.w
        )
    end

    v.multiply = function(factor)
        return new_vec3d(
            v.x * factor,
            v.y * factor,
            v.z * factor,
            v.w
        )
    end

    v.print = function()
        print(v.x.." "..v.y.." "..v.z)
    end
    return v
end

