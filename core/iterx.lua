local iterx = {}

-- expose helper if you want, or keep it local
local function toGen(src)
    if type(src) == "function" then
        return src
    elseif type(src) == "table" then
        local i = 0
        local n = #src
        return function()
            i = i + 1
            if i <= n then
                return src[i]
            end
        end
    else
        error("iterx: expected table or generator")
    end
end

-- each (mostly semantic, but nice)
function iterx.each(src)
    return toGen(src)
end

-- map (NOW generator -> generator)
function iterx.map(src, fn)
    local gen = toGen(src)
    return function()
        local v = gen()
        if v ~= nil then
            return fn(v)
        end
    end
end

-- filter (generator -> generator)
function iterx.filter(src, fn)
    local gen = toGen(src)
    return function()
        while true do
            local v = gen()
            if v == nil then return nil end
            if fn(v) then
                return v
            end
        end
    end
end

-- take
function iterx.take(src, count)
    local gen = toGen(src)
    local i = 0
    return function()
        if i >= count then return nil end
        local v = gen()
        if v == nil then return nil end
        i = i + 1
        return v
    end
end

-- range
function iterx.range(start, stop, step)
    start = start or 1
    step = step or 1
    local current = start - step
    return function()
        current = current + step
        if (step > 0 and current > stop)
        or (step < 0 and current < stop) then
            return nil
        end
        return current
    end
end

-- collect
function iterx.toTable(src)
    local gen = toGen(src)
    local t = {}
    local i = 1
    while true do
        local v = gen()
        if v == nil then break end
        t[i] = v
        i = i + 1
    end
    return t
end

return iterx
