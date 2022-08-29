local QBCore = exports['qb-core'].GetCoreObject() --needed for exports.chat:addMessage

local dlocvector = vector3(185.2087, -1078.198, 29.27457)
local aloc = vector3(187.3383, -1066.97, 77.54414)
local tpallow = false
src = source

-- dev testing



    TriggerServerEvent('playerconnect')


    -- =========================================================
-- /COMMANDS, PERMISSIONS, ERROR CHECKS
--==========================================================

-- New command:  /addtpperms playerid    -gives the player the proper perms to use the teleport
RegisterCommand("addtpperm", function(source, args, rawCommand)
    --default target of the command is the player entering the command
    local cmdtarget = -1
    if #args > 0 then
    -- Check if the user entered a player ID
        cmdtarget = tonumber(args[1])
        -- set the data to pass to the server and trigger the server event to check current perms and add if needed
        TriggerServerEvent("checkperm", cmdtarget)
    end
end)

--  New command: /removetpperms playerid      -Removes the perms to use the teleport
RegisterCommand("removetpperm", function(source, args, rawCommand)
    --default target of the command is the player entering the command
    local cmdtarget = -1
    if #args > 0 then
    -- Check if the user entered a player ID
        cmdtarget = tonumber(args[1])
        -- set the data to pass to the server and trigger the server event to check current perms and add if needed
        TriggerServerEvent("removeperm", cmdtarget)
    end
end)

-- perms successfully removed from target
RegisterNetEvent('removed')
AddEventHandler('removed', function(cmdtarget)
    TriggerEvent("chat:addMessage", {
        color = {255,0,0}, 
        multiline = true, 
        args = {"TP Script", "perms successfully removed from " .. cmdtarget }
    })
end)

-- error message if the player's steam hex couldn't be retrieved
RegisterNetEvent("errormessage")
AddEventHandler("errormessage", function()
    -- exports.chat:addMessage(source, "this is an error message" )  -WHY WONT THIS WORK?
    TriggerEvent("chat:addMessage", {
        color = {255,0,0}, 
        multiline = true, 
        args = {"TP Script", "This is an error message."}
    })
end)
-- error message to give if the player already has TP perms
RegisterNetEvent('alreadyexists')
AddEventHandler('alreadyexists', function()
    TriggerEvent("chat:addMessage", {
        color = {255,0,0}, 
        multiline = true, 
        args = {"TP Script", "This user already has TP perms"}
    })
end)
-- Message if the user was added to the database
RegisterNetEvent("success")
AddEventHandler("success", function()
TriggerEvent('chat:addMessage', {
    color = {0,255,0},
    multiline = true,
    args = {"Server", "TP perms added successfuly"}
})
--finished the /addtpperms command
end)

-- check if the user has perms when they attempt to teleport
function tprequest()
    print('sending tp perm check to server')
    TriggerServerEvent('tpcheck')
end 

-- Permission authentication response from server
RegisterNetEvent('permreceive')
AddEventHandler('permreceive', function(perm)
    print('perms recieved from server')
    if perm == 1 then
        tpallow = 1
        print('sufficient perms to TP.  Allowing TP.')
        else
            print('NO TP PERMS.')
    end
end)


--=================================================
-- LOCATIONS AND LOCATION CHECKS
--=================================================

-- set the location of the teleport areas
player = GetPlayerPed(-1)
playerloc = GetEntityCoords(player)
distance1 = Vdist2(playerloc, dlocvector)
-- dev command to get location and distance to departure point
RegisterCommand("location", function()
local player = GetPlayerPed(-1)
local playerloc = GetEntityCoords(player)
local distance1 = Vdist2(playerloc, dlocvector)
    print(GetEntityCoords(player))
    print(distance1)
end)
-- dev testing command
RegisterCommand("goto", function()
-- SetEntityCoords(player, locationarrive1.x, locationarrive1.y, locationarrive1.z, false, false, false, false)
-- print('player teleported')
location1()
end)

-- Authentication complete, move the player
function location1()
    tprequest()
    if tpallow == 1 then 
        print('checked perms and teleported')
    SetEntityCoords(player, aloc, false, false, false, false)
    print('teleport success')
    else
        Citizen.Wait(1)
    end
end

--Main loop
Citizen.CreateThread(
    function()
        while true do
        local player = GetPlayerPed(-1)
        local playerloc = GetEntityCoords(player)
        local distance1 = #(playerloc - dlocvector)
        -------------------------------------------------------------------------
            Citizen.Wait(1)  -- CHANGE THIS TO A LOWER NUMBER.  SET LOW DURING DEV!!!!!!!!!
        -------------------------------------------------------------------------
        -- Check to see if they are close enough, in a vehicle, and if they've pressed the 'E' button
            if distance1 < 3 and GetVehiclePedIsIn(player, false) == 0 and IsControlJustReleased(0, 38) then
                location1()
            end
        end
    end
)
