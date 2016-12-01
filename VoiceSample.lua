discordia = require('discordia')
local timer = require("timer")
local client = discordia.Client()
local voice = discordia.VoiceClient()

client:on('ready', function()
    local channel = client:getVoiceChannel('idOfChannel')
    voice:joinChannel(channel)
end)

local function bytes(str)
    return {str:byte(1, #str)}
end

voice:on('connect', function()

    p('connected')

    voice._voice_socket:setSpeaking(true)

    local wav = io.open('ding.wav', 'rb')
    wav:seek('set', 44) -- skip header

    local channels = 2
    local frame_size = 960 -- 20 ms at 48 kHz
    local pcm_len = frame_size * channels

    while true do
        local pcm = wav:read(pcm_len)
        if not pcm then break end
        voice:send(bytes(pcm))
        timer.sleep(10)
    end

end)


client:run('token')
