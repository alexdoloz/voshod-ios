-------------------- Version ----------------------
--- Working with versions – creation, comparison

local function parseVersion(versionString)
    local _, _, maj, min, pat = versionString:find "^(%d+)%.?(%d*)%.?(%d*)$"
    min = min == "" and "0" or min
    pat = pat == "" and "0" or pat
    return tonumber(maj), tonumber(min), tonumber(pat)
    -- error("Failed to parse version string " .. versionString)
end

local versionMT = {}

function versionMT:__eq(other)
    return self.major == other.major and
        self.minor == other.minor and
        self.patch == other.patch
end

function versionMT:__le(other)
    if self.major ~= other.major then
        return self.major <= other.major
    end
    if self.minor ~= other.minor then
        return self.minor <= other.minor
    end
    if self.patch ~= other.patch then
        return self.patch <= other.patch
    end
    return true
end

function versionMT:__tostring()
    return 
        tostring(self.major) .. 
        "." ..   
        tostring(self.minor) ..
        "." ..
        tostring(self.patch)
end

local MAX_VERSION_PART = 1000000

local VersionMT = {}

function VersionMT.__call(self, params)
    local major, minor, patch = 0, 0, 0
    
    if type(params) == "string" then
        major, minor, patch = parseVersion(params)
    else
        major, minor, patch = params.major, params.minor, params.patch
    end

    assert(major >= 0, "Negative major version")
    assert(minor >= 0, "Negative minor version")
    assert(patch >= 0, "Negative patch version")
    
    assert(major <= MAX_VERSION_PART, "Too big major version")
    assert(minor <= MAX_VERSION_PART, "Too big minor version")
    assert(patch <= MAX_VERSION_PART, "Too big patch version")
    
    local version = {
        major = major,
        minor = minor, 
        patch = patch
    }

    setmetatable(version, versionMT)
    return version
end

local Version = {}

setmetatable(Version, VersionMT)

Version.maxVersionPart = MAX_VERSION_PART

Version.max = Version {
    major = MAX_VERSION_PART,
    minor = MAX_VERSION_PART,
    patch = MAX_VERSION_PART
}

Version.min = Version {
    major = 0, minor = 0, patch = 0
}

return Version