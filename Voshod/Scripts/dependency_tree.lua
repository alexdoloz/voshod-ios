local DependencyTree = {}

local dependencyTreeMT = {}
dependencyTreeMT.__index = dependencyTreeMT

function dependencyTreeMT:iterateBottomUp(callback)
    
end

function DependencyTree()
    local dependencyTree = {
    }
    setmetatable(dependencyTree, dependencyTreeMT)
    return dependencyTree
end

return DependencyTree