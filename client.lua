local onDuty = false
local spikes = {}

RegisterNetEvent("fd_copextras:toggleOnDuty")
AddEventHandler("fd_copextras:toggleOnDuty", function(bool)
    onDuty = bool
end)

function spawnSpikes(coords)
    local player = GetPlayerPed(-1)
    local hash = GetHashKey("p_ld_stinger_s")
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
        print("loading model")
    end
    local spike = CreateObject(hash, coords.x, coords.y, coords.z, true, true, true)
    SetEntityHeading(spike, GetEntityHeading(player))
    PlaceObjectOnGroundProperly(spike)
    table.insert(spikes,{spike,coords})
    print("spikes should have spawned by now")
end

function deleteSpikes(coords)
    for k,v in pairs(spikes) do
        if v[2] == coords then
            DeleteObject(v[1])
            table.remove(spikes,k)
        end
    end
end

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

-- Draw Text Over Spawned Spikes and Armoury --
Citizen.CreateThread(function()
    local sleep = 1000
    local player = GetPlayerPed(-1)
    while true do
        TriggerServerEvent("fd_copextras:checkOnDuty")
        local playerPos = GetEntityCoords(player)
        for k,v in ipairs(spikes) do
            local spikePos = v[2]
            local distance = Vdist(playerPos.x,playerPos.y,playerPos.z,spikePos.x,spikePos.y,spikePos.z)
            print(distance, onDuty)
            if distance <= 3.0 and onDuty and distance ~= 0 and (GetVehiclePedIsIn(player,false) == 0) then
                sleep = 5
                exports["drp_core"]:DrawText3Ds(spikePos.x,spikePos.y,spikePos.z,"Press ~b~E~w~ to pack up spike strip")
                if IsControlJustPressed(1,86) then
                    exports["drp_progressBars"]:startUI(2500,"Packing Spike Strip")
                    Citizen.Wait(2500)
                    deleteSpikes(spikePos)
                end
            end
        end
        if onDuty then
            for k,v in ipairs(Armoury.Locations) do
                local distance = Vdist(playerPos.x,playerPos.y,playerPos.z,v.x,v.y,v.z)
                if distance <= 3.0 then
                    sleep = 5
                    exports["drp_core"]:DrawText3Ds(v.x,v.y,v.z,"Press ~b~E~w~ to grab your kit")
                    if IsControlJustPressed(1,86) then
                        local loadout = {
                            GetHashKey("weapon_nightstick"),
                            GetHashKey("weapon_stungun"),
                            GetHashKey("weapon_flashlight"),
                            GetHashKey("weapon_combatpistol"),
                            GetHashKey("weapon_carbinerifle_mk2")
                        }
                        for k,v in ipairs(loadout) do
                            GiveWeaponToPed(player,v,256,false,false)
                        end
                        SetPedArmour(player,100)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
--- Keybinds ---
Citizen.CreateThread(function()
    local sleep
    local player = GetPlayerPed(-1)
    while true do
        TriggerServerEvent("fd_copextras:checkOnDuty")
        if onDuty then
            sleep = 10
            if IsControlJustPressed(1,73) and (GetVehiclePedIsIn(player,false) == 0) then
                local target, distance = GetClosestPlayer()
                if distance ~= -1 and distance < 3 then
                    TriggerServerEvent("DRP_Police:CheckHandCuff", GetPlayerServerId(target))
                else
                    TriggerEvent("DRP_Core:Info", "Cuff", tostring("No Persons Near You"), 7000, false, "leftCenter")
                end
            elseif IsControlJustPressed(1,48) and (GetVehiclePedIsIn(player,false) == 0) then
                local target, distance = GetClosestPlayer()
                if distance ~= -1 and distance < 3 then
                    TriggerServerEvent("DRP_Police:CheckLEOEscort", GetPlayerServerId(target))
                else
                    TriggerEvent("DRP_Core:Info", "Drag", tostring("No Persons Near You"), 7000, false, "leftCenter")
                end
            end
        else
            sleep = 1000
        end
        Citizen.Wait(sleep)
    end
end)

RegisterCommand("ss", function(src,args,raw)
    local player = GetPlayerPed(-1)
    if onDuty and (GetVehiclePedIsIn(player,false) == 0) then
        print("should spawn spikes")
        local spikePos = GetOffsetFromEntityInWorldCoords(player,0,3.0,0)
        spawnSpikes(spikePos)
    end
end,false)

-- Tire Popping --
Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      local ped = GetPlayerPed(-1)
      local veh = GetVehiclePedIsIn(ped, false)
      local vehCoord = GetEntityCoords(veh)
      if IsPedInAnyVehicle(ped, false) then
        if DoesObjectOfTypeExistAtCoords(vehCoord["x"], vehCoord["y"], vehCoord["z"], 0.9, GetHashKey("P_ld_stinger_s"), true) then
           SetVehicleTyreBurst(veh, 0, true, 1000.0)
           SetVehicleTyreBurst(veh, 1, true, 1000.0)
           SetVehicleTyreBurst(veh, 2, true, 1000.0)
           SetVehicleTyreBurst(veh, 3, true, 1000.0)
           SetVehicleTyreBurst(veh, 4, true, 1000.0)
           SetVehicleTyreBurst(veh, 5, true, 1000.0)
           SetVehicleTyreBurst(veh, 6, true, 1000.0)
           SetVehicleTyreBurst(veh, 7, true, 1000.0)
           deleteSpikes(vehCoord)
         end
       end
     end
  end)