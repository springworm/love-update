--[[ 
	Is only updater
]]

local http = require("socket.http")

-- Draw something for the user to look at
love.graphics.clear(255, 255, 255)
love.graphics.setColor(247, 189, 190)
love.graphics.setNewFont(64)
love.graphics.printf("Updating...", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
love.graphics.present()

local base = "http://24.4.128.81/~spencer/cow-game/"

-- Function for getting table info from web
function getData(url, table)
	local s = http.request(url)
	if s == nil then error() end -- Catch the http failure
	local f = assert(loadstring(s))
	setfenv(f, table)
	f()
end

-- Get installed version, zero otherwise
localVersion = 0
if love.filesystem.exists("love-update/version") then
	localVersion = tonumber(love.filesystem.read("love-update/version"), 10)
end

-- Pull down remote version info
local manifest = {}
if pcall(getData, base.."meta/manifest.lua", manifest) then
	-- Get latest remote version
	local remoteVersion = manifest.versions[#manifest.versions]

	if remoteVersion > localVersion then
		-- Pull down latest version metadata
		getData(base..("meta/manifest-%03d.lua"):format(remoteVersion), manifest)

		-- Make directories for storing it all
		if not love.filesystem.exists("love-update") then love.filesystem.createDirectory("love-update") end

		love.filesystem.createDirectory(("love-update/version-%03d"):format(remoteVersion))

		-- Download the files
		for i, file in ipairs(manifest.files) do
			local contents = http.request(base..("version-%03d/"):format(remoteVersion)..file)
			love.filesystem.write(("love-update/version-%03d/%s"):format(remoteVersion, file), contents)
		end

		-- Write the version number
		love.filesystem.write("love-update/version", remoteVersion)
		localVersion = remoteVersion

	end
else
	-- Crash if no game exists
	if localVersion == 0 then
		error("Failure - no game exists")
	end
end

-- Run the game!
love.filesystem.load(("love-update/version-%03d/main.lua"):format(localVersion))()
