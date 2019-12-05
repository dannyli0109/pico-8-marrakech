pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

dir_x = {-1,1,0,0,1,1,-1,-1}
dir_y = {0,0,-1,1,1,-1,-1,1}
camera_x = 0
camera_y = 0
player_num = 2
dice_states = {
    "one",
    "three",
    "two",
    "two",
    "four",
    "three"
}
function _init()
    player_num, update, draw = 2, update_game_start,draw_game_start
end

function update_game_start()
    if (btnp(5)) then
        start_game()
        camera(0, -6)
    elseif (btnp(0)) then
        player_num = max(player_num - 1, 2)
    elseif (btnp(1)) then
        player_num = min(player_num + 1, 4)
    end
end

function draw_game_start()
    cls()
    map()
    camera(0, -28)
    local txt = "press ❎ to start       "
    oprint8(txt, 
        64 - #txt*3/2, 
        65, 
        0, 
        7
    )
    local txt2 = "players: ⬅️ "..player_num.." ➡️        "
    oprint8(txt2, 
        64 - #txt2*3/2, 
        50, 
        0, 
        7
    )

end

function _update60()
    update()
end

function update_game()
    del(entities,player)
    add(entities,player)
    timer_system.update()
    control_system.update()
    state_system.update()
    game_state_system.update()
    physics_system.update()

    if cor then
        if cor.timer.time > cor.timer.delay then
            coresume(cor.rutine)
            cor.timer.time = 0
        end
    end
end


function _draw()
    draw()
end

function draw_game()
    graphic_system.update()
    if game.game_state.state == "rolling_dice" or game.game_state.state == "roll_dice" then
        camera(-13, -118)
        mesh_cube.draw(7)
        camera(0, -6)
    end

end



function player_input(ent)
    if is_player[current_player] then
        ent.intention.left = btnp(ent.control.left)
        ent.intention.right = btnp(ent.control.right)
        ent.intention.up = btnp(ent.control.up)
        ent.intention.down = btnp(ent.control.down)
        ent.intention.o = btnp(ent.control.o)
        ent.intention.x = btnp(ent.control.x)
    end
end

function start_game()   
    row = 9
    col = 9
    cell_width = 14
    cell_height = 14
    carpert_width = 28
    carpert_height = 14
    dice_width = 16
    dice_height = 16
    carpert = nil
    carpert_index = 1
    carpert_dir = {7,3,6,2,4,8,1,7}
    dice_num = {1,2,2,3,3,4}
    mesh_cube = new_cube()
    players = {
        1,2,3,4
    }
    carperts_h = {
        {8,16},
        {72,48},
        {8,64},
        {56,64}
        
    }
    carperts_v = {
        {40,16},
        {104,48},
        {40,64},
        {88,64}
    }
    player_score = { 30, 30, 30, 30 }
    player_color = {10,4,12,8}
    starting_rugs = {0, 24, 15, 12}
    is_player = {true,false,false,false}
    player_rugs = {starting_rugs[player_num], starting_rugs[player_num], starting_rugs[player_num], starting_rugs[player_num]}
    current_player = 1
    turn = 1
    cor = nil
    draw = draw_game
    update = update_game
    entities = {}
    init_game()
    init_board()
    init_player(5,5)
end

function init_game()
    game = new_entity({
        game_state = new_game_state(),
        timer = new_timer(180)
    })
    add(entities, game)
end

function init_player(x,y)
    player = new_entity({
        position = new_position(
            (128 - (cell_width) * col) / 2 + (x - 1) * (cell_width),
            (128 - (cell_height) * row) / 2 + (y - 1) * cell_height,
            cell_width,
            cell_height
        ),
        sprite = new_sprite(
            {
                stand_left = {
                    images = {
                        {88,0}
                    },
                    flip = true
                },
                stand_right = {
                    images = {
                        {88,0}
                    },
                    flip = false
                },
                stand_down = {
                    images = {
                        {72,0}
                    },
                    flip = false
                },
                stand_up = {
                    images = {
                        {104,0}
                    },
                    flip = false
                }

                
            }
        ),
        control = new_control(0,1,2,3,4,5,player_input),
        intention = new_intention(),
        state = new_state("stand_down", {
            stand_down = function()
                return player.intention.down and player.state.current != "stand_up"
            end,
            stand_up = function()
                return player.intention.up and player.state.current != "stand_down"
            end,
            stand_left = function()
                return player.intention.left and player.state.current != "stand_right"
            end,
            stand_right = function()
                return player.intention.right and player.state.current != "stand_left"
            end
        }),
        grid = new_grid(x,y),
        timer = new_timer(60)
    })
    add(entities, player)
end

function new_spr(sx,sy,flip,tunnel)
    return {
            idle = {
                images = {
                    {sx, sy}
                },
                flip = flip
            }
        }, tunnel
end

function init_board()
    board = {}
    tunnels = {}
    carperts = {}
    local sprite = {
        idle = {
            images = {
                {8,0}
            },
            flip = false
        }
    }

    for x=1,col do
        board[x] = {}
        tunnels[x] = {}
        carperts[x] = {}
        for y=1,row do
            if y == 1 then
                if x % 2 == 1 and x != col then
                    sprite, tunnels[x][y] = new_spr(72,32, false, {2,4})
                elseif x % 2 == 0 and x != 2 then
                    sprite, tunnels[x][y] = new_spr(72,32, true, {1,4})
                elseif x == 2 then
                    sprite, tunnels[x][y] = new_spr(72,32, true, {1,4,2})
                else 
                    sprite = new_spr(56,48, true)
                end
            elseif x == 1 then
                if y % 2 == 0 and y != 2 then
                    sprite, tunnels[x][y] = new_spr(56,32, false, {3,2})
                elseif y % 2 == 1 and y != row then 
                    sprite, tunnels[x][y] = new_spr(72,32, false, {4,2})
                elseif y == 2 then
                    sprite, tunnels[x][y] = new_spr(56,32, false, {3,2,4})
                else
                    sprite = new_spr(56,48, false)
                end
            elseif x == col then
                if y % 2 == 1 then
                    sprite, tunnels[x][y] = new_spr(56,32, true, {3,1})
                elseif y % 2 == 0 and y != row-1 then  
                    sprite, tunnels[x][y] = new_spr(72,32, true, {4,1})
                else
                    sprite, tunnels[x][y] = new_spr(72,32, true, {4,1,3})
                end
            elseif y == row then
                if x % 2 == 0 and x != col - 1 then
                    sprite, tunnels[x][y] = new_spr(56,32, false, {2,3})
                elseif x % 2 == 1 then
                    sprite, tunnels[x][y] = new_spr(56,32, true, {1,3})
                else
                    sprite, tunnels[x][y] = new_spr(56,32, false, {2,3,1})
                end
            elseif x == col or y == row then
                sprite = new_spr(56,48, false)
            else
                if y % 2 == 0 then
                    if x % 2 == 0 then
                        sprite = new_spr(8,0, false)
                    else 
                        sprite = new_spr(24,0, false)
                    end
                else 
                    if x % 2 == 1 then
                        sprite = new_spr(8,0, false)
                    else 
                        sprite = new_spr(24,0, false)
                    end
                end
                
            end

            local grid = new_entity({
                position = new_position(
                    (128 - cell_width * col) / 2 + (x - 1) * cell_width,
                    (128 - cell_height * row) / 2 + (y - 1) * cell_height,
                    cell_width,
                    cell_height
                ),
                sprite = new_sprite(
                   sprite
                ),
                grid = new_grid(x,y)
            })

            carperts[x][y] = 0
            board[x][y] = {
                entity = grid,
                carpert = {
                    index = 0,
                    dir = 0
                },
                visited = false,
                valid = false
            }
            add(entities, grid)
        end
    end
end

function init_carpert(x,y,is_horizontal,state)
    local w = is_horizontal and carpert_width or carpert_height
    local h = is_horizontal and carpert_height or carpert_width
    local spr = is_horizontal and carperts_h[current_player] or carperts_v[current_player]
    local spr_frame = is_horizontal and {56,16} or {88,16}
    local spr_frame_red = is_horizontal and {8,80} or {104,16}
    local s = state or "idle"
    local c = new_entity({
        position = new_position(
            (128 - cell_width * col) / 2 + (x - 1) * cell_width,
            (128 - cell_height * row) / 2 + (y- 1) * cell_height,
            w,
            h
        ),
        sprite = new_sprite(
            {
                idle = {
                    images = {
                        spr
                    },
                    flip = false
                },
                frame = {
                    images = {spr_frame},
                    flip = false
                },
                frame_red = {
                    images = {spr_frame_red},
                    flip = false
                }
            }
        ),state = new_state(s, {}),
        grid = new_grid(x,y)
    })
    return c
end