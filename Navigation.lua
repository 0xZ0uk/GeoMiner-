local Utils = require("Utils")

local Navigation = {}

function Navigation.aStar(start, goal, blockMap)
    local openSet = {[table.concat(start, ",")] = true}
    local cameFrom = {}
    local gScore = {[table.concat(start, ",")] = 0}
    local fScore = {[table.concat(start, ",")] = Utils.manhattanDist(start[1], start[2], start[3], goal[1], goal[2], goal[3])}

    while next(openSet) do
        local current, currentFScore = nil, math.huge
        for node in pairs(openSet) do
            if fScore[node] < currentFScore then
                current = node
                currentFScore = fScore[node]
            end
        end

        local curPos = {}
        for num in string.gmatch(current, "-?%d+") do
            table.insert(curPos, tonumber(num))
        end

        if curPos[1] == goal[1] and curPos[2] == goal[2] and curPos[3] == goal[3] then
            local path = {}
            while current do
                local pos = {}
                for num in string.gmatch(current, "-?%d+") do
                    table.insert(pos, tonumber(num))
                end
                table.insert(path, 1, pos)
                current = cameFrom[current]
            end
            return path
        end

        openSet[current] = nil

        local neighbors = {
            {curPos[1] + 1, curPos[2], curPos[3]},
            {curPos[1] - 1, curPos[2], curPos[3]},
            {curPos[1], curPos[2] + 1, curPos[3]},
            {curPos[1], curPos[2] - 1, curPos[3]},
            {curPos[1], curPos[2], curPos[3] + 1},
            {curPos[1], curPos[2], curPos[3] - 1}
        }

        for _, neighbor in ipairs(neighbors) do
            local neighborKey = table.concat(neighbor, ",")
            if not blockMap[neighborKey] then
                local tentativeGScore = gScore[current] + 1
                if not gScore[neighborKey] or tentativeGScore < gScore[neighborKey] then
                    cameFrom[neighborKey] = current
                    gScore[neighborKey] = tentativeGScore
                    fScore[neighborKey] = tentativeGScore + Utils.manhattanDist(
                        neighbor[1], neighbor[2], neighbor[3], 
                        goal[1], goal[2], goal[3]
                    )
                    openSet[neighborKey] = true
                end
            end
        end
        os.sleep(0.05)
    end
    return nil
end

function Navigation.moveTurtle(path, direction)
    local directions = {["N"] = 0, ["E"] = 1, ["S"] = 2, ["W"] = 3}
    for i = 2, #path do
        local cur, next = path[i-1], path[i]
        local dir = Utils.directionFromTo(cur[1], cur[2], cur[3], next[1], next[2], next[3])

        if dir == "up" then
            while turtle.detectUp() do turtle.digUp() end
            turtle.up()
        elseif dir == "down" then
            while turtle.detectDown() do turtle.digDown() end
            turtle.down()
        else
            local targetDirection = directions[dir]
            local currentDirection = directions[direction[1]]

            local turn_steps = (targetDirection - currentDirection) % 4
            if turn_steps == 3 then
                turtle.turnLeft()
            elseif turn_steps == 1 then
                turtle.turnRight()
            elseif turn_steps == 2 then
                turtle.turnRight()
                turtle.turnRight()
            end

            direction[1] = dir
            while turtle.detect() do turtle.dig() end
            turtle.forward()
        end
    end
end

function Navigation.turnTo(newDirection, currentDirection)
    local dirMap = {["N"] = 0, ["E"] = 1, ["S"] = 2, ["W"] = 3}
    local current = dirMap[currentDirection[1]]
    local target = dirMap[newDirection]

    local diff = (target - current) % 4
    if diff == 1 then
        turtle.turnRight()
    elseif diff == 2 then
        turtle.turnRight()
        turtle.turnRight()
    elseif diff == 3 then
        turtle.turnLeft()
    end
    currentDirection[1] = newDirection
end

function Navigation.goTo(x, y, z, direction, blocks)
    local start = {0, 0, 0}
    local goal = {x, y, z}
    local blockMap = Utils.createBlockMap(blocks)
    local path = Navigation.aStar(start, goal, blockMap)
    
    if path then
        Navigation.moveTurtle(path, direction)
        return true
    end
    return false
end

return Navigation