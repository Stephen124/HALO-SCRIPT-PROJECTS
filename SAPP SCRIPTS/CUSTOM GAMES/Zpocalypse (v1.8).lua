--[[
--=====================================================================================================--
Script Name: Zpocalypse (v1.9), for SAPP (PC & CE)
Description: A custom Zombies Game designed for Team-Slayer game types.

### Game Play Mechanics:
- Blue Team play as the "zombies".
- Red Team play as the "humans".
- Zombies wield a "skull" with which they melee humans.
- When a human is killed by a zombie they become a zombie themselves.
- When all players have become a zombie the game will end.
- Zombies are lighting fast and slightly stronger than humans.
- Zombies have the ability to camouflage themselves when they crouch.
- The last human alive will have special abilities, such as regenerating health, camouflage and super speed among other things.

- Zombie Assistance: If enabled, a zombie that is killed "zombies_assistance_threshold" times 
consecutively will trigger a random human to be selected as a zombie to assist fellow zombies.

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)
--=====================================================================================================--
]]--

api_version = "1.11.0.0"

local zombies, parameters = {}, nil
function zombies:init()
    local weapon = zombies:GetTag()

    zombies.settings = {

        -- #Numbers of players required to set the game in motion (cannot be less than 2)
        required_players = 3,

        -- #Continuous message emitted when there aren't enough players:
        not_enough_players = "%current%/%required% players needed to start the game.",

        -- #This is a pre-game countdown initiated at the beginning of each game (in seconds):
        game_start_delay = 10,

        -- #Pre-Game message:
        pre_game_message = "Zpocalypse will begin in %time_remaining% second%s%",

        -- #End of Game message:
        end_of_game = "The %team% team won!",

        -- #Game Begun Message:
        on_game_begin = "The game has begun: You are on the %team% team",

        -- Human Team:
        human_team = "red",
        --Zombie Team
        zombie_team = "blue",

        on_zombify = "%victim% was Zombified",
        last_man = "%lastman% is the Last Human Alive",

        -- No Zombies:
        no_zombies = "No Zombies! Switching random human in %time_remaining% second%s%",
        no_zombies_switch = "%random_human% was switched to the Zombie Team",
        no_zombies_delay = 10,

        -- Zombie Assistance:
        assistance = true,
        assistance_zombie_count = 3, -- If there are only this many (or less) zombies, Zombie Assistance will be triggered.
        zombies_assistance_threshold = 6,
        zombie_assistance = "Zombies need Assistance! Switching random Human in %time_remaining% second%s%",
        zombie_assistance_switch = "%random_human% was switched to assist the Zombies",
        -- When triggered, a random human will be switched to Zombie Team after this many seconds.
        zombies_assistance_delay = 10,
        --

        -- Zombie Cured:
        cure_threshold = 5, -- Number of consecutive kills to become human again
        zombie_cured = "%killer% was cured!",
        zombie_weapon = weapon[11], -- oddball (see function mod:GetTag() on line 1208)

        -- If this is true, the teams will be evenly balanced at the beginning of the game
        balance_teams = false,

        -- #Respawn time (override)
        -- When enabled, players who are killed by the opposing team will respawn immediately.
        -- Does not affect suicides or other deaths (PvP only by design).
        respawn_override = true,
        respawn_time = 0, -- In seconds (0 = immediate)

        attributes = {
            ["Humans"] = {
                -- Set to 0 to disable (normal speed is 1)
                running_speed = 1,
                -- Zombie Health: (0 to 99999) (Normal = 1)
                health = 1.3,
                damage_multiplier = 1, -- (0 to 10) (Normal = 1)
            },
            ["Zombies"] = {
                -- Set to 0 to disable (normal speed is 1)
                running_speed = 1.3,
                -- Zombie Health: (0 to 99999) (Normal = 1)
                health = 2.3,
                damage_multiplier = 10, -- (0 to 10) (Normal = 1)
                -- Set to 'false' to disable:
                invisibility_on_crouch = true,
            },
            ["Last Man Standing"] = {
                -- Set to 0 to disable (normal speed is 1)
                running_speed = 3.3,
                -- Zombie Health: (0 to 99999) (Normal = 1)
                health = 2.5,
                -- Set to 'false' to disable temporary overshield:
                overshield = true,
                -- Set to 'false' to disable this feature:
                invisibility_on_crouch = true,
                -- If true, the last man standing will have regenerating health:
                regenerating_health = true,
                -- Health will regenerate in chunks of this percent every 30 ticks until they gain maximum health.
                increment = 0.0005,
                -- Last Man damage multiplier
                damage_multiplier = 2.00, -- (0 to 9999) (Normal = 1)

                -- A NAV marker will appear above the last man standing if your set the "kill in order" gametype flag to "yes". 
                -- This only works on FFA and Team Slayer gametypes.
                use_nav_marker = true
            },

            weapons = {

                -- If true, humans will be given up to 4 custom weapons:
                use = true, -- Set to "false" to disable weapon assignments for all maps

                -- Set the weapon index to the corresponding tag number (see function mod:GetTag() on line 1208)

                -- To disable a slot, set it to nil:
                -- Example: ["mymap"] = {weapon[1], nil, nil, nil},
                -- In the above example, you will only spawn with the pistol on the map "mymap"

                -- =========== [ STOCK MAPS ] =========== --
                -- PRIMARY | SECONDARY | TERTIARY | QUATERNARY

                -- weapon[1] = pistol
                -- weapon[2] = sniper
                -- etc...

                -- Set all slots to "nil" to disable weapon assignment for that map.
                -- For example: ["mymap"] = {nil, nil, nil, nil},

                ["beavercreek"] = { weapon[1], weapon[2], weapon[10], nil }, -- pistol, sniper, shotgun
                ["bloodgulch"] = { weapon[2], weapon[1], weapon[9], weapon[5] },
                ["boardingaction"] = { weapon[10], weapon[1], nil, nil },
                ["carousel"] = { weapon[2], weapon[1], weapon[10], nil },
                ["dangercanyon"] = { weapon[1], weapon[4], weapon[7], nil },
                ["deathisland"] = { weapon[2], weapon[1], weapon[7], nil },
                ["gephyrophobia"] = { weapon[2], weapon[1], weapon[4], nil },
                ["icefields"] = { weapon[1], weapon[7], nil, nil },
                ["infinity"] = { weapon[1], weapon[2], weapon[4], nil },
                ["sidewinder"] = { weapon[1], weapon[4], weapon[3], weapon[2] },
                ["timberland"] = { weapon[1], weapon[2], weapon[10], nil },
                ["hangemhigh"] = { weapon[1], weapon[10], nil, nil },
                ["ratrace"] = { weapon[7], weapon[1], nil, nil },
                ["damnation"] = { weapon[7], weapon[1], nil, nil },
                ["putput"] = { weapon[5], weapon[6], weapon[3], weapon[8] },
                ["prisoner"] = { weapon[1], weapon[4], nil, nil },
                ["wizard"] = { weapon[1], weapon[2], nil, nil },

                -- Repeat the structure to add more entries:
                ["mapname"] = { nil, nil, nil, nil },
            }
        },

        -- Some functions temporarily remove the server prefix while broadcasting a message.
        -- This prefix will be restored to 'server_prefix' when the message relay is done.
        -- Enter your servers default prefix here:
        server_prefix = "** SERVER **",
    }

    --# Do Not Touch #--
    zombies.players = {}
    zombies.map = get_var(0, "$map")
    parameters = zombies.settings
    zombies.zombie_weapon = parameters.zombie_weapon

    zombies.damage = {}
    zombies.falldamage = zombies:LookupTag("jpt!", "globals\\falling")
    zombies.distancedamage = zombies:LookupTag("jpt!", "globals\\distance")

    zombies.timers = {
        ["Pre-Game Countdown"] = {
            init = false,
            duration = parameters.game_start_delay,
            timer = 0,
        },
        ["No Zombies"] = {
            init = false,
            duration = parameters.no_zombies_delay,
            timer = 0,
        },
        ["Assistance"] = {
            init = false,
            duration = parameters.zombies_assistance_delay,
            timer = 0,
        },
    }

    zombies.human_count = 0
    zombies.zombie_count = 0

    local weapons = parameters.attributes.weapons
    local use_custom_weapons = (weapons.use == true)
    zombies.human_weapons = use_custom_weapons

    if (zombies.human_weapons) then
        local count = 0
        local map = weapons[zombies.map]
        if (map) then
            for _, Weapon in pairs(weapons[zombies.map]) do
                if (Weapon ~= nil) then
                    count = count + 1
                end
            end
        end
        if (count == 0) then
            zombies.human_weapons = false
        end
    end
end

-- Variables for String Library:
local format = string.format
local gsub = string.gsub

-- Variables for Math Library:
local floor = math.floor

-- Game Variables:
local gamestarted
local delta_time = 0.03333333333333333
local kill_message_addresss, originl_kill_message
local script_version = 1.6

function OnScriptLoad()

    -- Register needed event callbacks:
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb['EVENT_TICK'], "OnTick")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb['EVENT_DIE'], 'OnPlayerDeath')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamageApplication")
    register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
    register_callback(cb['EVENT_WEAPON_DROP'], "OnWeaponDrop")

    kill_message_addresss = sig_scan("8B42348A8C28D500000084C9") + 3
    originl_kill_message = read_dword(kill_message_addresss)

    if (get_var(0, '$gt') ~= "n/a") then
        gamestarted = false
        zombies:init()
        for i = 1, 16 do
            if player_present(i) then
                zombies:initPlayer(i, get_var(i, "$team"), true)
                zombies:gameStartCheck(i)
            end
        end
    end
end

function OnScriptUnload()
    --
end

function zombies:enableKillMessages()
    safe_write(true)
    write_dword(kill_message_addresss, originl_kill_message)
    safe_write(false)
end

function zombies:disableKillMessages()
    safe_write(true)
    write_dword(kill_message_addresss, 0x03EB01B1)
    safe_write(false)
end

function OnTick()

    local count = zombies:GetPlayerCount()
    local countdown_index, countdown = zombies:GetTimer("Pre-Game Countdown")
    local nozombie_index, nozombies = zombies:GetTimer("No Zombies")
    local assist_index, assistance = zombies:GetTimer("Assistance")
    local countdown_begun = (countdown.init == true)

    for i, player in pairs(zombies.players) do
        if (player) and player_present(i) then

            local isHteam = (player.team == parameters.human_team)
            local isZteam = (player.team == parameters.zombie_team)
            local isLastMan = (player.last_man ~= nil)

            if (countdown.print_nep) and (not gamestarted) and (count < parameters.required_players) then
                zombies:cls(i, 25)
                local msg = gsub(gsub(parameters.not_enough_players,
                        "%%current%%", count),
                        "%%required%%", parameters.required_players)
                rprint(i, msg)

            elseif (countdown_begun) and (not gamestarted) and (zombies.pregame) then
                zombies:cls(i, 25)
                rprint(i, zombies.pregame)

            elseif (gamestarted) then

                -- Weapon Assignment and Attribute Logic:
                if player_alive(i) then
                    local player_object = get_dynamic_player(i)
                    if (player_object ~= 0) then

                        if (isZteam) and (player.zombie_assign) then
                            local coords = zombies:getXYZ(i, player_object)
                            if (not coords.invehicle) then
                                player.zombie_assign = false
                                execute_command("wdel " .. i)
                                local oddball = spawn_object("weap", zombies.zombie_weapon, coords.x, coords.y, coords.z)
                                assign_weapon(oddball, i)
                                player.drone = oddball
                            end
                        end

                        local attributes = parameters.attributes
                        local weapons = attributes.weapons

                        for index, attribute in pairs(attributes) do

                            -- Human Weapon Assignment:
                            if (player.human_assign) and (index == "Humans") and (isHteam or isLastMan) then
                                local coords = zombies:getXYZ(i, player_object)
                                if (not coords.invehicle) then
                                    player.human_assign = false
                                    execute_command("wdel " .. i)
                                    for Slot, Weapon in pairs(weapons[zombies.map]) do
                                        if (Slot == 1 or Slot == 2) then
                                            assign_weapon(spawn_object("weap", Weapon, coords.x, coords.y, coords.z), i)
                                        elseif (Slot == 3 or Slot == 4) then
                                            timer(250, "DelaySecQuat", i, Weapon, coords.x, coords.y, coords.z)
                                        end
                                    end
                                end
                            end

                            -- Player is ZOMBIE:
                            if (index == "Zombies") and (isZteam) then
                                zombies:CamoOnCrouch(i)
                                -- Player is LAST MAN STANDING
                            elseif (index == "Last Man Standing") and (isHteam and isLastMan) then
                                zombies:CamoOnCrouch(i)
                                if (attribute.use_nav_marker) then
                                    zombies:SetNav(i)
                                end
                                if (attribute.regenerating_health) then
                                    if (player_object ~= 0) then
                                        if read_float(player_object + 0xE0) < 1 then
                                            write_float(player_object + 0xE0, read_float(player_object + 0xE0) + attribute.increment)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if (countdown_begun) then
        countdown.timer = countdown.timer + delta_time

        local timeRemaining = countdown.duration - floor(countdown.timer % 60)
        local char = zombies:getChar(timeRemaining)

        zombies.pregame = zombies.pregame or ""
        zombies.pregame = gsub(gsub(parameters.pre_game_message,
                "%%time_remaining%%", timeRemaining),
                "%%s%%", char)
        if (timeRemaining <= 0) then
            zombies:disableKillMessages()
            zombies:StopTimer(countdown_index, false)

            if (parameters.balance_teams) then
                for i = 1, 16 do
                    if player_present(i) then
                        zombies:sortPlayers(i, true)
                        local team = zombies:GetTeamType(i)
                        local msg = gsub(parameters.on_game_begin, "%%team%%", team)
                        rprint(i, msg)
                    end
                end
            else
                zombies:sortPlayers(nil, false)
            end

            gamestarted = true
            zombies:LastManCheck()
            execute_command("sv_map_reset")
            zombies:enableKillMessages()
        end
    elseif (nozombies.init) then
        nozombies.timer = nozombies.timer + delta_time

        local timeRemaining = nozombies.duration - floor(nozombies.timer % 60)
        local char = zombies:getChar(timeRemaining)

        zombies:cls(nil, 25, true)
        local msg = gsub(gsub(parameters.no_zombies, "%%time_remaining%%", timeRemaining), "%%s%%", char)
        zombies:broadcast(msg, false, false, nil, true)
        if (timeRemaining <= 0) then
            zombies:StopTimer(nozombie_index, false)
            zombies:SwitchToZombies()
        end
    elseif (assistance.init) then
        assistance.timer = assistance.timer + delta_time

        local timeRemaining = assistance.duration - floor(assistance.timer % 60)
        local char = zombies:getChar(timeRemaining)

        zombies:cls(nil, 25, true)
        local msg = gsub(gsub(parameters.zombie_assistance, "%%time_remaining%%", timeRemaining), "%%s%%", char)
        zombies:broadcast(msg, false, false, nil, true)
        if (timeRemaining <= 0) then
            zombies:StopTimer(assist_index, false)
            zombies:SwitchToZombies()
        end

    end
    if (gamestarted) then
        zombies:endGameCheck()
    end
end

function OnGameStart()
    if (get_var(0, '$gt') ~= "n/a") then
        zombies:init()

        -- Enable Weapons:
        EnableDisableWeapons(true)

        if not zombies:isTeamPlay() then
            zombies:unregisterSAPPEvents('Only supports team play!')
        elseif (parameters.required_players < 2) then
            zombies:unregisterSAPPEvents('Setting "required_players" cannot be less than 2!')
        elseif (parameters.balance_teams) then
            local function oddOrEven(Min, Max)
                math.randomseed(os.time())
                math.random();
                math.random();
                math.random();
                local num = math.random(Min, Max)
                if (num) then
                    return num
                end
            end
            if (oddOrEven(1, 2) % 2 == 0) then
                -- Number is even
                parameters.useEvenNumbers = true
            else
                -- Number is odd
                parameters.useEvenNumbers = false
            end
        end
    end
end

function OnGameEnd()
    zombies:StopTimer(nil, "ALL")
    gamestarted = false
end

function zombies:gameStartCheck(p)

    local player_count = zombies:GetPlayerCount()
    local required = parameters.required_players

    local _, countdown = zombies:GetTimer("Pre-Game Countdown")
    if (player_count >= required) and (not countdown.init) and (not gamestarted) then
        zombies:StartTimer()
    elseif (player_count >= required) and (countdown.print_nep) then
        countdown.print_nep = false
    elseif (player_count > 0 and player_count < required) then
        countdown.print_nep = true
    end

    -- Game has already begun. Set player to zombie team:
    if (gamestarted) and (p) then
        zombies:SwitchTeam(p, parameters.zombie_team, true, true, false)
    end
end

function OnPlayerConnect(p)
    zombies:initPlayer(p, get_var(p, "$team"), true)
    zombies:gameStartCheck(p)
end

function OnPlayerDisconnect(PlayerIndex)
    local p = tonumber(PlayerIndex)

    local player_count = zombies:GetPlayerCount()
    player_count = player_count - 1

    local team = get_var(p, "$team")
    if (team == parameters.zombie_team) then
        zombies:AddOrRemove("Zombies", false)
        zombies:CleanUpDrones(p, false)
    else
        zombies:AddOrRemove("Humans", false)
    end

    zombies:initPlayer(p, nil, false)
    local _, countdown = zombies:GetTimer("Pre-Game Countdown")

    if (gamestarted) then
        if (player_count <= 0) then

            -- Ensure all timer parameters are set to their default values.
            zombies:StopTimer(nil, "ALL")

            -- One player remains | ends the game.
        elseif (player_count == 1) then
            for i = 1, 16 do
                if (tonumber(i) ~= tonumber(p)) then
                    if player_present(i) then
                        -- Send game over message to the last remaining player:
                        local team = zombies:GetTeamType(i)
                        zombies:broadcast(gsub(parameters.end_of_game, "%%team%%", team), true)
                    end
                end
            end

            -- No Zombies left! | Select random player to become Zombie
        elseif (zombies.zombie_count <= 0 and zombies.human_count >= 1) then
            local _, nozombies = zombies:GetTimer("No Zombies")
            nozombies.init, nozombies.timer = true, 0
        elseif (zombies.human_count <= 0 and zombies.zombie_count >= 1) then
            zombies:broadcast(gsub(parameters.end_of_game, "%%team%%", "zombie"), true)
        elseif (zombies.human_count == 1 and zombies.zombie_count >= 1) then
            zombies:LastManCheck()
        end

        -- Pre-Game countdown was initiated but someone left before the game began.
        -- Stop the timer, reset the countdown and display the continuous
        -- message emitted when there aren't enough players to start the game.
    elseif (not gamestarted) and (countdown.init and player_count < parameters.required_players) then
        countdown.init, countdown.timer, countdown.print_nep = false, 0, true
    end
end

function OnPlayerSpawn(PlayerIndex)
    local PlayerObject = get_dynamic_player(PlayerIndex)
    if (PlayerObject ~= 0 and gamestarted) then
        if player_alive(PlayerIndex) then
            local player = zombies:PlayerTable(PlayerIndex)
            local speed = zombies:GetSpeed(player)

            local isHteam = (player.team == parameters.human_team)
            local isZteam = (player.team == parameters.zombie_team)
            local isLastMan = (player.last_man ~= nil)

            local weapons = parameters.attributes.weapons
            local use = (weapons.use == true)

            execute_command_sequence("w8 0.5;s " .. PlayerIndex .. " " .. speed)

            if (isZteam) then
                -- Set grenades to 0 for zombies:
                write_word(PlayerObject + 0x31E, 0)
                write_word(PlayerObject + 0x31F, 0)

                -- Set weapon assignment flag to true:
                player.zombie_assign = true
                -- Set zombie kill count to zero:
                player.kills = 0
            elseif (isHteam or isLastMan) and (use) then
                player.human_assign = zombies.human_weapons
            end
        end
    end
end

function zombies:GetSpeed(player)
    local isHteam = (player.team == parameters.human_team)
    local isZteam = (player.team == parameters.zombie_team)
    local isLastMan = (player.last_man ~= nil)

    for index, attribute in pairs(parameters.attributes) do
        if (index == "Humans") and (isHteam) then
            if (attribute.running_speed > 0) then
                return attribute.running_speed
            end
        elseif (index == "Zombies") and (isZteam) then
            if (attribute.running_speed > 0) then
                return attribute.running_speed
            end
        elseif (index == "Last Man Standing") and (isHteam and isLastMan) then
            if (attribute.running_speed > 0) then
                return attribute.running_speed
            end
        end
    end
    return 1
end

function OnWeaponDrop(PlayerIndex)
    zombies:CleanUpDrones(PlayerIndex, true)
end

function OnPlayerDeath(PlayerIndex, KillerIndex)

    if (gamestarted) then

        local killer = tonumber(KillerIndex)
        local victim = tonumber(PlayerIndex)

        local kteam = get_var(killer, "$team")
        local vteam = get_var(victim, "$team")

        local kname = get_var(killer, "$name")
        local vname = get_var(victim, "$name")

        local fall_damage = (zombies.damage[victim] == zombies.falldamage)
        local distance_damage = (zombies.damage[victim] == zombies.distancedamage)
        local params = {}

        params.kname = kname
        params.vname = vname

        if (killer > 0) then

            -- Check for suicide:
            if (killer == victim) then
                if (vteam == parameters.human_team) then
                    params.on_zombify = true
                    zombies:SwitchTeam(victim, parameters.zombie_team)
                end
            end

            -- PvP:
            if (killer ~= victim) then

                -- Zombie vs Human
                if (kteam == parameters.zombie_team) and (vteam == parameters.human_team) then

                    params.on_zombify = true
                    -- Switch victim to Zombie team:
                    zombies:SwitchTeam(victim, parameters.zombie_team)

                    local player = zombies:PlayerTable(killer)
                    player.kills = player.kills + 1

                    if (zombies.zombie_count <= parameters.assistance_zombie_count) then
                        player.assistance_score = player.assistance_score - 1
                        if (player.assistance_score <= 0) then
                            player.assistance_score = 0
                        end
                    end

                    -- If zombie has "cure_threshold" kills, set them to human team:
                    if (player.kills == parameters.cure_threshold) then
                        params.zombie_cured = true
                        zombies:SwitchTeam(killer, parameters.human_team)
                    end

                    -- Human vs Zombie:
                elseif (kteam == parameters.human_team) and (vteam == parameters.zombie_team) then

                    zombies:CleanUpDrones(victim, false)

                    if (parameters.assistance) then
                        local player = zombies:PlayerTable(victim)
                        player.assistance_score = player.assistance_score + 1

                        if (player.assistance_score == parameters.zombies_assistance_threshold) then
                            player.assistance_score = 0
                            if (zombies.human_count >= 2) then
                                local _, assistance = zombies:GetTimer("Assistance")
                                assistance.init = true
                            end
                        end
                    end
                end
            end
        elseif (fall_damage) or (distance_damage) then
            if (vteam == parameters.human_team) then
                zombies:SwitchTeam(victim, parameters.zombie_team)
                params.on_zombify = true
            end
        end
        if (params) and (params.on_zombify) then
            local player = zombies:PlayerTable(victim)
            local isLastMan = (player.last_man ~= nil)
            if (isLastMan) then
                player.last_man = nil
            end
            zombies:LastManCheck(params)
        end
        execute_command("wdel " .. victim)
    end
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, _, _)
    zombies.damage[PlayerIndex] = MetaID
    if (tonumber(CauserIndex) > 0 and PlayerIndex ~= CauserIndex and gamestarted) then

        local cTeam = get_var(CauserIndex, "$team")
        local vTeam = get_var(PlayerIndex, "$team")

        if (cTeam == vTeam) then
            return false
        else

            local player = zombies:PlayerTable(CauserIndex)
            local isHteam = (cTeam == parameters.human_team)
            local isZteam = (cTeam == parameters.zombie_team)
            local isLastMan = (player.last_man ~= nil)

            for index, attribute in pairs(parameters.attributes) do
                if (index == "Humans") and (isHteam) and (not isLastMan) then
                    return true, Damage * attribute.damage_multiplier
                elseif (index == "Last Man Standing") and (isHteam and isLastMan) then
                    return true, Damage * attribute.damage_multiplier
                elseif (index == "Zombies") and (isZteam) then
                    return true, Damage * attribute.damage_multiplier
                end
            end
        end
    end
end

function zombies:killPlayer(PlayerIndex)
    local player = get_player(PlayerIndex)
    if (player ~= 0) then
        local PlayerObject = read_dword(player + 0x34)
        if (PlayerObject ~= nil) then
            destroy_object(PlayerObject)
        end
    end
end

function zombies:SwitchTeam(PlayerIndex, team, bool, GameStartCheck, AutoSort)

    local player = zombies:PlayerTable(PlayerIndex)

    local function InitPlayer()
        if (not player) then
            if (GameStartCheck) then
                team = parameters.zombie_team
            end
            zombies:initPlayer(PlayerIndex, team, true)
            player = zombies:PlayerTable(PlayerIndex)
        end
    end
    InitPlayer()

    player.team = team

    local CurrentTeam = get_var(PlayerIndex, "$team")
    local sameteam = (CurrentTeam == team)

    if (team == parameters.zombie_team) then
        local nozombie_index, nozombies = zombies:GetTimer("No Zombies")
        if (nozombies.init) then
            zombies:StopTimer(nozombie_index, false)
        end
    end

    if (AutoSort) then

        -- Human -> Human
        if (sameteam) and (CurrentTeam == parameters.human_team) then
            zombies:AddOrRemove("Humans", true)
            -- Zombie -> Zombie
        elseif (sameteam) and (CurrentTeam == parameters.zombie_team) then
            zombies:AddOrRemove("Zombies", true)
            -- Human -> Zombie
        elseif (not sameteam) and (CurrentTeam == parameters.human_team) then
            zombies:AddOrRemove("Zombies", true)
            -- Zombie -> Human
        elseif (not sameteam) and (CurrentTeam == parameters.zombie_team) then
            zombies:AddOrRemove("Humans", true)
        end

    elseif (GameStartCheck) then
        -- Game has already started. Increment zombie count by 1
        zombies:AddOrRemove("Zombies", true)

        -- Human -> Zombie
    elseif (not sameteam) and (CurrentTeam == parameters.human_team) then
        zombies:AddOrRemove("Humans", false)
        zombies:AddOrRemove("Zombies", true)
        -- Zombie -> Human
    elseif (not sameteam) and (CurrentTeam == parameters.zombie_team) then
        zombies:AddOrRemove("Humans", true)
        zombies:AddOrRemove("Zombies", false)
    end

    zombies:disableKillMessages()
    if not (bool) then

        -- Set the player's team:
        if (not sameteam) then
            execute_command("st " .. tonumber(PlayerIndex) .. " " .. tostring(team))
        end

        -- Override respawn time:
        if (zombies.respawn_override == true) then
            local Player = get_player(PlayerIndex)
            if (Player ~= 0) then
                write_dword(Player + 0x2C, parameters.respawn_time * 33)
            end
        end

        -- Set their health:
        local health = zombies:setHealth(PlayerIndex, team)
        execute_command_sequence("w8 " .. (parameters.respawn_time + 1) .. ";hp " .. PlayerIndex .. " " .. health)
    else
        -- Set the player's team:
        execute_command("st " .. tonumber(PlayerIndex) .. " " .. tostring(team))
        local health = zombies:setHealth(PlayerIndex, team)
        execute_command_sequence("w8 2;hp " .. PlayerIndex .. " " .. health)
    end
    zombies:enableKillMessages()
end

function zombies:broadcast(message, endgame, exclude, player, Console)
    execute_command("msg_prefix \"\"")
    if (not exclude) then
        if not (Console) then
            say_all(message)
        else
            for i = 1, 16 do
                if player_present(i) then
                    rprint(i, message)
                end
            end
        end
    else
        for i = 1, 16 do
            if player_present(i) then
                if (i ~= player) then
                    say(i, message)
                end
            end
        end
    end

    execute_command("msg_prefix \" " .. parameters.server_prefix .. "\"")
    -- End the game if variable "GameOver" is true.
    if (endgame) then
        execute_command("sv_map_next")
    end
end

function zombies:StartTimer()
    local _, countdown = zombies:GetTimer("Pre-Game Countdown")
    countdown.init, countdown.timer = true, 0
end

function zombies:StopTimer(TableIndex, StopALL)

    for Index, Timer in pairs(zombies.timers) do
        if (not StopALL) and (Index == TableIndex) then
            Timer.timer, Timer.init = 0, false
        elseif (StopALL) then
            Timer.timer, Timer.init = 0, false
        end
        if (Timer.print_nep) then
            Timer.print_nep = false
        end
    end

    -- Clear Console for all player:
    for i = 1, 16 do
        if player_present(i) then
            zombies:cls(i, 25)
        end
    end

    --
    if (gamestarted) then
        EnableDisableWeapons(false)
    end
end

function EnableDisableWeapons(State)

    if (State) then
        -- Enable vehicles for both teams:
        State = "enable_object"
        execute_command("disable_all_vehicles 0 0")
    else
        -- Disable vehicles for both teams:
        State = "disable_object"
        execute_command("disable_all_vehicles 0 1")
    end

    execute_command(State .. " 'weapons\\assault rifle\\assault rifle' 2")
    execute_command(State .. " 'weapons\\flamethrower\\flamethrower' 2")
    execute_command(State .. " 'weapons\\needler\\mp_needler' 2")
    execute_command(State .. " 'weapons\\pistol\\pistol' 2")
    execute_command(State .. " 'weapons\\plasma pistol\\plasma pistol' 2")
    execute_command(State .. " 'weapons\\plasma rifle\\plasma rifle' 2")
    execute_command(State .. " 'weapons\\plasma_cannon\\plasma_cannon' 2")
    execute_command(State .. " 'weapons\\rocket launcher\\rocket launcher' 2")
    execute_command(State .. " 'weapons\\shotgun\\shotgun' 2")
    execute_command(State .. " 'weapons\\sniper rifle\\sniper rifle' 2")

    -- Disable Grenades for Zombies:
    execute_command(State .. " 'weapons\\frag grenade\\frag grenade' 2")
    execute_command(State .. " 'weapons\\plasma grenade\\plasma grenade' 2")
end

function zombies:endGameCheck()
    -- No humans left -> zombies win
    local reds, blues = tonumber(get_var(0, "$reds")), tonumber(get_var(0, "$blues"))
    if (reds == 0 and blues >= 1) then
        zombies:broadcast(gsub(parameters.end_of_game, "%%team%%", "Zombies"), true)
    end
end

-- This function deletes stray oddballs:
function zombies:CleanUpDrones(PlayerIndex, Assign)
    local player = zombies:PlayerTable(PlayerIndex)
    if (player) then
        if (player.team == parameters.zombie_team) then
            if (player.drone) then
                destroy_object(player.drone)
                player.drone = nil
            end
            if (Assign) then
                player.zombie_assign = true
            end
        end
    end
end

function zombies:cls(PlayerIndex, count, AllPlayers)
    count = count or 25
    if (not AllPlayers) then
        for _ = 1, count do
            rprint(PlayerIndex, " ")
        end
    else
        for i = 1, 16 do
            if player_present(i) then
                for _ = 1, count do
                    rprint(i, " ")
                end
            end
        end
    end
end

function zombies:isTeamPlay()
    if (get_var(0, "$ffa") == "0") then
        return true
    end
end

function zombies:sortPlayers(PlayerIndex, BalanceTeams)
    if (BalanceTeams) then
        if (parameters.useEvenNumbers) then
            if (tonumber(PlayerIndex) % 2 == 0) then
                zombies:setTeam(PlayerIndex, parameters.zombie_team, true)
            else
                zombies:setTeam(PlayerIndex, parameters.human_team, true)
            end
        else
            if (tonumber(PlayerIndex) % 2 == 0) then
                zombies:setTeam(PlayerIndex, parameters.human_team, true)
            else
                zombies:setTeam(PlayerIndex, parameters.zombie_team, true)
            end
        end
    else

        local players = { }
        for i = 1, 16 do
            if player_present(i) then
                players[#players + 1] = i
            end
        end

        if (#players > 0) then

            math.randomseed(os.time())
            math.random();
            math.random();
            math.random();

            -- Choose random player to become Zombie (blue team):
            local player = players[math.random(1, #players)]
            zombies:setTeam(player, parameters.zombie_team, true)
            local team = zombies:GetTeamType(player)
            local msg = gsub(parameters.on_game_begin, "%%team%%", team)
            rprint(player, msg)

            -- Set every other player as a human (red team):
            for i = 1, 16 do
                if (player_present(i) and i ~= player) then
                    zombies:setTeam(i, parameters.human_team, true)
                    local team = zombies:GetTeamType(i)
                    local msg = gsub(parameters.on_game_begin, "%%team%%", team)
                    rprint(i, msg)
                end
            end
        end
    end
end

function zombies:setHealth(PlayerIndex, Team)

    local player = zombies:PlayerTable(PlayerIndex)
    local isHteam = (player.team == parameters.human_team)
    local isZteam = (player.team == parameters.zombie_team)
    local isLastMan = (player.last_man ~= nil)

    for index, attribute in pairs(parameters.attributes) do
        if (index == "Humans") and (isHteam) and (not isLastMan) then
            return tonumber(attribute.health)
        elseif (index == "Last Man Standing") and (isHteam and isLastMan) then
            return tonumber(attribute.health)
        elseif (index == "Zombies") and (isZteam) then
            return tonumber(attribute.health)
        end
    end
end

function zombies:GetTeamType(p)
    local team = get_var(p, "$team")
    if (team == parameters.human_team) then
        return "human"
    else
        return "zombie"
    end
end

function zombies:setTeam(PlayerIndex, team, AutoSort)
    local PlayerObject = get_dynamic_player(PlayerIndex)
    execute_command("wdel " .. PlayerIndex)

    if (PlayerObject ~= 0) then
        zombies:killPlayer(PlayerIndex)
        write_word(PlayerObject + 0x31E, 0)
        write_word(PlayerObject + 0x31F, 0)
    end

    zombies:SwitchTeam(PlayerIndex, team, nil, nil, AutoSort)
    zombies:ResetScore(PlayerIndex)
end

function zombies:LastManCheck(params)

    local params = params or {}

    if (zombies.human_count == 1 and zombies.zombie_count >= 1) then
        for i, player in pairs(zombies.players) do
            if (player) and player_present(i) then
                if (player.team == parameters.human_team) then
                    if (player.last_man == nil) then
                        player.last_man, params.last_man = true, player.name
                        for index, attribute in pairs(parameters.attributes) do
                            if (index == "Last Man Standing") then
                                local player_object = get_dynamic_player(i)
                                if (player_object ~= 0) then
                                    if (attribute.overshield) then
                                        zombies:ApplyOvershield(i)
                                    end
                                    write_float(player_object + 0xE0, floor(tonumber(attribute.health)))
                                    local speed = zombies:GetSpeed(player)
                                    execute_command_sequence("w8 1;s " .. i .. " " .. speed)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local msg = nil
    if (not params.last_man) then
        if (params.on_zombify) and (not params.zombie_cured) then
            msg = gsub(gsub(parameters.on_zombify, "%%victim%%", params.vname), "%%killer%%", params.kname)
        elseif (params.on_zombify) and (params.zombie_cured) then
            msg = gsub(gsub(parameters.zombie_cured, "%%victim%%", params.vname), "%%killer%%", params.kname)
        end
    else
        msg = gsub(parameters.last_man, "%%lastman%%", params.last_man)
    end

    if (msg ~= nil) then
        zombies:broadcast(msg, false)
    end
end

function zombies:ApplyOvershield(PlayerIndex)
    if (player_present(PlayerIndex) and player_alive(PlayerIndex)) then
        local ObjectID = spawn_object("eqip", "powerups\\over shield")
        powerup_interact(ObjectID, PlayerIndex)
    end
end

function zombies:CamoOnCrouch(PlayerIndex)
    local team = get_var(PlayerIndex, "$team")

    for index, attribute in pairs(parameters.attributes) do
        if (index == "Zombies" and team == parameters.zombie_team) or (index == "Last Man Standing" and team == parameters.human_team) then
            if (attribute.invisibility_on_crouch) then
                local player_object = get_dynamic_player(PlayerIndex)
                if (player_object ~= 0) then
                    local couching = read_float(player_object + 0x50C)
                    if (couching == 1) then
                        execute_command("camo " .. PlayerIndex .. " 2")
                    end
                end
            end
        end
    end
end

function zombies:unregisterSAPPEvents(error)
    unregister_callback(cb['EVENT_TICK'])
    unregister_callback(cb['EVENT_GAME_END'])
    unregister_callback(cb['EVENT_JOIN'])
    unregister_callback(cb['EVENT_LEAVE'])
    unregister_callback(cb['EVENT_DIE'])
    unregister_callback(cb['EVENT_DAMAGE_APPLICATION'])
    execute_command("log_note \"" .. format('[Zpocalypse] ' .. error) .. "\"")
    cprint(format('[Zpocalypse] ' .. error), 4 + 8)
end

function zombies:GetPlayerCount()
    return tonumber(get_var(0, "$pn"))
end

function zombies:SetNav(LastMan)
    for i = 1, 16 do
        if player_present(i) then
            local PlayerSM = get_player(i)
            local PTableIndex = to_real_index(i)
            if (PlayerSM ~= 0) then
                if (LastMan ~= nil) then
                    write_word(PlayerSM + 0x88, to_real_index(LastMan))
                else
                    write_word(PlayerSM + 0x88, PTableIndex)
                end
            end
        end
    end
end

function zombies:getChar(input)
    local char = ""
    if (tonumber(input) > 1) then
        char = "s"
    elseif (tonumber(input) <= 1) then
        char = ""
    end
    return char
end

function zombies:ResetScore(PlayerIndex)
    execute_command("score " .. PlayerIndex .. " 0")
    execute_command_sequence("team_score 0 0")
end

function zombies:initPlayer(PlayerIndex, Team, Init)
    if (PlayerIndex) then
        local players = zombies.players
        if (Init) then
            zombies.damage[PlayerIndex] = nil
            players[PlayerIndex] = {
                kills = 0,
                assistance_score = 0,
                team = Team,
                drone = nil,
                zombie_assign = false,
                human_assign = false,
                last_man = nil,
                name = get_var(PlayerIndex, "$name"),
            }
        else
            players[PlayerIndex] = nil
        end
    end
    return true
end

function zombies:PlayerTable(PlayerIndex)
    local players = zombies.players
    for Index, player in pairs(players) do
        if (player) and (Index == PlayerIndex) then
            return player
        end
    end
    return nil
end

function zombies:getXYZ(PlayerIndex, PlayerObject)
    local coords, x, y, z = { }
    if player_alive(PlayerIndex) then
        local VehicleID = read_dword(PlayerObject + 0x11C)
        if (VehicleID == 0xFFFFFFFF) then
            coords.invehicle = false
            x, y, z = read_vector3d(PlayerObject + 0x5c)
        else
            coords.invehicle = true
            x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
        end

        if (coords.invehicle) then
            z = z + 1
        end
        coords.x, coords.y, coords.z = x, y, z
    end
    return coords
end

function zombies:GetTag()
    return {

        -- ============= [ STOCK WEAPONS ] ============= --
        [1] = "weapons\\pistol\\pistol",
        [2] = "weapons\\sniper rifle\\sniper rifle",
        [3] = "weapons\\plasma_cannon\\plasma_cannon",
        [4] = "weapons\\rocket launcher\\rocket launcher",
        [5] = "weapons\\plasma pistol\\plasma pistol",
        [6] = "weapons\\plasma rifle\\plasma rifle",
        [7] = "weapons\\assault rifle\\assault rifle",
        [8] = "weapons\\flamethrower\\flamethrower",
        [9] = "weapons\\needler\\mp_needler",
        [10] = "weapons\\shotgun\\shotgun",
        [11] = "weapons\\ball\\ball",
        [12] = "weapons\\flag\\flag",

        -- ============= [ CUSTOM WEAPONS ] ============= --
        -- Weapon indexes 13-30 belong to bigassv2,104
        [13] = "altis\\weapons\\binoculars\\binoculars",
        [14] = "altis\\weapons\\binoculars\\gauss spawner\\create gauss",
        [15] = "altis\\weapons\\smoke\\smoke",
        [16] = "bourrin\\halo reach\\vehicles\\warthog\\gauss\\gauss gun",
        [17] = "bourrin\\halo reach\\vehicles\\warthog\\rocket\\rocket",
        [18] = "bourrin\\weapons\\dmr\\dmr",
        [19] = "bourrin\\weapons\\ma5k\\cmt's ma5k reloaded",
        [20] = "bourrin\\weapons\\masternoob's assault rifle\\assault rifle",
        [21] = "cmt\\weapons\\human\\shotgun\\shotgun",
        [22] = "cmt\\weapons\\human\\stealth_sniper\\sniper rifle",
        [23] = "halo reach\\objects\\weapons\\support_high\\spartan_laser\\spartan laser",
        [24] = "halo3\\weapons\\odst pistol\\odst pistol",
        [25] = "my_weapons\\trip-mine\\trip-mine",
        [26] = "reach\\objects\\weapons\\pistol\\magnum\\magnum",
        [27] = "vehicles\\le_falcon\\weapon",
        [28] = "vehicles\\scorpion\\scorpion cannon_heat",
        [29] = "weapons\\gauss sniper\\gauss sniper",
        [30] = "weapons\\rocket launcher\\rocket launcher test",

        -- repeat the structure to add more weapon tags:
        [31] = "tag_goes_here",
    }
end

function DelaySecQuat(PlayerIndex, Weapon, x, y, z)
    assign_weapon(spawn_object("weap", Weapon, x, y, z), PlayerIndex)
end

function zombies:SwitchToZombies()

    local players = { }
    for i = 1, 16 do
        if player_present(i) then
            if (get_var(i, "$team") == parameters.human_team) then
                players[#players + 1] = i
            end
        end
    end

    if (#players > 0) then

        local iterations = 0
        while (true) do
            iterations = iterations + 1
            math.randomseed(os.time())
            math.random();
            math.random();
            math.random();
            local index = players[math.random(1, #players)]
            local player = zombies:PlayerTable(index)

            if (player.last_man == nil) then
                local params = {}
                params.vname = player.name
                zombies:setTeam(index, parameters.zombie_team)

                zombies:broadcast(player.name .. " was switched to zombie team")
                zombies:LastManCheck(params)
                break
            end

            if (iterations > 500) then
                break
            end
        end
    end
end

function zombies:GetTimer(type)
    for Index, Timer in pairs(zombies.timers) do
        if (Index == type) then
            return Index, Timer
        end
    end
end

function zombies:AddOrRemove(Type, Add)
    if (Type == "Zombies") then
        if (Add) then
            zombies.zombie_count = zombies.zombie_count + 1
        else
            zombies.zombie_count = zombies.zombie_count - 1
        end
    elseif (Type == "Humans") then
        if (Add) then
            zombies.human_count = zombies.human_count + 1
        else
            zombies.human_count = zombies.human_count - 1
        end
    end
end

function zombies:LookupTag(obj_type, obj_name)
    local tag = lookup_tag(obj_type, obj_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function report()
    local version = format("%0.2f", script_version)
    cprint("--------------------------------------------------------", 5 + 8)
    cprint("Please report this error on github:", 7 + 8)
    cprint("https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/issues", 7 + 8)
    cprint("Script Version: " .. version, 7 + 8)
    cprint("--------------------------------------------------------", 5 + 8)
end

function OnError()
    local error = debug.traceback()
    cprint(error, 4 + 8)
    local file = io.open("zombies error log.log", "a+")
    if file then
        file:write(error .. "\n")
        file:close()
    end
    timer(50, "report")
end
