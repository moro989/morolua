local tablex = {}

-- Clear a table
function tablex.clear(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

-- Check if a table is an array (1..n consecutive integer keys)
function tablex.isArray(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    local max = 0

    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k <= 0 or k % 1 ~= 0 then
            return false
        end
        if k > max then
            max = k
        end
        count = count + 1
    end

    return count == max
end

-- Check if table contains a value (search in array or dictionary values)
function tablex.contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Get all keys (returns array of keys)
function tablex.keys(tbl)
    local t = {}
    local i = 1
    for k in pairs(tbl) do
        t[i] = k
        i = i + 1
    end
    return t
end

-- Get all values (returns array of values)
function tablex.values(tbl)
    local t = {}
    local i = 1
    for _, v in pairs(tbl) do
        t[i] = v
        i = i + 1
    end
    return t
end

-- Find index of a value in an array (only works if isArray(tbl) == true)
function tablex.indexOf(tbl, value)
    if not tablex.isArray(tbl) then
        error("tablex.indexOf: given table is not an array")
    end
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Shallow copy of a table (works for arrays or dictionaries)
function tablex.shallowCopy(tbl)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = v
    end
    return t
end

function tablex.deepCopy(tbl, seen)
    if type(tbl) ~= "table" then
        return tbl
    end
    -- track already-copied tables (for cycles)
    seen = seen or {}
    if seen[tbl] then
        return seen[tbl]
    end
    local copy = {}
    seen[tbl] = copy
    for k, v in pairs(tbl) do
        local newKey = tablex.deepCopy(k, seen)
        local newVal = tablex.deepCopy(v, seen)
        copy[newKey] = newVal
    end
    return copy
end


-- Merge two tables into a new one (dictionary keys will overwrite)
function tablex.merge(t1, t2)
    local t = tablex.shallowCopy(t1)
    for k, v in pairs(t2) do
        t[k] = v
    end
    return t
end

function tablex.circularIndex(tbl, i)
    assert(type(tbl) == "table", "expected table")
    local len = #tbl
    assert(len > 0, "empty table")

    -- Lua-safe modulo wrapping
    return ((i - 1) % len) + 1
end
--[[example usage for circularIndex:
local items = { "Play", "Options", "Quit" }
local selected = 1
-- move right
selected = tablex.circularIndex(items, selected + 1)
-- move left
selected = tablex.circularIndex(items, selected - 1)
print(items[selected])
]]
return tablex


