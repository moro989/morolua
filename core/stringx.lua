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

-- Generic progressive helper using a character producer
local function progressiveFromIterator(nextChar)
    local buf = stringx.buffer()
    local done = false

    local obj = {}

    function obj:update()
        if not done then
            local ch = nextChar()
            if ch then
                buf:push(ch)
            else
                done = true
            end
        end
        return buf:concat()
    end

    function obj:get()
        return buf:concat()
    end

    function obj:isDone()
        return done
    end

    function obj:reset()
        buf:clear()
        done = false
        if obj._reset then
            nextChar = obj._reset()
        end
    end

    return obj
end

-- Byte-based progressive string
function stringx.progressiveString(s)
    assert(type(s) == "string", "expected string")

    local index = 1
    local len = #s

    local function makeIter()
        index = 1
        return function()
            if index <= len then
                local ch = string.sub(s, index, index)
                index = index + 1
                return ch
            end
        end
    end

    local obj = progressiveFromIterator(makeIter())
    obj._reset = makeIter
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

stringx.utf8 = {}

local function utf8_char_size(byte)
    if byte < 0x80 then
        return 1
    elseif byte < 0xE0 then
        return 2
    elseif byte < 0xF0 then
        return 3
    elseif byte < 0xF8 then
        return 4
    end
    return 1 -- fallback for invalid data
end

function stringx.utf8.len(s)
    if type(s) ~= "string" then return 0 end

    local len = 0
    local i = 1
    local bytes = #s

    while i <= bytes do
        local c = string.byte(s, i)
        i = i + utf8_char_size(c)
        len = len + 1
    end

    return len
end

function stringx.utf8.sub(s, startChar, endChar)
    assert(type(s) == "string", "expected string")

    startChar = startChar or 1
    endChar = endChar or math.huge

    local i = 1
    local charIndex = 1
    local byteStart, byteEnd

    while i <= #s do
        if charIndex == startChar then
            byteStart = i
        end

        if charIndex > endChar then
            byteEnd = i - 1
            break
        end

        i = i + utf8_char_size(string.byte(s, i))
        charIndex = charIndex + 1
    end

    if byteStart then
        byteEnd = byteEnd or #s
        return string.sub(s, byteStart, byteEnd)
    end

    return ""
end

function stringx.utf8.iter(s)
    assert(type(s) == "string", "expected string")

    local i = 1
    local n = #s

    return function()
        if i > n then return nil end

        local start = i
        i = i + utf8_char_size(string.byte(s, i))

        return string.sub(s, start, i - 1)
    end
end

--[[example usage for stringx.utf8.iter(s):
for ch in stringx.utf8.iter("héllo") do
    print(ch)
end
]]  

--gets unicode codepoint number at character index.
function stringx.utf8.codepoint(s, targetIndex)
    assert(type(s) == "string", "expected string")

    local i = 1
    local charIndex = 1

    while i <= #s do
        local c = string.byte(s, i)
        local size = utf8_char_size(c)

        if charIndex == targetIndex then
            local code = c % (2 ^ (8 - size - 1))
            for j = 1, size - 1 do
                i = i + 1
                code = code * 64 + (string.byte(s, i) % 64)
            end
            return code
        end

        i = i + size
        charIndex = charIndex + 1
    end

    return nil
end

-- UTF-8 progressive string using iterator + shared helper
function stringx.utf8.progressiveString(s)
    assert(type(s) == "string", "expected string")

    local function makeIter()
        return stringx.utf8.iter(s)
    end

    local obj = progressiveFromIterator(makeIter())
    obj._reset = makeIter
    return obj
end

return stringx