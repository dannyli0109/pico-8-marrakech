pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
entities = {}
function new_entity(componenttable)
    local e = {}
    e.position = componenttable.position or nil
    e.sprite = componenttable.sprite or nil
    e.control = componenttable.control or nil
    e.intention = componenttable.intention or nil
    e.state = componenttable.state or { current= "idle" }
    e.game_state = componenttable.game_state or nil
    e.grid = componenttable.grid or nil
    e.timer = componenttable.timer or nil
    return e
end