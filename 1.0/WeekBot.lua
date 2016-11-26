local discordia = require('discordia')
local timer = require("timer")
local func = require("funciones")
local help = require("help")
local base64 = require('base64')
local Http = require('coro-http')
local client = discordia.Client()


local function RandomFact(table)
	assert(type(table) == "table", "RandomFact: table expected.")
	if table then
		local randomed = math.random(1, #table)
		return randomed, table[randomed]
	end
end

local function read_file(path)
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

local function UpdateBot(avatar, status)
	coroutine.wrap(function()
		local success, result = pcall(function()
			local _, av = Http.request("GET", avatar)
			client:setAvatar("data:image/png;base64,"..base64.encode(av))
			client:setGameName(status)
		end)
		if success then
			WriteFile("WeekBotModules","WeekBotAvatar", date[WhichDay].avatar)
			print("Successfully changed the avatar.")
			print("Successfully changed the status.")
		else
			print(result)
		end
	end)()
end


client:on("ready", function()
	for guild in client.guilds do
		p(func.ts(guild))
	end
	if read_file("WeekBotModules/WeekBotAvatar.txt") ~= date[WhichDay].avatar then
		UpdateBot(date[WhichDay].avatar, date[WhichDay].status)
	else
		print("Bot was not updated as it was already.")
	end
end)

client:on("messageCreate", function(message)
	if not message or message.author == client.user then return end

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if message.content == "!fact" then

		local number, fact = RandomFact(date[WhichDay].facts)
		-- I'm using a modified sendMessage
		message.channel:sendMessage(" ", {
			["color"] = date[WhichDay].color,
			["fields"] = {
				{
					name = "Fact #"..number, 
					value = fact, 
					inline = false
				},
			},
		}) 
	end

	if cmd == "!help" then
		message.channel:sendMessage(" ", help[arg] or help["empty"])
	end

	if message.author.id == "191442101135867906" then
		if func.l(message.content) == "update" then
			message.channel:sendMessage("Updating myself...")
			UpdateBot(date[WhichDay].avatar, date[WhichDay].status)
		end
		if func.l(message.content) == "restart" then
			message.channel:sendMessage("Okay, give me a second.")
			client:stop()
		end
	end
end)


client:run(read_file("WeekBotModules/token.txt"))
