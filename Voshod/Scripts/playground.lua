if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- local SpecifierPattern = require "specifier_pattern"
-- local Specifier = require "Specifier"
-- local sp = SpecifierPattern "JSON 4.3.[5:]"

local VersionPattern = require "version_pattern"
local Version = require "version"
local vp = VersionPattern "4.2+"
-- print(vp:matches(Version "4.2.0"))
-- print(vp:matches(Version "4.2.3"))
-- print(vp:matches(Version "4.5.0"))
-- print(vp:matches(Version "5.2.0"))
-- print(vp:matches(Version "1.2.0"))
-- print(vp:matches(Version "1.9.0"))

local Specifier = require "specifier"
local spec = Specifier "JSON 4.3"

local SpecifierPattern = require "specifier_pattern"
local sp = SpecifierPattern "JSON 20-"
print(sp:matches(spec))
-- print(sp:matches(Specifier "JSON 4.3.1"))