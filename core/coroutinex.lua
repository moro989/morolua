-- coroutinex.lua
local coroutinex = {}


function coroutinex.run(fn)
    local co = coroutine.create(fn)
    coroutine.resume(co)
    return co
end

-- Pauses the current coroutine for `seconds`
-- The coroutine must be resumed with delta time (dt)
function coroutinex.sleep(seconds)
    local elapsed = 0
    while elapsed < seconds do
        elapsed = elapsed + coroutine.yield()
    end
end


function coroutinex.wrap(fn)
    local co = coroutine.create(fn)
    return function(...)
        return coroutine.resume(co, ...)
    end
end

function coroutinex.status(co)
    if type(co) ~= "thread" then
        return "invalid"
    end
    return coroutine.status(co)
end

return coroutinex
