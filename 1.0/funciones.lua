local func = {}

b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
func.enc = function(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

func.dec = function(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

func.ts = function(...) return tostring(...) end -- tostring
func.l = function(...) return string.lower(...) end -- lower
func.u = function(...) return string.upper(...) end -- upper
func.r = function(index, times)                     -- repeat
    local k = "" 
    for i = 1, tonumber(times) do 
        k = k.." "..index 
    end
    return k
end

func.Restricted = function(message)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Restricted Command**", 
        ["color"] = 16520231,
    })
end

func.Requesting = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Requesting...**\n"..str, 
        ["color"] = 15917850,
    })
end

func.Success = function(message, str)
    return message.channel:sendMessage(" ", {
        ["description"] = "**Success**\n"..str, 
        ["color"] = 1765979,
    })
end

return func
