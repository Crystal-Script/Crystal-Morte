ESX = exports["es_extended"]:getSharedObject()
local premorto = false
local morto = false
local displayText = true

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

AddEventHandler('esx:onPlayerDeath', function(data)
    if premorto then
        playermorto()
    else
        funzionepremorto()
    end
end)

function funzionepremorto()
    premorto = true
    DoScreenFadeOut(1500)
    Wait(1500)
    DoScreenFadeIn(1000)


    TriggerServerEvent('player:update', 1)

    LocalPlayer.state:set("dead", true, true)
    LocalPlayer.state.injuries = true

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, false)
    SetEntityHealth(playerPed, 200)

    ESX.Streaming.RequestAnimDict('move_injured_ground', function()
        TaskPlayAnim(playerPed, 'move_injured_ground', 'front_loop', 8.0, 4.0, -1, 1, 0, 0, 0, 0)
    end)

    exports.rprogress:Custom({
        Async = true,
        Duration = Config.strisciando, 
        Label = 'Morendo ...',
        onComplete = function()
            playermorto()
        end
    })

    local fermo = false
    local lastRot = 0
    Citizen.CreateThread(function ()
        while premorto do
            Citizen.Wait(0)
            if not fermo then
                local rotazioneMouse = Citizen.InvokeNative(0x837765A25378F0BB, 0, Citizen.ResultAsVector())
                if math.abs(rotazioneMouse.z - lastRot) > 3.5 then
                    lastRot = rotazioneMouse.z
                    TaskPlayAnim(playerPed, 'move_injured_ground', 'front_loop', 100.0, 8.0, -1, 1, 0, 0, 0, 0)
                    SetEntityHeading(PlayerPedId(), rotazioneMouse.z)
                end
            end

            if IsControlJustPressed(0, Keys['W']) then
                if fermo then
                    fermo = false
                    TaskPlayAnim(playerPed, 'move_injured_ground', 'front_loop', 100.0, 8.0, -1, 1, 0, 0, 0, 0)
                else
                    ESX.Streaming.RequestAnimDict('random@dealgonewrong', function()
                        TaskPlayAnim(playerPed, 'random@dealgonewrong', 'idle_a', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
                    end)
                    fermo = true
                end
            end
        end
    end)
end

function playermorto()
    TriggerEvent("rprogress:stop")
    premorto = false
    morto = true
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, true, false)
    displayText = true


    AnimpostfxPlay("DeathFailOut", 0, false)
    startCountdown()

    Citizen.CreateThread(function ()
        while morto do
            Citizen.Wait(0)
            lib.requestAnimDict('dead', 100)
            TaskPlayAnim(ped, 'dead', 'dead_a', 8.0, -8.0, -1, 0, 0, 0, 0)
        end
    end)
end

function startCountdown()
    local timer = Config.tempodimorte
    displayText = true

    Citizen.CreateThread(function()
        while timer > 0 and displayText do
            Citizen.Wait(1000)
            timer = timer - 1
        end
    end)

    Citizen.CreateThread(function()
        while displayText do
            Citizen.Wait(0)
            if timer > 0 then
                drawText("Premi G Per avvisare i medici", 0.45, 0.93, 0.5, 255, 255, 255, 255)
                drawText("Tempo rimasto: " .. timer, 0.45, 0.96, 0.5, 255, 255, 255, 255)
                if IsControlJustReleased(0, Keys['G']) then
                    alertems()
                end
            else
                drawText("Premi G Per avvisare i medici", 0.45, 0.93, 0.5, 255, 255, 255, 255)
                drawText("Premi E Per respawnare in ospedale", 0.45, 0.96, 0.5, 255, 255, 255, 255)
                
                if IsControlJustReleased(0, Keys['E']) then
                    respawninospitale()
                end
                if IsControlJustReleased(0, Keys['G']) then
                    alertems()
                end
            end
        end
    end)
end

function respawninospitale()
    SetEntityCoords(PlayerPedId(), Config.RespawnCoords.x, Config.RespawnCoords.y, Config.RespawnCoords.z)
    SetEntityHeading(PlayerPedId(), Config.RespawnCoords.heading)
    TriggerEvent('rianima')
end

----------------- drawText -------------------

function drawText(text, x, y, scale, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

---------------------- rianima ------------------------------

RegisterNetEvent('rianima')
AddEventHandler('rianima', function ()
    TriggerServerEvent('player:update', 0)

    LocalPlayer.state.injuries = false
    LocalPlayer.state:set("dead", false, true)
    premorto = false
    morto = false
    displayText = false
    StopScreenEffect('DeathFailOut')
    ClearTimecycleModifier()
    TriggerEvent("rprogress:stop")
    local ped = PlayerPedId()
    ClearPedBloodDamage(PlayerPedId())
    lib.requestAnimDict('get_up@directional@movement@from_knees@action', 100)
    TaskPlayAnim(ped, 'get_up@directional@movement@from_knees@action', 'getup_r_0', 8.0, -8.0, -1, 0, 0, 0, 0)
    TriggerEvent('esx_status:set', 'hunger', 500000)
    TriggerEvent('esx_status:set', 'thirst', 500000)
end)

--------------- notifa all'ambulanza ---------

local lastAlertTime = 0
local alertCooldown = 60000
function alertems()
    local currentTime = GetGameTimer()

    if currentTime - lastAlertTime >= alertCooldown then
        ESX.ShowNotification("I medici sono stati avvisati, presto saranno da te")
        local job = Config.jobalert -- Jobs that will recive the alert
        local text = "Richiesta EMS più veloce possibile" -- Main text alert
        local coords = GetEntityCoords(PlayerPedId()) -- Alert coords
        local id = GetPlayerServerId(PlayerId()) -- Player that triggered the alert
        local title = "Rianimazione" -- Main title alert
        local panic = false -- Allow/Disable panic effect
        TriggerServerEvent('Opto_dispatch:Server:SendAlert', job, title, text, coords, panic, id)
        lastAlertTime = currentTime
    else
        ESX.ShowNotification("È troppo presto per inviare un'altra notifica.")
    end
end

RegisterCommand('medico', function ()
    if morto then
        exports.rprogress:Custom({
            Duration = 300000,
            maxAngle = 60,
            rotation = -120,
            onComplete = function()
                TriggerEvent('rianima')
            end
        })
    else
        ESX.ShowNotification('Non sei morto', 'error')
    end
end, false)

------- rianima player

exports.ox_target:addGlobalPlayer({
    {
        event = "revive1",
        icon = 'fa-solid fa-person',
        label = 'Rianima'
    },
})

local isReviving = false
RegisterNetEvent('revive1')
AddEventHandler('revive1', function(data)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 then
            if not isReviving then
                local medikitcheck = exports.ox_inventory:Search('count', 'medikit') 
				if medikitcheck < 1 then
                    ESX.ShowNotification('Non hai il medikit', 'error')
					return
				end
                if medikitcheck then
                    ESX.ShowNotification('Stai rianimando')
                    -- TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', 'ambulance', 500)
                    isReviving = true
                    exports.rprogress:Custom({
                        maxAngle = 240,
                        rotation = -120,
                        Label = "Rianimando...",
                        Duration = 8000,
                        Animation = {
                            animationDictionary = "mini@cpr@char_a@cpr_str",
                            animationName = "cpr_pumpchest",
                        },
                        onStart = function ()
                            FreezeEntityPosition(closestPlayer, true)
                        end,
                        onComplete = function(cancelled)
                            ClearPedTasksImmediately(PlayerPedId())
                            if cancelled then
                            else
                                FreezeEntityPosition(closestPlayer, false)
                                isReviving = false
                                TriggerServerEvent('revive', GetPlayerServerId(closestPlayer))
                            end
                        end,
                    })
                end
            end
        
    else
        ESX.ShowNotification('Nessun Giocatore Nelle Vicinanze')
    end
end)

exports['crystal_lib']:CRYSTAL().gridsystem({ 
    pos = vector3(299.4704, -580.1213, 43.2608), -- posizione del marker
    rot = vector3(90.0, 90.0, 90.0), -- rotazione del marker
    scale = vector3(0.8, 0.8, 0.8), -- grandezza del marker
    textureName = 'marker', -- nome della texture del marker.ytd
    msg = 'Premi [E] per aprire lo shop della farmacia', -- messagio che compare se sarai sopra al marker
    action = function ()
        lib.callback('crystal:morte:mediciinservizio', false, function(medici)
            if medici >= 1 then
                ESX.ShowNotification('Ci sono medici in servizio', 'error')
            else
                local moneymedikit = exports.ox_inventory:Search('count', 'money') 
				if moneymedikit < 1000 then
                    ESX.ShowNotification('Non hai abbastanza soldi', 'error')
					return
				end
                if moneymedikit then
                TriggerEvent('medkitcompra')
                end
            end
        end)
    end
})

RegisterNetEvent('medkitcompra', function(args)
    lib.registerContext({
      id = 'event_menu',
      title = 'Menu farmacia',
      menu = 'some_menu',
      options = {
        {
            title = 'Medikit',
            description = 'Compra un medikit!',
            onSelect = function()
                TriggerServerEvent('compramedikit')
           end
        }
      }
    })
   
    lib.showContext('event_menu')
  end)