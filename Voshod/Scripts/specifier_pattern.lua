local Specifier = require "specifier"
local VersionPattern = require "version_pattern"
local Version = require "version"

local specifierPatternMT = {}

specifierPatternMT.__index = specifierPatternMT

function specifierPatternMT:matches(specifier)
    return specifier.name == self.name and self.versionPattern:matches(specifier.version)
end

function specifierPatternMT:maxMatching(specifiers)
    local resultVersion = Version.min
    local resultSpecifier = nil
    for i = 1, #specifiers do
        local specifier = specifiers[i]
        if specifier.version >= resultVersion then
            resultVersion = specifier.version
            resultSpecifier = specifier
        end
    end
    return resultSpecifier
end

local function parsePattern(pattern)
    local _, _, name, versionPatternString = pattern:find "^([%w]+) ([%d%.%+%-%[%]%:]+)"
    assert(name and versionPatternString, "Can't parse pattern " .. pattern)
    local versionPattern = VersionPattern(versionPatternString)
    return name, versionPattern
end

local function SpecifierPattern(pattern)
    local name, versionPattern = parsePattern(pattern)
    local specifierPattern = {
        name = name,
        versionPattern = versionPattern
    }

    setmetatable(specifierPattern, specifierPatternMT)

    return specifierPattern
end

return SpecifierPattern