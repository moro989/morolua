-- eventx.lua
-- Lightweight event system (Roblox-style signals)

local eventx = {}
eventx.__index = eventx

-- create a new event bus
-- example:morolua = require("morolua.init") 
--         uievents = morolua.eventx.new()
--         uievents:on("button_click",function() print("button clicked")end)
--         etc.
function eventx.new()
    return setmetatable({
        listeners = {}
    }, eventx)
end

-- register a listener
function eventx:on(name, fn)
    local listeners = self.listeners

    if not listeners[name] then
        listeners[name] = {}
    end

    table.insert(listeners[name], fn)
    return fn -- optional: lets you store reference for :off
end

-- remove a listener
function eventx:off(name, fn)
    local list = self.listeners[name]
    if not list then return end

    for i = #list, 1, -1 do
        if list[i] == fn then
            table.remove(list, i)
        end
    end

    if #list == 0 then
        self.listeners[name] = nil
    end
end

-- register a listener that runs once
function eventx:once(name, fn)
    local wrapper
    wrapper = function(...)
        self:off(name, wrapper)
        fn(...)
    end
    self:on(name, wrapper)
end

-- fire an event
function eventx:emit(name, ...)
    local list = self.listeners[name]
    if not list then return end

    -- snapshot to prevent mutation issues
    local snapshot = {}
    for i, fn in ipairs(list) do
        snapshot[i] = fn
    end

    for _, fn in ipairs(snapshot) do
        fn(...)
    end
end

-- clear listeners
function eventx:clear(name)
    if name then
        self.listeners[name] = nil
    else
        self.listeners = {}
    end
end

return eventx
