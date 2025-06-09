local basalt = require("basalt")
local Utils = require("Utils")

local UI = {}

function UI.create()
    local mainFrame = basalt.createFrame()
    local w, h = term.getSize()
    
    -- Common header
    mainFrame:addPane()
        :setPosition(1, 1)
        :setSize(w, 1)
        :setBackground(colors.gray)
    
    mainFrame:addLabel()
        :setText("Geo")
        :setForeground(colors.lime)
        :setPosition(1, 1)
    
    mainFrame:addLabel()
        :setText("Miner")
        :setForeground(colors.red)
        :setPosition(4, 1)

    -- Menu Bar
    local menubar = mainFrame:addMenubar()
        :setPosition(1, 2)
        :setSize(w, 1)
    
    local menuItems = {"Fuel", "Scanner", "Blocks", "Miner", "About", "How to use?"}
    for _, item in ipairs(menuItems) do
        menubar:addItem(item)
    end

    -- Frame containers
    local frames = {}
    for _, name in ipairs(menuItems) do
        frames[name] = mainFrame:addScrollableFrame()
            :setBackground(colors.lightGray)
            :setPosition(1, 3)
            :setSize(w, h - 2)
            :hide()
    end
    frames.Fuel:show()
    
    -- Fuel Frame
    local fuelLabel = frames.Fuel:addLabel()
        :setText("Current fuel level: ")
        :setPosition(2, 2)
    
    frames.Fuel:addButton()
        :setText("Refuel")
        :setPosition(2, 4)
        :setSize(10, 1)

    -- Scanner Frame
    local scannerFrame = {
        frame = frames.Scanner,
        scanButton = frames.Scanner:addButton()
            :setText("Start scanning")
            :setPosition(2, 2)
            :setSize(16, 1),
        radiusInput = frames.Scanner:addInput()
            :setInputType("number")
            :setSize(4, 1)
            :setPosition(10, 4),
        blocksList = frames.Scanner:addList()
            :setSize(20, h - 4)
            :setPosition(w - 20, 2),
        statusLabel = frames.Scanner:addLabel()
            :setPosition(2, 6)
            :hide()
    }

    -- Blocks Frame
    local blocksFrame = {
        frame = frames.Blocks,
        dropdown = frames.Blocks:addDropdown()
            :setPosition(2, 2)
            :setSize(20, 1),
        addButton = frames.Blocks:addButton()
            :setText("+")
            :setSize(3, 1)
            :setPosition(2, 4),
        removeButton = frames.Blocks:addButton()
            :setText("-")
            :setSize(3, 1)
            :setPosition(7, 4),
        blocksToList = frames.Blocks:addList()
            :setSize(16, h - 4)
            :setPosition(w - 16, 2)
    }

    -- Miner Frame
    local minerFrame = {
        frame = frames.Miner,
        pathfindingCheckbox = frames.Miner:addCheckbox()
            :setPosition(2, 2),
        returnHomeCheckbox = frames.Miner:addCheckbox()
            :setPosition(2, 4),
        directionDropdown = frames.Miner:addDropdown()
            :setPosition(2, 7),
        startButton = frames.Miner:addButton()
            :setText("Start")
            :setPosition(w - 9, 6)
            :setSize(9, 3),
        progressBar = frames.Miner:addProgressbar()
            :setPosition(6, math.floor((h - 3) / 2))
            :setSize(w - 6, 1)
            :hide(),
        statusLabel = frames.Miner:addLabel()
            :setPosition(1, 10)
            :hide(),
        progressLabel = frames.Miner:addLabel()
            :setPosition(2, math.floor((h - 3) / 2))
            :hide()
    }

    -- Add labels and setup dropdowns
    frames.Miner:addLabel()
        :setText("Use pathfinding")
        :setPosition(4, 2)
    frames.Miner:addLabel()
        :setText("Return home")
        :setPosition(4, 4)
    frames.Miner:addLabel()
        :setText("Direction:")
        :setPosition(2, 6)
    
    local directions = {"South", "North", "East", "West"}
    for _, dir in ipairs(directions) do
        minerFrame.directionDropdown:addItem(dir)
    end

    -- About and How to use frames (content omitted for brevity)
    
    return {
        main = mainFrame,
        frames = frames,
        scanner = scannerFrame,
        blocks = blocksFrame,
        miner = minerFrame,
        fuel = fuelLabel
    }
end

return UI