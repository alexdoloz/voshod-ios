local Version = require "version"

local function parseVersionPattern(pattern)
    local _, _, versionString, sign = pattern:find "^([%d%.]+)([%+%-])$"
    if versionString and sign then
        local version = Version(versionString)
        if sign == "+" then
            return version, Version.max
        else
            return Version.min, version
        end
    end
    error("Can't parse pattern " .. pattern)
    -- TODO: Implement [:]
end

local versionPatternMT = {}
versionPatternMT.__index = versionPatternMT

function versionPatternMT:matches(version)
    return self.fromVersion <= version and self.toVersion >= version
end

function versionPatternMT:__eq(other)
    return self.fromVersion == other.fromVersion and
        self.toVersion == other.toVersion
end

local VersionPatternMT = {}

function VersionPatternMT.__call(self, pattern)    
    local fromVersion, toVersion = parseVersionPattern(pattern)
    local versionPattern = {
        fromVersion = fromVersion,
        toVersion = toVersion
    }

    setmetatable(versionPattern, versionPatternMT)
    return versionPattern
end

local VersionPattern = {}

setmetatable(VersionPattern, VersionPatternMT)

return VersionPattern