local QBCore = exports['qb-core'].GetCoreObject()
src = tonumber(source)
steamhex = false

-- A player has connected.  Lets make sure they are in the TP database
RegisterServerEvent('playerconnect')
AddEventHandler('playerconnect', function()
    for k,v in pairs (GetPlayerIdentifiers(source)) do 
        if string.match(v, 'steam:') then
            steamhex = v
            print('player ' .. source .. ' is Connecting - found steam hex')
            break
        end
    end
    if steamhex then
        MySQL.query('SELECT * FROM perms WHERE steam = @steamhex', {['@steamhex'] = steamhex}, function(result)
            if not result[1] then
                MySQL.insert('INSERT INTO perms (steam, permission) VALUES(@steam, @permission)',
                {['@steam'] = steamhex, ['@permission'] = false}, function()
                print("TP Script: successfully wrote to DB")    
                end)       
            end
        
        end)
    end
end)


RegisterServerEvent ('checkperm')
-- received /addtpperms from client
AddEventHandler('checkperm', function(cmdtarget)
    local src = tonumber(source)
steamhex = false
--dummy checks
cmdtarget = tonumber(cmdtarget)
local t = type(cmdtarget)
if t == nil then
    print('not a number')
    return
end
if not GetPlayerName(cmdtarget) then
    print("error message")
end
-- Find the player's steam hex
for k,v in pairs (GetPlayerIdentifiers(cmdtarget)) do 
    if string.match(v, 'steam:') then
        steamhex = v
        --Found the steam id of player
        break
    end
end
-- couldn't find steamhex
if not (steamhex) then
    -- There was an error getting the steamhex for player
    TriggerClientEvent("errormessage", src)
end
    -- check to see if the target already has TP perms
if steamhex then
    MySQL.query('SELECT * FROM perms WHERE steam = @steamhex', {['@steamhex'] = steamhex}, function(result)
-- If they don't have perms yet, write it to database
    if not (result[2]) then
        -- MySQL.insert('INSERT INTO perms (steam, permission) VALUES(@steam, @permission)',
        -- {['@steam'] = steamhex, ['@permission'] = true}, function()
        MySQL.query('UPDATE perms SET permission = TRUE WHERE steam = @steamhex',
        {['@steamhex'] = steamhex}, function()
        print("TP Script: successfully wrote to DB")
        -- tell the client that the TP perms were added successfully 
        TriggerClientEvent('success', src)
        end)
    else
        -- tell the client they already had perms
        TriggerClientEvent("alreadyexists", src)
    end
    end)
end
end)

-- command to remove perms
RegisterServerEvent('removeperm')
AddEventHandler('removeperm', function(cmdtarget)
local src = source
steamhex = false
cmdtarget = tonumber(cmdtarget)
local t = type(cmdtarget)
-- dummy checks
if t == nil then
    return
end
if not GetPlayerName(cmdtarget) then
end
-- find steam hex
for k,v in pairs (GetPlayerIdentifiers(cmdtarget)) do 
    if string.match(v, 'steam:') then
        steamhex = v
        break
    end
end
if not (steamhex) then
    -- There was an error getting the steamhex for player
    TriggerClientEvent("errormessage", src)
end
    -- check to see if the target already has TP perms
if steamhex then
    MySQL.query('SELECT * FROM perms WHERE steam = @steamhex', {['@steamhex'] = steamhex}, function(result)
-- remove the TP perms
        MySQL.query('UPDATE perms SET permission = FALSE WHERE steam = @steamhex',
            {['@steamhex'] = steamhex}, function()
            -- successfully wrote to DB - PERMISSION REMOVED
            TriggerClientEvent('removed', src, cmdtarget)
        end)
    end)
end
end)

-- Recieved a TP request.  Check perms
RegisterServerEvent('tpcheck')
AddEventHandler('tpcheck', function()
    local src = source
    -- recieved tp perm check
    local perm = 0
    for k,v in pairs (GetPlayerIdentifiers(source)) do 
        if string.match(v, 'steam:') then
            steamhex = v
            -- found steamhex
            break
        end
    end
    if steamhex then
        MySQL.query('SELECT * FROM perms WHERE steam = @steamhex', {['@steamhex'] = steamhex}, function(result)
        if not result[1].permission or result[1].permission == nil then
            -- no perms to tp
        end
        if result[1].permission then
        -- sufficient perms to TP, sent back to client
            perm = 1
            TriggerClientEvent("permreceive", src, perm) 
        end
    end)
    end
end)



-- if not GetPlayerName(cmdtarget) then
--     -- exports.chat:addMessage(src, "Target player is invalid")  -WHY WONT THIS WORK?
--     TriggerEvent("chat:addMessage", {
--         color = {255,0,0}, 
--         multiline = true, 
--         args = {"TP Script", "Target player is invalid.  Enter a player ID."}
--     })
--     return
-- end