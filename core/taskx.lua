-- taskx.lua
-- Cooperative task scheduler built on coroutines

local taskx = {}

-- Tasks are stored locally for easy cancellation, pausing, etc.
local tasks = {}

-- Task object

local Task = {}
Task.__index = Task

-- Create a new task
function Task.new(fn)
    return setmetatable({
        fn = fn,
        co = coroutine.create(fn),
        wait = -1,       -- run immediately on first update
        cancelled = false,
        paused = false,

        done = false,
        value = nil,
        err = nil,
    }, Task)
end

-- Cancel this task
function Task:cancel()
    self.cancelled = true
end

-- Pause this task
function Task:pause()
    self.paused = true
end

-- Resume this task
function Task:resume()
    self.paused = false
end

-- Restart this task
function Task:restart()
    self.co = coroutine.create(self.fn)
    self.wait = -1
    self.cancelled = false
    self.paused = false
    self.done = false
    self.value = nil
    self.err = nil

    -- reinsert if not already scheduled
    for _, t in ipairs(tasks) do
        if t == self then
            return self
        end
    end

    table.insert(tasks, self)
    return self
end

-- Task state helpers
function Task:isDone()
    return self.done
end

function Task:result()
    return self.value
end

function Task:error()
    return self.err
end

-- Sleep from inside this task
function Task:sleep(seconds)
    assert(
        coroutine.running() == self.co,
        "Task:sleep must be called from its own task"
    )
    coroutine.yield(seconds)
end

-- taskx API

-- Spawn a new task
function taskx.spawn(fn)
    local task = Task.new(fn)
    table.insert(tasks, task)
    return task
end

-- Sleep inside a task
function taskx.sleep(seconds)
    assert(
        coroutine.running(),
        "taskx.sleep must be called inside a task"
    )
    coroutine.yield(seconds)
end

-- Update all tasks (call every frame / tick)
function taskx.update(dt)
    for i = #tasks, 1, -1 do
        local task = tasks[i]

        if task.cancelled then
            table.remove(tasks, i)

        elseif not task.paused then
            task.wait = task.wait - dt

            if task.wait <= 0 then
                local ok, res = coroutine.resume(task.co)

                if not ok then
                    -- Task crashed
                    task.err = res
                    task.done = true
                    table.remove(tasks, i)

                elseif coroutine.status(task.co) == "dead" then
                    -- Task finished normally
                    task.done = true
                    task.value = res
                    table.remove(tasks, i)

                elseif type(res) == "number" then
                    -- Task yielded a sleep duration
                    task.wait = res
                end
            end
        end
    end
end

-- Step scheduler once (zero-dt update)
function taskx.step()
    taskx.update(0)
end

-- Cancel all tasks, returns how many were cancelled
function taskx.cancelAll()
    local count = #tasks
    for i = #tasks, 1, -1 do
        tasks[i] = nil
    end
    return count
end

return taskx