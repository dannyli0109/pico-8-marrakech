pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

graphic_system = {}
graphic_system.update = function()
    cls()

    for x=2,col-1 do
        for y=2,row-1 do
            if board[x][y].carpert.index != 0 and board[x][y].carpert.dir != 0 then
                local c = board[x][y].carpert
                local px = (128 - cell_width * col) / 2 + (x - 1) * cell_width
                local py = (128 - cell_height * row) / 2 + (y - 1) * cell_height
                if c.dir == 1 then
                    board[x][y].entity.sprite = new_sprite(new_spr(carperts_h[c.index][1], carperts_h[c.index][2]))
                end
                if c.dir == 2 then
                    board[x][y].entity.sprite = new_sprite(new_spr(carperts_h[c.index][1] + cell_width, carperts_h[c.index][2]))
                end
                if c.dir == 3 then
                    board[x][y].entity.sprite = new_sprite(new_spr(carperts_v[c.index][1], carperts_h[c.index][2]))
                end
                if c.dir == 4 then
                    board[x][y].entity.sprite = new_sprite(new_spr(carperts_v[c.index][1], carperts_h[c.index][2] + cell_height))
                end
            end
        end
    end
    sprite_system.draw()
    game_state_system.draw()
end

physics_system = {}
physics_system.update = function()
    for ent in all(entities) do
        if ent.grid and ent.position then
            ent.position.x = (128 - cell_width * col) / 2 + (ent.grid.x - 1) * cell_width
            ent.position.y = (128 - cell_height * row) / 2 + (ent.grid.y - 1) * cell_height
        end
    end
    
end

sprite_system = {}
sprite_system.draw = function()
    for ent in all(entities) do
        if ent.sprite != nil and ent.position != nil and ent.state != nil then  
            pal(14,0)

            if ent.grid then
                sspr(
                    ent.sprite.sprite_list[ent.state.current].images[ent.sprite.index][1],
                    ent.sprite.sprite_list[ent.state.current].images[ent.sprite.index][2],
                    ent.position.w, 
                    ent.position.h,
                    ent.position.x,
                    ent.position.y,
                    ent.position.w, 
                    ent.position.h,
                    ent.sprite.sprite_list[ent.state.current].flip,
                    false
                )
            else 
                sspr(
                    ent.sprite.sprite_list[ent.state.current].images[ent.sprite.index][1],
                    ent.sprite.sprite_list[ent.state.current].images[ent.sprite.index][2],
                    ent.position.w, 
                    ent.position.h,
                    ent.position.x, 
                    ent.position.y,
                    ent.position.w, 
                    ent.position.h,
                    ent.sprite.sprite_list[ent.state.current].flip,
                    false
                )
            end
            pal()
        end
    end

    for x = 1, #board do
        for y = 1, #board[x] do
            if board[x][y].valid and board[x][y].carpert.index != 0 and board[x][y].carpert.dir != 0 then
                rectfill(
                    board[x][y].entity.position.x, 
                    board[x][y].entity.position.y, 
                    board[x][y].entity.position.x + board[x][y].entity.position.w - 1,
                    board[x][y].entity.position.y + board[x][y].entity.position.h - 1,
                    player_color[board[x][y].carpert.index]
                )
            end
        end
    end

    for i=1,player_num do
        local padding = 2
        local padding_left = 2
        local r =  2
        circfill(
            128/player_num * (i - 1) + r + padding_left, 
            r + 1, 
            r, 
            player_color[i]
        )

        if i == current_player then
            circ(
                128/player_num * (i - 1) + r + padding_left, 
                r + 1, 
                r + 1, 
                11
            )
        end

        oprint8(
            "$:"..player_score[i], 
            128/player_num * (i - 1) + padding + r * 2 + 3 + padding_left, 
            1, 
            7, 
            0
        )
    end 

    local txt = "rounds: "..starting_rugs[player_num] - player_rugs[1].."/"..starting_rugs[player_num]
     oprint8(txt, 
        40, 
        -6, 
        7, 
        0
    )
end

control_system = {}
control_system.update = function()
    for ent in all(entities) do
        if  ent.control != nil and ent.intention != nil then
            ent.control.input(ent)
        end
    end
end

state_system = {}
state_system.update = function()
    for ent in all(entities) do
        if ent.sprite and ent.state and ent.intention and game.game_state.state == "select_direction" then
            ent.state.previous = ent.state.current
            if not is_player[current_player] then
                player.intention.left = false
                player.intention.right = false
                player.intention.up = false
                player.intention.down = false
                -- player.intention = rnd(4) + 1
                local rand_direction = flr(rnd(4)) + 1

                local p_states_opp = {
                    "stand_right",
                    "stand_left",
                    "stand_down",
                    "stand_up"
                }


                local p_dir = {
                    1,2,3,4
                }

                while p_states_opp[rand_direction] == player.state do
                    rand_direction = flr(rnd(4)) + 1
                end 

                if rand_direction == 1 then
                    player.intention.left = true
                elseif rand_direction == 2 then
                    player.intention.right = true
                elseif rand_direction == 3 then
                    player.intention.up = true
                else
                    player.intention.down = true
                end
            end
            for state,rule in pairs(ent.state.rules) do
                if rule() then
                    ent.state.current = state
                    game.game_state.state = "roll_dice"
                    break
                end
            end
        end
    end
end

game_state_system = {}
game_state_system.update = function()

    if game.game_state.state == "roll_dice" then
        num = 1
        dice_state = dice_states[num]
        final_angle = dest_angle[num]
        final_z = rand_z[1]

        if not is_player[current_player] then
            player.intention.x = true
        end

        if player.intention.x then
            game.game_state.state = "rolling_dice"
            player.intention.x = false
            game.timer.time = 0
            speed_x = rnd(5) + 10
            speed_y = rnd(5) + 10
            speed_z = rnd(5) + 10
            game.timer.delay = 60
            -- duration = game.timer.delay
            -- mesh_cube = new_cube()
            num = flr(rnd(#dest_angle)) + 1
            dice_state = dice_states[num]
            final_angle = dest_angle[num]
            final_z = get_rnd(rand_z)
        end
    end

    if game.game_state.state == "rolling_dice" then

        if game.timer.time > game.timer.delay then
            mesh_cube.rx = final_angle[1]
            mesh_cube.ry = final_angle[2]
            mesh_cube.rz = final_z
            game.game_state.state = "move_player"
        else 

            if game.timer.time / game.timer.delay < 0.5 then
                mesh_cube.rx += speed_x * (game.timer.delay - game.timer.time) / game.timer.delay 
                mesh_cube.ry += speed_y * (game.timer.delay - game.timer.time) / game.timer.delay
                mesh_cube.rz += speed_z * (game.timer.delay - game.timer.time) / game.timer.delay
                mesh_cube.rx = mesh_cube.rx % 360
                mesh_cube.ry = mesh_cube.ry % 360
                mesh_cube.rz = mesh_cube.rz % 360

            else
                mesh_cube.rx = map_val(game.timer.time / game.timer.delay, 0.5, 1, mesh_cube.rx, final_angle[1])
                mesh_cube.ry = map_val(game.timer.time / game.timer.delay, 0.5, 1, mesh_cube.ry, final_angle[2])
                mesh_cube.rz = map_val(game.timer.time / game.timer.delay, 0.5, 1, mesh_cube.rz, final_z)
            end
        end
    end

    if game.game_state.state == "move_player" then
        local d_state = {
            one = 1,
            two = 2,
            three = 3,
            four = 4
        }
        local p_state = {
            stand_left = 1,
            stand_right = 2,
            stand_up = 3,
            stand_down = 4
        }

        local p_state_name = {
            "stand_left",
            "stand_right",
            "stand_up",
            "stand_down"
        }
        game.game_state.state = "animate_player_movement"

        cor = new_entity({
            timer = new_timer(1)
        })
        local animation_length = 10
        local animation_length_tunnel = 5
        cor.rutine = cocreate(function()        
            for i=1,d_state[dice_state] do
                for j = 1, animation_length do
                    player.grid.x += 1/animation_length * dir_x[p_state[player.state.current]]
                    player.grid.y += 1/animation_length * dir_y[p_state[player.state.current]]
                    yield()
                end


                player.grid.x = round(player.grid.x)
                player.grid.y = round(player.grid.y)

                local tunnel = tunnels[player.grid.x][player.grid.y]
                if tunnel then
                    for i = 1, #tunnel do
                        for j = 1, animation_length_tunnel do
                            player.grid.x += 1/animation_length_tunnel * dir_x[tunnel[i]]
                            player.grid.y += 1/animation_length_tunnel * dir_y[tunnel[i]]
                            player.state.current = p_state_name[tunnel[i]]
                            yield()
                        end
                    end
                end

                player.grid.x = round(player.grid.x)
                player.grid.y = round(player.grid.y)

                yield()
                yield()
                yield()
            end
            del(entities, dice)
        end)

        add(entities, cor)

    end

    if game.game_state.state == "animate_player_movement" then
        if cor then
            if costatus(cor.rutine) == "dead" then
                --player_score[current_player]

                --calculate score

                del(entities, cor)
                cor = new_entity({
                    timer = new_timer(5)
                })
                cor.timer.time = 5
                cor.rutine = cocreate(function()      
                    if board[player.grid.x][player.grid.y].carpert.index > 0 and board[player.grid.x][player.grid.y].carpert.index != current_player then
                        local score = calculate_score(player.grid.x, player.grid.y)
                        player_score[board[player.grid.x][player.grid.y].carpert.index] += score
                        player_score[current_player] -= score
                    end
                    cor.timer.delay = 2
                    reset_visited()
                    yield()
                    select_carpert(false)
                    game.game_state.state = "place_carpert"
                    player.intention.left = false
                    player.intention.right = false
                end)
                add(entities, cor)
            end
        end
    end

    if game.game_state.state == "place_carpert" then
        -- if count_valid_cells() > 0 then
        if cor then
            if costatus(cor.rutine) == "dead" then
                del(entities, cor)
                cor = nil
            end
        end
        if not is_player[current_player] then
            if not cor then
                cor = new_entity({
                    timer = new_timer(30)
                })
                local best = -1
                local best_index = 1
                for i=1,8 do
                    local x = player.grid.x + dir_x[carpert_dir[i]]
                    local y = player.grid.y + dir_y[carpert_dir[i]]
                    local is_horizontal = flr((i-1) / 2) % 2 == 0
                    if (valid_cell(
                        x, 
                        y,
                        is_horizontal
                    )) then
                        local score = 0
                        if board[x][y].carpert.index == 0 then
                            score += 10
                        elseif (board[x][y].carpert.index != current_player) then
                            score += 20
                        else 
                            score -= 10
                        end

                        if is_horizontal then
                            if (board[x + 1][y].carpert.index == 0) then
                                score += 10
                            elseif(board[x + 1][y].carpert.index != current_player) then
                                score += 20
                            else 
                                score -= 10
                            end
                        else 
                            if board[x][y + 1].carpert.index == 0 then
                                score += 10
                            elseif (board[x][y + 1].carpert.index != current_player) then
                                score += 20
                            else 
                                score -= 10
                            end
                        end

                        if score > best then
                            best = score
                            best_index = i
                        end
                    end
                    debug = best_index
                end
                cor.timer.time = 0
                cor.rutine = cocreate(function()      
                    while (true) do
                        if best_index != carpert_index then
                            if best_index > carpert_index then
                                select_carpert(false)
                            else
                                select_carpert(true)
                            end
                            yield()
                        else 
                            player.intention.x = true
                            yield()
                            break
                        end
                    end
                end)
                add(entities, cor)
            end

            
        end
        if player.intention.right then
            select_carpert(false)
        end
        
        if player.intention.left then
            select_carpert(true)
        end


        if player.intention.x then
            local is_horizontal = flr((carpert_index-1) / 2) % 2 == 0

            if valid_cell(
                player.grid.x + dir_x[carpert_dir[carpert_index]], 
                player.grid.y + dir_y[carpert_dir[carpert_index]],
                is_horizontal
            ) then
                if is_horizontal then
                    board[carpert.grid.x][carpert.grid.y].carpert = {
                        index = current_player,
                        dir = 1
                    }
                    board[carpert.grid.x + dir_x[2]][carpert.grid.y + dir_y[2]].carpert = {
                        index = current_player,
                        dir = 2
                    }
                else
                    board[carpert.grid.x][carpert.grid.y].carpert = {
                        index = current_player,
                        dir = 3
                    }
                    board[carpert.grid.x + dir_x[4]][carpert.grid.y + dir_y[4]].carpert = {
                        index = current_player,
                        dir = 4
                    }
                end
                del(entities, carpert)

                if carpert_frame then
                del(entities, carpert_frame)
                end                
                carpert_frame = nil
                carpert = nil
            
                next_turn()
            end
        end

    end

    if game.game_state.state == "game_over" then
        if cor then
            if costatus(cor.rutine) == "dead" then
                if (btnp(5)) then
                        player_num, update, draw = 2, update_game_start,draw_game_start
                    -- start_game()
                end
            end
        end
    end

end

game_state_system.draw = function()

    if game.game_state.state == "select_direction" then
         local directions = {
            "⬅️","➡️","⬆️","⬇️"
        }

        local p_states_opp = {
            "stand_right",
            "stand_left",
            "stand_down",
            "stand_up"
        }
        for i=1,4 do
            if player.state.current != p_states_opp[i] then
                oprint8(directions[i], 
                    player.position.x + dir_x[i] * player.position.w + player.position.w / 2 - 3, 
                    player.position.y + dir_y[i] * player.position.h + player.position.h / 2 - 2 - sin(time() * 2), 
                    0, 
                    7
                )
            end
        end
    end


    if game.game_state.state == "roll_dice" then
        -- if dice then
            oprint8("❎", 
                10, 
                95- sin(time() * 2), 
                0, 
                7
            )
        -- end
    end
    if game.game_state.state == "game_over" then
        -- if dice then

        if cor then
            if costatus(cor.rutine) == "dead" then
                local winner = 1
                for i=1,player_num do
                    if (player_score[i] > player_score[winner]) winner = i
                end

                local win_txt = "you win!"
                if (winner != 1) do
                    win_txt = "you lose!"
                end
                oprint8(win_txt, 
                    64 - #win_txt*3/2, 
                    64 - 2 - 6, 
                    0, 
                    7
                )
                oprint8("press ❎ to restart", 
                    30, 
                    64 - 2 + 6, 
                    0, 
                    7
                )
            end
        end
        -- end
    else 
        if not is_player[current_player] then
            local txt = "ai moving..."
            oprint8(txt, 
                64 - #txt*3/2, 
                64 - 2 - 6, 
                0, 
                7
            )
        end

    end

end


timer_system = {}
timer_system.update = function()
    for ent in all(entities) do
        if ent.timer then
            ent.timer.time += 1
        end
    end
end

function select_carpert(left)
    if carpert then
        del(entities, carpert)
    end

    if carpert_frame then
        del(entities, carpert_frame)
    end

    carpert_index = left and (carpert_index - 1 + 7) % 8 + 1 or carpert_index % 8 + 1

    while(
        not valid_cordinates(
            player.grid.x + dir_x[carpert_dir[carpert_index]],
            player.grid.y + dir_y[carpert_dir[carpert_index]],
            flr((carpert_index-1) / 2) % 2 == 0
        )
    ) do
        carpert_index = left and (carpert_index - 1 + 7) % 8 + 1 or carpert_index % 8 + 1
    end

    carpert = init_carpert(
        player.grid.x + dir_x[carpert_dir[carpert_index]], 
        player.grid.y + dir_y[carpert_dir[carpert_index]],
        flr((carpert_index-1) / 2) % 2 == 0
    )
    
    local frame_state = "frame"
    if not valid_cell(
        player.grid.x + dir_x[carpert_dir[carpert_index]],
        player.grid.y + dir_y[carpert_dir[carpert_index]],
        flr((carpert_index-1) / 2) % 2 == 0
    ) then
        frame_state = "frame_red"
    end
    carpert_frame = init_carpert(
        player.grid.x + dir_x[carpert_dir[carpert_index]], 
        player.grid.y + dir_y[carpert_dir[carpert_index]],
        flr((carpert_index-1) / 2) % 2 == 0,
        frame_state
    )
    add(entities, carpert)
    add(entities, carpert_frame)
end

function count_valid_cells()
    local valid_cells = 0
    for i=1,8 do
        if (valid_cell(
            player.grid.x + dir_x[carpert_dir[i]],
            player.grid.y + dir_y[carpert_dir[i]],
            flr((i-1) / 2) % 2 == 0
        )) then 
            valid_cells += 1
        end
    end
    return valid_cells
end

function next_turn()
    player_rugs[current_player] -= 1
    local should_end = true
    for i=1, player_num do
        if(player_rugs[i] > 0) should_end = false
    end
    if not(should_end) then
        carpert_index = 1
        turn += 1
        current_player = (turn - 1) % player_num + 1
        game.game_state.state = "select_direction"
    else
        game.game_state.state = "game_over"
        -- player.intention.x = false

        cor = new_entity({
            timer = new_timer(5)
        })
        cor.timer.time = 5
        cor.rutine = cocreate(function()      
            for x = 1, #board do
                for y = 1, #board[x] do
                    if board[x][y].carpert.index != 0 then
                        board[x][y].valid = true
                        player_score[board[x][y].carpert.index] += 1
                        yield()
                    end
                end
            end
        end)
        add(entities, cor)
        player.intention.x = false
    end
    
end

function calculate_score(x,y)
    local stack = {}
    local index = board[x][y].carpert.index
    local current_cell = board[x][y]
    current_cell.visited = true
    current_cell.valid = true
    local score = 1
    yield()
    
    while(true) do
        local unvisited_neighbour = get_unvisited_neighbour(current_cell)
        debug = #unvisited_neighbour
        if #unvisited_neighbour > 0 then    
            add(stack, current_cell)
            local rnd_cell = get_rnd(unvisited_neighbour)
            rnd_cell.visited = true
            rnd_cell.valid = true
            score += 1
            current_cell = rnd_cell
            yield()
        else
            if #stack > 0 then  
                local c = stack[#stack]
                current_cell = c
                del(stack, c)
            else 
                break
            end
        end
    end
    return score
end


function reset_visited()
    for x = 1, #board do
        for y = 1, #board[x] do
            board[x][y].visited = false
            
            if board[x][y].valid then
                board[x][y].valid = false
                yield()
            end

        end
    end
end

function get_unvisited_neighbour(cell)
    local output = {}
    for i=1,4 do
        if not board[cell.entity.grid.x + dir_x[i]][cell.entity.grid.y + dir_y[i]].visited then
            if (
                board[cell.entity.grid.x + dir_x[i]][cell.entity.grid.y + dir_y[i]].carpert.index == cell.carpert.index
            ) then
                add(output, board[cell.entity.grid.x + dir_x[i]][cell.entity.grid.y + dir_y[i]])
            else 
                board[cell.entity.grid.x + dir_x[i]][cell.entity.grid.y + dir_y[i]].visited = true
            end
        end
    end

    return output
end