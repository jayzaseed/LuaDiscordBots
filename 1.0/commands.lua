return {
	["!restart"] = function(message, client)
		if message.author.id == "191442101135867906" then
			message.channel:sendMessage("Okay, give me a second.")
			client:stop()
		else
			func.Restricted(message)
		end
	end,
	["!fact"] = function(message, number, fact)
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
	end,
}
