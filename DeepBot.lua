-- some functions (the ones with _G.) were taken from https://gitlab.com/McModder/answernator# ;)
local discordia = require('discordia')
local colorize = require('pretty-print').colorize
local fs = require("fs")
_G.timer = require("timer")
local http = require('http')
local json = require("json")
local http1 = require('coro-http')
require("table2")
require("lib/utf8")
require("lib/utf8data")
local client = discordia.Client:new()

function date()
	return os.date("[%d.%m.%y][%X]")
end

function printLog( text, logType ) -- pretty logs print
  logType = string.upper(logType or "INFO")
  local logColors = { INFO = "string", LOG = "string", WARN = "highlight", DEBUG= "highlight", ERR = "err", ERROR= "err", FAIL = "failure", FAILURE = "failure"}
  print(colorize(logColors[logType] or "string", "'"..date().."["..logType.."] "..text.."'"))
  local logfile = io.open("bot.log", "a")
  if logfile then
    logfile:write(date().."["..logType.."] "..text.."\n")
    logfile:close()
  else
    print(colorize('failure', "'"..date().."[ERR] Can't open log file!'"))
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

function AddToFile(path, file, text)
	local TeamsFile = io.open(path.."/"..file..".txt", "a")
	TeamsFile:write(text.."\n")
	TeamsFile:close()
end


-- PONER UN LOOP EN SERVERCONFIGURATION Y PONER: QUIEN TIENE PERMISOS PARA MANEJARLO OWNER + DEEPBOTGUIDES

client:on('memberJoin', function(member)
	local carpeta = "serverData/"..member.server.id.."/"
	local serverConfig = carpeta.."ServerConfig/"
	if not fs.existsSync(serverConfig.."Welcome.txt") then
		member.server.owner:sendMessage("You didn't configure yet my welcome message :(\nPlease run .Welcome HereAllTheWelcomeMessageYouWantForNewUsers.")
	else
		member:sendMessage(read_file(serverConfig.."Welcome.txt"))
	end
end)



client:on('serverCreate', function(newServer)
	if not newServer then return end

	local carpeta = "serverData/"..newServer.id.."/"
	local serverConfig = carpeta.."ServerConfig/"

	if not fs.existsSync("serverData/"..newServer.id) then 
		print("new folder for "..newServer.name)  
		fs.mkdirSync("serverData/"..newServer.id)
		newServer.owner:sendMessage("New server I see... Steps to configure me:\n```Markdown\n#Run\n.ServerConfiguration to see all the configured data\n<<.Logs ChannelID>> to set up the channel for my moderating logs.\n<<.MuteRank RankName>> to set up the default rank when muting someone... \nSay in your server .help and I'll show you all of me ;)\n\n To give other mods access to the moderating commands you will have to create a role called 'DeepBotGuide' and give it to them. (you will need this role aswell).\n```")
	end
	if not fs.existsSync(carpeta.."ServerConfig") then
		fs.mkdirSync(carpeta.."ServerConfig")
		printLog("Carpeta Server config creada en "..newServer.name, "INFO")
	end
	if not fs.existsSync(serverConfig.."Logs.txt") then
		local emptyFile = io.open(serverConfig.."Logs.txt", "w")
		emptyFile:close()
		printLog("Archivo Logs.txt creado en "..newServer.name, "INFO")
	end
	if not fs.existsSync(serverConfig.."MuteRank.txt") then
		local emptyFile = io.open(serverConfig.."MuteRank.txt", "w")
		emptyFile:close()
		printLog("Archivo MuteRank.txt creado en "..newServer.name, "INFO")
	end
	if not fs.existsSync(serverConfig.."Welcome.txt") then
		local emptyFile = io.open(serverConfig.."Welcome.txt", "w")
		emptyFile:close()
		printLog("Archivo Welcome.txt creado en "..newServer.name, "INFO")
	end
	if not fs.existsSync(carpeta.."Teams") then
		printLog("Carpeta Teams creada en "..newServer.name, "INFO")
		fs.mkdirSync(carpeta.."Teams")
	end
	if not fs.existsSync(carpeta.."Teams/Discorders.txt") then
		local emptyFile = io.open(carpeta.."Teams/Discorders.txt", "w")
		emptyFile:close()
		printLog("Archivo Discorders.txt creado en "..newServer.name, "INFO")
	end
	if not fs.existsSync(carpeta.."Teams/Rioters.txt") then
		local emptyFile = io.open(carpeta.."Teams/Rioters.txt", "w")
		emptyFile:close()
		printLog("Archivo Rioters.txt creado en "..newServer.name, "INFO")
	end
end)


client:on(
	'ready', 
	function()
		p(string.format('Logged in as %s', client.user.username))
		client:setGameName("mrjuicylemon.es/deepBot/")
		for k, server in pairs(client.servers) do
			--p(k)
			if read_file("serverData/"..server.id.."/ServerConfig/Logs.txt") ~= nil then
				--server:getChannelById(read_file("serverData/"..server.id.."/ServerConfig/Logs.txt")):sendMessage("@here\nI received a new update, Mute, kick and ban commands are fixed now.")
			end
		end
end)


client:on("messageCreate", function(message)
	if message.server == nil then return end
	local carpeta = "serverData/"..message.server.id.."/"
	local serverConfig = carpeta.."ServerConfig/"
	local Teams = carpeta.."Teams/"

	_G.sendAndDelete = function( channel, message, Ttimer )
	  	Ttimer = Ttimer or 3000
	  	local Tmessage = channel:sendMessage(message)
	  	if Tmessage then
	    	timer.setTimeout(Ttimer, coroutine.wrap(function()
	      		Tmessage:delete()
	    	end))
	  	end
	end
	_G.TempMute = function(who, time)
	  	unMuteTime = time * 60000
	  	local Roles = {}
	    timer.setTimeout(unMuteTime, coroutine.wrap(function()
			who:setRoles(Roles)
			message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage(who.name.." was UnTempMuted.")
	    end))
	end

	function HasRole(who)
		for _, ids in pairs(who.roles) do
		  if ids.name:find("Guide") then
		    return true
		  end
		end
	end

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if cmd == ".help" then
		message.author:sendMessage("```Markdown\n#Mod Commands:\n\n .add @someone Role\n .mute @someone Reason  \n .unmute @someone \n .banList \n .prune NumberOfMessages\n .kick @someone Reason\n .ban @someone Reason\n .tempMute @someone TimeInMinutes\n .Welcome WelcomingMessage\n\n```<@"..message.author.id..">\n")
		message.channel:sendMessage("Check PM.")
	end

	if message.author == client.user then return end

	if cmd == ".join" then
		for dUser in io.lines(Teams.."Discorders.txt") do
		for rUser in io.lines(Teams.."Rioters.txt") do
			print(rUser.." "..dUser)
  			if dUser == message.author.id or rUser == message.author.id then
  				message.channel:sendMessage("```\nYou are already in a team.\n```")
  				return
  			end
  		end
  		end
		if arg:find("corders") then
			AddToFile(Teams, "Discorders", message.author.id)
			message.channel:sendMessage("```\n"..message.author.username.." has joined Discorders team, Good Luck!\n```")
		elseif arg:find("oters") then
			AddToFile(Teams, "Rioters", message.author.id)
			message.channel:sendMessage("```\n"..message.author.username.." has joined Rioters team, Good Luck!\n```")
		end
	end

	if cmd == ".add" then
		local theRole = string.match(arg, "<@[%d]+> (.*)")
		Roles = {}
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, role in pairs(message.server.roles) do
				if theRole:find(role.name) then
					table.insert(Roles, role)
				end
			end
			for _, member in pairs(message.mentions.members) do
				for _, role in pairs(member.roles) do
					table.insert(Roles, role)
				end
				message.channel:sendMessage("<@"..message.author.id.."> granted **"..theRole.."** role to: **"..member.name.."** at "..date().." (GMT+1).")
				member:setRoles(Roles)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end

	if cmd == ".banList" then
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			local str = ''
			for _, user in pairs(message.server:getBannedUsers()) do
			  str = str .. user.username .."\n"
			end
			message.author:sendMessage(str)
			message.channel:sendMessage("List PMed") 
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end

	if message.content == ".ServerConfiguration" then
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			if not fs.existsSync(carpeta.."ServerConfig") then
				message.channel:sendMessage("Server configuration folder not found, creating folder...")
				fs.mkdirSync(carpeta.."ServerConfig")
				message.channel:sendMessage("Done. Run this command again.")
			else
				if not fs.existsSync(serverConfig.."Logs.txt") then
					message.channel:sendMessage("Logs channel file not found, creating empty file...")
					local emptyFile = io.open(serverConfig.."Logs.txt", "w")
					emptyFile:close()
					message.channel:sendMessage("Done.\nTo configure properly this file, please use the following command:\n\n.``Logs ChannelIDHere``    :    Example: .Logs 225510824607875072")
					message.channel:sendMessage("This will set up a channel for the logs of this bot, everytime he bans, kicks, mutes someone it will be written down there.")
				else
					logChannel = read_file(serverConfig.."Logs.txt")
					message.channel:sendMessage("```Markdown\nServer Owner: "..message.server.owner.username.."\n#Logs Channel:\n<<"..logChannel..">>\n```")
				end
				if not fs.existsSync(serverConfig.."MuteRank.txt") then
					message.channel:sendMessage("\nMuteRank file not found, creating empty file...")
					local emptyFile = io.open(serverConfig.."MuteRank.txt", "w")
					emptyFile:close()
					message.channel:sendMessage("Done.\nTo configure properly this file, please use the following command:\n\n``.MuteRank RoleName``    :    Example: .MuteRank Muted   REMEMBER that this role MUST exist.")
					message.channel:sendMessage("This will set up a channel for the logs of this bot, everytime he bans, kicks, mutes someone it will be written down there.")
				else
					DefMuted = read_file(serverConfig.."MuteRank.txt")
					message.channel:sendMessage("```Markdown\n#Default Mute Rank:\n<<"..DefMuted..">>\n```")
				end
				if not fs.existsSync(serverConfig.."Welcome.txt") then
					message.channel:sendMessage("\nWelcome file not found, creating empty file...")
					local emptyFile = io.open(serverConfig.."Welcome.txt", "w")
					emptyFile:close()
					message.channel:sendMessage("Done.\nTo configure properly this file, please use the following command:\n\n``.Welcome Message``    :    Example:  ``.Welcome Hey new user, welcome!``")
				else
					WelMess = read_file(serverConfig.."Welcome.txt")
					message.channel:sendMessage("```Markdown\n#Welcome message:\n<<"..WelMess..">>\n```")
				end
			end
		else
			message.channel:sendMessage(":x: You don't have permissions to run this command :x:")
		end
	end
	if cmd == ".Logs" then
		id = arg
		if message.author.id == message.server.owner.id or message.author.id == "191442101135867906" then
			if id == nil then 
				message.channel:sendMessage("```\nSyntax to run this command properly:\n.Logs ChannelID  --- This will create a file with the ChannelID set where the logs will be sent.\n```")
				return 
			end
			if not fs.existsSync(serverConfig.."Logs.txt") then
				message.channel:sendMessage("Logs channel file not found, creating empty file...\nPlease run this command again.")
				local emptyFile = io.open(serverConfig.."Logs.txt", "w")
				emptyFile:close()
			else
				if not id:find("%d") then
					message.channel:sendMessage("Please enter a valid ID.")
					return
				else
					WriteFile(serverConfig, "Logs", id)
					message.channel:sendMessage("Logs channel was set up in the channel with the following ID: "..id)
					printLog("Logs added to channel: "..id.." from server: "..message.server.name)
				end
			end
		else
			message.channel:sendMessage(":x: Only the owner of the server can run this command. :x:")
		end
	end
	if cmd == ".Welcome" then
		Message = arg
		if message.author.id == message.server.owner.id or message.author.id == "191442101135867906" then
			if Message == nil then 
				message.channel:sendMessage("```\nSyntax to run this command properly:\n.Welcome Message  --- This will set up a welcome message for every new user.\n```")
				return 
			end
			if not fs.existsSync(serverConfig.."Welcome.txt") then
				message.channel:sendMessage("Welcome file not found, creating empty file...\nPlease run this command again.")
				local emptyFile = io.open(serverConfig.."Welcome.txt", "w")
				emptyFile:close()
			else
				WriteFile(serverConfig, "Welcome", Message)
				message.channel:sendMessage("Welcome message was set up, this is your new welcome message: "..Message)
				printLog("New welcome message: "..Message.." from server: "..message.server.name)
			end
		else
			message.channel:sendMessage(":x: Only the owner of the server can run this command. :x:")
		end
	end
	if cmd == ".MuteRank" then
		id = arg
		if message.author.id == message.server.owner.id or message.author.id == "191442101135867906" then
			if id == nil then 
				message.channel:sendMessage("```\nSyntax to run this command properly:\n.MuteRank Name  --- This will create a file with the name of the default mute rank in your server (the one you choose with .MuteRank).\n```")
				return 
			end
			if not fs.existsSync(serverConfig.."MuteRank.txt") then
				message.channel:sendMessage("MuteRank file not found, creating empty file...\nPlease run this command again.")
				local emptyFile = io.open(serverConfig.."MuteRank.txt", "w")
				emptyFile:close()
			else
				WriteFile(serverConfig, "MuteRank", id)
				message.channel:sendMessage("Default Mute Rank will be : ``"..id.."`` for now on.")
				printLog("MuteRank added: "..id.." from server: "..message.server.name)
			end
		else
			message.channel:sendMessage(":x: Only the owner of the server can run this command. :x:")
		end
	end
	if cmd == ".prune" then
		local number = arg
		if number == nil then return end
		if not number:find("%d") then
			message.channel:sendMessage("Use a number, please.")
			return
		end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			local messages = message.channel:getMessageHistory(number+1) 
			message.channel:bulkDelete(messages)
			sendAndDelete(message.channel, number .. " messages pruned.", 2500)
		end
	end
	if cmd == ".tempMute" then
		if arg == nil then return end
		local timee = string.match(arg, "<@[%d]+> (.*)")
		time = tonumber(timee)
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		if read_file(serverConfig.."MuteRank.txt") == nil then
			message.channel:sendMessage("Please configure first MuteRank.txt, run ``.MuteRank Name`` command.")
			return
		end
		Roles = {}
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, role in pairs(message.server.roles) do
				if role.name == read_file(serverConfig.."MuteRank.txt") then
					table.insert(Roles, role)
				end
			end
			for _, member in pairs(message.mentions.members) do
				for _, role in pairs(member.roles) do
					table.insert(Roles, role)
				end
				message.channel:sendMessage("**"..member.name.."** is going to be muted for "..time.." minutes.")
				TempMute(member, time)
				member:setRoles(Roles)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".mute" then
		Roles = {}
		local reason = string.match(arg, "<@[%d]+> (.*)")
		if reason == nil then 
			message.channel:sendMessage("Enter a reason, please.")
			return
		end
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		if read_file(serverConfig.."MuteRank.txt") == nil then
			message.channel:sendMessage("Please configure first MuteRank.txt, run ``.MuteRank Name`` command.")
			return
		end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, role in pairs(message.server.roles) do
				if role.name == read_file(serverConfig.."MuteRank.txt") then
					table.insert(Roles, role)
				end
			end
			for _, member in pairs(message.mentions.members) do
				for _, role in pairs(member.roles) do
					table.insert(Roles, role)
				end
				message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("**Mute**: "..date().." \n**User**: "..member.name.." ("..member.id..")\n**Reason**: "..reason.."\n**Responsible Moderator**: "..message.author.name)
				member:setRoles(Roles)
				message.channel:sendMessage("<@"..message.author.id.."> muted: **"..member.name.."**.\n\n**REASON**: "..reason)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".unmute" then
		Roles = {}
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		if read_file(serverConfig.."MuteRank.txt") == nil then
			message.channel:sendMessage("Please configure first MuteRank.txt, run ``.MuteRank Name`` command.")
			return
		end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				for _, role in pairs(member.roles) do
					if not role.name == read_file(serverConfig.."MuteRank.txt") then
						table.insert(Roles, role)
					end
				end
				message.channel:sendMessage("<@"..message.author.id.."> unmuted: **"..member.name.."**.")
				member:setRoles(Roles)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".kick" then
		Roles = {}
		local reason = string.match(arg, "<@[%d]+> (.*)")
		if reason == nil then 
			message.channel:sendMessage("Enter a reason, please.")
			return
		end
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("**Kick**: "..date().." \n**User**: "..member.name.." ("..member.id..")\n**Reason**: "..reason.."\n**Responsible Moderator**: "..message.author.name)
				message.server:kickUser(member)
				message.channel:sendMessage("<@"..message.author.id.."> kicked: **"..member.name.."**.\n\n**REASON**: "..reason)
				member:sendMessage("<@"..message.author.id.."> kicked you.\n\n**REASON**: "..reason)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".ban" then
		local reason = string.match(arg, "<@[%d]+> (.*)")
		if reason == nil then 
			message.channel:sendMessage("Enter a reason, please.")
			return
		end
		Roles = {}
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("**Ban**: "..date().." \n**User**: "..member.name.." ("..member.id..")\n**Reason**: "..reason.."\n**Responsible Moderator**: "..message.author.name)
				message.server:banUser(member)
				message.channel:sendMessage("<@"..message.author.id.."> Banned: **"..member.name.."**.\n\n**REASON**: "..reason)
				member:sendMessage("<@"..message.author.id.."> Banned you. \n\n**REASON**: "..reason)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if message.content:find("discord.gg") then
		stopped = false
		if read_file(serverConfig.."Logs.txt") == nil then
			message.channel:sendMessage("Please configure first Logs.txt, run ``.Logs ChannelID`` command.")
			return
		end
		for _, role in pairs(message.author.roles) do
			if role.name == "Rule Breaker" then
				message.server:kickUser(message.author)
				message.channel:sendMessage("Was kicked because he was a Rule Breaker already.")
				message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("<@"..message.author.id.."> tried to post a discord link, since he was already a 'Rule Breaker' I kicked him.")
			end
		end
		if stopped == false then
			Discorded = {}
			for _, role in pairs(message.server.roles) do
				for _, rolez in pairs(message.author.roles) do
					if role.name == "Rule Breaker" then
						table.insert(Discorded, role)
					end
					table.insert(Discorded, rolez)
				end
			end
			message.channel:sendMessage("Please <@"..message.author.id.."> don't send discord links.")
			message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("<@"..message.author.id.."> tried to post a discord link, I deleted it.")
			message:delete()
			message.author:setRoles(Discorded)
		end
	end

	if message.author.id == "191442101135867906" then
		if message.content == "Restart" then
			message.channel:sendMessage("Restarting...")
			message.channel:sendMessage(os.date("[%d.%m.%y][%X]").."Texting functions reload started.")
			message.channel:sendMessage(os.date("[%d.%m.%y][%X]").."Texts reloaded. Starting Commands reload.")
			message.channel:sendMessage(os.date("[%d.%m.%y][%X]").."Commands reloaded. Starting Back-Up.")
			message.channel:sendMessage(os.date("[%d.%m.%y][%X]").."Back-Up done. Bot is fully restarted.")
			client:stop()
		end
	end
end)

client:run(read_file("DeepBotToken.txt"))
