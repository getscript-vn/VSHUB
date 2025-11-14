if not getgenv()._VST then
    getgenv()._VST = {["Loader"] = {}}
end
if not getgenv()._vstfunction then
    getgenv()._vstfunction = {}
end
getgenv()._vstfunction["AddID"] = function(a)
    if type(a) ~= "table" then
        return warn("[AddID] : expected table as argument")
    end
    local b = game:GetService("AssetService")
    local c, d =
        pcall(
        function()
            return b:GetGamePlacesAsync()
        end
    )
    if not c then
        warn("[AddID] : failed to call GetGamePlacesAsync:", d)
        return
    end
    local e = d
    while true do
        local f, g =
            pcall(
            function()
                return e:GetCurrentPage()
            end
        )
        if not f or not g then
            break
        end
        for h, i in ipairs(g) do
            if i and i.PlaceId then
                table.insert(a, i.PlaceId)
            end
        end
        if e.IsFinished then
            break
        end
        local j, k =
            pcall(
            function()
                e:AdvanceToNextPageAsync()
            end
        )
        if not j then
            warn("[AddID] : AdvanceToNextPageAsync failed:", k)
            break
        end
    end
end

getgenv()._vstfunction.base64 = (function()
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local function encode(data)
        return ((data:gsub(".", function(x)
            local byte = x:byte()
            local bits = {}
            for i = 8, 1, -1 do
                bits[#bits + 1] = math.floor(byte / (2 ^ (i - 1))) % 2
            end
            return table.concat(bits)
        end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
            if #x < 6 then return "" end
            local num = tonumber(x, 2)
            return b:sub(num + 1, num + 1)
        end) .. ({ "", "==", "=" })[#data % 3 + 1])
    end

    local function decode(data)
        data = data:gsub("[^" .. b .. "=]", "")
        return (data:gsub(".", function(x)
            if x == "=" then return "" end
            local idx = b:find(x) - 1
            local bits = {}
            for i = 6, 1, -1 do
                bits[#bits + 1] = math.floor(idx / (2 ^ (i - 1))) % 2
            end
            return table.concat(bits)
        end):gsub("%d%d%d%d%d%d%d%d", function(x)
            return string.char(tonumber(x, 2))
        end))
    end

    return {
        encode = (base64_encode or (crypt and crypt.base64 and crypt.base64.encode) or encode),
        decode = (base64_decode or (crypt and crypt.base64 and crypt.base64.decode) or decode)
    }
end)()


getgenv()._vstfunction.load = function(l)
    print('[VST] Load Game initialising...')
    if type(l) == "table" then
        if l.type == 'Url' then
            if l.status:find('https://') then
                print('[VST] Load Game Runing...')
                loadstring(game:HttpGet(l.status))()
            else
                print('[VST] Load Game Runing...')
                loadstring(game:HttpGet('https://'..l.status))()
            end
        elseif l.type == 'Base' then 
            print('[VST] Load Game Runing...')
            loadstring(game:HttpGet(getgenv()._vstfunction.base64(l.status)))()
        end
    else
        print("[VST] : load called with non-table body")
    end
end

local m = tonumber(game.PlaceId)
print("[VST] : Loader initialising...")
getgenv()._VST["Loader"] = {
    ["Cộng Đồng Việt Nam"] = {
    PlaceId = {18192562963}, 
    Body = {type = "Url", status = "https://upload.cswz.site/api/674117893334682.lua"}
    }
}
if not getgenv()._VST["Loader"]["__GETGID"] then
    getgenv()._VST["Loader"]["__GETGID"] = {}
end
pcall(
    function()
        if #getgenv()._VST["Loader"]["__GETGID"] == 0 then
            getgenv()._vstfunction["AddID"](getgenv()._VST["Loader"]["__GETGID"])
        end
    end
)
for n, o in pairs(getgenv()._VST["Loader"]) do
    if n ~= "__GETGID" then
        local p = false
        if type(o.PlaceId) == "table" and next(o.PlaceId) then
            for h, q in ipairs(o.PlaceId) do
                if tonumber(q) and tonumber(q) == m then
                    p = true
                    break
                end
            end
        end
        if not p then
            for h, q in ipairs(getgenv()._VST["Loader"]["__GETGID"]) do
                if tonumber(q) and tonumber(q) == m then
                    p = true
                    break
                end
            end
        end
        if p then
            pcall(
                function()
                    print("[VST] : Loader "..n.."...")
                    getgenv()._vstfunction.load(o.Body)
                    print("[VST] : Loader Success...")
                end
            )
        end
    end
end

return {__VST = {}}
