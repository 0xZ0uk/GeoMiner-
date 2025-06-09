local BASE_URL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/"  -- Update this URL

local files = {
    "Utils.lua",
    "Scanner.lua",
    "Navigation.lua",
    "Miner.lua",
    "UI.lua",
    "Main.lua",
}

local function downloadFile(filename)
    local url = BASE_URL .. filename
    local response = http.get(url)
    
    if not response then
        printError("Failed to download " .. filename)
        return false
    end
    
    local handle = fs.open(filename, "w")
    handle.write(response.readAll())
    handle.close()
    return true
end

local function main()
    print("GeoMiner Installation")
    print("---------------------")
    
    local successCount = 0
    for _, file in ipairs(files) do
        write("Downloading " .. file .. "... ")
        if fs.exists(file) then
            print("Already exists (use --force to overwrite)")
        else
            if downloadFile(file) then
                print("Success")
                successCount = successCount + 1
            else
                print("Failed")
            end
        end
    end
    
    print("\nInstallation complete!")
    print(successCount .. "/" .. #files .. " files successfully installed")
    print("\nTo start the program, run:")
    print("lua Main.lua")
end

local args = {...}
if args[1] == "--force" then
    print("Forcing clean installation...")
    for _, file in ipairs(files) do
        if fs.exists(file) then
            fs.delete(file)
        end
    end
end

main()