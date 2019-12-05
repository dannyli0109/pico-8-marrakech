pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function oprint8(
	_t,_x,_y,_c,_c2
)
	for i=1,8 do
		print(
			_t,
			_x+dir_x[i],
			_y+dir_y[i],
			_c2
		)
	end
	print(_t,_x,_y,_c)
end

-- function get_rnd(arr)
-- 	return arr[1+flr(rnd(#arr))]
-- end


-- function round(val)
--     if val % 1 > 0.5 then
--         return ceil(val)
--     else 
--         return flr(val)
--     end
-- end

function valid_cell(x,y,is_horizontal)
    if is_horizontal then
        return 
            valid_cordinates(x,y,is_horizontal) and
            (
                board[x][y].carpert.index == 0 and true or not 
                (
                    board[x][y].carpert.index == board[x + 1][y].carpert.index and
                    board[x][y].carpert.dir == 1 and board[x + 1][y].carpert.dir == 2
                )
            )
    else 
        return 
            valid_cordinates(x,y,is_horizontal) and
            (
                board[x][y].carpert.index == 0 and true or not
                (
                    board[x][y].carpert.index == board[x][y + 1].carpert.index and
                    board[x][y].carpert.dir == 3 and board[x][y + 1].carpert.dir == 4
                )
            )
    end
end

function valid_cordinates(x,y,is_horizontal)
    if is_horizontal then
        return 
            x != 1 and 
            x < (col - 1) and 
            y != 1 and 
            y < row
    else 
        return 
            x != 1 and 
            x < col and 
            y != 1 and 
            y < (row - 1)
    end
end