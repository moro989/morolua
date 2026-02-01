-- oopx.lua
-- Advanced but practical OOP helpers for Lua

local oopx = {}

----------------------------------------------------------------
-- CLASS SYSTEM
----------------------------------------------------------------
function oopx.class(base)
    local cls = {}
    cls.__index = cls
    cls.__base = base
    cls.__final = {}

    -- constructor
    function cls:new(...)
        local obj = setmetatable({}, cls)
        if obj.init then
            obj:init(...)
        end
        return obj
    end

    -- class metatable (important)
    setmetatable(cls, {
        __index = base,

        __newindex = function(t, k, v)
            -- block overriding final methods
            if base and base.__final and base.__final[k] then
                error("Cannot override final method: " .. k)
            end
            rawset(t, k, v)
        end
    })

    return cls
end

----------------------------------------------------------------
-- INSTANCE CHECK
----------------------------------------------------------------
function oopx.isInstance(obj, cls)
    local mt = getmetatable(obj)
    while mt do
        if mt == cls then return true end
        mt = mt.__base
    end
    return false
end

----------------------------------------------------------------
-- MIXINS (add behavior horizontally)
----------------------------------------------------------------
function oopx.mixin(cls, mixin)
    for k,v in pairs(mixin) do
        if cls[k] == nil then
            cls[k] = v
        end
    end
end

----------------------------------------------------------------
-- INTERFACES (rules only)
----------------------------------------------------------------
function oopx.interface(methods)
    return {
        __interface = true,
        methods = methods
    }
end

function oopx.implements(cls, interface)
    for name in pairs(interface.methods) do
        if type(cls[name]) ~= "function" then
            error("Class must implement method: " .. name)
        end
    end
end

----------------------------------------------------------------
-- TRAITS (rules + default behavior)
----------------------------------------------------------------
function oopx.trait(def)
    return {
        __trait = true,
        def = def
    }
end

function oopx.use(cls, trait)
    for k,v in pairs(trait.def) do
        if cls[k] == nil then
            cls[k] = v
        end
    end
end

----------------------------------------------------------------
-- ABSTRACT METHODS (must override)
----------------------------------------------------------------
function oopx.abstract(name)
    return function()
        error("Abstract method not implemented: " .. name)
    end
end

----------------------------------------------------------------
-- FINAL METHODS (cannot override)
----------------------------------------------------------------
function oopx.final(cls, methodName)
    cls.__final[methodName] = true
end

function oopx.super(obj, methodName, ...)
    local cls = getmetatable(obj)
    local base = cls and cls.__base

    if not base then
        error("No base class to call super from")
    end

    local method = base[methodName]
    if type(method) ~= "function" then
        error("Super method not found: " .. methodName)
    end

    return method(obj, ...)
end


return oopx
