local basalt = require("basalt")
local Utils = require("Utils")
local Scanner = require("Scanner")
local Miner = require("Miner")
local UI = require("UI")

-- Initialize components
local ui = UI.create()
local blocksToMine = {}
local currentDirection = {"S"}

-- Fuel management
local function updateFuel()
    while true do
        ui.fuel:setText("Current fuel level: "..turtle.getFuelLevel())
        os.sleep(1)
    end
end

-- Scanner handling
ui.scanner.scanButton:onClick(function()
    local radius = tonumber(ui.scanner.radiusInput:getValue())
    if not radius or radius < 1 or radius > 16 then
        ui.scanner.statusLabel:show()
            :setText("Invalid radius (1-16)")
            :setForeground(colors.red)
        return
    end
    
    local blocks, err = Scanner.scan(radius)
    if not blocks then
        ui.scanner.statusLabel:show()
            :setText(err)
            :setForeground(colors.red)
        return
    end
    
    ui.scanner.blocksList:clear()
    ui.blocks.dropdown:clear()
    ui.blocks.blocksToList:clear()
    
    for _, block in ipairs(blocks) do
        local name = Utils.splitString(block.name, ":")[2]
        ui.scanner.blocksList:addItem(name.." "..block.x.." "..block.y.." "..block.z)
        if not blocksToMine[name] then
            ui.blocks.dropdown:addItem(name)
        end
    end
    ui.scanner.statusLabel:show()
        :setText("Scanned "..tostring(#blocks).." blocks")
        :setForeground(colors.lime)
end)

-- Blocks management
ui.blocks.addButton:onClick(function()
    local selected = ui.blocks.dropdown:getItem(ui.blocks.dropdown:getItemIndex()).text
    if not blocksToMine[selected] then
        blocksToMine[selected] = true
        ui.blocks.blocksToList:addItem(selected)
    end
end)

ui.blocks.removeButton:onClick(function()
    local selected = ui.blocks.blocksToList:getItem(ui.blocks.blocksToList:getItemIndex()).text
    blocksToMine[selected] = nil
    ui.blocks.blocksToList:removeItem(ui.blocks.blocksToList:getItemIndex())
end)

-- Miner control
ui.miner.startButton:onClick(function()
    if Utils.getSetLen(blocksToMine) == 0 then
        ui.miner.statusLabel:show()
            :setText("Select blocks to mine first!")
            :setForeground(colors.red)
        return
    end
    
    -- Hide UI elements
    ui.miner.startButton:hide()
    ui.miner.directionDropdown:hide()
    ui.miner.pathfindingCheckbox:hide()
    ui.miner.returnHomeCheckbox:hide()
    ui.miner.statusLabel:show()
    ui.miner.progressBar:show()
    ui.miner.progressLabel:show()
    
    -- Get mining parameters
    local usePathfinding = ui.miner.pathfindingCheckbox:getValue()
    local returnHome = ui.miner.returnHomeCheckbox:getValue()
    local selectedDir = string.sub(ui.miner.directionDropdown:getItem(1).text, 1, 1)
    currentDirection[1] = selectedDir
    
    -- Setup progress handlers
    local function updateStatus(text, color)
        ui.miner.statusLabel:setText(text):setForeground(color)
    end
    
    local function updateProgress(percent)
        local pct = math.floor(percent * 100)
        ui.miner.progressBar:setProgress(pct)
        ui.miner.progressLabel:setText(pct.."%")
    end
    
    -- Start mining thread
    local miningFunction = usePathfinding and Miner.AStarMiner or Miner.simpleMiner
    main:addThread():start(function()
        miningFunction(
            blocksToMine,
            Scanner.getBlocks(),
            selectedDir,
            updateStatus,
            updateProgress
        )
        
        if returnHome then
            updateStatus("Returning home...", colors.black)
            -- Implement return home logic
        end
        
        -- Restore UI
        ui.miner.startButton:show()
        ui.miner.directionDropdown:show()
        ui.miner.pathfindingCheckbox:show()
        ui.miner.returnHomeCheckbox:show()
        ui.miner.statusLabel:hide()
        ui.miner.progressBar:hide()
        ui.miner.progressLabel:hide()
    end)
end)

-- Start system threads
main:addThread():start(updateFuel)
basalt.autoUpdate()