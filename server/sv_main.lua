local QBCore = exports['qb-core']:GetCoreObject()
Config = {
    Inv = "ox", -- qb(=lj) or ox [Inventory system]
    webhook = "https://discord.com/api/webhooks/1098347143602913340/61nQVpgAZILNJyUNN3v6AP2yvtR8VLKcOjNVcfGYpKBfotrpqNy4uDxsQA-ERh4bqnFi", -- Add Discord webhook
    UsePsMDT = true,
}

RegisterNetEvent("ps-camera:cheatDetect", function()
    DropPlayer(source, "Cheater Detected")
end)

RegisterNetEvent("ps-camera:requestWebhook", function(Key)
    local source = source
    local event = ("ps-camera:grabbed%s"):format(Key)
    if Config.webhook == '' then
        print("^1A webhook is missing in: Config.webhook")
    else
        TriggerClientEvent(event, source, Config.webhook)
    end
end)

RegisterNetEvent("ps-camera:CreatePhoto", function(url)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local coords = GetEntityCoords(GetPlayerPed(source))

    TriggerClientEvent("ps-camera:getStreetName", source, url, coords)
end)

RegisterNetEvent("ps-camera:savePhoto", function(url, streetName)
    
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local location = streetName

    local info = {
        ps_image = url,
        location = location
    }
    if Config.Inv == "qb" then
        player.Functions.AddItem("photo", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['photo'], "add")
    elseif Config.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        
        if not ox_inventory:CanCarryItem(source, 'photo', 1) then
			return TriggerClientEvent('QBCore:Notify', source, "Can not carry photo!", "error")
		end

        ox_inventory:AddItem(source, "photo", 1, info)
        
    end
    if Config.UsePsMDT then
        TriggerEvent("ps-camera:ps-mdt", source, url)
    end
end)


QBCore.Functions.CreateUseableItem("camera", function(source, item)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Inv == "qb" then
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent("ps-camera:useCamera", source)
        end
    elseif Config.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        if ox_inventory:GetItem(source, item.name, nil, true) > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        end
    end
    
end)

QBCore.Functions.CreateUseableItem("photo", function(source, item)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Inv == "qb" then
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent("ps-camera:usePhoto", source, item.info.ps_image, item.info.location)
        end
    elseif Config.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        if ox_inventory:GetItem(source, item.name, nil, true) > 0 then
            TriggerClientEvent("ps-camera:usePhoto", source, item.metadata.ps_image, item.metadata.location)
        end
    end
end)

function UseCam(source)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if Config.Inv == "qb" then
        if Player.Functions.GetItemByName('camera') then
            TriggerClientEvent("ps-camera:useCamera", source)
        else
            TriggerClientEvent('QBCore:Notify', source, "U don\'t have a camera", "error")
        end
    elseif Config.Inv == "ox" then
        local ox_inventory = exports.ox_inventory
        if ox_inventory:GetItem(source, 'camera', nil, true) > 0 then
            TriggerClientEvent("ps-camera:useCamera", source)
        else
            TriggerClientEvent('QBCore:Notify', source, "U don\'t have a camera", "error")
        end
    end    
end

exports("UseCam", UseCam)
