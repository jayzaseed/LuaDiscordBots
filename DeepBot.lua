-- some functions (the ones with _G.) were taken from https://gitlab.com/McModder/answernator# ;)
_G.DeepBotVersion = "0.6.3"
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
local InCDWood = {}
local InCDIron = {}
local InCDStone = {}



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

function WriteFile2(path, file, text)
	local file = io.open(path.."/"..file..".txt", "w+")
	file:write(text)
	file:close()
end

function AddToFile(path, file, text)
	local TeamsFile = io.open(path.."/"..file..".txt", "a")
	TeamsFile:write(text.."\n")
	TeamsFile:close()
end


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
	--newServer.owner:sendMessage("Hey owner of "..newServer.name..", I have a new function! As you know I delete discord.gg messages, well if you want me to ignore someone you can configure me!\nBy doing ``\n.WhiteList @someone\n`` I will add him/her to my White List and I won't remove his discord.gg messages! :)")
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
	if not fs.existsSync(serverConfig.."CWelcome.txt") then
		local emptyFile = io.open(serverConfig.."CWelcome.txt", "w")
		emptyFile:close()
		printLog("Archivo CWelcome.txt creado en "..newServer.name, "INFO")
	end
	if not fs.existsSync(carpeta.."Teams") then
		printLog("Carpeta Teams creada en "..newServer.name, "INFO")
		fs.mkdirSync(carpeta.."Teams")
	end
	if not fs.existsSync(carpeta.."Rioters") then
		printLog("Carpeta Rioters creada en "..newServer.name, "INFO")
		fs.mkdirSync(carpeta.."Rioters")
		fs.mkdirSync(carpeta.."Rioters/BlackWhizard")
	end
	if not fs.existsSync(carpeta.."Discorders") then
		printLog("Carpeta Discorders creada en "..newServer.name, "INFO")
		fs.mkdirSync(carpeta.."Discorders")
		fs.mkdirSync(carpeta.."Discorders/WhiteWizard")
	end
	if not fs.existsSync(carpeta.."Recollect") then
		printLog("Carpeta Recollect creada en "..newServer.name, "INFO")
		fs.mkdirSync(carpeta.."Recollect")
		fs.mkdirSync(carpeta.."Recollect/Wood")
		fs.mkdirSync(carpeta.."Recollect/Iron")
		fs.mkdirSync(carpeta.."Recollect/Stone")
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
	if not fs.existsSync(carpeta.."WhiteList") then
		fs.mkdirSync(carpeta.."WhiteList")
		local emptyFile = io.open(carpeta.."WhiteList/WhiteList.txt", "w")
		emptyFile:close()
		printLog("Archivo WhiteList.txt creado en "..newServer.name, "INFO")
	end
end)


client:on(
	'ready', 
	function()
		p(string.format('Logged in as %s', client.user.username))
		client:setGameName("mrjuicylemon.es/deepBot/")
		for k, server in pairs(client.servers) do
			--p(k)
			if read_file("serverData/"..server.id.."/ServerConfig/Logs.txt") ~= "" then
				--server:getChannelById(read_file("serverData/"..server.id.."/ServerConfig/Logs.txt")):sendMessage("@here\nI received a new update, Mute, kick and ban commands are fixed now.")
			end
		end
end)


client:on("messageCreate", function(message)
	if message.server == nil then return end
	local carpeta = "serverData/"..message.server.id.."/"
	local serverConfig = carpeta.."ServerConfig/"
	local Teams = carpeta.."Teams/"
	local Recollect = carpeta.."Recollect/"

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
		if message.author == message.server.owner then return true end
		for _, ids in pairs(who.roles) do
		  if ids.name:find("Guide")then
		    return true
		  end
		end
	end

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if cmd == ".help" then
		message.author:sendMessage("```Markdown\nCommands:\n\n .add @someone Role\n .mute @someone Reason  \n .unmute @someone \n .banList \n .prune NumberOfMessages\n .kick @someone Reason\n .ban @someone Reason\n .tempMute @someone TimeInMinutes\n .Welcome WelcomingMessage\n .Logs channelID\n .WhiteList @someone so the bot doesnt remove his discord.gg links.\n .MuteRank DefaultMuteRole\n\n```<@"..message.author.id..">\n")
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

	if cmd == ".WhiteList" then
		if not arg then message.channel:sendMessage("Proper use of this command: ```\n.WhiteList @someone\n```") return end
		if HasRole(message.author) or message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.channel:sendMessage("<@"..message.author.id.."> added **"..member.username.."** to the WhiteList			 "..date().." (GMT+1).")
				AddToFile(carpeta.."WhiteList", "WhiteList", member.id)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end

	if cmd == ".resource" then
		if arg == nil then
			message.channel:sendMessage("```\nProper usage of this command:\n.resource Wood / .resource Iron / .resource Stone\n```")
			return
		end
		if arg:lower() == "wood" then
			local WoodCount = read_file(Recollect.."Wood/"..message.author.id..".txt")
			message.channel:sendMessage("You have "..WoodCount.." pieces of wood.")
		elseif arg:lower() == "iron" then
			local IronCount = read_file(Recollect.."Iron/"..message.author.id..".txt")
			message.channel:sendMessage("You have "..IronCount.." iron ores.")
		elseif arg:lower() == "stone" then
			local StoneCount = read_file(Recollect.."Stone/"..message.author.id..".txt")
			message.channel:sendMessage("You have "..StoneCount.." stone ores.")
		end
	end

	if cmd == ".recruit" then
		local team
		local sinequipo = false
		for dUser in io.lines(Teams.."Discorders.txt") do
			if dUser == message.author.id then
				team = "Discorders"
				sinequipo = true
				break
			end
		end
		for rUser in io.lines(Teams.."Rioters.txt") do
			if rUser == message.author.id then
				team = "Rioters"
				sinequipo = true
				break
			end
		end
		if sinequipo == false then
			message.channel:sendMessage("```\nPlease join a team before\n.join Discorders / Rioters\n```")
			return
		end
		local WoodCount = tonumber(read_file(Recollect.."Wood/"..message.author.id..".txt"))
		local IronCount = tonumber(read_file(Recollect.."Iron/"..message.author.id..".txt"))
		local StoneCount = tonumber(read_file(Recollect.."Stone/"..message.author.id..".txt"))
		if arg == nil then
			message.channel:sendMessage("```Markdown\nProper usage of this command:\n.recruit Troop\n\nAvailable troops:\n<For Discorders>\n·White Wizard\n·Giant\n\n<For Rioters>\n·Black Wizard\n·Vampire\n·Succubus```")
			return
		end
		if team == "Discorders" then
			if arg:lower():find("hite") then
				if WoodCount <= 55 and IronCount <= 40 and StoneCount <= 25 then
					message.channel:sendMessage("You dont have enough materials. \nWood required: 55, Iron required: 40, Stone required: 25\nyou have "..WoodCount.." of Wood, "..IronCount.." of Iron and "..StoneCount.." of Stone")
					return
				end
				WriteFile(Recollect.."Wood", message.author.id, WoodCount-55)
				WriteFile(Recollect.."Iron", message.author.id, IronCount-40)
				WriteFile(Recollect.."Stone", message.author.id, StoneCount-25)
				MagosBlancos = tonumber(read_file(carpeta.."Discorders/WhiteWizard/"..message.author.id..".txt")) or 0
				io.open(carpeta.."Discorders/WhiteWizard/"..message.author.id..".txt", "w")
				WriteFile(carpeta.."Discorders/WhiteWizard", message.author.id, MagosBlancos + 1)
				message.channel:sendMessage("```\nYou recruited 1 White Whizard!\n```")
			end
		elseif team == "Rioters" then
			if arg:lower():find("ack") then
				if WoodCount <= 55 and IronCount <= 40 and StoneCount <= 25 then
					message.channel:sendMessage("You dont have enough materials. \nWood required: 55, Iron required: 40, Stone required: 25\nyou have "..WoodCount.." of Wood, "..IronCount.." of Iron and "..StoneCount.." of Stone")
					return
				end
				WriteFile(Recollect.."Wood", message.author.id, WoodCount-55)
				WriteFile(Recollect.."Iron", message.author.id, IronCount-40)
				WriteFile(Recollect.."Stone", message.author.id, StoneCount-25)
				MagosNegros = tonumber(read_file(carpeta.."Rioters/BlackWhizard/"..message.author.id..".txt")) or 0
				io.open(carpeta.."Rioters/BlackWhizard/"..message.author.id..".txt", "w")
				WriteFile(carpeta.."Rioters/BlackWhizard", message.author.id, MagosNegros + 1)
				message.channel:sendMessage("```\nYou recruited 1 Black Whizard!\n```")
			end
		end
	end

	if cmd == ".count" then
		if not arg then return end
		if arg:find("hite") then
			MaguetesBlanketes = tonumber(read_file(carpeta.."Discorders/WhiteWizard/"..message.author.id..".txt")) or 0
			message.channel:sendMessage("```\nYou have "..MaguetesBlanketes.." White Whizard!\n```")
		elseif arg:find("ack") then
			MaguetesNegretes = tonumber(read_file(carpeta.."Rioters/BlackWhizard/"..message.author.id..".txt")) or 0
			message.channel:sendMessage("```\nYou have "..MaguetesNegretes.." White Whizard!\n```")
		end
	end

	if cmd == ".giveWood" then
		local WoodCount1 = tonumber(read_file(Recollect.."Wood/"..message.author.id..".txt"))
		local IronCount1 = tonumber(read_file(Recollect.."Iron/"..message.author.id..".txt"))
		local StoneCount1 = tonumber(read_file(Recollect.."Stone/"..message.author.id..".txt"))
		local amount = string.match(arg, "<@[%d]+> (.*)") or string.match(arg, "<@#[%d]+> (.*)")
		if message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.channel:sendMessage("<@"..message.author.id.."> sent **"..amount.." of Wood** to: **"..member.name.."** at "..date().." (GMT+1).")
				WriteFile(Recollect.."Wood", message.author.id, WoodCount1+amount)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".giveStone" then
		local amount = string.match(arg, "<@[%d]+> (.*)") or string.match(arg, "<@#[%d]+> (.*)")
		if message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.channel:sendMessage("<@"..message.author.id.."> sent **"..amount.." of Stone** to: **"..member.name.."** at "..date().." (GMT+1).")
				WriteFile(Recollect.."Wood", message.author.id, StoneCount1+amount)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end
	if cmd == ".giveIron" then
		local amount = string.match(arg, "<@[%d]+> (.*)") or string.match(arg, "<@#[%d]+> (.*)")
		if message.author.id == "191442101135867906" then
			for _, member in pairs(message.mentions.members) do
				message.channel:sendMessage("<@"..message.author.id.."> sent **"..amount.." of Iron** to: **"..member.name.."** at "..date().." (GMT+1).")
				WriteFile(Recollect.."Wood", message.author.id, IronCount1+amount)
			end
		else
			message.channel:sendMessage("You don't have permissions to run this command.")
		end
	end

	if cmd == ".recollect" then
		local team
		for dUser in io.lines(Teams.."Discorders.txt") do
			if dUser == message.author.id then
				team = "Discorders"
			end
		end
		for rUser in io.lines(Teams.."Rioters.txt") do
			if rUser == message.author.id then
				team = "Rioters"
			end
		end
		if team == nil then
			message.channel:sendMessage("```\nPlease join a team before\n.join Discorders / Rioters\n```")
			return
		end
		if arg == nil then
			message.channel:sendMessage("```\nYou must choose Wood, Iron or Stone.")
			return
		elseif arg:lower() == "wood" then
			if InCDStone[message.author.id] == true then
				message.channel:sendMessage("```\nTry again later\n```")
				return
			end
			madera = math.random(3, 12)
			message.channel:sendMessage("<@"..message.author.id.."> recollected "..madera.." pieces of wood.		Team: "..team)
			local ActWood = read_file(Recollect.."Wood/"..message.author.id..".txt")
			InCDWood[message.author.id] = true
			if ActWood ~= nil then
				ActWood = tonumber(ActWood)
				WriteFile(Recollect.."Wood", message.author.id, ActWood+madera)
			else
				io.open(Recollect.."Wood/"..message.author.id..".txt", "w")
				maderaFile = io.open(Recollect.."Wood/"..message.author.id..".txt", "w")
				maderaFile:write(madera)
				maderaFile:close()
			end
			timer.sleep(30000)
			InCDWood[message.author.id] = false
		elseif arg:lower() == "iron" then
			if InCDIron[message.author.id] == true then
				message.channel:sendMessage("```\nTry again later\n```")
				return
			end
			Iron = math.random(1, 7)
			message.channel:sendMessage("<@"..message.author.id.."> recollected "..Iron.." iron ores.		Team: "..team)
			local ActIron = read_file(Recollect.."Iron/"..message.author.id..".txt")
			InCDIron[message.author.id] = true
			if ActIron ~= nil then
				ActIron = tonumber(ActIron)
				WriteFile(Recollect.."Iron", message.author.id, ActIron+Iron)
			else
				io.open(Recollect.."Iron/"..message.author.id..".txt", "w")
				IronFile = io.open(Recollect.."Iron/"..message.author.id..".txt", "w") 
				IronFile:write(Iron)
				IronFile:close()
			end
			timer.sleep(30000)
			InCDIron[message.author.id] = false
		elseif arg:lower() == "stone" then
			if InCDStone[message.author.id] == true then
				message.channel:sendMessage("```\nTry again later\n```")
				return
			end
			Stone = math.random(1, 7)
			message.channel:sendMessage("<@"..message.author.id.."> recollected "..Stone.." stones.		Team: "..team)
			local ActStone = read_file(Recollect.."Stone/"..message.author.id..".txt")
			InCDStone[message.author.id] = true
			if ActStone ~= nil then
				ActStone = tonumber(ActStone)
				WriteFile(Recollect.."Stone", message.author.id, ActStone+Stone)
			else
				io.open(Recollect.."Stone/"..message.author.id..".txt", "w")
				StoneFile = io.open(Recollect.."Stone/"..message.author.id..".txt", "w")
				StoneFile:write(Stone)
				StoneFile:close()
			end
			p(InCDStone)
			timer.sleep(30000)
			InCDStone[message.author.id] = false
			p(InCDStone)
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
		for k, user in io.lines(carpeta.."WhiteList/WhiteList.txt") do
			print(k.." ")
			if k == message.author.id then
				stopped = true
			end
		end
		if stopped == false then
			message.channel:sendMessage("Please <@"..message.author.id.."> don't send discord links.")
			message:delete()
			message.server:getChannelById(read_file(serverConfig.."Logs.txt")):createMessage("<@"..message.author.id.."> tried to post a discord link, I deleted it.")
		end
	end
--[[
	function LoadFunc(x)
		_G.DeepBotVersion = "0.6.3"
		--z = x:gsub("\n", "")
		local func, error = loadstring('return (function() return '..x..' end)()')
		if not func then message.channel:sendMessage("```lua\n"..error.."\n```") return end
		local results = {pcall(func)}
		message.channel:sendMessage("```lua\n"..results[2].."\n```")
	end]]
	function LoadFunc(x)
		z = x:gsub("\n", " ")
		local func, error = loadstring(z)
		if not func then message.channel:sendMessage("```lua\n"..error.."\n```") return end
		local results = {pcall(func)}
		message.channel:sendMessage("```lua\n"..results[2].."\n```")
	end

	if cmd == ".lua" then
		if message.author.id == "191442101135867906" or HasRole(message.author) then
			if not arg then return end
			if arg then
				LoadFunc(arg)
			end
		else
			message.channel:sendMessage("You do not have permissions to run this command. Triggered :sunglasses:.")
		end
	end

	if message.author.id == "191442101135867906" then
		if cmd == "default" then
			print(message.server.defaultChannel.id)
		end
		if cmd:lower() == "github" then
			if not arg then return end
			for k, server in pairs(client.servers) do
				--print(server.id)
				print(read_file("serverData/"..server.id.."/ServerConfig/Logs.txt"))
				if read_file("serverData/"..server.id.."/ServerConfig/Logs.txt") ~= "" then
					client:getServerById(server.id):getChannelById(read_file("serverData/"..server.id.."/ServerConfig/Logs.txt")):sendMessage("@here\nI received a new update:\n"..arg.."\nfrom https://github.com/PurgePJ/LuaDiscordBots/blob/master/DeepBot.lua")
				else
					client:getServerById(server.id):getChannelById(server.defaultChannel.id):sendMessage("I received a **new update**:\n"..arg.."\nfrom https://github.com/PurgePJ/LuaDiscordBots/blob/master/DeepBot.lua")
				end
			end
		end
		if message.content:lower():find("link") then
			message.channel:sendMessage("Add me to your server ;)\nhttps://discordapp.com/oauth2/authorize?client_id=232959194460848128&scope=bot&permissions=66321471")
		end
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
