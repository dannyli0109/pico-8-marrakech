pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function new_triangle(options)
    local t = {}
    local p = options.p
    t.p = {p[1], p[2], p[3]}
    t.texture = {p[4], p[5], p[6]}
    t.sprite = options.sprite or nil
    t.lum = options.lum or 0

    t.rotate = function(angle_x, angle_y, angle_z, tx, ty, tz, mat_view) 

        local mat_rotate_xyz = new_matrix(4,4)
        mat_rotate_xyz.m[1] = {
            cos2(angle_z) * cos2(angle_y),          
            sin2(angle_z) * cos2(angle_y), 
            sin2(angle_y),
            0   
        }

        mat_rotate_xyz.m[2] = {
            -sin2(angle_y) * sin2(angle_x) * cos2(angle_z) - sin2(angle_z) * cos2(angle_x), 
            -sin2(angle_x) * sin2(angle_y) * sin2(angle_z) + cos2(angle_z) * cos2(angle_x),  
            sin2(angle_x) * cos2(angle_y), 
            0
        }

        mat_rotate_xyz.m[3] = {
            -sin2(angle_y) * cos2(angle_x) * cos2(angle_z) + sin2(angle_z) * sin2(angle_x), 
            -sin2(angle_y) * cos2(angle_x) * sin2(angle_z) - cos2(angle_z) * sin2(angle_x), 
            cos2(angle_x) * cos2(angle_y), 
            0
        }
        mat_rotate_xyz.m[4] = {0, 0, 0, 1}

        local rotated_vectors = {}
        for vec3d in all(t.p) do
            local new_vec3d = new_vec3d(vec3d.x, vec3d.y, vec3d.z, vec3d.w)
            local result = 
                    new_vec3d
                        .to_matrix()
                        .multiply(mat_rotate_xyz)
                        -- .multiply(mat_view)
                        .to_vec3d()
            result.x = result.x + tx
            result.y = result.y + ty
            result.z = result.z + tz

            result = result.to_matrix().multiply(mat_view).to_vec3d()

            add(rotated_vectors, result)
        end

        -- add texture to the triangles
        for vec2d in all(t.texture) do
            add(rotated_vectors, vec2d)
        end
        return new_triangle({
            p = rotated_vectors,
            lum = t.lum,
            sprite= t.sprite
        })
    end

    t.draw = function(c)

        local new_triangles = 1
        local list_triangle = List.new()
        List.pushright(list_triangle, t)

        for p=1,4 do
            -- local tris_to_add = 0
            local tris_to_add = {}
            while(new_triangles > 0) do
                local test = List.popleft(list_triangle)
                new_triangles-=1

                if p == 1 then
                    tris_to_add = triangle_clip_against_plane(new_vec3d(0,-10,0), new_vec3d(0,1,0), test)
                elseif p == 2 then
                    tris_to_add = triangle_clip_against_plane(new_vec3d(0,128 + 10,0), new_vec3d(0,-1,0), test)
                elseif p == 3 then
                    tris_to_add = triangle_clip_against_plane(new_vec3d(-10,0,0), new_vec3d(1,0,0), test)
                else
                    tris_to_add = triangle_clip_against_plane(new_vec3d(128 + 10,0,0), new_vec3d(-1,0,0), test)
                end

                for w=1,#tris_to_add do
                    List.pushright(list_triangle, tris_to_add[w])
                end

            end
            new_triangles = List.count(list_triangle)
        end

        for i=list_triangle.first,list_triangle.last do

            if list_triangle[i] then
            
                draw_textured_triangle(
                    list_triangle[i].p[1].x, 
                    list_triangle[i].p[1].y,
                    list_triangle[i].texture[1].u, 
                    list_triangle[i].texture[1].v,
                    list_triangle[i].texture[1].w,
                    list_triangle[i].p[2].x, 
                    list_triangle[i].p[2].y,
                    list_triangle[i].texture[2].u, 
                    list_triangle[i].texture[2].v,
                    list_triangle[i].texture[2].w,
                    list_triangle[i].p[3].x, 
                    list_triangle[i].p[3].y,
                    list_triangle[i].texture[3].u, 
                    list_triangle[i].texture[3].v,
                    list_triangle[i].texture[3].w,
                    t.lum,
                    t.sprite
                )
            end
        end
    end
    return t
end

