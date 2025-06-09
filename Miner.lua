local Utils = require("Utils")
local Navigation = require("Navigation")

local Miner = {}

function Miner.countNeededBlocks(blocksToMine, blocks)
    local cnt = 0
    for _, block in ipairs(blocks) do
        if blocksToMine[Utils.splitString(block.name, ":")[2]] then
            cnt = cnt + 1
        end
    end
    return cnt
end

function Miner.findClosestBlock(blocksToMine, blocks, startPos)
    local closestBlock = nil
    local min_distance = math.huge

    for _, block in ipairs(blocks) do
        local blockType = Utils.splitString(block.name, ":")[2]
        if blocksToMine[blockType] then
            local distance = Utils.manhattanDist(
                startPos[1], startPos[2], startPos[3],
                block.x, block.y, block.z
            )
            if distance < min_distance then
                min_distance = distance
                closestBlock = block
            end
        end
    end
    return closestBlock
end

function Miner.removeBlockAt(x, y, z, blocks)
    for i = #blocks, 1, -1 do
        if blocks[i].x == x and blocks[i].y == y and blocks[i].z == z then
            table.remove(blocks, i)
            break
        end
    end
end

function Miner.moveToNearestFree(x, y, z, direction, blocks)
    local blockMap = Utils.createBlockMap(blocks)
    local neighbors = {
        {x + 1, y, z, "W"},
        {x - 1, y, z, "E"},
        {x, y + 1, z, "D"},
        {x, y - 1, z, "U"},
        {x, y, z + 1, "N"},
        {x, y, z - 1, "S"}
    }

    for _, neighbor in ipairs(neighbors) do
        local nx, ny, nz, blockDirection = unpack(neighbor)
        if not blockMap[nx..","..ny..","..nz] then
            local success = Navigation.goTo(nx, ny, nz, direction, blocks)
            if success then return {neighbor, {x, y, z}} end
        end
    end
    return nil
end

function Miner.AStarMiner(blocksToMine, blocks, initialDirection, updateStatus, updateProgress)
    local startBlocksLen = Miner.countNeededBlocks(blocksToMine, blocks)
    local dug = 0
    local currentPos = {0, 0, 0}
    local offset = {0, 0, 0}
    local direction = {initialDirection}

    while true do
        local closestBlock = Miner.findClosestBlock(blocksToMine, blocks, offset)
        if not closestBlock then break end

        local currentBlockName = Utils.splitString(closestBlock.name, ":")[2]
        updateStatus("Finding path to "..currentBlockName, colors.black)

        local moveResult = Miner.moveToNearestFree(closestBlock.x, closestBlock.y, closestBlock.z, direction, blocks)
        
        if not moveResult then
            updateStatus("Can't reach "..currentBlockName..", skipping", colors.yellow)
            os.sleep(1)
            Miner.removeBlockAt(closestBlock.x, closestBlock.y, closestBlock.z, blocks)
            dug = dug + 1
            updateProgress(dug / startBlocksLen)
            goto continue
        end

        offset = {moveResult[1][1], moveResult[1][2], moveResult[1][3]}
        updateStatus("Digging "..currentBlockName, colors.black)

        -- Digging logic
        local blockDirection = moveResult[1][4]
        if blockDirection == "U" then
            while turtle.detectUp() do turtle.digUp() end
        elseif blockDirection == "D" then
            while turtle.detectDown() do turtle.digDown() end
        else
            Navigation.turnTo(blockDirection, direction)
            while turtle.detect() do turtle.dig() end
        end

        dug = dug + 1
        Miner.removeBlockAt(moveResult[2][1], moveResult[2][2], moveResult[2][3], blocks)

        -- Update block positions relative to turtle
        for _, block in ipairs(blocks) do
            block.x = block.x - offset[1]
            block.y = block.y - offset[2]
            block.z = block.z - offset[3]
        end

        currentPos[1] = currentPos[1] + offset[1]
        currentPos[2] = currentPos[2] + offset[2]
        currentPos[3] = currentPos[3] + offset[3]
        offset = {0, 0, 0}

        updateProgress(dug / startBlocksLen)
        ::continue::
    end

    return true
end

function Miner.simpleMiner(blocksToMine, blocks, initialDirection, updateStatus, updateProgress)
    local startBlocksLen = Miner.countNeededBlocks(blocksToMine, blocks)
    local dug = 0
    local currentPos = {0, 0, 0}
    local offset = {0, 0, 0}
    local direction = {initialDirection}

    while true do
        local block = Miner.findClosestBlock(blocksToMine, blocks, offset)
        if not block then break end

        local currentBlockName = Utils.splitString(block.name, ":")[2]
        updateStatus("Moving to "..currentBlockName, colors.black)

        -- X axis movement
        if block.x ~= 0 then
            local targetDir = block.x > 0 and "E" or "W"
            Navigation.turnTo(targetDir, direction)
            while offset[1] ~= block.x do
                while turtle.detect() do turtle.dig() end
                offset[1] = offset[1] + (targetDir == "E" and 1 or -1)
                Miner.removeBlockAt(offset[1], offset[2], offset[3], blocks)
                turtle.forward()
            end
        end

        -- Z axis movement
        if block.z ~= 0 then
            local targetDir = block.z > 0 and "S" or "N"
            Navigation.turnTo(targetDir, direction)
            while offset[3] ~= block.z do
                while turtle.detect() do turtle.dig() end
                offset[3] = offset[3] + (targetDir == "S" and 1 or -1)
                Miner.removeBlockAt(offset[1], offset[2], offset[3], blocks)
                turtle.forward()
            end
        end

        -- Y axis movement
        if block.y ~= 0 then
            while offset[2] ~= block.y do
                if block.y > 0 then
                    while turtle.detectUp() do turtle.digUp() end
                    turtle.up()
                else
                    while turtle.detectDown() do turtle.digDown() end
                    turtle.down()
                end
                offset[2] = offset[2] + (block.y > 0 and 1 or -1)
                Miner.removeBlockAt(offset[1], offset[2], offset[3], blocks)
            end
        end

        dug = dug + 1
        for _, block in ipairs(blocks) do
            block.x = block.x - offset[1]
            block.y = block.y - offset[2]
            block.z = block.z - offset[3]
        end

        currentPos[1] = currentPos[1] + offset[1]
        currentPos[2] = currentPos[2] + offset[2]
        currentPos[3] = currentPos[3] + offset[3]
        offset = {0, 0, 0}

        updateProgress(dug / startBlocksLen)
    end

    return true
end

return Miner