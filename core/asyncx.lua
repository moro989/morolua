-- asyncx.lua
-- Sync / Async sugar layer for morolua

local asyncx = {}

local scheduler

-- =========================
-- Scheduler handling
-- =========================
local function getScheduler()
	if not scheduler then
		scheduler = require("core.taskx")
	end
	return scheduler
end

-- Optional dependency injection
-- Custom schedulers must implement:
--   .spawn(fn, ...)
--   .step()
function asyncx.use(customScheduler)
	scheduler = customScheduler
end

-- =========================
-- Core async API
-- =========================

function asyncx.run(fn, ...)
	-- spawn takes only one arg. You should probably refactor it to take varargs and store them in Task
	-- so they can be passed to fn
	return getScheduler().spawn(fn, ...)
end

function asyncx.await(task)
	assert(task and task.isDone, "asyncx.await expects a task")

	local sched = getScheduler()
	while not task:isDone() do
		sched.step()
	end

	if task.error then
		local err = task:error()
		if err then error(err) end
	end

	if task.result then
		return task:result()
	end
end

function asyncx.call(fn, ...)
	local running, isMain = coroutine.running()
	if running and not isMain then
		return fn(...)
	else
		local task = asyncx.run(fn, ...)
		return asyncx.await(task)
	end
end

function asyncx.sleep(steps)
	for _ = 1, (steps or 1) do
		coroutine.yield()
	end
end

-- =========================
-- Utilities
-- =========================

function asyncx.defer(fn)
	return asyncx.run(function()
		coroutine.yield()
		fn()
	end)
end

function asyncx.all(tasks)
	local results = {}
	for i, task in ipairs(tasks) do
		results[i] = asyncx.await(task)
	end
	return results
end

function asyncx.race(tasks)
	local sched = getScheduler()

	while true do
		for _, task in ipairs(tasks) do
			if task:isDone() then
				if task.error then
					local err = task:error()
					if err then error(err) end
				end
				if task.result then
					return task:result()
				end
				return
			end
		end
		sched.step()
	end
end

return asyncx
