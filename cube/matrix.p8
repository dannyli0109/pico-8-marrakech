pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

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
        assert(m.col == other.row , 'The target matrix\'s row must equals to the col of the matrix')
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
        assert(m.row == 1 and m.col >= 4, "row needs to be 1 to convert to a vec 3d")
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

    m.print = function()
        for i=1,row do
            local line = ""
            for j = 1,col do
                line = line.." "..m.m[i][j]
            end
            print(line)
        end 

    end
    return m
end
