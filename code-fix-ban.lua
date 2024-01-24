------------------------------------
-- CODED by V1N1
------------------------------------

------------------------------------
-- CLIENT
------------------------------------

local animCount = 0
local lastAnimTime = 0

function VehGrudado()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)

    local veiculos = GetGamePool('CVehicle')

    for _, veiculo in ipairs(veiculos) do
        local veiculoCoords = GetEntityCoords(veiculo)
        local distancia = #(playerCoords - veiculoCoords)

        if distancia < 1.5 then
            local model = GetEntityModel(veiculo)
            local nomeVeiculo = GetDisplayNameFromVehicleModel(model)
			TriggerServerEvent("enviarWebhook", nomeVeiculo)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)

        local playerPed = GetPlayerPed(-1)
        if IsEntityPlayingAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 3) then
			TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
            animCount = animCount + 1
            if animCount >= 5 and (GetGameTimer() - lastAnimTime) < 3000 then
                VehGrudado()
            end
        else
			lastAnimTime = GetGameTimer()
        end
    end
end)

------------------------------------
-- SERVER
------------------------------------
local webhookHackHulk = "https://discord.com/api/webhooks/1199785709565923328/HK0iZigGj665BvX4nJ8RcLtDb-befY9BZGJ3ZdPjsBIdD5nXIxKkYP6b9JYubyIptRQP"
RegisterServerEvent("enviarWebhook")
AddEventHandler("enviarWebhook", function(veiculo)
    local user_id = vRP.getUserId(source)
	local id = vRP.getUserSource(user_id)
	vRP.setBanned(user_id,true)    
	vRP.kick(id, "Vai Usar Hack na Casa do Caralho.")
	print(id)
	local reason = "HACK - HULK BR"
    SendWebhookMessage(webhookHackHulk,"```prolog\n[ID]: "..user_id.."  \n[MOTIVO]: " .. reason .. "\n[Tentou carregar o Veículo]: " .. veiculo .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")

end)