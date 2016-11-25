WhichDay = os.date("%a")
date = require("WeekBotModules/Week")

return {
	["!fact"] = {
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
		["color"] = date[WhichDay].color,
		["fields"] = {
			{
				name = "Available help commands", 
				value =  "!help !fact\n!help !help.",
				inline = false
			},
		},
	},
}
