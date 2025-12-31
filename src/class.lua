-- class.lua - OOP enforcement for Lua
-- Provides: classes, inheritance, polymorphism, interfaces, abstract methods

local Class = {}
Class.__index = Class

-- Abstract method marker
function Class.abstract()
    error("Abstract method must be implemented by subclass")
end

-- Interface definition
function Class.interface(name, methods)
    return {
        __interface = true,
        __name = name,
        __methods = methods
    }
end

-- Main extend function
function Class:extend(name, options)
    options = options or {}
    local cls = {}
    cls.__name = name
    cls.__index = cls
    cls.super = self
    cls.__interfaces = options.implements or {}
    cls.__abstract = options.abstract or false

    return setmetatable(cls, {
        __index = self,
        __call = function(c, ...)
            -- Prevent instantiation of abstract classes
            if c.__abstract then
                error(string.format("Cannot instantiate abstract class '%s'", name))
            end
            
            -- Check abstract methods are implemented
            local current = c
            while current do
                for methodName, method in pairs(current) do
                    if type(method) == "function" then
                        local info = debug.getinfo(method, "S")
                        if info.source:find("Abstract method must be implemented") then
                            error(string.format("Class '%s' must implement abstract method '%s'", name, methodName))
                        end
                    end
                end
                current = current.super
            end
            
            -- Check interface implementation
            for _, interface in ipairs(c.__interfaces) do
                if interface.__interface then
                    for _, method in ipairs(interface.__methods) do
                        if not c[method] or type(c[method]) ~= "function" then
                            error(string.format("Class '%s' must implement interface method '%s' from '%s'", 
                                name, method, interface.__name))
                        end
                    end
                end
            end
            
            -- Create instance
            local instance = setmetatable({}, c)
            instance.__class = c
            
            if instance.init then
                instance:init(...)
            end
            return instance
        end
    })
end

-- Helper for instanceof check
function instanceof(obj, class)
    if not obj or not obj.__class then return false end
    local mt = obj.__class
    while mt do
        if mt == class then return true end
        mt = mt.super
    end
    return false
end

-- Helper for interface check
function implements(obj, interface)
    if not obj or not obj.__class then return false end
    for _, impl in ipairs(obj.__class.__interfaces) do
        if impl == interface then return true end
    end
    return false
end

return Class
