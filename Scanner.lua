local Scanner = {}
local Utils = require("Utils")

Scanner.scanner = peripheral.find("geoScanner")
Scanner.blocks = {}
Scanner.blocksNamesSet = {}

function Scanner.scan(radius)
    if not Scanner.scanner then return nil, "Scanner not attached" end
    if Scanner.scanner.cost(radius) > turtle.getFuelLevel() then
        return nil, "Not enough fuel"
    end
    Scanner.blocks = Scanner.scanner.scan(radius)
    Scanner.blocksNamesSet = {}
    for _, block in ipairs(Scanner.blocks) do
        local name = Utils.splitString(block.name, ":")[2]
        Scanner.blocksNamesSet[name] = true
    end
    return Scanner.blocks
end

function Scanner.getBlocks() return Scanner.blocks end
function Scanner.getBlockTypes() return Scanner.blocksNamesSet end

return Scanner