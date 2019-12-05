pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

color_shades = {
    {0},
    {1,1,1,0},
    {2,2,1,1,0},
    {3,3,3,1,1,0},
    {4,2,2,1,1,0},
    {5,5,1,1,1,0},
    {6,6,13,5,1,0},
    {7,7,6,13,1,0},
    {8,8,2,2,1,0},
    {9,4,2,2,1,0},
    {10,9,4,2,1,0},
    {11,11,3,3,1,0},
    {12,12,13,5,1,0},
    {13,13,5,1,1,0},
    {14,14,4,2,1,0},
    {15,9,4,2,1,0}
}

dest_angle = {
    {360,360},
    {360,450},
    {360,540},
    {360,630},
    {450,360},
    {630,360}
}

rand_z = {
    360, 450, 540, 630
}

function make_tri(p1,p2,p3,p4,p5,p6,p7,p8,p9,v1,v2,v3,v4,v5,v6,s1,s2)
    return {
                p = {
                    new_vec3d(p1,p2,p3),
                    new_vec3d(p4,p5,p6),
                    new_vec3d(p7,p8,p9),
                    new_vec2d(v1,v2),
                    new_vec2d(v3,v4),
                    new_vec2d(v5,v6)
                },
                sprite = {
                    s1,s2,16,16
                }
            }
end

function new_cube()
    local v_camera = new_vec3d(0,0,0)
    local v_look_dir = new_vec3d(0,0,1)
    local yaw = 0
    return new_mesh(v_camera,v_look_dir,yaw,{
        --south
        new_triangle(
            make_tri(-0.5,-0.5,-0.5,-0.5,0.5,-0.5,0.5,0.5,-0.5,0,1,0,0,1,0,8,32)
        ),
        new_triangle(
            make_tri(-0.5,-0.5,-0.5,0.5,0.5,-0.5,0.5,-0.5,-0.5,0,1,1,0,1,1,8,32)
        ),
        new_triangle(
            make_tri(0.5,-0.5,-0.5,0.5,0.5,-0.5,0.5,0.5,0.5,0,1,0,0,1,0,24,32)
        ),
        new_triangle(
            make_tri(0.5,-0.5,-0.5,0.5,0.5,0.5,0.5,-0.5,0.5,0,1,1,0,1,1,24,32)
        ),
        new_triangle(
            make_tri(0.5,-0.5,0.5,0.5,0.5,0.5,-0.5,0.5,0.5,0,1,0,0,1,0,24,32)
        ),
        new_triangle(
            make_tri(0.5,-0.5,0.5,-0.5,0.5,0.5,-0.5,-0.5,0.5,0,1,1,0,1,1,24,32)
        ),
        new_triangle(
            make_tri(-0.5,-0.5,0.5,-0.5,0.5,0.5,-0.5,0.5,-0.5,0,1,0,0,1,0,8,48)
        ),
        new_triangle(
            make_tri(-0.5,-0.5,0.5,-0.5,0.5,-0.5,-0.5,-0.5,-0.5,0,1,1,0,1,1,8,48)
        ),
        new_triangle(
            make_tri(-0.5,0.5,-0.5,-0.5,0.5,0.5,0.5,0.5,0.5,0,1,0,0,1,0,8,48)
        ),
        new_triangle(
            make_tri(-0.5,0.5,-0.5,0.5,0.5,0.5,0.5,0.5,-0.5,0,1,1,0,1,1,8,48)
        ),
        new_triangle(
            make_tri(0.5,-0.5,0.5,-0.5,-0.5,0.5,-0.5,-0.5,-0.5,0,1,0,0,1,0,24,48)
        ),
        new_triangle(
            make_tri(0.5,-0.5,0.5,-0.5,-0.5,-0.5,0.5,-0.5,-0.5,0,1,1,0,1,1,24,48)
        )
    },
    3)
end

function new_matrix(row, col)
    local m = {}
    m.m = {}
    m.row = row
    m.col = col
    for i=1,row do
        m.m[i] = {}
        for j = 1,col do
            m.m[i][j] = 0
        end
    end 
    
    m.multiply = function(other)
        local result = new_matrix(m.row, other.col)

        for i=1,result.row do
            for j=1,result.col do
                for k = 1,m.col do
                    result.m[i][j] += m.m[i][k] * other.m[k][j]
                end
            end
        end
        return result
    end

    m.scaler = function(factor)
        local result = new_matrix(m.row, m.col)
    
        for i=1,m.row do
            for j=1,m.col do
                result.m[i][j] = m.m[i][j] * factor
            end
        end 
        
        return result
    end

    m.to_vec3d = function()
        local x = m.m[1][1]
        local y = m.m[1][2]
        local z = m.m[1][3]
        local w = m.m[1][4]
 
        return new_vec3d(x,y,z,w)
    end


    m.quick_inverse = function()
        local matrix = new_matrix(4,4)
        matrix.m[1] = {m.m[1][1], m.m[2][1], m.m[3][1], 0}
        matrix.m[2] = {m.m[1][2], m.m[2][2], m.m[3][2], 0}
        matrix.m[3] = {m.m[1][3], m.m[2][3], m.m[3][3], 0}
        matrix.m[4][1] = -(m.m[4][1] * matrix.m[1][1] + m.m[4][2] * matrix.m[2][1] + m.m[4][3]* matrix.m[3][1])
        matrix.m[4][2] = -(m.m[4][1] * matrix.m[1][2] + m.m[4][2] * matrix.m[2][2] + m.m[4][3]* matrix.m[3][2])
        matrix.m[4][3] = -(m.m[4][1] * matrix.m[1][3] + m.m[4][2] * matrix.m[2][3] + m.m[4][3]* matrix.m[3][3])
        matrix.m[4][4] = 1
        return matrix
    end
    return m
end

function new_mesh(v_camera,v_look_dir,yaw,tris)
    local m = {}
    m.tris = tris
    m.v_camera = v_camera
    m.v_look_dir = v_look_dir
    m.yaw = yaw

    m.rx = 0
    m.ry = 0
    m.rz = 0

    m.get_projection = function()
        local near = 0.1
        local far = 10
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

            local triangle_translated = triangle
                .rotate(
                    m.rx, m.ry, m.rz, 
                    0, 0, 5,
                    mat_view
                )

                local line1 = new_vec3d(
                    triangle_translated.p[2].x - triangle_translated.p[1].x,
                    triangle_translated.p[2].y - triangle_translated.p[1].y,
                    triangle_translated.p[2].z - triangle_translated.p[1].z
                )
                local line2 = new_vec3d(
                    triangle_translated.p[3].x - triangle_translated.p[1].x,
                    triangle_translated.p[3].y - triangle_translated.p[1].y,
                    triangle_translated.p[3].z - triangle_translated.p[1].z
                )

                local normal = get_cross_product(line1, line2).normalize()

                local p = new_vec3d(
                    triangle_translated.p[1].x,
                    triangle_translated.p[1].y,
                    triangle_translated.p[1].z
                )

                if (get_dot_product(normal, p) < 0) then    
                    local light_dir = new_vec3d(
                        -0.3,-0.5,-1
                    ).normalize()
                    local dp = get_dot_product(normal, light_dir)
                    
                    local ws = {}
                    for vec3d in all(triangle_translated.p) do
                        local new_vec3d = new_vec3d(vec3d.x, vec3d.y, vec3d.z, vec3d.w)   
                        local result = 
                            new_vec3d
                                .to_matrix()
                                .multiply(mat_proj)
                        local w = result.m[1][4]

                        add(ws, w)

                        local projected_vec3d = 
                            result
                                .scaler(1/w)
                                .scaler(70)
                                .to_vec3d()
                            
                        add(projected_triangle_vec3d, projected_vec3d)
                    end 

                    for i = 1,#triangle_translated.texture do
                        local vec2d = triangle_translated.texture[i]
                        local vec3d = triangle_translated.p[i]

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
                            sprite = triangle_translated.sprite
                        }
                    ))
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


function tan(theta)
    return sin2(theta) / cos2(theta)
end

function sin2(theta)
    return sin(1 - (theta / 360 % 360))
end


function cos2(theta)
    return cos(theta / 360 % 360)
end

function get_cross_product(v1, v2)
    return new_vec3d(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end


function get_dot_product(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end



function filter(arr, condition)
	local output = {}
	for i=1,#arr do
		if condition(arr[i]) then
			add(output,arr[i])
		end
	end
	return output
end

function sort(arr, condition)
    for i=1,#arr-1 do
        for j=1,#arr-i do
            if condition(arr[j], arr[j + 1]) then
                arr[j], arr[j+1] = arr[j+1], arr[j]
            end
        end
    end
    return arr
end


function matrix_point_at(pos, target, up)
    local new_forward = v_subtract(target, pos).normalize()
    
    local a = v_mult(new_forward, get_dot_product(up, new_forward))

    local new_up = v_subtract(up, a).normalize()

    local new_right = get_cross_product(
        new_up, new_forward
    )


    local point_at_matrix = new_matrix(4,4)
    point_at_matrix.m[1] = {new_right.x, new_right.y, new_right.z, 0}
    point_at_matrix.m[2] = {new_up.x, new_up.y, new_up.z, 0}
    point_at_matrix.m[3] = {new_forward.x, new_forward.y, new_forward.z, 0}
    point_at_matrix.m[4] = {
        pos.x, pos.y, pos.z, 1
    }

    return point_at_matrix
end

function v_subtract(v1, v2)
    return new_vec3d(
        v1.x - v2.x,
        v1.y - v2.y,
        v1.z - v2.z,
        v1.w
    )
end
function v_add(v1, v2)
    return new_vec3d(
        v1.x + v2.x,
        v1.y + v2.y,
        v1.z + v2.z,
        v1.w
    )
end

function v_mult(v, factor)
    return new_vec3d(
        v.x * factor,
        v.y * factor, 
        v.z * factor,
        v.w * factor
    )
end

function draw_textured_triangle(
    x1, y1, u1, v1,
    x2, y2, u2, v2,
    x3, y3, u3, v3,
    lum,
    sprite
)
    if y2 < y1 then
        -- y1, y2, = y2, y1
        -- x1, x2 = x2, x1
        -- u1, u2 = u2, u1
        -- v1, v2 = v2, v1
        y1,y2,x1,x2,u1,u2,v1,v2 = y2,y1,x2,x1,u2,u1,v2,v1
    end

    if y3 < y1 then
        y1,y3,x1,x3,u1,u3,v1,v3 = y3,y1,x3,x1,u3,u1,v3,v1
        -- y1, y3 = y3, y1
        -- x1, x3 = x3, x1
        -- u1, u3 = u3, u1
        -- v1, v3 = v3, v1
    end

    if y3 < y2 then
        y2,y3,x2,x3,u2,u3,v2,v3 = y3,y2,x3,x2,u3,u2,v3,v2
        -- y2, y3 = y3, y2
        -- x2, x3 = x3, x2
        -- u2, u3 = u3, u2
        -- v2, v3 = v3, v2
    end



    -- local dy1 = y2 - y1
    -- local dx1 = x2 - x1
    -- local dv1 = v2 - v1
    -- local du1 = u2 - u1

    -- local dy2 = y3 - y1
    -- local dx2 = x3 - x1
    -- local dv2 = v3 - v1
    -- local du2 = u3 - u1

    local dy1,dx1,dv1,du1,dy2,dx2,dv2,du2 = y2-y1,x2 - x1,v2 - v1,u2 - u1,y3 - y1,x3 - x1,v3 - v1,u3 - u1

    local tex_u, tex_v, tex_w

    local dax_step, dbx_step, du1_step, dv1_step, du2_step, dv2_step = 0

    if dy1 then
        dax_step = dx1 / abs(dy1)
    end
    
    if dy2 then
        dbx_step = dx2 / abs(dy2)
    end

    if dy1 then
        du1_step = du1 / abs(dy1)
    end
    if dy1 then
        dv1_step = dv1 / abs(dy1)
    end

    
    if dy2 then
        du2_step = du2 / abs(dy2)
    end
    if dy2 then
        dv2_step = dv2 / abs(dy2)
    end


    if dy1 then
        for i=y1,y2 do
            local ax = x1 + (i - y1) * dax_step
            local bx = x1 + (i - y1) * dbx_step

            local tex_su = u1 + (i - y1) * du1_step
            local tex_sv = v1 + (i - y1) * dv1_step

            local tex_eu = u1 + (i - y1) * du2_step
            local tex_ev = v1 + (i - y1) * dv2_step

            if ax > bx then
                ax, bx = bx, ax
                tex_su, tex_eu = tex_eu, tex_su
                tex_sv, tex_ev = tex_ev, tex_sv
            end

            tex_u = tex_su
            tex_v = tex_sv

            local tstep = 1 / (bx - ax)
            local t = 0

            for j=ax,bx do
                tex_u = (1 - t) * tex_su + t * tex_eu
                tex_v = (1 - t) * tex_sv + t * tex_ev

                -- assert(false, sprite)
                local x, y = sample_sprite(sprite[1], sprite[2], sprite[3], sprite[4],tex_u, tex_v)
                local c =  get_color_from_byte(
                    peek(
                        num2hex(
                            flr((y * 128 + x % 128) / 2)
                        )
                    ),
                    (y * 128 + x % 128) % 2 == 0
                )

                local color = color_shades[c + 1][max(ceil((1-lum)* #color_shades[c + 1]), 1)]

                pset(j, i, color)
                t += tstep
            
            end
        end
    end

    dy1 = y3 - y2
    dx1 = x3 - x2
    dv1 = v3 - v2
    du1 = u3 - u2

    if dy1 then
        dax_step = dx1 / abs(dy1)
    end
    if dy2 then
        dbx_step = dx2 / abs(dy2)
    end

    du1_step,dv1_step = 0
    if dy1 then
        du1_step = du1 / abs(dy1)
    end
    if dy1 then
        dv1_step = dv1 / abs(dy1)
    end

    for i=y2,y3 do
        local ax = x2 + (i - y2) * dax_step
        local bx = x1 + (i - y1) * dbx_step

        local tex_su = u2 + (i - y2) * du1_step
        local tex_sv = v2 + (i - y2) * dv1_step

        local tex_eu = u1 + (i - y1) * du2_step
        local tex_ev = v1 + (i - y1) * dv2_step

        if ax > bx then
            ax, bx = bx, ax
            tex_su, tex_eu = tex_eu, tex_su
            tex_sv, tex_ev = tex_ev, tex_sv
        end

        tex_u = tex_su
        tex_v = tex_sv

        local tstep = 1 / (bx - ax)
        local t = 0

        for j=ax,bx do
            tex_u = (1 - t) * tex_su + t * tex_eu
            tex_v = (1 - t) * tex_sv + t * tex_ev

            local x, y = sample_sprite(sprite[1], sprite[2], sprite[3], sprite[4],tex_u, tex_v)
            local c =  get_color_from_byte(
                peek(
                    num2hex(
                        flr((y * 128 + x % 128) / 2)
                    )
                ),
                (y * 128 + x % 128) % 2 == 0
            )

            local color = color_shades[c + 1][max(ceil((1-lum)* #color_shades[c + 1]), 1)]


            pset(j, i, color)
            t += tstep
        end
    end
end

function sample_sprite(sx, sy, sw, sh, u, v)
    local x = round(map_val(u, 0, 1, sx, sx + sw - 1))
    local y = round(map_val(v, 0, 1, sy, sy + sh - 1))
    return x,y
end

function round(val)
    if val % 1 >= 0.5 then
        return ceil(val)
    else
        return flr(val)
    end
end

function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = num % 16
        s = sub(hexstr, mod+1, mod+1) .. s
        num = flr(num / 16)
    end
    if s == '' then s = '0x0' else
        s = '0x'..s
    end
    return s
end


function get_color_from_byte(b, left)
    return left == true and b % 16 or flr(b / 16)
end

function map_val(_val, start1, stop1, start2, stop2)
	return (_val - start1) * (stop2 - start2) / (stop1 - start1) + start2
end

function get_rnd(arr)
    return arr[flr(rnd(#arr)) + 1]
end

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
        draw_textured_triangle(
            t.p[1].x, 
            t.p[1].y,
            t.texture[1].u, 
            t.texture[1].v,
            t.p[2].x, 
            t.p[2].y,
            t.texture[2].u, 
            t.texture[2].v,
            t.p[3].x, 
            t.p[3].y,
            t.texture[3].u, 
            t.texture[3].v,
            t.lum,
            t.sprite
        )
    end
    return t
end

function new_vec2d(u, v)
    local vt = {}
    vt.u = u
    vt.v = v
    vt.w = 1
    return vt
end


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
    return v
end

__gfx__
00000000666666666666660055555555555555006666666666666600666666666666660000007888870000000000788887000000000078888700000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd60000078888887000000000788887000000000788888870000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007ffffff70000000007ffff70000000007ffffff70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007feffef70000000007fffe70000000007ffffff70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007ffffff70000000007ffff70000000007ffffff70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007ff55ff70000000007fff470000000007ffffff70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007f5555f70000000007fff470000000007ffffff70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd60000007ffff700000000007ffff700000000007ffff700000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd60000007eeee700000000007eeee700000000007eeee700000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007eeeeee00000000007eeee70000000007eeeeee70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd6000007e7ee7e70000000007ee7e70000000007eeeeee70000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd600007ee7ee7ee7000000007ee7e7000000007eeeeeeee7000000000000
00000000666666666666660055555555555555006ddddddddddddd006dddddddddddd600007e7eeee7e7000000007e7ee7000000007eeeeeeee7000000000000
000000006666666666666600555555555555550066666666666666006666666666666600007eeeeeeee7000000007eeee7000000007eeeeeeee7000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000777777777700000000777777000000007777777777000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaa00bbbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbbbbbbbbbb00888888888888880000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaeeaaaaaaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaeeeeeeaaaaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaeeeeaaeeeeaaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaeeeeaaaaeeeeaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaeeeeaaaaeeeeaaaaaaaa0000aaaaaaaaaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaeeeeaaeeeeaaaaaaaaa0000aaaaaaeeaaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaeeeeeeaaaaaaaaaaa0000aaaaaeeeeaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaeeaaaaaaaaaaaaa0000aaaaaeeeeaaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaeeeeeeaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaeeaaeeaaaa00b00000000000000000000000000b0000b000000000000b00800000000000080000000000
00000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaeeaaaaeeaaa00bbbbbbbbbbbbbbbbbbbbbbbbbbbb0000b000000000000b00800000000000080000000000
0000000000000000000000000000000000000000aaaeeaaaaeeaaa0000000000000000000000000000000000b000000000000b00800000000000080000000000
0000000000000000000000000000000000000000aaaaeeaaeeaaaa0000000000000000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777777777777777aaaaeeeeeeaaaa0000000777700000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777777777777777aaaaaeeeeaaaaa0000000000000000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777777777777777aaaaaeeeeaaaaa0000000077000000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777770000777777aaaaaaeeaaaaaa0000000077000000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777770000777777aaaaaaaaaaaaaa0000000077000000000000000000000000b000000000000b00800000000000080000000000
0000000077777777777777777777770000777777aaaaaaaaaaaaaa0000000077000007000000000000000700b000000000000b00800000000000080000000000
0000000077777700007777777777770000777777aaaaaaaaaaaaaa0000000077777707000000007777770700b000000000000b00800000000000080000000000
0000000077777700007777777777777777777777aaaaaaaaaaaaaa0000000077777707000000007777770700b000000000000b00800000000000080000000000
0000000077777700007777777777777777777777aaaaaaaaaaaaaa0000000000000007000000007700000700b000000000000b00800000000000080000000000
0000000077777700007777777777770000777777aaaaaaaaaaaaaa0000000000000000000000007700000000b000000000000b00800000000000080000000000
0000000077777777777777777777770000777777aaaaaaaaaaaaaa0000000000000000000000007700000000b000000000000b00800000000000080000000000
0000000077777777777777777777770000777777aaaaaaaaaaaaaa0000000000000000000000007700000000bbbbbbbbbbbbbb00888888888888880000000000
00000000777777777777777777777700007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777777777770000000000000000000000000000000000000777700000000000000000000000000000000000000000000000
00000000777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777777777777777777777777777777777777777000000000000000000000000444444444444444444444444444400004e4e444444e4e40000000000
000000007000077777777777777777777777777777777777000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeee00004eee4e44e4eee40000000000
0000000070000777777777777777777777777777777777770000000000000000000000004e4444e4444e4444e4444e4444e400004e4e444444e4e40000000000
000000007000077777777777777000077000077777700777000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeee00004e4e4e44e4e4e40000000000
000000007000077777777777777000077000077777700777000000000000000000000000444444444444444444444444444400004e4e444444e4e40000000000
0000000077777777777777777770000770000777777777770000000000000000000000004e4e4e444e44e44e44e444e4e4e400004e4e4e44e4e4e40000000000
000000007777770000777777777000077000077777777777000000000000000000000000444444444444444444444444444400004eee444444eee40000000000
000000007777770000777777777777777777777777777777000000000000000000000000444444444444444444444444444400004e4e444444e4e40000000000
0000000077777700007777777777777777777777000000000000000000000000000000004e4e4e444e44e44e44e444e4e4e400004e4e444444e4e40000000000
000000007777770000777777777000077000077700000000000000000000000000000000444444444444444444444444444400004e4e4e44e4e4e40000000000
000000007777777777777777777000077000077700000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeee00004e4e444444e4e40000000000
0000000077777777777000077770000770000777000000000000000000000000000000004e4444e4444e4444e4444e4444e400004eee444444eee40000000000
000000007777777777700007777000077000077700000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeee00004e4e4e44e4e4e40000000000
000000007777777777700007777777777777777700000000000000000000000000000000444444444444444444444444444400004e4e444444e4e40000000000
000000007777777777700007777777777777777700000000000000000000000000000000000000000000000000000000000000004e4e444444e4e40000000000
000000007777777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000004e4e4e44e4e4e40000000000
00000000cecececcccccceecccccccececec0000cccccccccccccc008e88ee88e8888ee8888e88ee88e8000088888888888888004eee444444eee40000000000
00000000ceccceccccccceecccccccecccec0000eeeeeeeeeeeeee008e888888e8888ee8888e888888e80000eeeeeeeeeeeeee004e4e444444e4e40000000000
00000000cecececcccccceecccccccececec0000cccccccccccccc008e88ee88e888eeee888e88ee88e8000088888888888888004e4e4e44e4e4e40000000000
00000000ceccceccccccceecccccccecccec0000ececcecceccece008e88ee88e8888ee8888e88ee88e800008888eeeeee8888004e4e444444e4e40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e8e88e8e8888ee8888e8e88e8e80000e8ee8eeee8ee8e004e4e444444e4e40000000000
00000000cecececcccccceecccccccececec0000eeeeeeeeeeeeee008e8eeee8e888eeee888e8eeee8e80000e8ee8eeee8ee8e004eee444444eee40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e8eeee8e88eeeeee88e8eeee8e800008888eeeeee8888004e4e4e44e4e4e40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e8eeee8e88eeeeee88e8eeee8e8000088888888888888004e4e444444e4e40000000000
00000000cecececcccccceecccccccececec0000cccccccccccccc008e8eeee8e888eeee888e8eeee8e80000eeeeeeeeeeeeee004e4e4e44e4e4e40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e8e88e8e8888ee8888e8e88e8e8000088888888888888004e4e444444e4e40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e88ee88e8888ee8888e88ee88e8000088888888888888004eee4e44e4eee40000000000
00000000cecececcccccceecccccccececec0000cccccccccccccc008e88ee88e888eeee888e88ee88e80000888888ee888888004e4e444444e4e40000000000
00000000ceccceccccccceecccccccecccec0000cccccccccccccc008e888888e8888ee8888e888888e8000088e88eeee88e8800000000000000000000000000
00000000cecececcccccceecccccccececec0000eeeeeeeeeeeeee008e88ee88e8888ee8888e88ee88e80000eeeeeeeeeeeeee00000000000000000000000000
0000000000000000000000000000000000000000eeeeeeeeeeeeee0000000000000000000000000000000000eeeeeeeeeeeeee00000000000000000000000000
0000000000000000000000000000000000000000cccccccccccccc000000000000000000000000000000000088e88eeee88e8800000000000000000000000000
0000000088888888888888888888888888880000cccccccccccccc0000000000000000000000000000000000888888ee88888800000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888888888888800000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888888888888800000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc0000000000000000000000000000000000eeeeeeeeeeeeee00000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888888888888800000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888eeeeee888800000000000000000000000000
0000000080000000000000000000000000080000eeeeeeeeeeeeee0000000000000000000000000000000000e8ee8eeee8ee8e00000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc0000000000000000000000000000000000e8ee8eeee8ee8e00000000000000000000000000
0000000080000000000000000000000000080000ececcecceccece00000000000000000000000000000000008888eeeeee888800000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888888888888800000000000000000000000000
0000000080000000000000000000000000080000eeeeeeeeeeeeee0000000000000000000000000000000000eeeeeeeeeeeeee00000000000000000000000000
0000000080000000000000000000000000080000cccccccccccccc00000000000000000000000000000000008888888888888800000000000000000000000000
00000000800000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000