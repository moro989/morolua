-- assertx.lua
local assertx = {}

local function fail(msg, level)
    error(msg, (level or 1) + 1)
end

-- basic assertions

function assertx.isTrue(v, msg)
    if v ~= true then
        fail(msg or "expected true, got " .. tostring(v), 2)
    end
end

function assertx.isFalse(v, msg)
    if v ~= false then
        fail(msg or "expected false, got " .. tostring(v), 2)
    end
end

function assertx.notNil(v, name)
    if v == nil then
        fail((name or "value") .. " must not be nil", 2)
    end
end

-- type assertions

function assertx.type(v, expected, name)
    local t = type(v)
    if t ~= expected then
        fail(
            (name or "value") ..
            " must be of type '" .. expected ..
            "', got '" .. t .. "'",
            2
        )
    end
end

function assertx.oneOf(v, allowed, name)
    for _, a in ipairs(allowed) do
        if v == a then
            return
        end
    end
    fail(
        (name or "value") ..
        " must be one of [" .. table.concat(allowed, ", ") .. "]",
        2
    )
end

-- numeric assertions

function assertx.range(v, min, max, name)
    assertx.type(v, "number", name)
    if v < min or v > max then
        fail(
            (name or "value") ..
            " must be in range [" .. min .. ", " .. max .. "]",
            2
        )
    end
end

-- table assertions

function assertx.table(v, name)
    assertx.type(v, "table", name)
end

function assertx.nonEmptyTable(v, name)
    assertx.type(v, "table", name)
    if next(v) == nil then
        fail((name or "table") .. " must not be empty", 2)
    end
end

-- function assertion

function assertx.func(v, name)
    assertx.type(v, "function", name)
end

return assertx
