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

-- Pull down version info
local manifest = {} 
do
	local s = http.request(base.."meta/manifest.lua")
	local f = assert(loadstring(s))
	setfenv(f, manifest)
	f()
end

-- Get installed version, zero otherwise
localVersion = 0
if love.filesystem.exists("love-update/version") then
	localVersion = tonumber(love.filesystem.read("love-update/version"), 10)
end

if not #manifest == 0 then
	-- Get latest remote version
	local remoteVersion = manifest.versions[#manifest.versions]

	if remoteVersion > localVersion then
		-- Pull down latest version metadata
		do
			local s = http.request(base..("meta/manifest-%03d.lua"):format(remoteVersion))
			local f = assert(loadstring(s))
			setfenv(f, manifest)
			f()
		end

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
end

love.filesystem.load(("love-update/version-%03d/main.lua"):format(localVersion))()
