_G.discordia = require('discordia')
_G.timer = require("timer")
_G.base64 = require('base64')
_G.Http = require('coro-http')
_G.client = discordia.Client()

date = require("WeekBotModules/"..os.date("%a"))

function UpdateBot(avatar, status)
	coroutine.wrap(function()
		local success, result = pcall(function()
			local _, av = Http.request("GET", avatar)
			client:setAvatar("data:image/png;base64,"..base64.encode(av))
			client:setGameName(status)
		end)
		if success then
			WriteFile("WeekBotModules","WeekBotAvatar", date.avatar)
			print("Successfully changed the avatar.")
			print("Successfully changed the status.")
		else
			print(result)
		end
	end)()
end

function RandomFact(table)
	assert(type(table) == "table", "RandomFact: table expected.")
	if table then
		local randomed = math.random(1, #table)
		return randomed, table[randomed]
	end
end

function read_file(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*a"
	file:close()
	return content
end

function WriteFile(path, file, text)
	local file = io.open(path.."/"..file..".txt", "w")
	file:write(text)
	file:close()
end

function IntervalCheck(day)
	timer.setInterval(60000, function()
		if day ~= os.date("%a") then
			print("Woops, new day!!!!")
			client:stop()
		end
	end)
end


client:on("ready", function()
	date:Init() -- Start the module of today's day
	if read_file("WeekBotModules/WeekBotAvatar.txt") ~= date.avatar then
		UpdateBot(date.avatar, date.status)
	else
		print("Bot was not updated as it was already.")
	end
	IntervalCheck(os.date("%a"))
end)

client:on("messageCreate", function(message)
	if not message or message.author == client.user then return end
	if message.content == "!fact" then
		local number, fact = RandomFact(date.facts)
		
		-- I'm using a modified sendMessage
		message.channel:sendMessage(" ", {
			["color"] = date.color,
			["fields"] = {
				{name = "Fact #"..number, value = fact, inline = false},
			},
		}) 
	end	

end)
