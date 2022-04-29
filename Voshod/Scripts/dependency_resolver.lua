local resolverMT = {}
resolverMT.__index = resolverMT

-- function resolverMT:resolveSpecifierPattern(specifierPattern) 

-- end

-- function resolverMT:resolveSpecifier(specifier)
    
-- end

local function matchingSpecifiers(specifiers, specifierPattern)
    local result = {}
    for i in 1, #specifiers do
        local specifier = specifiers[i]
        if specifierPattern:matches(specifier) then
            result[#result + 1] = specifier
        end
    end
    return result
end

local function contains(table, item)
    for _, v in pairs(table) do
        if v == item then return true end
    end
    return false
end

local function copy(table)
    local result = {}
    for k, v in pairs(table) do
        result[k] = v
    end

    return result
end

local function resolveSpecifierPattern(dependencies, specifierPattern, origins)
    local matches = matchingSpecifiers(dependencies.specifiers, specifierPattern)
    assert(#matches > 0, "No matching specifiers for " .. specifierPattern)
    
end

local function resolveSpecifier(dependencies, specifier, origins)
    assert(contains(dependencies.specifiers, specifier), "Specifier " .. tostring(specifier) .. " doesn't exist")
    assert(not contains(origins, specifier), "Circular dependency")
    if #dependencies.required[specifier] == 0 and #dependencies.optional[specifier] == 0 then
        return { specifier }
    end
    for _, dep in pairs(dependencies.required[specifier]) do
        local newOrigins = copy(origins)
        newOrigins[#newOrigins + 1] = specifier
        local status, result = pcall(resolveSpecifierPattern, dependencies, dep, newOrigins)
        assert(status, "Can't resolve required dependency " .. tostring(dep) .. " for " .. tostring(specifier))
    end

    

    -- return   
end

local function DependencyResolver(specifiers, dependencies)
    local resolver = {}
    setmetatable(resolver, resolverMT)
    return resolver
end

return DependencyResolver