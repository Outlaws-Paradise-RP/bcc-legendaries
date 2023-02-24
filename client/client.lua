--Do not touch anything in here if you do not know what you are doing. At the very least make a back up before you do.


local VORPutils = {}

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)
--Pulls vorp core

local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

--end pulling it

--Animal spawn setup
function spawnanimal()
    local catch17 = false --creates a kinda of catch/trigger varaible
    local deadcheck = false --creates a kind of catch/trigger variable
    local distancetracker = false --acts as a trigger of sorts
    local createdped = 0 --sets varible to 0
    local model = GetHashKey(Animal) --sets the model to the varible ped to make set in the menu part of the code(Animal is a global set in menusetup.lua)
    local coords = Animalcoords -- pulls the global set in menusetup.lua
    RequestModel(model) --dont know but is needed
    if not HasModelLoaded(model) then
        RequestModel(model)
    end
    while not HasModelLoaded(model) or HasModelLoaded(model) == 0 or model == 1 do
        Citizen.Wait(1)
    end --end dont know but is needed
    distancetracker = true --sets the trigger to true so it allows the while loop to work
    local blip = VORPutils.Blips:SetBlip('Last Location', 'blip_mp_collector_map', 0.8, coords.x, coords.y, coords.z) --sets a blip until you are within the distance
    --Waypointsetup
    local ul = GetEntityCoords(PlayerPedId()) --gets players location(not needed if alreadysetup)
    StartGpsMultiRoute(6, true, true) --sets the color and tells it to waypoint on foot and in vehicle
    AddPointToGpsMultiRoute(ul.x, ul.y, ul.z) --playerscoords
    AddPointToGpsMultiRoute(coords.x, coords.y, coords.z) --Where the waypoint is set too
    SetGpsMultiRouteRender(true) --sets the waypoint to active
    --end waypoint setup
    while distancetracker == true do --starts a loop
        Citizen.Wait(0) --waits a little(prevents crashing)
        if StopAll == false then --if the varible from menusetup lua is false then
            local pl = GetEntityCoords(PlayerPedId()) --gets the players coords without multiple varibles for optimization
            Dist9 = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, coords.x, coords.y, coords.z, false)--gets distance between player and animal spawn
            if Dist9 < 40 then --if distance is less than then
                if catch17 == false then --if catch17 is false then
                    catch17 = true --sets it to true to prevent the code below from running again since this is in a loop
                    ClearGpsMultiRoute() --deletes the waypoint
                    blip:Remove()
                    Createdped2 = CreatePed(model, coords.x, coords.y, coords.z, true, true, true, true) --creates the ped
                    Citizen.InvokeNative(0x283978A15512B2FE, Createdped2, true) --This sets the ped into a random outift(fixes an invisiblity bug)
                    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, Createdped2) --sets the blip that tracks the ped
                    SetEntityHealth(Createdped2, 500, 0) --changes the entity health to a higher amount
                    Citizen.CreateThread(function()
                        deadcheck = true --sets deadcheck to true
                        while deadcheck == true do --creates a loop
                            local dead = IsEntityDead(Createdped2) --checks if the ped is dead
                            Citizen.Wait(0) --prevents crashing
                            if dead == 1 then --if it is dead then
                                skinnedped() --trigger the skin ped event
                                break --breaks loop to save rss
                            end
                        end
                    end)
                end
            end
        elseif StopAll == true then --else if it is true(player dead) then
            if Dist9 > 40 then --if distance is greater than 50 then
                ClearGpsMultiRoute() --clears waypoint
                blip:Remove()
            end
            Citizen.Wait(2000) --waits 2 seconds
            DeletePed(createdped) --deletes ped
            VORPcore.NotifyBottomRight('You died, hunt failed', 6000) break --prints you died and failed in bottom right and breaks loop
        end
    end
end
--End animal spawn setup