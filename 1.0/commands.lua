local Channel = require('../Channel')
local Message = require('../Message')
local OrderedCache = require('../../../utils/OrderedCache')

local command = {_={}}
command.__index = command

function command.new()
	return setmetatable({}, command)
end

function command.kick(index, user)
	return index:kickUser(user)
end

function command.Kick(...)
	return index:kick(...)
end

function command.ban(index, user)
	return index:banUser(user)
end

function command.Ban(...)
	return index:banUser(...)
end

function command.unban(index, user)
	return index:unbanUser(user)
end

function command.unBan(...)
	return index:unban(...)
end

function command.UnBan(...)
	return index:unban(...)
end

return command