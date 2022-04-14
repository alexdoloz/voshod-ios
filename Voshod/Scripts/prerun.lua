--- This script runs before launching main script of the VM
--- It completes following tasks:
---     + setup package.path so `require` works correctly
---     + setup plugin infrastructure
---     + setup appropriate environment table for main script
---     + make some tricky `pcall` swizzling so script cancelling works

