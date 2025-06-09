local basalt = require("basalt")
local Utils = require("Utils")

local UI = {}

function UI.create()
    local mainFrame = basalt.createFrame()
    local w, h = term.getSize()

    -- Common header
    mainFrame:newPane()
        :setPosition(1, 1)
        :setSize(w, 1)
        :setBackground(colors.gray)

    mainFrame:newLabel()
        :setText("Geo")
        :setForeground(colors.lime)
        :setPosition(1, 1)

    mainFrame:newLabel()
        :setText("Miner")
        :setForeground(colors.red)
        :setPosition(4, 1)

    -- Menu Bar
    local menubar = mainFrame:newMenubar()
        :setPosition(1, 2)
        :setSize(w, 1)

    local menuItems = {"Fuel", "Scanner", "Blocks", "Miner", "About", "How to use?"}
    for _, item in ipairs(menuItems) do
        menubar:newItem(item)
    end

    -- Frame containers
    local frames = {}
    for _, name in ipairs(menuItems) do
        frames[name] = mainFrame:newScrollableFrame()
            :setBackground(colors.lightGray)
            :setPosition(1, 3)
            :setSize(w, h - 2)
            :hide()
    end
    frames.Fuel:show()

    -- Fuel Frame
    local fuelLabel = frames.Fuel:newLabel()
        :setText("Current fuel level: ")
        :setPosition(2, 2)

    frames.Fuel:newButton()
        :setText("Refuel")
        :setPosition(2, 4)
        :setSize(10, 1)

    -- Scanner Frame
    local scannerFrame = {
        frame = frames.Scanner,
        scanButton = frames.Scanner:newButton()
            :setText("Start scanning")
            :setPosition(2, 2)
            :setSize(16, 1),
        radiusInput = frames.Scanner:newInput()
            :setInputType("number")
            :setSize(4, 1)
            :setPosition(10, 4),
        blocksList = frames.Scanner:newList()
            :setSize(20, h - 4)
            :setPosition(w - 20, 2),
        statusLabel = frames.Scanner:newLabel()
            :setPosition(2, 6)
            :hide()
    }

    -- Blocks Frame
    local blocksFrame = {
        frame = frames.Blocks,
        dropdown = frames.Blocks:newDropdown()
            :setPosition(2, 2)
            :setSize(20, 1),
        addButton = frames.Blocks:newButton()
            :setText("+")
            :setSize(3, 1)
            :setPosition(2, 4),
        removeButton = frames.Blocks:newButton()
            :setText("-")
            :setSize(3, 1)
            :setPosition(7, 4),
        blocksToList = frames.Blocks:newList()
            :setSize(16, h - 4)
            :setPosition(w - 16, 2)
    }

    -- Miner Frame
    local minerFrame = {
        frame = frames.Miner,
        pathfindingCheckbox = frames.Miner:newCheckbox()
            :setPosition(2, 2),
        returnHomeCheckbox = frames.Miner:newCheckbox()
            :setPosition(2, 4),
        directionDropdown = frames.Miner:newDropdown()
            :setPosition(2, 7),
        startButton = frames.Miner:newButton()
            :setText("Start")
            :setPosition(w - 9, 6)
            :setSize(9, 3),
        progressBar = frames.Miner:newProgressbar()
            :setPosition(6, math.floor((h - 3) / 2))
            :setSize(w - 6, 1)
            :hide(),
        statusLabel = frames.Miner:newLabel()
            :setPosition(1, 10)
            :hide(),
        progressLabel = frames.Miner:newLabel()
            :setPosition(2, math.floor((h - 3) / 2))
            :hide()
    }

    -- Add labels and setup dropdowns
    frames.Miner:newLabel()
        :setText("Use pathfinding")
        :setPosition(4, 2)
    frames.Miner:newLabel()
        :setText("Return home")
        :setPosition(4, 4)
    frames.Miner:newLabel()
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