--- Proxying of array, dictionary and string

function Voshod.makeArrayProxy(proxyUD) 
    local arrayProxyMT = {}

    function arrayProxyMT:__index(key)
        return Voshod.callbacks.getArrayIndex(proxyUD, key)
    end

    function arrayProxyMT:__newindex(key, value)
        Voshod.callbacks.setArrayIndex(proxyUD, key, value)
    end

    function arrayProxyMT:__len()
        return Voshod.callbacks.getArrayCount(proxyUD)
    end
    setmetatable(proxyUD, arrayProxyMT)
    return proxyUD
end