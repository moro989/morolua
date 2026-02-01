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

function typex.isCallable(x)
    if type(x) == "function" then
        return true
    end

    if type(x) == "table" then
        local mt = getmetatable(x)
        return mt and type(mt.__call) == "function"
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
