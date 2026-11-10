RegisterCommand(Config.LogViewer.command or 'ravnlogs', function()
    TriggerServerEvent('ravn_logs:viewerOpen')
end, false)

RegisterNetEvent('ravn_logs:viewerOpenResult', function(allowed)
    if not allowed then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'visible', visible = true })
end)

RegisterNetEvent('ravn_logs:viewerSearchResult', function(result, err)
    SendNUIMessage({ action = 'results', result = result, error = err })
end)

RegisterNUICallback('searchLogs', function(data, cb)
    TriggerServerEvent('ravn_logs:viewerSearch', data)
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then SetNuiFocus(false, false) end
end)
