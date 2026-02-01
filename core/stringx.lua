local stringx = {}

-- Check if a string is empty or nil
function stringx.isEmpty(s)
    return s == nil or s == ""
end

-- Check if string starts with a prefix
function stringx.startsWith(s, prefix)
    if s == nil or prefix == nil then return false end
    return string.sub(s, 1, #prefix) == prefix
end

-- Check if string ends with a suffix
function stringx.endsWith(s, suffix)
    if s == nil or suffix == nil then return false end
    return string.sub(s, -#suffix) == suffix
end

-- Trim whitespace from both ends
function stringx.trim(s)
    if s == nil then return "" end
    return s:match("^%s*(.-)%s*$")
end

-- Split string by separator
function stringx.split(s, sep)
    if s == nil then return {} end
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
        t[#t + 1] = str
    end
    return t
end

-- Repeat a string n times
function stringx.repeatString(s, n)
    if s == nil or n <= 0 then return "" end
    local t = {}
    for i = 1, n do
        t[i] = s
    end
    return table.concat(t)
end

-- Buffer helper
function stringx.buffer()
    local buf = {}
    local obj = {}

    -- Add a string to the buffer
    function obj:push(s)
        if s ~= nil then
            buf[#buf + 1] = s
        end
    end

    -- Concatenate all buffer contents
    function obj:concat(sep)
        sep = sep or ""
        return table.concat(buf, sep)
    end

    -- Clear the buffer
    function obj:clear()
        for k in pairs(buf) do
            buf[k] = nil
        end
    end

    return obj
end

function stringx.progressiveString(s)
    assert(type(s) == "string", "expected string")

    local buf = stringx.buffer()
    local index = 1
    local len = #s

    local obj = {}

    function obj:update()
        if index <= len then
            buf:push(string.sub(s, index, index))
            index = index + 1
        end
        return buf:concat()
    end

    function obj:get()
        return buf:concat()
    end

    function obj:isDone()
        return index > len
    end

    function obj:reset()
        buf:clear()
        index = 1
    end

    return obj
end

--[[example buffer usage:
local stringx = require("morolua/core/stringx") -- or wherever your module lives

-- create a buffer
local buf = stringx.buffer()

-- push strings into it
buf:push("Hello")
buf:push(", ")
buf:push("World")
buf:push("!")

-- join all the strings
local result = buf:concat()  -- "Hello, World!"

print(result)

-- clear the buffer to reuse
buf:clear()
buf:push("Another string")
print(buf:concat())  -- "Another string"


also dont forget buf:concat can take a sep argument example:
buf:push("a")
buf:push("b")
buf:push("c")
print(buf:concat("-"))  -- "a-b-c"


]]

return stringx
