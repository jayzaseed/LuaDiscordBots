func = require("funciones")

WhichDay = os.date("%a")
date = require("WeekBotModules/Week")

local Promote = "[Add me to your server!]('https://discordapp.com/oauth2/authorize?client_id=250995355653505024&scope=bot&permissions=0')"

return {
	["!fact"] = {
		["description"] = Promote, 
		["color"] = date[WhichDay].color,
		["fields"] = {
			{
				name = "!fact", 
				value =  "Typing !fact will make me send you a random fact from the current day!",
				inline = false
			},
		},
	},
	["!help"] = {
		["description"] = Promote, 
		["color"] = date[WhichDay].color,
		["fields"] = {
			{
				name = "!help", 
				value =  "I will send you the information about my commands.",
				inline = false
			},
		},
	},
	["empty"] = {
		["description"] = Promote, 
		["color"] = date[WhichDay].color,
		["fields"] = {
			{
				name = "Available help commands", 
				value =  "!help !fact\n!help !help",
				inline = false
			},
		},
	},
}
