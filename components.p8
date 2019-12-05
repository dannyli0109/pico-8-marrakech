pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- position component
function new_position(x,y,w,h)
    local p = {}
    p.x = x
    p.y = y
    p.w = w
    p.h = h
    return p
end

function new_sprite(sl)
    local s = {}
    s.sprite_list = sl
    s.index = 1
    return s
end

function new_control(left,right,up,down,o,x,input)
    local c = {}
    c.left = left
    c.right = right
    c.up = up
    c.down = down
    c.o = o
    c.x = x
    c.input = input
    return c
end

function new_intention()
    local i = {}
    i.left,i.right,i.up,i.down,i.o,i.x = false
    return i
end

function new_state(initial_state, r)
    local s = {}
    s.current = initial_state
    s.previous = initial_state
    s.rules = r
    return s
end

function new_grid(x,y)
    local g = {}
    g.x = x
    g.y = y
    return g
end

function new_game_state(state)
    local gs = {}
    gs.state = state or "select_direction" 
    return gs
end


-- function new_animation()

function new_timer(delay)
    local t = {}
    t.time = 0
    t.delay = delay
    return t
end