pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function new_mesh(v_camera,v_look_dir,yaw,tris)
    local m = {}
    m.tris = tris
    m.v_camera = v_camera
    m.v_look_dir = v_look_dir
    m.yaw = yaw

    m.rx = 0
    m.ry = 0
    m.rz = 0

    m.rx_last = 0
    m.ry_last = 0
    m.rz_last = 0

    m.get_projection = function()
        local near = 0.1
        local far = 100
        local fov = 90
        local aspect_ratio = 1
        local fov_rad = 1 / tan(fov / 2) 
        --assert(false, fov_rad)
        local mat_proj = new_matrix(4,4)
        mat_proj.m[1][1] = aspect_ratio * fov_rad
        mat_proj.m[2][2] = fov_rad
        mat_proj.m[3][3] = far / (far - near)
        mat_proj.m[4][3] = (-far * near) / (far - near)
        mat_proj.m[3][4] = 1


        local mat_rotate_xyz = new_matrix(4,4)
        mat_rotate_xyz.m[1] = {
            cos2(0) * cos2(m.yaw),          
            sin2(0) * cos2(m.yaw), 
            sin2(m.yaw),
            0   
        }

        mat_rotate_xyz.m[2] = {
            -sin2(m.yaw) * sin2(0) * cos2(0) - sin2(0) * cos2(0), 
            -sin2(0) * sin2(m.yaw) * sin2(0) + cos2(0) * cos2(0),  
            sin2(0) * cos2(m.yaw), 
            0
        }

        mat_rotate_xyz.m[3] = {
            -sin2(m.yaw) * cos2(0) * cos2(0) + sin2(0) * sin2(0), 
            -sin2(m.yaw) * cos2(0) * sin2(0) - cos2(0) * sin2(0), 
            cos2(0) * cos2(m.yaw), 
            0
        }
        mat_rotate_xyz.m[4] = {0, 0, 0, 1}

        local projected_tris = {}

        for triangle in all(m.tris) do
            local projected_triangle_vec3d = {}

            local v_up = new_vec3d(0,1,0)
            local v_target = new_vec3d(0,0,1)
            m.v_look_dir = v_target.to_matrix().multiply(mat_rotate_xyz).to_vec3d()

            v_target = v_add(m.v_camera, m.v_look_dir)


            local mat_camera = matrix_point_at(m.v_camera, v_target, v_up)
            -- mat_camera.print()
            local mat_view = mat_camera.quick_inverse()
            -- mat_view.print()

            local triangle_translated = triangle
                .rotate(
                    m.rx, m.ry, m.rz, 
                    0, 0, 5,
                    mat_view
                )
                -- .rotate()

            local clipped_triangles = triangle_clip_against_plane(new_vec3d(0,0,0.1), new_vec3d(0,0,1), triangle_translated)

            for clipped_triangle in all(clipped_triangles) do

                local line1 = new_vec3d(
                    clipped_triangle.p[2].x - clipped_triangle.p[1].x,
                    clipped_triangle.p[2].y - clipped_triangle.p[1].y,
                    clipped_triangle.p[2].z - clipped_triangle.p[1].z
                )
                local line2 = new_vec3d(
                    clipped_triangle.p[3].x - clipped_triangle.p[1].x,
                    clipped_triangle.p[3].y - clipped_triangle.p[1].y,
                    clipped_triangle.p[3].z - clipped_triangle.p[1].z
                )

                local normal = get_cross_product(line1, line2).normalize()

                local p = new_vec3d(
                    clipped_triangle.p[1].x,
                    clipped_triangle.p[1].y,
                    clipped_triangle.p[1].z
                )

                if (get_dot_product(normal, p) < 0) then    
                    local light_dir = new_vec3d(
                        -0.3,-0.5,-1
                    ).normalize()
                    local dp = get_dot_product(normal, light_dir)
                    
                    local ws = {}
                    for vec3d in all(clipped_triangle.p) do
                        local new_vec3d = new_vec3d(vec3d.x, vec3d.y, vec3d.z, vec3d.w)   
                        local result = 
                            new_vec3d
                                .to_matrix()
                                -- .multiply(mat_view)
                                .multiply(mat_proj)
                        local w = result.m[1][4]

                        add(ws, w)

                        local projected_vec3d = 
                            result
                                .scaler(1/w)
                                .scaler(100)
                                .to_vec3d()
                            
                        --projected_vec3d.print()
                        add(projected_triangle_vec3d, projected_vec3d)
                    end 

                    for i = 1,#clipped_triangle.texture do
                        local vec2d = clipped_triangle.texture[i]
                        local vec3d = clipped_triangle.p[i]

                        add(projected_triangle_vec3d, vec2d)
                    end
                    
                    add(projected_tris, new_triangle(
                        {
                            p = {
                                projected_triangle_vec3d[1],
                                projected_triangle_vec3d[2],
                                projected_triangle_vec3d[3],
                                projected_triangle_vec3d[4],
                                projected_triangle_vec3d[5],
                                projected_triangle_vec3d[6]
                            },
                            lum = dp,
                            sprite = clipped_triangle.sprite
                        }
                    ))
                end
            end
        
        end
        return new_mesh(m.v_camera, m.v_look_dir, m.yaw, projected_tris)
    end


 

    m.draw = function(color)
        local projected = m.get_projection()
        

        projected.tris = sort(projected.tris, function(t1, t2)
            local z1  = (t1.p[1].z + t1.p[2].z + t1.p[3].z) / 3
            local z2  = (t2.p[1].z + t2.p[2].z + t2.p[3].z) / 3
            return z1 > z2
        end)

        for i=1,#projected.tris do
            projected.tris[i].draw(color)
        end
    end
    return m
end
