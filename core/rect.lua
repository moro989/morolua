local vec2 = require("core.vector2")

--------------------------------------
-- Class: rect
--------------------------------------
-- Class representing a rectangle utility
---@class rect
---@field min vector2
---@field max vector2
---@overload fun(min: vector2, max: vector2) : rect
local rect = { __type = "rect" }
rect.__index = rect
---@diagnostic disable-next-line
setmetatable(rect, {
	__call = function(_, ...)
		return rect.new(...)
	end
})

---@param min vector2
---@param max vector2
---@return rect
function rect.new(min, max)
	---@diagnostic disable-next-line
	return setmetatable({ min = min, max = max }, rect)
end

---@return number
function rect:get_width()
	return self.max.x - self.min.x
end

---@return number
function rect:get_height()
	return self.max.y - self.min.y
end

---@return vector2
function rect:get_size()
	return vec2:new(
		self.max.x - self.min.x,
		self.max.y - self.min.y
	)
end

---@return number
function rect:get_area()
	return (self.max.x - self.min.x) * (self.max.y - self.min.y)
end

---@return vector2
function rect:get_center()
	return vec2:new(
		(self.min.x + self.max.x) * 0.5,
		(self.min.y + self.max.y) * 0.5
	)
end

---@param point vector2
---@return boolean
function rect:contains(point)
	return
		point.x >= self.min.x and
		point.x <= self.max.x and
		point.y >= self.min.y and
		point.y <= self.max.y
end

---@param point vector2
---@return rect
function rect:add_point(point)
	local min = vec2:new(math.min(self.min.x, point.x), math.min(self.min.y, point.y))
	local max = vec2:new(math.max(self.max.x, point.x), math.max(self.max.y, point.y))
	return rect(min, max)
end

---@param other_rect rect
---@return rect
function rect:add(other_rect)
	local min = vec2:new(math.min(self.min.x, other_rect.min.x), math.min(self.min.y, other_rect.min.y))
	local max = vec2:new(math.max(self.max.x, other_rect.max.x), math.max(self.max.y, other_rect.max.y))
	return rect(min, max)
end

---@param other rect
---@return rect
function rect:__add(other)
	return self:add(other)
end

return rect
