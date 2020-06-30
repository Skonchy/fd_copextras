RegisterServerEvent("fd_copextras:checkOnDuty")
AddEventHandler("fd_copextras:checkOnDuty", function()
    local src = source
    local char = exports["drp_id"]:GetCharacterData(src)
    exports["externalsql"]:AsyncQueryCallback({
        query = [[SELECT * FROM characters WHERE id = :charid]],
        data = {
            charid = char.charid
        }
    }, function(results)
        if results.data == nil then
            TriggerClientEvent("DRP_Core:Error",src,"Cop Extras",tostring("Couldnt find character id in db"),4500,false,"leftCenter")
        else
            if results.data[1].job == "POLICE" then
                TriggerClientEvent("fd_copextras:toggleOnDuty", src, true)
            else
                TriggerClientEvent("fd_copextras:toggleOnDuty", src, false)
            end
        end
    end)
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end