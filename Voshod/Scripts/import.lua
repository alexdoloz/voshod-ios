
print("VMUD from import", vmUD)

local pluginsEnvironmentCache = {}

local pluginsRegistry = {}

function __voshod_receive_message(pluginUD, message)
    local plugin = pluginsRegistry[pluginUD]
    if not plugin then
        error("Received message for nonexisting plugin " .. tostring(pluginUD))
    end
    return plugin:receive(message)
end

local function copyTable(fromTable, toTable)
    for k, v in pairs(fromTable) do
        toTable[k] = v
    end
end

local function import_string(specifier, environment)
    local name, version = __voshod_resolve_specifier(vmUD, specifier)
    print("NV", name, version)
    local cachedEnvironment = pluginsEnvironmentCache[name .. version]
    if cachedEnvironment then
        copyTable(cachedEnvironment, environment)
        return
    end
    local pluginUD = __voshod_create_plugin(vmUD, specifier)
    local installerScript = __voshod_get_installer(pluginUD)
    local plugin = {
        name = name,
        version = version
    }
    local pluginMT = {
        __metatable = "No access"
    }
    pluginMT.__index = pluginMT

    function pluginMT:send(message)
        return __voshod_send_message(pluginUD, message)
    end

    function pluginMT:receive(message)
        print(name ..  ": received " .. tostring(message))
    end

    setmetatable(plugin, pluginMT)

    pluginsRegistry[pluginUD] = plugin

    local installer = loadstring(installerScript, name .. " " .. version)
    local tempEnvironment = {}
    --[[setfenv(installer, {
        plugin = plugin,
        environment = tempEnvironment
    })
    ]]

    installer(plugin, tempEnvironment)
    copyTable(tempEnvironment, environment)
    pluginsEnvironmentCache[name..version] = tempEnvironment
end

local function import_table(specifiers, environment)
 -- todo - сделать
end

local function import(a, environment)
    local t = type(a)
    if t ~= "string" and t ~= "table" then
        error([[
        Can't import \"" .. tostring(a) .. "\"; pass either string 
        with plugin specifier (e.g. 'JSON 0.1.x') or table of plugin specifiers
        ]]
    )
    end
    local exportedEnvironment = {}
    if t == "string" then
        import_string(a, environment or exportedEnvironment)
    end
    if t == "table" then 
        import_table(a, environment or exportedEnvironment)
    end
    if not environment then
        local callerEnvironment = getfenv(2)
        copyTable(exportedEnvironment, callerEnvironment)
    end
end

return import

