local Utils = {}

function Utils.getSetLen(set)
    local ret = 0
    for _ in pairs(set) do ret = ret + 1 end
    return ret
end

function Utils.splitString(input, delimiter)
    if not delimiter then delimiter = "%s" end
    local t = {}
    for str in string.gmatch(input, "([^"..delimiter.."]+)") do
        table.insert(t, str)
    end
    return t
end

function Utils.manhattanDist(x1, y1, z1, x2, y2, z2)
    return math.abs(x1 - x2) + math.abs(y1 - y2) + math.abs(z1 - z2)
end

function Utils.directionFromTo(x1, y1, z1, x2, y2, z2)
    if x1 < x2 then return "E"
    elseif x1 > x2 then return "W"
    elseif z1 < z2 then return "S"
    elseif z1 > z2 then return "N"
    elseif y1 < y2 then return "up"
    elseif y1 > y2 then return "down" end
end

function Utils.createBlockMap(blocks)
    local map = {}
    for _, block in ipairs(blocks) do
        if block.name ~= "minecraft:air" and block.name ~= "computercraft:turtle_advanced" then
            map[block.x..","..block.y..","..block.z] = true
        end
    end
    return map
end

return Utils