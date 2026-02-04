---@alias anyval<T> table|metatable|userdata|lightuserdata|function|string|float|boolean Any Lua value except nil.

--------------------------------------
-- Class: set
--------------------------------------
---@generic T
---@class set<T> : { [T]: true }
---@field protected m_data table<anyval, true>
---@field protected m_data_type string
---@overload fun(...): set<...>
local set = { __type = "set" }
set.__index = set
---@diagnostic disable-next-line: param-type-mismatch
setmetatable(set, {
	__call = function(_, ...)
		return set.new(...)
	end
})

---@generic T
---@param ... T
---@return set<T>
function set.new(...)
	---@diagnostic disable-next-line: param-type-mismatch
	local instance = setmetatable({ m_data = {} }, set)
	local args = { ... }

	if (#args > 0) then
		instance.m_data_type = type(args[1])
		for _, arg in ipairs(args) do
			instance:push(arg)
		end
	end

	return instance
end

---@param element anyval
function set:push(element)
	if (element == nil) then
		return
	end

	if (self:contains(element)) then
		return
	end

	local __type = type(element)
	if (not self.m_data_type) then
		self.m_data_type = __type
	elseif (__type ~= self.m_data_type) then
		error(string.format(
			"[set]: Data type mismatch! A set can only be created with unique same-type objects. %s expected, got %s instead.",
			self.m_data_type,
			__type
		))
	end

	self.m_data[element] = true
end

---@param element anyval
function set:pop(element)
	self.m_data[element] = nil
end

function set:clear()
	self.m_data = {}
end

---@param element anyval
---@return boolean
function set:contains(element)
	return self.m_data[element] == true
end

---@return boolean
function set:is_empty()
	return (next(self.m_data) == nil)
end

---@return number
function set:size()
	local size = 0
	for _ in pairs(self.m_data) do
		size = size + 1
	end

	return size
end

function set:iter()
	return pairs(self.m_data)
end

function set:__pairs()
	return pairs(self.m_data)
end

-- This is probably bad. Set:Contains() should be the only source of truth.
-- function set:__index(key)
-- 	return set[key] or (self.m_data[key] == true)
-- end
return set
