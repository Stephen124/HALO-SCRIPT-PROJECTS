--[[
--=====================================================================================================--
Script Name: Word Buster (v1.3), for SAPP (PC & CE)
Description:
> Advanced profanity filter mod that automatically censors chat messages containing profanity.
> Supports multiple languages
> Warning System + Grace Period

-------------- [ INSTALLING LANGUAGE FILES ] ------------
1). Create a new folder in your servers Root directory and call it "wordbuster_database".
2). Download language files [here](https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/tree/master/SAPP%20SCRIPTS/UTILITY%20MODS/Word%20Buster/wordbuster_database)
3). Place these files in the folder you created in step 1.

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local wordBuster = { }
-- Word Buster Configuration --

-- Version: Current version of Word Buster
wordBuster.version = 1.3

-- Censor: Which character should be used to replace bad words?
wordBuster.censor = "*"

-- Warning Count: How many warnings before the player is kicked?
wordBuster.warnings = 5

-- Grace Period: Warnings reset after this many seconds of no profanity
wordBuster.grace = 30

-- Semi Censor: Show the first and last character of bad words?
-- If false, the whole word will be censored
wordBuster.semiCensor = true

-- Block Word: If this is true, the users message will not be sent
wordBuster.blockWord = false

-- Notify: Notify the user that one of his/her words were censored.
wordBuster.notifyUser = true

-- Notify Text: Text to notify the user with.
wordBuster.notifyText = "Watch your language!"

-- Profanity Warning Message: Warning message sent to player when they use obscene language
wordBuster.onWarn = "[Word Buster] You will be kicked if you continue to use that language!"

-- Kick Message: Message sent to player when they are kicked for profanity
wordBuster.onKick = "[Word Buster] You were kicked for profanity!"

-- Notify Admins: Notify admins that player was kicked?
wordBuster.notifyAdmins = true
wordBuster.adminMsg = "[Word Buster] %name% was kicked for profanity!"

-- Server Prefix: A chat relay function temporarily removes the server
-- prefix during a broadcast and and will restores it to this when the relay is finished:
wordBuster.serverPrefix = "**SAPP**"

-- Chat Format: Messages are formatted as per default settings
wordBuster.chatFormat = {
    global = "%name%: %msg%",
    team = "[%name%]: %msg%",
    vehicle = "[%name%]: %msg%"
}

-- Language Directory: Folder path to Language Files database
wordBuster.lang_directory = "wordbuster_database/"

-- Languages: Which languages should be loaded?
wordBuster.languages = {
    ["cs"] = false, -- Czech
    ["da"] = false, -- Danish
    ["de"] = false, -- German
    ["en"] = true, -- English
    ["eo"] = false, -- Esperanto
    ["es"] = true, -- Spanish
    ["fr"] = false, -- French
    ["hu"] = false, -- Hungry
    ["it"] = false, -- Italy
    ["ja"] = false, -- Japan
    ["ko"] = false, -- Korea
    ["nl"] = false, -- Dutch
    ["no"] = false, -- Norway
    ["pl"] = false, -- Poland
    ["pt"] = false, -- Portuguese
    ["ru"] = false, -- Russia
    ["sv"] = false, -- Swedish
    ["th"] = false, -- Thai
    ["tr"] = false, -- Turkish
    ["zh"] = false, -- Chinese
    ["tlh"] = false, -- Vietnamese
}

-- Whitelist: Groups allowed to use bad words.
wordBuster.whitelist = {
    [-1] = false, -- PUBLIC
    [1] = true, -- ADMIN LEVEL 1
    [2] = true, -- ADMIN LEVEL 2
    [3] = true, -- ADMIN LEVEL 3
    [4] = true, -- ADMIN LEVEL 4
}

-- Patterns: Advanced users only, patterns used to block variations of bad words.
wordBuster.patterns = {
    ["a"] = { "[aA@]" },
    ["b"] = { "[bB]" },
    ["c"] = { "[cCkK]" },
    ["d"] = { "[dD]" },
    ["e"] = { "[eE3]" },
    ["f"] = { "[fF]" },
    ["g"] = { "[gG6]" },
    ["h"] = { "[hH]" },
    ["i"] = { "[iIl!1]" },
    ["j"] = { "[jJ]" },
    ["k"] = { "[cCkK]" },
    ["l"] = { "[lL1!i]" },
    ["m"] = { "[mM]" },
    ["n"] = { "[nN]" },
    ["o"] = { "[oO0]" },
    ["p"] = { "[pP]" },
    ["q"] = { "[qQ9]" },
    ["r"] = { "[rR]" },
    ["s"] = { "[sS$5]" },
    ["t"] = { "[tT7]" },
    ["u"] = { "[uUvV]" },
    ["v"] = { "[vVuU]" },
    ["w"] = { "[wW]" },
    ["x"] = { "[xX]" },
    ["y"] = { "[yY]" },
    ["z"] = { "[zZ2]" },
}

local len = string.len
local sub, gsub = string.sub, string.gsub
local insert, remove = table.insert, table.remove

function OnScriptLoad()
    wordBuster.Load()
end

function wordBuster.Load()

    cprint("[Word Buster] Loading languages...", 2 + 8)

    local load_count = 0
    wordBuster.players = { }
    wordBuster.badWords = { }

    local dir = wordBuster.lang_directory
    for lang, load in pairs(wordBuster.languages) do
        if load then

            local file = io.open(dir .. lang .. ".txt", "r")
            if (file ~= nil) then
                io.close(file)
            end

            if (file) then

                load_count = load_count + 1

                local words = {}
                for line in io.lines(dir .. lang .. ".txt") do
                    insert(words, line)
                end

                for _, word in pairs(words) do
                    local Pattern = ""
                    for _, char in pairs(string.ToTable(word)) do
                        if (wordBuster.patterns[char]) then
                            for i = 1, #wordBuster.patterns[char] do
                                if (wordBuster.patterns[char][i]) then
                                    Pattern = Pattern .. wordBuster.patterns[char][i]
                                end
                            end
                        else
                            Pattern = Pattern .. "."
                        end
                    end

                    insert(wordBuster.badWords, { Pattern, word, lang })
                end
            else
                cprint("[Word Buster] Couldn't load language '" .. lang .. ".txt', language not found!", 4 + 8)
            end
        end
    end

    if (#wordBuster.badWords > 0) then

        if (get_var(0, "$gt") ~= "n/a") then
            for i = 1, 16 do
                if player_present(i) then
                    InitPlayer(i, false)
                end
            end
        end

        for k, v in pairs(wordBuster.badWords) do
            if (v[1] == "" or v[1] == " ") then
                cprint("[Word Buster] Removing empty filters " .. v, 4 + 8)
                remove(wordBuster.badWords, k) -- Removes empty filters
            end
        end

        local time_took = os.clock()

        cprint("[Word Buster] Successfull loaded " .. load_count .. " languages:", 2 + 8)
        cprint("[Word Buster] " .. #wordBuster.badWords .. " words loaded in " .. time_took .. " seconds", 2 + 8)

        register_callback(cb["EVENT_CHAT"], "OnTick")
        register_callback(cb["EVENT_CHAT"], "OnPlayerChat")
        register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
        register_callback(cb["EVENT_GAME_START"], "OnGameStart")
        register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    else
        unregister_callback(cb["EVENT_TICK"])
        unregister_callback(cb["EVENT_CHAT"])
        unregister_callback(cb["EVENT_JOIN"])
        unregister_callback(cb["EVENT_LEAVE"])
        cprint("[Word Buster] Unable to load Bad Words! ", 4 + 8)
    end
end

function OnGameStart()
    -- DEBUG CODE:
    --local _, Params = wordBuster.isCensored("sex")
    --if (#Params > 0) then
    --    for i = 1, #Params do
    --        cprint("------------- WORD FOUND ------------- ", 5 + 8)
    --        cprint("Pattern: " .. Params[i][1], 5 + 8)
    --        cprint("Word: " .. Params[i][2], 5 + 8)
    --        cprint("Language: " .. Params[i][3], 5 + 8)
    --    end
    --else
    --    cprint("WORD NOT FOUND", 4 + 8)
    --end

    if (get_var(0, "$gt") ~= "n/a") then
        wordBuster.players = { }
    end
end

function OnTick()
    for player, v in pairs(wordBuster.players) do
        if (player) then
            if (v.begin_cooldown) then
                v.timer = v.timer + 1 / 30
                if (v.timer >= wordBuster.grace) then
                    v.timer = 0
                    v.begin_cooldown = false
                    v.warnings = wordBuster.warnings
                end
            end
        end
    end
end

function OnPlayerConnect(PlayerIndex)
    InitPlayer(PlayerIndex, false)
end

function OnPlayerDisconnect(PlayerIndex)
    InitPlayer(PlayerIndex, true)
end

function InitPlayer(PlayerIndex, Reset)
    if (Reset) then
        wordBuster.players[PlayerIndex] = { }
    else
        wordBuster.players[PlayerIndex] = {
            timer = 0,
            begin_cooldown = false,
            warnings = wordBuster.warnings
        }
    end
end

function OnPlayerChat(PlayerIndex, Message, Type)

    if (PlayerIndex > 0 and Type ~= 6) then

        local lvl = tonumber(get_var(PlayerIndex, "$lvl"))
        if (wordBuster.whitelist[lvl]) then
            return
        end

        local CMD = ((sub(Message, 1, 1) == "/") or (sub(Message, 1, 1) == "\\"))
        if (not CMD) then

            local Msg, Params = wordBuster.isCensored(Message)
            if (#Params > 0) then

                Message = Msg

                local name = get_var(PlayerIndex, "$name")
                local p = wordBuster.players[PlayerIndex]
                p.timer = 0
                p.begin_cooldown = true
                p.warnings = p.warnings - 1

                if (wordBuster.notifyUser) then

                    cprint("--------- [ WORD BUSTER ] ---------", 5 + 8)
                    for i = 1, #Params do
                        cprint(Params[i][1] .. ", " .. Params[i][2] .. ", " .. Params[i][3])
                    end

                    if (p.warnings == 1) then
                        -- last warning
                        Broadcast(PlayerIndex, wordBuster.onWarn, "rprint")
                    elseif (p.warnings <= 0) then
                        -- kick message
                        Broadcast(PlayerIndex, wordBuster.onKick, "say")
                    else
                        -- every other warning:
                        Broadcast(PlayerIndex, wordBuster.notifyText, "rprint")
                    end
                    cprint("--------------------------------------------------------------------", 5 + 8)
                end

                if (p.warnings <= 0) then

                    if (wordBuster.notifyAdmins) then
                        local Msg = gsub(wordBuster.adminMsg, "%%name%%", name)
                        for i = 1, 16 do
                            if player_present(i) then
                                if (i ~= PlayerIndex) then
                                    if (tonumber(get_var(i, "$lvl")) >= 1) then
                                        Broadcast(i, Msg, "say")
                                    end
                                end
                            end
                        end
                        cprint(Msg, 5 + 8)
                    end

                    timer(0, "SilentKick", PlayerIndex)
                    return false
                end

                if (wordBuster.blockWord) then
                    return false
                end

                local f = wordBuster.chatFormat
                local FORMAT = wordBuster.formatMessage

                if (Type == 0) then
                    Broadcast(PlayerIndex, FORMAT(PlayerIndex, Message, f.global), "say_all")
                    return false
                elseif (Type == 1) then
                    wordBuster.SayTeam(PlayerIndex, FORMAT(PlayerIndex, Message, f.team))
                    return false
                elseif (Type == 2) then
                    wordBuster.SayTeam(PlayerIndex, FORMAT(PlayerIndex, Message, f.vehicle))
                    return false
                end
            end
        end
    end
end

function wordBuster.SayTeam(PlayerIndex, Message)
    local team = get_var(PlayerIndex, "$team")
    for i = 1, 16 do
        if player_present(i) then
            if (get_var(i, "$team") == team) then
                Broadcast(i, Message, "say")
            end
        end
    end
end

function Broadcast(PlayerIndex, Message, Type)
    execute_command("msg_prefix \"\"")
    if (Type == "rprint") then
        for _ = 1, 25 do
            rprint(PlayerIndex, " ")
        end
        rprint(PlayerIndex, Message)
    elseif (Type == "say") then
        say(PlayerIndex, Message)
    elseif (Type == "say_all") then
        say_all(Message)
    end
    execute_command("msg_prefix \" " .. wordBuster.serverPrefix .. "\"")
end

function wordBuster.CensorWord(Str, Pattern)
    local l = 0
    local censor = ""
    local WORD = Str:match(Pattern)
    local ORI = WORD
    if (wordBuster.semiCensor) then
        for i = 1, len(WORD) do
            if (i > 1 and i < len(WORD)) then
                local letters = sub(WORD, i, i)
                WORD = gsub(WORD, letters, wordBuster.censor)
            end
        end
        return gsub(Str, ORI, WORD)
    else
        while l < len(WORD) do
            censor = censor .. wordBuster.censor
            l = l + 1
        end
        return gsub(Str, WORD, censor)
    end
end

function wordBuster.isCensored(Msg)
    local Params = { }
    for _, Pattern in pairs(wordBuster.badWords) do
        if (Msg:lower():match(Pattern[1])) then
            Msg = wordBuster.CensorWord(Msg, Pattern[1])
            Params[#Params + 1] = Pattern
        end
    end
    return Msg, Params
end

function wordBuster.formatMessage(PlayerIndex, Message, Str)

    local name = get_var(PlayerIndex, "$name")

    local patterns = {
        { "%%name%%", name },
        { "%%msg%%", Message },
        { "%%id%%", PlayerIndex }
    }

    for i = 1, #patterns do
        Str = (gsub(Str, patterns[i][1], patterns[i][2]))
    end

    return Str
end

-- Overwhelm the player console (causes player to disconnect)
function SilentKick(PlayerIndex)
    for _ = 1, 9999 do
        rprint(PlayerIndex, " ")
    end
end

string.ToTable = function(String)
    local Array = {}
    for i = 1, String:len() do
        insert(Array, String:sub(i, i))
    end
    return Array
end

function report()
    local script_version = string.format("%0.2f", wordBuster.version)
    cprint("--------------------------------------------------------", 5 + 8)
    cprint("Please report this error on github:", 7 + 8)
    cprint("https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/issues", 7 + 8)
    cprint("Script Version: " .. script_version, 7 + 8)
    cprint("--------------------------------------------------------", 5 + 8)
end

function OnError()
    cprint(debug.traceback(), 4 + 8)
    timer(50, "report")
end