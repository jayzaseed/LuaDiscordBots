local discordia = require('discordia')
local timer = require("timer")
local func = require("funciones")
local help = require("help")
local base64 = require('base64')
local Http = require('coro-http')
local client = discordia.Client()

date = require("WeekBotModules/"..os.date("%a"))

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

local function IntervalCheck(day)
	timer.setInterval(60000, function()
		if day ~= os.date("%a") then
			print("Woops, new day!!!!")
			client:stop()
		end
	end)
end

local function UpdateBot(avatar, status)
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

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if message.content == "!fact" then

		local number, fact = RandomFact(date.facts)
		-- I'm using a modified sendMessage
		message.channel:sendMessage(" ", {
			["color"] = date.color,
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
		if arg == nil then
			message.channel:sendMessage(" ",{
				["color"] = date.color,
				["fields"] = {
					{
						name = "What do you need help in?", 
						value = "!help !fact ??",
						inline = false
					},
				},
			})
		elseif arg == "!fact" then
			message.channel:sendMessage(" ",{
				["color"] = date.color,
				["fields"] = {
					{
						name = arg, 
						value =  help[arg],
						inline = false
					},
				},
			})
		elseif arg == "!help" then
			message.channel:sendMessage(" ",{
				["color"] = date.color,
				["fields"] = {
					{
						name = arg, 
						value =  help[arg],
						inline = false
					},
				},
			})
		end
	end

	if message.author.id == "191442101135867906" then
		if func.l(message.content) == "update" then
			message.channel:sendMessage("Updating myself...")
			UpdateBot(date.avatar, date.status)
		end
		if message.content == "Restart" then
			message.channel:sendMessage("Okay, give me a second.")
			client:stop()
		end
	end
end)

