local typex = {}

function typex.isNumber(x)
    return type(x) == "number"
end

function typex.isString(x)
    return type(x) == "string"
end

function typex.isTable(x)
    return type(x) == "table"
end

function typex.isNil(x)
    return type(x) == "nil"
end

function typex.isCallable(x,seen)
    seen = seen or {}
    local t = type(x)
    if t == "function" then
        return true
    end

    if t == "table" or t == "userdata" then
        if seen[x] then --just so things dont go kaboom in an infinite loop
            return false
        end
        seen[x] = true
        local mt = getmetatable(x)
        if mt and mt.__call then
            return typex.isCallable(mt.__call, seen)
        end
    end

    return false
end

function typex.isFunction(x)
    return type(x) == "function"
end

function typex.isThread(x)
    return type(x) == "thread"
end

function typex.isType(x, expected)
    return type(x) == expected
end


function typex.assertType(x, expectedType)
    if type(x) ~= expectedType then
        error(
            ("Expected type '%s', got '%s'"):format(expectedType, type(x)),
            2
        )
    end
end

function typex.isSameType(...)
    local packed = {...}
    if #packed < 2 then
        error("only one argument or no argument was given to typex.isSameType!")
    end

    local t = type(packed[1])
    for i = 2, #packed do
        if type(packed[i]) ~= t then
            return false
        end
    end
    return true
end

return typex
