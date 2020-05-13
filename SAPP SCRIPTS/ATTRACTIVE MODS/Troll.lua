--[[
--=====================================================================================================--
Script Name: Troll, for SAPP (PC & CE)
Description: A unique mod designed to troll your whole server (or specific players)

Features:
* Damage Modifier           Randomly change damage multipliers.
* Chat Text Randomizer      Jumbles up characters in some sentences.
* Silent Kill               Inexplicable deaths (no death message).
* Teleport Under Map        Randomly teleport players under the map.
* Flag Dropper              Randomly forces a player to drop the flag.
* Vehicle Exit              Randomly ejects a player from their vehicle.
* Name Changer              Change player name to a random pre-defined name.
* Ammo Changer              Randomly change weapon ammo/battery and grenades.
* Silent Kick               Force player to disconnect (no kick message output).
* Random Color Change       Randomly change a player's colour when they spawn.
* Client Crasher            Randomly crash a player's game client.
* Nuke                      Randomly nuke a player.
* Fake Join-Quit            Randomly show fake player join/quit messages to the target.
* Force Chat:               [1] Randomly force a player to say something from a list of pre-defined sentences.
                            [2] Optionally force a player to say something with a custom command.

* Add/Remove commands (see config section for more details):
/addtroll [player id]
/removetroll [player id]

Copyright (c) 2020, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/Halo-Scripts-Phasor-V2-/blob/master/LICENSE

* Written by Jericho Crosby (Chalwk)

Credits to Kavawuvi and Devieth for functions at bottom of script.
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

-- Configuration [STARTS] ------------------------------------------------------
local Troll = {

    -------- [ S E T T I N G S ] ----------
    --===================================--
    settings = {

        -- This command lets you manually add a player to the
        -- troll list (bypassing "ignore_admins" settings and "specific_users" settings).
        -- Command Syntax: /add_troll_command <player id>
        add_troll_command = "addtroll",
        add_troll_permission = 1,
        --------------

        -- This command will prevent a player from being trolled by this script.
        remove_troll_command = "deltroll",
        remove_troll_permission = 1,
        --------------

        -- Several functions temporarily remove the server prefix when certain messages are broadcast.
        -- The prefix will be restored to 'server_prefix' when the relay has finished.
        -- Enter your server prefix here:
        server_prefix = "**SAPP**",

        --[[

        If "specific_users_only" is true, then only players whose IP addresses
        are in this list will be affected by this script.

        If "specific_users_only" is false then all players will be affected,
        excluding Admins under special circumstances (see below):

        If a player is an admin, they will be affected unless
        "ignore_admins" is "true" for each specific feature
        and their level is >= "ignore_admin_level" level.

        ]]

        specific_users_only = true,
        specific_users = {
            "127.0.0.1", -- Local Host
            "108.5.107.145" -- DeathBringR
        },

        -- Do Not Touch this.
        script_version = 1.3
    },

    -------- [ F E A T U R E S ] ----------
    --===================================--
    features = {

        ["Damage Modifier"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            multipliers = {

                -- I wanted to give the end user the opportunity to change
                -- the min/max damage multipliers on a per-damage-type basis,
                -- as well as the chances of applied damage being effected by this script.

                -- EXAMPLE 1:
                -- Will generate random number between (1) and (10) units with a (3 in 6) chance of this happening.
                -- The damage dealt will have a reduced number of units by the random number generated above.
                -- { "weapons\\assault rifle\\melee", 8, 10, { 3, 6 } },

                -- Additionally, the chance of a players damage multiplier being affected
                -- is randomized every application of damage.

                melee = {
                    { "weapons\\assault rifle\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\ball\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\flag\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\flamethrower\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\needler\\melee", 8, 10, { 1, 3 } },
                    { "weapons\\pistol\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\plasma pistol\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\plasma rifle\\melee", 8, 10, { 1, 4 } },
                    { "weapons\\rocket launcher\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\shotgun\\melee", 8, 10, { 1, 3 } },
                    { "weapons\\sniper rifle\\melee", 8, 10, { 1, 2 } },
                    { "weapons\\plasma_cannon\\effects\\plasma_cannon_melee", 8, 10, { 1, 2 } },
                },

                grenades = {

                    -- EXAMPLE 2:
                    -- There are separate damage multipliers for causers, and victims.

                    -- For example, you will lose a minimum of 7 and maximum of 10 units of damage dealt to your victims
                    -- with a 1 in 2 chance of this happening.

                    -- If you grenade yourself, you will receive 10x normal damage

                    { "weapons\\frag grenade\\explosion", others = { 7, 10 }, you = { 10, 10 }, { 1, 2 } },
                    { "weapons\\plasma grenade\\explosion", others = { 6, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\plasma grenade\\attached", others = { 8, 10 }, you = { 10, 10 }, { 1, 2 } },
                },

                vehicles = {
                    { "vehicles\\ghost\\ghost bolt", 6, 10, { 1, 3 } },
                    { "vehicles\\scorpion\\bullet", 5, 10, { 1, 6 } },
                    { "vehicles\\warthog\\bullet", 7, 10, { 1, 5 } },
                    { "vehicles\\c gun turret\\mp bolt", 7, 10, { 1, 6 } },
                    { "vehicles\\banshee\\banshee bolt", 6, 10, { 1, 3 } },
                    { "vehicles\\scorpion\\shell explosion", 8, 10, { 1, 2 } },
                    { "vehicles\\banshee\\mp_fuel rod explosion", 8, 10, { 1, 2 } },
                },

                projectiles = {
                    { "weapons\\pistol\\bullet", others = { 7, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\plasma rifle\\bolt", others = { 6, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\shotgun\\pellet", others = { 5, 10 }, you = { 10, 10 }, { 1, 4 } },
                    { "weapons\\plasma pistol\\bolt", others = { 8, 10 }, you = { 10, 10 }, { 1, 6 } },
                    { "weapons\\needler\\explosion", others = { 7, 10 }, you = { 10, 10 }, { 1, 4 } },
                    { "weapons\\assault rifle\\bullet", others = { 6, 10 }, you = { 10, 10 }, { 1, 2 } },
                    { "weapons\\needler\\impact damage", others = { 6, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\flamethrower\\explosion", others = { 7, 10 }, you = { 10, 10 }, { 1, 2 } },
                    { "weapons\\sniper rifle\\sniper bullet", others = { 8, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\rocket launcher\\explosion", others = { 7, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\needler\\detonation damage", others = { 7, 10 }, you = { 10, 10 }, { 1, 2 } },
                    { "weapons\\plasma rifle\\charged bolt", others = { 5, 10 }, you = { 10, 10 }, { 1, 3 } },
                    { "weapons\\plasma_cannon\\effects\\plasma_cannon_melee", others = { 8, 10 }, you = { 10, 10 }, { 1, 2 } },
                    { "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion", others = { 7, 10 }, you = { 10, 10 }, { 1, 2 } },
                },
                {

                    vehicle_collision = { "globals\\vehicle_collision", others = { 7, 10 }, you = { 10, 10 }, { 1, 3 } },
                },

                fall_damage = {
                    { "globals\\falling", you = { 10, 10 }, chance = { 1, 3 } },
                    { "globals\\distance", you = { 10, 10 }, chance = { 1, 3 } },
                },
            }
        },

        ["Chat Text Randomizer"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            min_chances = 1, -- 1 in 6 chance of your messages being randomized every time you chat.
            max_chances = 6,
            format = {

                --[[ Custom Variables:

                    %name% - will output the players name
                    %msg% - will output message

                    -- Add this if you're using my ChatID script! (or because reasons)
                    "%id% - will output the Player Index ID

                --]]

                global = "%name%: %msg%",
                team = "[%name%]: %msg%",
                vehicle = "[%name%]: %msg%"
            }
        },

        ["Silent Kill"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- When a player spawns, the interval until they are killed is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 35, -- in seconds
            max = 300, -- in seconds
        },

        ["Teleport Under Map"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- Players will be teleported a random number of world units under the map.
            -- The value of W/Units is a random number between minZ, maxZ
            minZ = 0.3, -- in world units
            maxZ = 0.4, -- in world units

            -- Players will be teleported under the map at a random time between min/max seconds.
            min = 60, -- in seconds
            max = 280, -- in seconds
        },

        ["Flag Dropper"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- When a player pick up the flag, the interval until they drop it is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 5, -- in seconds
            max = 120, -- in seconds
        },

        ["Vehicle Exit"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- When a player enters a vehicle, the interval until they are forced to exit is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 5, -- in seconds
            max = 140, -- in seconds
        },

        ["Name Changer"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- When a player joins, their new name will be randomly selected from this list.
            names = { -- Max 11 Characters only!
                { "iLoveAG" },
                { "iLoveV3" },
                { "loser4Eva" },
                { "iLoveChalwk" },
                { "iLoveSe7en" },
                { "iLoveAussie" },
                { "benDover" },
                { "clitEruss" },
                { "tinyDick" },
                { "cumShot" },
                { "PonyGirl" },
                { "iAmGroot" },
                { "twi$t3d" },
                { "maiBahd" },
                { "frown" },
                { "Laugh@me" },
                { "imaDick" },
                { "facePuncher" },
                { "TEN" },
                { "whatElse" },

                -- Repeat the structure to add more entries!
            }
        },

        ["Nuke"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            projectile = { "proj", "weapons\\rocket launcher\\rocket" },

            -- Quantity of projectiles spawned:
            min_projectiles = 1,
            max_projectiles = 10,


            -- The interval until they are nuked.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 55, -- in seconds
            max = 175, -- in seconds
        },

        ["Ammo Changer"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- Min/Max time until ammo count is modified:
            minAmmoTime = 15,
            maxAmmoTime = 300,

            -- Min/Max time until grenade count is modified:
            minNadeTime = 45,
            maxNadeTime = 250,

            weapons = {

                -- If battery powered weapon, set to true!
                { "weapons\\plasma rifle\\plasma rifle", true },
                { "weapons\\plasma_cannon\\plasma_cannon", true },
                { "weapons\\plasma pistol\\plasma pistol", true },

                { "weapons\\pistol\\pistol", false },
                { "weapons\\shotgun\\shotgun", false },
                { "weapons\\needler\\mp_needler", false },
                { "weapons\\sniper rifle\\sniper rifle", false },
                { "weapons\\assault rifle\\assault rifle", false },
                { "weapons\\flamethrower\\flamethrower", false },
                { "weapons\\rocket launcher\\rocket launcher", false },

            },
        },

        ["Silent Kick"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            announcements = {
                enabled = false,
                msg = "%name% was silently disconnected from the server!"
            },

            -- When a player joins, the interval until they are kicked is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 20, -- in seconds
            max = 360, -- in seconds
        },

        ["Random Color Change"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- Chance that someone's color will be changed when they spawn:
            chance = { 1, 6 },

            -- COLOR ID, Enabled/Disabled
            colors = {
                { 0, true }, --white
                { 1, true }, --black
                { 2, true }, --red
                { 3, true }, --blue
                { 4, true }, --gray
                { 5, true }, --yellow
                { 6, true }, --green
                { 7, true }, --pink
                { 8, true }, --purple
                { 9, true }, --cyan
                { 10, true }, --cobalt
                { 11, true }, --orange
                { 12, true }, --teal
                { 13, true }, --sage
                { 14, true }, --brown
                { 15, true }, --tan
                { 16, true }, --maroon
                { 17, true } --salmon
            }
        },

        ["Client Crasher"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- When a player joins, the interval until they are crashed is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 45, -- in seconds
            max = 270, -- in seconds
        },

        ["Fake Join-Quit"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            fake_join_message = "Welcome %fakename%",
            fake_quit_message = "%fakename% quit",

            names = {
                { "ILoveRock" },
                { "leila water" },
                { "LilTuGfa" },
                { "Nuevo001" },
                { "Jass" },
                { "Crypt®" },
                { "Carbono980" },
                { "shagnemite" },
                { "DA-n00b1n8R" },
                { "i- XTuAnuel" },
            },

            -- Interval until fake join/quit message is broadcast to the target player.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 65, -- in seconds
            max = 255, -- in seconds
        },

        ["Force Chat"] = {
            -- Set this to "false" to disable this feature on start up:
            enabled = true,

            ignore_admins = true,
            -- Admins who are this level (or higher) will be ignored:
            ignore_admin_level = 1,

            -- Command Syntax: /command [player id] {message}
            command = "fchat",

            -- Minimum permission level the player must be in order to execute /command:
            permission_level = 1,

            -- The interval until a player is forced to say something is randomized.
            -- The interval itself is an amount of seconds between "min" and "max".
            min = 60, -- in seconds
            max = 300, -- in seconds

            -- Players message output format:
            -- %name% is replaced with the players name
            -- %msg% is replaced with a random message from the list of sentences.
            chat_format = "%name%: %msg%",

            sentences = {
                "I suck at this game!",
                "I want my mommy!",
                "Momma always said life is like a box of chocolates",
                "I'm horny",
                "I like turtles",
                "I like eating human hotdogs",
                "I was born a bastard",
                "You can fuck my sister",
                "I am the reason the gene pool needs a lifeguard",
                "My only chance of getting laid is to crawl up the chicken's butt and wait!",
                "Warthogs are gay",
                "My favourite game type is CTF",
                "Race game types suck balls",
                "I ate some dirt out of the garden earlier",
                "I'm wearing lipstick",
                "Oh ouh! I shit myself. Be right back. Gotta clean up!",
                "I'm a little school girl",
                "I want to guzzle some gasoline",
                "My brother just spat in my face",
                "My mom said it's bed time. Bye fuckers",
                "My nana is sitting next to me and asked what I'm doing",
                "God damn my clothes smell",
                "Time to take a rip off my bowl",
                "I have to see my probation officer tomorrow",

                -- repeat the structure to add more entries
            },
        },
    }
}

-- Configuration [ENDS] ------------------------------------------------------

local game_over
local players = { }
local format = string.format
local gsub, sub, gmatch = string.gsub, string.sub, string.gmatch
local time_scale = 1 / 30

local flag, globals, ls, network_struct = { }, nil

function OnScriptLoad()

    -- Register needed event callbacks:
    register_callback(cb["EVENT_TICK"], "OnTick")

    register_callback(cb['EVENT_PREJOIN'], "OnPlayerPreJoin")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")

    register_callback(cb["EVENT_CHAT"], "OnPlayerChat")
    register_callback(cb["EVENT_PRESPAWN"], "OnPreSpawn")

    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_VEHICLE_ENTER"], "OnVehicleEntry")

    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "OnDamageApplication")

    local gp = sig_scan("8B3C85????????3BF9741FE8????????8B8E2C0200008B4610") + 3
    if (gp == 3) then
        return
    end
    globals = read_dword(gp)
    network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)

    if (Troll.features["Random Color Change"].enabled) then
        LSS(true)
    end

    if (get_var(0, "$gt") ~= "n/a") then
        game_over, players = false, { }
        for i = 1, 16 do
            if player_present(i) then
                InitPlayer(i, false)
            end
        end
    end
end

function OnScriptUnload()
    if (Troll.features["Random Color Change"].enabled) then
        LSS(false)
    end
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then
        game_over, players = false, { }
        flag = { read_word(globals + 0x8), read_word(globals + 0xc) }
        local nc = Troll.features["Name Changer"]
        if (nc.enabled) then
            for i = 1, #nc.names do
                nc.names[i].used = false
            end
        end
        local fjq = Troll.features["Fake Join-Quit"]
        if (fjq.enabled) then
            for i = 1, #fjq.names do
                fjq.names[i].joined = false
            end
        end
        PrintFeatureState()
    end
end

function OnGameEnd()
    game_over = true
end

function OnTick()

    if (not gameover) then

        for player, ply in pairs(players) do
            if (player) and player_present(player) then
                for Feature, V1 in pairs(Troll.features) do
                    for B, t in pairs(ply) do
                        if (Feature == B) then
                            if (V1.enabled) and TrollPlayer(player, V1) then

                                math.randomseed(os.time())
                                if player_alive(player) then
                                    local DynamicPlayer = get_dynamic_player(player)

                                    if (Feature == "Silent Kill") then

                                        t.timer = t.timer + time_scale
                                        if (t.timer >= t.time_until_kill) then
                                            KillSilently(player)
                                        end
                                    elseif (Feature == "Teleport Under Map") then

                                        if (not InVehicle(DynamicPlayer)) then
                                            t.timer = t.timer + time_scale
                                            if (math.floor(t.timer) >= t.time_until_tp) then
                                                t.timer = 0
                                                t.time_until_tp = math.random(V1.min, V1.max)
                                                local x, y, z = read_vector3d(DynamicPlayer + 0x5c)
                                                write_vector3d(DynamicPlayer + 0x5c, x, y, z - t.zaxis)
                                                cprint("[TROLL] " .. ply.name .. " was teleported under the map", 5 + 8)
                                            end
                                        end
                                    elseif (Feature == "Flag Dropper") then

                                        if (not InVehicle(DynamicPlayer)) then
                                            if hasObjective(DynamicPlayer) then
                                                t.hasflag = true
                                                t.timer = t.timer + time_scale
                                                if (math.floor(t.timer) >= t.time_until_drop) then
                                                    drop_weapon(player)
                                                    cprint("[TROLL] " .. ply.name .. " was forced to drop the flag", 5 + 8)
                                                end
                                            elseif (t.hasflag) then
                                                t.hasflag = false
                                                t.time_until_drop = math.random(V1.min, V1.max)
                                                t.timer = 0
                                            else
                                                t.timer = 0
                                            end
                                        end
                                    elseif (Feature == "Vehicle Exit") then
                                        if InVehicle(DynamicPlayer) then
                                            t.timer = t.timer + time_scale
                                            if (t.timer >= t.time_until_exit) then
                                                t.timer = 0
                                                exit_vehicle(player)
                                                cprint("[TROLL] " .. ply.name .. " was forced to exit their vehicle", 5 + 8)
                                            end
                                        end
                                    elseif (Feature == "Ammo Changer") then

                                        if (not InVehicle(DynamicPlayer)) then
                                            t.nade_timer = t.nade_timer + time_scale
                                            t.weapon_timer = t.weapon_timer + time_scale

                                            if (t.weapon_timer >= t.time_until_take_ammo) then
                                                t.weapon_timer = 0
                                                t.time_until_take_ammo = math.random(V1.minAmmoTime, V1.maxAmmoTime)

                                                local weapon = read_dword(DynamicPlayer + 0x118)
                                                local Object = get_object_memory(weapon)
                                                if (Object ~= 0) then

                                                    local weapons = V1.weapons
                                                    for i = 1, #weapons do
                                                        local tag_name = read_string(read_dword(read_word(Object) * 32 + 0x40440038))
                                                        if (tag_name == weapons[i][1]) then
                                                            local battery_powered = weapons[i][2]
                                                            if (battery_powered) then
                                                                local energy = read_float(Object + 0x240)
                                                                execute_command("battery " .. player .. " " .. math.random(0, energy) .. " 0")
                                                            else
                                                                local ammo = read_word(Object + 0x2B8)
                                                                safe_write(true)
                                                                write_dword(Object + 0x2B8, math.random(0, ammo))
                                                                safe_write(false)
                                                                sync_ammo(weapon)
                                                            end
                                                            cprint("[TROLL] " .. ply.name .. " had their ammo count modified", 5 + 8)
                                                        end
                                                    end
                                                end
                                            elseif (t.nade_timer >= t.time_until_take_nades) then
                                                t.nade_timer = 0
                                                t.time_until_take_nades = math.random(V1.minNadeTime, V1.maxNadeTime)

                                                local nade_type = math.random(1, 2)
                                                if (nade_type == 1) then

                                                    local current = read_byte(DynamicPlayer + 0x31E)
                                                    local amount_to_take = math.random(0, current)
                                                    execute_command("nades " .. player .. " " .. current - amount_to_take)

                                                elseif (nade_type == 2) then

                                                    local current = read_byte(DynamicPlayer + 0x31F)
                                                    local amount_to_take = math.random(0, current)
                                                    execute_command("plasmas " .. player .. " " .. current - amount_to_take)
                                                end
                                                cprint("[TROLL] " .. ply.name .. " had their grenade count modified", 5 + 8)
                                            end
                                        end
                                    elseif (Feature == "Client Crasher") then

                                        if not (t.delay) then
                                            t.timer = t.timer + time_scale
                                            if (t.timer >= t.time_until_crash) then
                                                t.timer = 0
                                                if hasObjective(DynamicPlayer) or InVehicle(DynamicPlayer) then
                                                    KillSilently(player)
                                                    t.delay = true
                                                else
                                                    CrashClient(player, DynamicPlayer)
                                                end
                                            end
                                        elseif player_alive(player) and (DynamicPlayer ~= 0) then
                                            CrashClient(player, DynamicPlayer)
                                        end
                                    elseif (Feature == "Nuke") then

                                        t.timer = t.timer + time_scale
                                        if (t.timer >= t.time_until_nuke) then
                                            t.timer = 0
                                            t.time_until_nuke = math.random(V1.min, V1.max)
                                            Nuke(DynamicPlayer, V1)
                                        end
                                    end
                                end

                                -- Player does not need to be alive to execute blocks of code below this line:
                                if (Feature == "Silent Kick") then

                                    t.timer = t.timer + time_scale
                                    if (t.timer >= t.time_until_kick) and (t.broadcast) then
                                        SilentKick(player, V1)
                                    end
                                elseif (Feature == "Force Chat") then

                                    t.timer = t.timer + time_scale
                                    if (t.timer >= t.time_until_say) then
                                        t.timer = 0
                                        t.time_until_say = math.random(V1.min, V1.max)
                                        local message = V1.sentences[math.random(#V1.sentences)]
                                        local str = V1.chat_format
                                        message = gsub(gsub(str, "%%name%%", ply.name), "%%msg%%", message)
                                        execute_command("msg_prefix \"\"")
                                        say_all(message)
                                        execute_command("msg_prefix \" " .. Troll.settings.server_prefix .. "\"")
                                        cprint("[TROLL] " .. ply.name .. " was forced to say random message!", 5 + 8)
                                    end
                                elseif (Feature == "Fake Join-Quit") then
                                    t.timer = t.timer + time_scale
                                    if (t.timer >= t.time_until_say) then
                                        t.timer = 0
                                        t.time_until_say = math.random(V1.min, V1.max)
                                        local n = math.random(#V1.names)
                                        local joined = V1.names[n].joined
                                        local name = V1.names[n][1]
                                        execute_command("msg_prefix \"\"")
                                        if (joined) then
                                            V1.names[n].joined = false
                                            say_all(gsub(V1.fake_quit_message, "%%fakename%%", name))
                                        else
                                            V1.names[n].joined = true
                                            say_all(gsub(V1.fake_join_message, "%%fakename%%", name))
                                        end
                                        execute_command("msg_prefix \" " .. Troll.settings.server_prefix .. "\"")
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

function OnPlayerPreJoin(P)
    InitPlayer(P, false)
end

function OnPlayerDisconnect(P)

    local nc = Troll.features["Name Changer"]
    if (nc.enabled) and TrollPlayer(P, nc) then
        local id = players[P]["Name Changer"].name_id
        if (nc.names[id] ~= nil) then
            nc.names[id].used = false
        end
    end

    InitPlayer(P, true)
end

function OnPreSpawn(P)
    local t = players[P]
    if (t ~= nil) then
        for Feature, V1 in pairs(Troll.features) do
            for B, V2 in pairs(t) do
                if (Feature == B) then
                    if (V1.enabled) and TrollPlayer(P, V1) then
                        math.randomseed(os.time())
                        if (Feature == "Silent Kill") then
                            V2.timer = 0
                            V2.time_until_kill = math.random(V1.min, V1.max)

                        elseif (Feature == "Silent Kick") then
                            V2.timer = 0
                            V2.broadcast = true
                            V2.time_until_kick = math.random(V1.min, V1.max)

                        elseif (Feature == "Teleport Under Map") then
                            V2.timer = 0
                            V2.zaxis = math.random(V1.minZ, V1.maxZ)
                            V2.time_until_tp = math.random(V1.min, V1.max)

                        elseif (Feature == "Flag Dropper") then
                            V2.hasflag = false
                            V2.timer = 0
                            V2.time_until_drop = math.random(V1.min, V1.max)

                        elseif (Feature == "Ammo Changer") then
                            V2.weapon_timer = 0
                            V2.time_until_take_ammo = math.random(V1.minAmmoTime, V1.maxAmmoTime)
                            V2.nade_timer = 0
                            V2.time_until_take_nades = math.random(V1.minNadeTime, V1.maxNadeTime)

                        elseif (Feature == "Nuke") then
                            V2.timer = 0
                            V2.time_until_nuke = math.random(V1.min, V1.max)

                        elseif (Feature == "Force Chat") then
                            V2.timer = 0
                            V2.time_until_say = math.random(V1.min, V1.max)

                        elseif (Feature == "Fake Join-Quit") then
                            V2.timer = 0
                            V2.time_until_say = math.random(V1.min, V1.max)

                        elseif (Feature == "Client Crasher") then
                            V2.timer = 0
                            V2.delay = false
                            V2.time_until_crash = math.random(V1.min, V1.max)

                        elseif (Feature == "Random Color Change") then
                            local chance = V1.chance[math.random(#V1.chance)]
                            if (chance == 1) then
                                local player = get_player(P)
                                if (player ~= 0) then
                                    local NewColor = function()
                                        local temp = { }
                                        for i = 1, #V1.colors do
                                            if (V1.colors[i][2]) then
                                                temp[#temp + 1] = V1.colors[i][1]
                                            end
                                        end
                                        if (#temp > 0) then
                                            return math.random(#temp)
                                        end
                                        return 0
                                    end
                                    write_byte(player + 0x60, NewColor())
                                    cprint("[TROLL] " .. t.name .. " had their armor colour changed!", 5 + 8)
                                end
                            end

                        elseif (Feature == "Chat Text Randomizer") then

                            V2.chance = function()
                                return math.random(V1.min_chances, V1.max_chances)
                            end
                        end
                    end
                end
            end
        end
    end
end

function OnPlayerChat(P, Message, Type)
    if (Type ~= 6) then
        local Msg = StrSplit(Message)
        if (Msg == nil or Msg == "") then
            return
        elseif (not isChatCmd(Msg)) then
            local p = players[P]
            if (p ~= nil) then

                local t = p["Chat Text Randomizer"]
                if (t.chance) then
                    local chance = t.chance()
                    if (chance and chance == 1) then

                        local new_message = ShuffleWords(Message)
                        local formatMsg = function(Str)
                            local patterns = {
                                { "%%name%%", p.name },
                                { "%%msg%%", new_message },
                                { "%%id%%", P }
                            }
                            for i = 1, #patterns do
                                Str = (gsub(Str, patterns[i][1], patterns[i][2]))
                            end
                            return Str
                        end

                        execute_command("msg_prefix \"\"")
                        local F = Troll.features["Chat Text Randomizer"].format
                        if (Type == 0) then
                            say_all(formatMsg(F.global))
                        elseif (Type == 1) then
                            SayTeam(P, formatMsg(F.team))
                        elseif (Type == 2) then
                            SayTeam(P, formatMsg(F.vehicle))
                            execute_command("msg_prefix \" " .. Troll.settings.server_prefix .. "\"")
                            cprint("[TROLL] " .. players[P].name .. " chat message was scrambled!", 5 + 8)
                            return false
                        end
                    end
                end
            end
        else

            local t = Troll.features["Force Chat"]
            if (Msg[1] == "/" .. t.command or Msg[1] == "\\" .. t.command) then
                local TargetID, Message = tonumber(Msg[2]), tostring(Msg[3])
                if (TargetID ~= nil and Message ~= nil) then

                    if player_present(TargetID) then
                        if (P ~= TargetID) then

                            local msg = " "
                            for i = 1, #Msg do
                                if (i ~= 1 and i ~= 2) then
                                    msg = msg .. Msg[i] .. " "
                                end
                            end

                            local name = get_var(TargetID, "$name")
                            local str = t.chat_format
                            local msg = gsub(gsub(str, "%%name%%", name), "%%msg%%", msg)

                            execute_command("msg_prefix \"\"")
                            say_all(msg)
                            execute_command("msg_prefix \" " .. Troll.settings.server_prefix .. "\"")

                            local EName = get_var(P, "$name")
                            if (P == 0) then
                                EName = "SERVER"
                            end
                            cprint("[TROLL] " .. name .. " was forced to say something by " .. EName, 5 + 8)
                        else
                            Respond(P, "You cannot execute this command on yourself!")
                        end
                    else
                        Respond(P, "Invalid Player ID or Player Not Online!")
                    end
                else
                    Respond(P, "Invalid Syntax. Usage: " .. Msg[1] .. " [player id] {message}")
                end
                return false
            elseif (Msg[1] == "/" .. Troll.settings.add_troll_command or Msg[1] == "\\" .. Troll.settings.add_troll_command) then
                local lvl = tonumber(get_var(P, "$lvl"))
                if (lvl >= Troll.settings.add_troll_permission) then
                    local TargetID = tonumber(Msg[2])
                    if (TargetID ~= nil) then
                        if player_present(TargetID) then
                            if (players[TargetID] == nil) then
                                InitPlayer(TargetID, false, true)
                                players[TargetID].ignore_status = true
                                if (TargetID == P) then
                                    Respond(P, "Successfully added yourself to TROLL list!")
                                else
                                    local name = get_var(TargetID, "$name")
                                    Respond(P, "Temporarily adding " .. name .. " to the list of players to troll!")
                                end
                            else
                                Respond(P, "This player is already on the Troll List!")
                            end
                        else
                            Respond(P, "Invalid Player ID or Player Not Online!")
                        end
                    else
                        Respond(P, "Invalid Syntax. Usage: " .. Msg[1] .. " [player id]")
                    end
                else
                    Respond(P, "You do not have permission to execute this command!")
                end
                return false
            elseif (Msg[1] == "/" .. Troll.settings.remove_troll_command or Msg[1] == "\\" .. Troll.settings.remove_troll_command) then
                local lvl = tonumber(get_var(P, "$lvl"))
                if (lvl >= Troll.settings.remove_troll_permission) then
                    local TargetID = tonumber(Msg[2])
                    if (TargetID ~= nil) then
                        if player_present(TargetID) then
                            if (players[TargetID] ~= nil) then
                                players[TargetID] = nil
                                if (TargetID == P) then
                                    Respond(P, "Successfully removed yourself from TROLL list!")
                                else
                                    local name = get_var(TargetID, "$name")
                                    Respond(P, "Removed " .. name .. " to the list of players to troll!")
                                end
                            else
                                Respond(P, "This player isn't on the TROLL LIST!")
                            end
                        else
                            Respond(P, "Invalid Player ID or Player Not Online!")
                        end
                    else
                        Respond(P, "Invalid Syntax. Usage: " .. Msg[1] .. " [player id]")
                    end
                else
                    Respond(P, "You do not have permission to execute this command!")
                end
                return false
            end
        end
    end
end

function OnVehicleEntry(P, _)
    local t = players[P]
    if (t ~= nil) then
        local VE = Troll.features["Vehicle Exit"]
        if (VE.enabled) and TrollPlayer(P, VE) then
            math.randomseed(os.time())
            t["Vehicle Exit"].timer = 0
            t["Vehicle Exit"].time_until_exit = math.random(VE.min, VE.max)
        end
    end
end

function ChangeName(P)
    local nc = Troll.features["Name Changer"]
    if (nc.enabled) and TrollPlayer(P, nc) then
        local name = GetRandomName(P, nc)
        players[P].name = name
        local client_network_struct = network_struct + 0x1AA + 0x40 + to_real_index(P) * 0x20
        cprint("[TROLL] " .. get_var(P, "$name") .. " had their name changed to " .. name, 5 + 8)
        write_widestring(client_network_struct, string.sub(name, 1, 11), 12)
    end
end

function SayTeam(P, Message)
    for i = 1, 16 do
        if player_present(i) then
            if get_var(i, "$team") == get_var(P, "$team") then
                say(i, Message)
            end
        end
    end
end

function InitPlayer(P, Reset, Bypass)
    if (Reset) then
        players[P] = nil
    else

        local Case = function()
            local ip = get_var(P, "$ip"):match("%d+.%d+.%d+.%d+")
            for i = 1, #Troll.settings.specific_users do
                if (ip == Troll.settings.specific_users[i] or (not Troll.settings.specific_users_only)) or (Bypass) then
                    return true
                end
            end
            return false
        end

        if Case() then

            math.randomseed(os.time())

            players[P] = {
                name = get_var(P, "$name"),
                ignore_status = false,
                ["Nuke"] = {},
                ["Force Chat"] = {},
                ["Silent Kick"] = {},
                ["Silent Kill"] = {},
                ["Flag Dropper"] = {},
                ["Vehicle Exit"] = {},
                ["Ammo Changer"] = {},
                ["Name Changer"] = {},
                ["Fake Join-Quit"] = {},
                ["Client Crasher"] = {},
                ["Teleport Under Map"] = {},
                ["Random Color Change"] = {},
                ["Chat Text Randomizer"] = {},
            }

            cprint("[TROLL] " .. get_var(P, "$name") .. " has been added to the list of players to troll", 5 + 8)

            OnPreSpawn(P)
            ChangeName(P)
            return true
        end
    end

    return false
end

function SilentKick(P, SK)

    for _ = 1, 9999 do
        rprint(P, " ")
    end

    local t = players[P]
    if (t["Silent Kick"].broadcast) then
        t["Silent Kick"].broadcast = false
        if (SK.announcements.enabled) then
            for i = 1, 6 do
                if player_present(i) and (i ~= P) then
                    say(i, gsub(SK.announcements.msg, "%%name%%", t.name))
                end
            end
        end
    end
    cprint("[TROLL] " .. t.name .. " was auto-kicked silently", 5 + 8)
end

function OnDamageApplication(VictimIndex, CauserIndex, MetaID, Damage, _, _)
    if (tonumber(CauserIndex) > 0) then
        local t = Troll.features["Damage Modifier"]
        if (t.enabled) then

            if (players[CauserIndex] ~= nil and players[VictimIndex] ~= nil) then

                for Table, _ in pairs(t.multipliers) do
                    for _, Tag in pairs(t.multipliers[Table]) do
                        if (MetaID == GetTag("jpt!", Tag[1])) then

                            local SelfHarm = (VictimIndex == CauserIndex)
                            math.randomseed(os.clock())

                            if (SelfHarm) and TrollPlayer(VictimIndex, t) then
                                Damage = (Damage + math.random(Tag.you[1], Tag.you[2]))
                                cprint("[TROLL] " .. players[VictimIndex].name .. " units of damage was modified!", 5 + 8)

                            elseif (not SelfHarm) and TrollPlayer(CauserIndex, t) then
                                cprint("[TROLL] " .. players[CauserIndex].name .. " units of damage was modified!", 5 + 8)
                                if (Table == "vehicle_collision" or Table == "grenades" or Table == "projectiles") then
                                    Damage = Damage - math.random(Tag.others[1], Tag.others[2])
                                else
                                    Damage = -math.random(Tag[2], Tag[3])
                                end
                            end

                            return true, Damage
                        end
                    end
                end
            end
        end
    end
end

function Nuke(DynamicPlayer, N)
    local coords = GetXYZ(DynamicPlayer)
    local projectile_object = N.projectile
    local object = GetTag(projectile_object[1], projectile_object[2])
    if (object) then
        for _ = N.min_projectiles, N.max_projectiles do
            local payload = spawn_object(projectile_object[1], projectile_object[2], coords.x, coords.y, coords.z + 0.5)
            local projectile = get_object_memory(payload)
            if (projectile ~= 0) then
                write_float(projectile + 0x68, 0)
                write_float(projectile + 0x6C, 0)
                write_float(projectile + 0x70, -1)
            end
        end
    else
        cprint("[TROLL] Nuke() | Projectile Tag Address Error", 4 + 8)
    end
end

function CrashClient(Player, DynamicPlayer)
    local Coords = GetXYZ(DynamicPlayer)
    local TagType, TagName = "vehi", "vehicles\\rwarthog\\rwarthog"
    if GetTag(TagType, TagName) then
        local Vehicle = spawn_object(TagType, TagName, Coords.x, Coords.y, Coords.z)
        local VehicleObject = get_object_memory(Vehicle)
        if (VehicleObject ~= 0) then
            for j = 0, 20 do
                enter_vehicle(Vehicle, Player, j)
                exit_vehicle(Player)
            end
            destroy_object(Vehicle)
            cprint(" [TROLL] " .. players[Player].name .. " had their game crashed", 5 + 8)
        end
    else
        cprint("[TROLL] CrashClient() | Vehicle Tag Address Error", 4 + 8)
    end
end

function GetTag(obj_type, obj_name)
    local tag = lookup_tag(obj_type, obj_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function GetXYZ(DynamicPlayer)
    local coordinates, x, y, z = {}
    local VehicleID = read_dword(DynamicPlayer + 0x11C)
    if (VehicleID == 0xFFFFFFFF) then
        x, y, z = read_vector3d(DynamicPlayer + 0x5c)
    else
        x, y, z = read_vector3d(get_object_memory(VehicleID) + 0x5c)
    end
    coordinates.x, coordinates.y, coordinates.z = x, y, z
    return coordinates
end

function hasObjective(DynamicPlayer)
    for i = 0, 3 do
        local WeaponID = read_dword(DynamicPlayer + 0x2F8 + 0x4 * i)
        if (WeaponID ~= 0xFFFFFFFF) then
            local Weapon = get_object_memory(WeaponID)
            if (Weapon ~= 0) then
                local tag_address = read_word(Weapon)
                local tag_data = read_dword(read_dword(0x40440000) + tag_address * 0x20 + 0x14)
                if (read_bit(tag_data + 0x308, 3) == 1) then
                    return true
                end
            end
        end
    end
    return false
end

function InVehicle(DynamicPlayer)
    if (DynamicPlayer ~= 0) then
        local VehicleID = read_dword(DynamicPlayer + 0x11C)
        if (VehicleID ~= 0xFFFFFFFF) then
            return true
        end
    end
    return false
end

function TrollPlayer(P, Feature)
    local lvl = tonumber(get_var(P, "$lvl"))
    local ignore_status = (players[P].ignore_status == true)
    return (lvl == -1) or ((Feature.ignore_admins == false) or (lvl <= Feature.ignore_admin_level)) or (ignore_status)
end

function KillSilently(P)
    local kma = sig_scan("8B42348A8C28D500000084C9") + 3
    local original = read_dword(kma)
    safe_write(true)
    write_dword(kma, 0x03EB01B1)
    safe_write(false)
    execute_command("kill " .. tonumber(P))
    safe_write(true)
    write_dword(kma, original)
    safe_write(false)
    write_dword(get_player(P) + 0x2C, 0 * 33)
    local deaths = tonumber(get_var(P, "$deaths"))
    execute_command("deaths " .. tonumber(P) .. " " .. deaths - 1)
    cprint("[TROLL] " .. get_var(P, "$name") .. " was auto-killed silently", 5 + 8)
end

function GetRandomName(P, NC)

    local ply = players[P]["Name Changer"]
    ply.name_id = ply.name_id or 0

    local t = { }
    for i = 1, #NC.names do
        if (string.len(NC.names[i][1]) < 12) then
            if (not NC.names[i].used) then
                t[#t + 1] = { NC.names[i][1], i }
            end
        end
    end

    if (#t > 0) then

        math.randomseed(os.time())

        local rand = math.random(#t)
        local name = t[rand][1]
        local n_id = t[rand][2]
        NC.names[n_id].used = true
        ply.name_id = n_id

        return name
    end

    return "no name"
end

function isChatCmd(Msg)
    if (sub(Msg[1], 1, 1) == "/" or sub(Msg[1], 1, 1) == "\\") then
        return true
    end
end

function StrSplit(Message)
    local Args, index = { }, 1
    for Params in gmatch(Message, "([^%s]+)") do
        Args[index] = Params
        index = index + 1
    end
    return Args
end

function Respond(PlayerIndex, Message)
    if (PlayerIndex == 0) then
        cprint(Message, 4 + 8)
    else
        rprint(PlayerIndex, Message)
    end
end

function ShuffleWords(String)
    math.randomseed(os.time())
    local letters = { }

    for letter in String:gmatch '.[\128-\191]*' do
        letters[#letters + 1] = { letter = letter, rnd = math.random() }
    end

    table.sort(letters, function(a, b)
        return a.rnd < b.rnd
    end)

    for i, v in ipairs(letters) do
        letters[i] = v.letter
    end
    return table.concat(letters)
end

function PrintFeatureState()
    cprint(" ")
    cprint("---- TROLL FEATURES ----", 5 + 8)
    for k, v in pairs(Troll.features) do
        if (v.enabled) then
            cprint("[" .. k .. '] is enabled', 2 + 8)
        else
            cprint("[" .. k .. '] is disabled', 4 + 8)
        end
    end
    cprint(" ")
end

function report()
    local script_version = format("%0.2f", Troll.settings.script_version)
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


------------ CREDITS BELOW --------------------------------------:
-- Credits to Kavawuvi for this chunk of code:
function LSS(state)
    if (state) then
        ls = sig_scan("741F8B482085C9750C")
        if (ls == 0) then
            ls = sig_scan("EB1F8B482085C9750C")
        end
        safe_write(true)
        write_char(ls, 235)
        safe_write(false)
    else
        if (ls == 0) then
            return
        end
        safe_write(true)
        write_char(ls, 116)
        safe_write(false)
    end
end
-----------------------------------------------------------------------
-- Credits to Devieth for these functions:
function write_widestring(address, str, len)
    local Count = 0
    for _ = 1, len do
        write_byte(address + Count, 0)
        Count = Count + 2
    end
    local count = 0
    local length = string.len(str)
    for i = 1, length do
        local newbyte = string.byte(string.sub(str, i, i))
        write_byte(address + count, newbyte)
        count = count + 2
    end
end
function read_widestring(Address, Size)
    local str = ""
    for i = 0, Size - 1 do
        if read_byte(Address + i * 2) ~= 00 then
            str = str .. string.char(read_byte(Address + i * 2))
        end
    end
    if str ~= "" then
        return str
    end
    return nil
end
-----------------------------------------------------------------------

return Troll
