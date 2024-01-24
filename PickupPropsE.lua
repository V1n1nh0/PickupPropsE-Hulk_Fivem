local holdingEntity = false
local holdingCarEntity = false
local heldEntity = nil
local entityType = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if holdingEntity and heldEntity then
            local playerPed = PlayerPedId()
            local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
            if holdingCarEntity and not IsEntityPlayingAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 3) then
                RequestAnimDict('anim@mp_rollarcoaster')
                while not HasAnimDictLoaded('anim@mp_rollarcoaster') do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
            elseif not IsEntityPlayingAnim(playerPed, "anim@heists@box_carry@", "idle", 3) and not holdingCarEntity then
                RequestAnimDict("anim@heists@box_carry@")
                while not HasAnimDictLoaded("anim@heists@box_carry@") do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
            end
 
            if not IsEntityAttached(heldEntity) then
                holdingEntity = false
                holdingCarEntity = false
                heldEntity = nil
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local camPos = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(2)
        local direction = RotationCamToDirection(camRot)
        local dest = vec3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)

        local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, playerPed, 0)
        local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
        local validTarget = false

        if hit == 1 then
            entityType = GetEntityType(entityHit)
            if entityType == 3 or entityType == 2 then
                validTarget = true
                local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
            end
        end

        if IsControlJustReleased(1, 38) then  -- Aperta E
            if validTarget then
                if not holdingEntity and entityHit and entityType == 3 then
                    local entityModel = GetEntityModel(entityHit)
                    DeleteEntity(entityHit)
                    RequestModel(entityModel)
                    while not HasModelLoaded(entityModel) do
                        Citizen.Wait(100)
                    end

                    local clonedEntity = CreateObject(entityModel, camPos.x, camPos.y, camPos.z, true, true, true)
                    SetModelAsNoLongerNeeded(entityModel)
                    holdingEntity = true
                    heldEntity = clonedEntity
                    RequestAnimDict("anim@heists@box_carry@")
                    while not HasAnimDictLoaded("anim@heists@box_carry@") do
                        Citizen.Wait(100)
                    end
                    TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
                    AttachEntityToEntity(clonedEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                elseif not holdingEntity and entityHit and entityType == 2 then
                    holdingEntity = true
                    holdingCarEntity = true
                    heldEntity = entityHit
                    RequestAnimDict('anim@mp_rollarcoaster')
                    while not HasAnimDictLoaded('anim@mp_rollarcoaster') do
                        Citizen.Wait(100)
                    end
                    TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
                    AttachEntityToEntity(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                end
            else
                if holdingEntity and holdingCarEntity then
                    holdingEntity = false
                    holdingCarEntity = false
                    ClearPedTasks(playerPed)
                    DetachEntity(heldEntity, true, true)
                    ApplyForceToEntity(heldEntity, 1, direction.x * 20, direction.y * 20, direction.z * 200, 0.0, 0.0, 0.0, 0, false, true, true, false, true) -- Força Pra Jogar o Veiculo
                elseif holdingEntity then
                    holdingEntity = false
                    ClearPedTasks(playerPed)
                    DetachEntity(heldEntity, true, true)
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    SetEntityCoords(heldEntity, playerCoords.x, playerCoords.y, playerCoords.z - 1, false, false, false, false)
                    SetEntityHeading(heldEntity, GetEntityHeading(PlayerPedId()))
                end
            end
        end
    end
end)

        function RotationCamToDirection(rotation)
            local adjustedRotation = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
            local direction = vec3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
            return direction
        end
