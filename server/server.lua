ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('revive', function(src, args)
    if src == 0 or src == nil then
        TriggerClientEvent("rianima",tonumber(args[1]))
    else
        local xPlayer = ESX.GetPlayerFromId(src)
        
            if 'admin' == xPlayer.getGroup() or 'mod' == xPlayer.getGroup() then
                if #args > 0 and tonumber(args[1]) then
                    TriggerClientEvent("rianima",tonumber(args[1]))
                else 
                    TriggerClientEvent("rianima",src)
                end
            end
        
    end
end, false)

RegisterNetEvent('player:update')
AddEventHandler('player:update', function(morte)
    local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Sync.execute('UPDATE users SET is_dead = @is_dead WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@is_dead'] = morte
        })
    print(morte)
end)

-----------------------------

RegisterServerEvent('revive')
AddEventHandler('revive', function(id, value)
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.source == source then 
			
			if xPlayer.getInventoryItem('medikit').count > 0 then 
				TriggerClientEvent('rianima', id)
                xPlayer.removeInventoryItem('medikit', 1)
			else 
				xPlayer.showNotification("Ti serve un medikit")
			end

		end
	end
end)

------------- check medici -------------------

lib.callback.register('crystal:morte:mediciinservizio', function(source)

	local cops = 0
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == Config.jobalert then
			cops = cops + 1
		end
	end
	return cops
end)

-----------------------

RegisterNetEvent('compramedikit')
AddEventHandler('compramedikit', function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('money', 1000)
    xPlayer.addInventoryItem('medikit', 1)
end)