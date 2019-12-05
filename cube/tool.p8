pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

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
    
    local a = new_forward.multiply(
        get_dot_product(up, new_forward)
    )

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

function vector_intersect_plane(plane_p, plane_n, line_start, line_end)
    plane_n = plane_n.normalize()
    local plane_d = -get_dot_product(plane_n, plane_p)
    local ad = get_dot_product(line_start, plane_n)
    local bd = get_dot_product(line_end, plane_n)
    local t = (-plane_d - ad) / (bd - ad)
    local line_start_to_end = v_subtract(line_end, line_start)
    local line_to_intersect = v_mult(line_start_to_end, t)
    return v_add(line_start, line_to_intersect), t
end

function triangle_clip_against_plane(plane_p, plane_n, triangle)
    plane_n = plane_n.normalize()
    local dist = function(p)    
        local n = p.normalize()
        return (plane_n.x * p.x + plane_n.y * p.y + plane_n.z * p.z - get_dot_product(plane_n, plane_p))
    end

    local inside_points = {}
    local outside_points = {}
    local inside_tex = {}
    local outside_tex = {}

    local n_inside_point_count = 0
    local n_outside_point_count = 0
    local n_inside_tex_count = 0
    local n_outside_tex_count = 0

    local d1 = dist(triangle.p[1])
    local d2 = dist(triangle.p[2])
    local d3 = dist(triangle.p[3])

    if d1 >= 0 then
        inside_points[n_inside_point_count + 1] = triangle.p[1]
        n_inside_point_count += 1
        inside_tex[n_inside_tex_count + 1] = triangle.texture[1]
        n_inside_tex_count += 1
    else
        outside_points[n_outside_point_count + 1] = triangle.p[1]
        n_outside_point_count += 1
        outside_tex[n_outside_tex_count + 1] = triangle.texture[1]
        n_outside_tex_count += 1
    end
    if d2 >= 0 then
        inside_points[n_inside_point_count + 1] = triangle.p[2]
        n_inside_point_count += 1
        inside_tex[n_inside_tex_count + 1] = triangle.texture[2]
        n_inside_tex_count += 1
    else
        outside_points[n_outside_point_count + 1] = triangle.p[2]
        n_outside_point_count += 1
        outside_tex[n_outside_tex_count + 1] = triangle.texture[2]
        n_outside_tex_count += 1
    end
    if d3 >= 0 then
        inside_points[n_inside_point_count + 1] = triangle.p[3]
        n_inside_point_count += 1
        inside_tex[n_inside_tex_count + 1] = triangle.texture[3]
        n_inside_tex_count += 1
    else
        outside_points[n_outside_point_count + 1] = triangle.p[3]
        n_outside_point_count += 1
        outside_tex[n_outside_tex_count + 1] = triangle.texture[3]
        n_outside_tex_count += 1
    end

    if n_inside_point_count == 0 then
        return {}
    end

    if n_outside_point_count == 0 then
        return {
            triangle
        }
    end

    if n_inside_point_count == 1 and n_outside_point_count == 2 then
        local v1,t1 = vector_intersect_plane(plane_p, plane_n, inside_points[1], outside_points[1])

       
        local v2,t2 = vector_intersect_plane(plane_p, plane_n, inside_points[1], outside_points[2])
        --  assert(fase, t2)

        local tex1 = inside_tex[1]

        local tex2 = new_vec2d(
            t1 * (outside_tex[1].u - inside_tex[1].u) + inside_tex[1].u,
            t1 * (outside_tex[1].v - inside_tex[1].v) + inside_tex[1].v
        )
        -- assert(false,tex2.u.." "..tex2.v)

        local tex3 = new_vec2d(
            t2 * (outside_tex[2].u - inside_tex[1].u) + inside_tex[1].u,
            t2 * (outside_tex[2].v - inside_tex[1].v) + inside_tex[1].v
        )


        local out_tri = new_triangle(
            {
                p = {
                    inside_points[1],
                    v1,
                    v2,
                    tex1,
                    tex2,
                    tex3
                },
                lum = triangle.lum,
                sprite = triangle.sprite
            }
        )
        return {out_tri}
    end

    if n_inside_point_count == 2 and n_outside_point_count == 1 then
        local v1,t1 = vector_intersect_plane(plane_p, plane_n, inside_points[1], outside_points[1])

        local v2,t2 = vector_intersect_plane(plane_p, plane_n, inside_points[2], outside_points[1])

        local tex1 = inside_tex[1]
        local tex2 = inside_tex[2]

        local tex3 = new_vec2d(
            t1 * (outside_tex[1].u - inside_tex[1].u) + inside_tex[1].u,
            t1 * (outside_tex[1].v - inside_tex[1].v) + inside_tex[1].v
        )

        local tex4 = inside_tex[2]



        local out_tri1 = new_triangle(
            {
                p = {
                    inside_points[1],
                    inside_points[2],
                    v1,
                    tex1,
                    tex2,
                    tex3
                },
                lum = triangle.lum,
                sprite = triangle.sprite
            }
        )

        local tex5 = out_tri1.texture[3]

        local tex6 = new_vec2d(
            t2 * (outside_tex[1].u - inside_tex[2].u) + inside_tex[2].u,
            t2 * (outside_tex[1].v - inside_tex[2].v) + inside_tex[2].v
        )


        local out_tri2 = new_triangle({
            p = {
                inside_points[1],
                out_tri1.p[2],
                v2,
                tex4,
                tex5,
                tex6
            },
            lum = triangle.lum,
            sprite = triangle.sprite
        })
        return {out_tri1, out_tri2}
    end
end

List = {}
function List.new ()
  return {first = 0, last = -1}
end

function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft (list)
  local first = list.first
  if first > list.last then error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright (list)
  local last = list.last
  if list.first > last then error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end

function List.count (list)
    local count = 0
    for i=list.first, list.last do
        -- if list[i] then
        count +=1
        -- end
    end
    return count
end


function draw_textured_triangle(
    x1, y1, u1, v1, w1,
    x2, y2, u2, v2, w2,
    x3, y3, u3, v3, w3,
    lum,
    sprite
)
    if y2 < y1 then
        y1, y2 = y2, y1
        x1, x2 = x2, x1
        u1, u2 = u2, u1
        v1, v2 = v2, v1
        w1, w2 = w2, w1
    end

    if y3 < y1 then
        y1, y3 = y3, y1
        x1, x3 = x3, x1
        u1, u3 = u3, u1
        v1, v3 = v3, v1
        w1, w3 = w3, w1
    end

    if y3 < y2 then
        y2, y3 = y3, y2
        x2, x3 = x3, x2
        u2, u3 = u3, u2
        v2, v3 = v3, v2
        w2, w3 = w3, w2
    end



    local dy1 = y2 - y1
    local dx1 = x2 - x1
    local dv1 = v2 - v1
    local du1 = u2 - u1
    local dw1 = w2 - w1

    local dy2 = y3 - y1
    local dx2 = x3 - x1
    local dv2 = v3 - v1
    local du2 = u3 - u1
    local dw2 = w3 - w1

    local tex_u, tex_v, tex_w

    local dax_step, dbx_step, du1_step, dv1_step, du2_step, dv2_step, dw1_step, dw2_step = 0

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
    if dy1 then
        dw1_step = dw1 / abs(dy1)
    end
    
    if dy2 then
        du2_step = du2 / abs(dy2)
    end
    if dy2 then
        dv2_step = dv2 / abs(dy2)
    end
    if dy2 then
        dw2_step = dw2 / abs(dy2)
    end

    if dy1 then
        for i=y1,y2 do
            local ax = x1 + (i - y1) * dax_step
            local bx = x1 + (i - y1) * dbx_step

            local tex_su = u1 + (i - y1) * du1_step
            local tex_sv = v1 + (i - y1) * dv1_step
            local tex_sw = w1 + (i - y1) * dw1_step

            local tex_eu = u1 + (i - y1) * du2_step
            local tex_ev = v1 + (i - y1) * dv2_step
            local tex_ew = w1 + (i - y1) * dw2_step

            if ax > bx then
                ax, bx = bx, ax
                tex_su, tex_eu = tex_eu, tex_su
                tex_sv, tex_ev = tex_ev, tex_sv
                tex_sw, tex_ew = tex_ew, tex_sw
            end

            tex_u = tex_su
            tex_v = tex_sv
            tex_w = tex_sw

            local tstep = 1 / (bx - ax)
            local t = 0

            for j=ax,bx do
                tex_u = (1 - t) * tex_su + t * tex_eu
                tex_v = (1 - t) * tex_sv + t * tex_ev
                tex_w = (1 - t) * tex_sw + t * tex_ew

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
    dw1 = w3 - w2

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
    if dy1 then
        dw1_step = dw1 / abs(dy1)
    end

    for i=y2,y3 do
        local ax = x2 + (i - y2) * dax_step
        local bx = x1 + (i - y1) * dbx_step

        local tex_su = u2 + (i - y2) * du1_step
        local tex_sv = v2 + (i - y2) * dv1_step
        local tex_sw = w2 + (i - y2) * dw1_step

        local tex_eu = u1 + (i - y1) * du2_step
        local tex_ev = v1 + (i - y1) * dv2_step
        local tex_ew = w1 + (i - y1) * dw2_step

        if ax > bx then
            ax, bx = bx, ax
            tex_su, tex_eu = tex_eu, tex_su
            tex_sv, tex_ev = tex_ev, tex_sv
            tex_sw, tex_ew = tex_ew, tex_sw
        end

        tex_u = tex_su
        tex_v = tex_sv
        tex_w = tex_sw

        local tstep = 1 / (bx - ax)
        local t = 0

        for j=ax,bx do
            tex_u = (1 - t) * tex_su + t * tex_eu
            tex_v = (1 - t) * tex_sv + t * tex_ev
            tex_w = (1 - t) * tex_sw + t * tex_ew

            -- assert(false, tex_w)

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


    -- local x,y = sample_sprite(0,0,8,8,1,1)
    -- local c =  get_color_from_byte(
    --     peek(
    --         num2hex(
    --             flr((y * 128 + x % 128) / 2)
    --         )
    --     ),
    --     (y * 128 + x % 128) % 2 == 0
    -- )

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