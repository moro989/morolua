-- taskx.lua
-- Cooperative task scheduler built on coroutines

local taskx = {}

local tasks = {}

-- internal: create a task
local function newTask(fn)
    local co = coroutine.create(fn)
    return {
        co = co,
        wait = 0
    }
end

-- spawn a new task
function taskx.spawn(fn)
    local task = newTask(fn)
    table.insert(tasks, task)
    return task
end

-- sleep inside a task
function taskx.sleep(seconds)
    coroutine.yield(seconds)
end

-- update all tasks (call every frame / tick)
function taskx.update(dt)
    for i = #tasks, 1, -1 do
        local task = tasks[i]

        task.wait = task.wait - dt
        if task.wait <= 0 then
            local ok, res = coroutine.resume(task.co)
            if not ok or coroutine.status(task.co) == "dead" then
                table.remove(tasks, i)
            elseif type(res) == "number" then
                task.wait = res
            end
        end
    end
end

-- cancel a task
function taskx.cancel(task)
    for i, t in ipairs(tasks) do
        if t == task then
            table.remove(tasks, i)
            return true
        end
    end
    return false
end

return taskx
