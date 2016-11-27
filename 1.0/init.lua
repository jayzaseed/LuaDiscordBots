local timer = require("timer")
local fs = require("fs")
local http1 = require('coro-http')
local http = require('http')
local colorize = require('pretty-print').colorize

local Files = {
	"WeekBot.lua",
	"commands.lua",
	"funciones.lua",
	"help.lua",
}

function WriteFile(file, text, path)
	if path then
		if not fs.existsSync(path) then 
			fs.mkdirSync(path)
			print(path.." folder created.")
		end
		local file = io.open(path.."/"..file, "w")
		file:write(text)
		file:close()
	else
		local file = io.open(file, "w")
		file:write(text)
		file:close()
	end
end

local function Download(name, path)
	coroutine.wrap(function()
		local head, body = http1.request("GET", "http://mrjuicylemon.es/Discordia/"..name)
		WriteFile(name, body, path)
		print(name.." file downloaded succesfully.")
	end)()
end

for _, __ in pairs(Files) do
	Download(__)
end

Download("Week.lua", "WeekBotModules")
coroutine.wrap(function()
	timer.sleep(1500)
	print(colorize('highlight', "Finished downloading.\nNow you can start the bot.\n'luvit WeekBot'."))
end)()
