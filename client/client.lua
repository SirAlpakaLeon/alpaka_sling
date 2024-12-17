local currentRack = nil 
local holding = nil 
local backProp = nil 

local location = 1

AddEventHandler('ox_inventory:currentWeapon', function(weapon) 
    if type(weapon) == 'table' then 
        holding = weapon.name
        for k,v in pairs(Config.BackItems) do 
            if string.lower(v[1]) == string.lower(weapon.name) then 
                if currentRack == nil then 
                    if not isNearDoor() then 
                        TriggerEvent('ox_inventory:disarm', GetPlayerServerId(PlayerId()), true)
                    else 
                        if lib.progressCircle({
                            duration = Config.putouttime,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            anim = {
                                dict = 'mini@repair',
                                clip = 'fixing_a_ped'
                            },
                        }) then 
                            currentRack = weapon.name
                        else 
                            TriggerEvent('ox_inventory:disarm', GetPlayerServerId(PlayerId()), true)
                        end 
                    end 
                else 
                    if weapon.name ~= currentRack then 
                        TriggerEvent('ox_inventory:disarm', GetPlayerServerId(PlayerId()), true)
                    else 
                        fromBack(weapon.name)
                    end     
                end 
            end 
        end
    else 
        if holding == currentRack then 
            holding = nil 
            onBack(currentRack)
        end 
    end 
end)

function onBack(weapon)
    for k,v in pairs(Config.BackItems) do 
        if string.lower(v[1]) == string.lower(weapon) then 
            ESX.Game.SpawnObject(v[2], GetEntityCoords(PlayerPedId()), function(object)
                setBackProp(object)
                AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(GetPlayerPed(-1), Config.Bone), Config.Coords[location].pos[1], Config.Coords[location].pos[2], Config.Coords[location].pos[3], Config.Coords[location].rot[1], Config.Coords[location].rot[2], Config.Coords[location].rot[3], false, false, false, true, 0, true)
            end)
        end 
    end 
end

RegisterCommand(Config.command, function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehicle = ESX.Game.GetClosestVehicle(pedCoords)

    if vehicle then
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(pedCoords - vehicleCoords)

        if distance <= 5.0 then
            if currentRack == holding then 
                if lib.progressCircle({
                    duration = Config.putintime,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    },
                }) then 
                    TriggerEvent('ox_inventory:disarm', GetPlayerServerId(PlayerId()), true)
                    Citizen.Wait(10)
                    DeleteObject(backProp)
                    currentRack = nil 
                    holding = nil 
                    backProp = nil 
                end 
            else 
                lib.notify({
                    description = 'Du kannst diese Waffe nicht in den Kofferraum packen oder du hast sie nicht in der Hand',
                    type = 'error',
                })
            end 
        else
            lib.notify({
                description = 'Du bist zu weit vom Fahrzeug entfernt, um diese Aktion auszuführen.',
                type = 'error',
            })
        end
    else
        lib.notify({
            description = 'Kein Fahrzeug in der Nähe gefunden.',
            type = 'error',
        })
    end
end)

RegisterCommand('setholster', function(source, args, rawCommand)
    location = tonumber(args[1]) 
    lib.notify({
        description = 'Du trägst deine Waffe nun ' .. Config.Coords[location].label..', Bitte nehmen Sie sie einmal heraus und packen Sie sie wieder ein, damit die Änderungen übernommen werden.',
        type = 'info',
    })
end)

exports('setholster', function(pos)
    location = tonumber(pos) 
    lib.notify({
        description = 'Du trägst deine Waffe nun ' .. Config.Coords[location].label..', Bitte nehmen Sie sie einmal heraus und packen Sie sie wieder ein, damit die Änderungen übernommen werden.',
        type = 'info',
    })
end)

TriggerEvent('chat:addSuggestion', '/setholster', '1 oder 2')

exports('getholster', function()
    return(location)
end)

function fromBack(weapon)
    DeleteObject(backProp)
    backProp = nil 
end

function setBackProp(object)
    backProp = object
end 

function isNearDoor()
    local near = false 
    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehicle = ESX.Game.GetClosestVehicle(pedCoords)

    local backdoorLeft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_r")) or vector3(0,0,0)
    local backdoorRight = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_r")) or vector3(0,0,0)
    local frontDoorLeft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_f")) or vector3(0,0,0)
    local frontDoorRight = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_f")) or vector3(0,0,0)
    local trunkDoor = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot")) or vector3(0,0,0)
    local lTail = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"))
    local rTail = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"))

    local dist1 = #(backdoorLeft- pedCoords)
    local dist2 = #(backdoorRight- pedCoords)
    local dist3 = #(frontDoorLeft- pedCoords)
    local dist4 = #(frontDoorRight- pedCoords)
    local dist5 = #(trunkDoor- pedCoords)
    local dist6 = #(lTail- pedCoords)
    local dist7 = #(rTail- pedCoords)

    if dist1 < 1.5 or dist2 < 1.5 or dist3 < 1.5 or dist4 < 1.5 or dist5 < 1.5 or (dist6 < 2 and dist7 < 2) then 
        near = true 
    end 

    return(near)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        DeleteObject(backProp)
    end 
end)
