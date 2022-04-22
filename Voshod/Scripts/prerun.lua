--- This script runs before launching main script of the VM
--- It completes following tasks:
---     + setup package.path so `require` works correctly
---     + setup plugin infrastructure
---     + setup appropriate environment table for main script
---     + make some tricky `pcall` swizzling so script cancelling works

vmUD = ...
Voshod = {}

local pluginSpecifiers = { "JSON 1.1.0", "Std 0.1.0" }
local dependencies = { "JSON 1.1.0": { "Std 0+" } }

print("I'm in prerun script!")
print(__voshod_resolve_specifier)
print(vmUD)
print(bundlePath, voshodScriptsPath)

package.path = package.path .. ";" .. voshodScriptsPath .. "?.lua"

import = require "import" 