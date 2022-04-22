local Version = require "version"

local function parseSpecifier(str)
    local _, _, name, versionString = str:find "^(%a%w*) (.+)$"
    local version = Version(versionString)
    return name, version
end

local function Specifier(params)
    local name, version
    if type(params) == "string" then
        name, version = parseSpecifier(params)
    else
        name, version = params.name, params.version
    end
    local specifier = {
        name = name,
        version = version
    }

    local specifierMT = {}

    function specifierMT:__tostring()
        return tostring(self.name) .. " " .. tostring(self.version)
    end

    setmetatable(specifier, specifierMT)
    return specifier
end

return Specifier