---@diagnostic disable: unknown-operator

local vec2 = require("core.Vector2")
local vec3 = require("core.Vector3")

--------------------------------------
-- Class: vector4
--------------------------------------
-- A 4D vector utility class with arithmetic, geometric, and serialization helpers.
---@class vector4
---@field private assert function
---@field public x float
---@field public y float
---@field public z float
---@field public w float
---@operator add(vector4|float): vector4
---@operator sub(vector4|float): vector4
---@operator mul(vector4|float): vector4
---@operator div(vector4|float): vector4
---@operator unm: vector4
---@operator eq(vector4): boolean
---@operator le(vector4): boolean
---@operator lt(vector4): boolean
local vector4 = { __type = "vector4" }
vector4.__index = vector4


--------------------------------------
-- Constructors & Utils
--------------------------------------

-- Creates a new vec4 instance.
---@param x float?
---@param y float?
---@param z float?
---@param w float?
---@return vector4
function vector4:new(x, y, z, w)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 0,
	}, vector4)
end

-- Checks if the given argument is a valid vec4, raises on failure.
---@param arg any
---@return boolean
function vector4:assert(arg)
	if (
			(type(arg) == "table" or type(arg) == "userdata")
			and type(arg.x) == "number"
			and type(arg.y) == "number"
			and type(arg.z) == "number"
			and type(arg.w) == "number"
		) then
		return true
	else
		error(
			string.format("Invalid argument! Expected 4D vector, got %s instead", type(arg))
		)
	end
end

-- Returns a copy of this vector.
---@return vector4
function vector4:copy()
	return vector4:new(self.x, self.y, self.z, self.w)
end

-- Unpacks the components of the vector.
---@return float x, float y, float z, float w
function vector4:unpack()
	return self.x, self.y, self.z, self.w
end

-- Returns a zero vector (0, 0, 0, 0).
---@return vector4
function vector4:zero()
	return vector4:new(0, 0, 0, 0)
end

-- Returns true if all components are zero.
---@return boolean
function vector4:is_zero()
	return (self.x == 0) and (self.y == 0) and (self.z == 0) and (self.w == 0)
end

-- Returns the string representation of the vector
function vector4:__tostring()
	return string.format(
		"(%.3f, %.3f, %.3f, %.3f)",
		self.x,
		self.y,
		self.z,
		self.w
	)
end

--------------------------------------
-- Arithmetic Metamethods
--------------------------------------

-- Addition between vectors or vector + number.
---@param b float|vector4
---@return vector4
function vector4:__add(b)
	if type(b) == "number" then
		return vector4:new(self.x + b, self.y + b, self.z + b, self.w + b)
	end

	self:assert(b)
	return vector4:new(self.x + b.x, self.y + b.y, self.z + b.z, self.w + b.w)
end

-- Subtraction between vectors or vector - number.
---@param b float|vector4
---@return vector4
function vector4:__sub(b)
	if type(b) == "number" then
		return vector4:new(self.x - b, self.y - b, self.z - b, self.w - b)
	end

	self:assert(b)
	return vector4:new(self.x - b.x, self.y - b.y, self.z - b.z, self.w - b.w)
end

-- Multiplication between vectors or vector * number.
---@param b float|vector4
---@return vector4
function vector4:__mul(b)
	if type(b) == "number" then
		return vector4:new(self.x * b, self.y * b, self.z * b, self.w * b)
	end

	self:assert(b)
	return vector4:new(self.x * b.x, self.y * b.y, self.z * b.z, self.w * b.w)
end

-- Division between vectors or vector / number.
---@param b float|vector4
---@return vector4
function vector4:__div(b)
	if type(b) == "number" then
		return vector4:new(self.x / b, self.y / b, self.z / b, self.w / b)
	end

	self:assert(b)
	return vector4:new(self.x / b.x, self.y / b.y, self.z / b.z, self.w / b.w)
end

-- Equality check between two vectors.
---@param b vector4
---@return boolean
function vector4:__eq(b)
	self:assert(b)
	return self.x == b.x and self.y == b.y and self.z == b.z and self.w == b.w
end

-- Less-than check between two vectors.
---@param b vector4
---@return boolean
function vector4:__lt(b)
	self:assert(b)
	return self.x < b.x and self.y < b.y and self.z < b.z and self.w < b.w
end

-- Less-or-equal check between two vectors.
---@param b vector4
---@return boolean
function vector4:__le(b)
	self:assert(b)
	return self.x <= b.x and self.y <= b.y and self.z <= b.z and self.w <= b.w
end

-- Unary negation (returns the inverse vector).
---@return vector4
function vector4:__unm()
	return vector4:new(-self.x, -self.y, -self.z, -self.w)
end

--------------------------------------
-- Vector Operations
--------------------------------------

-- Returns the magnitude (length) of the vector.
---@return float
function vector4:length()
	return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2 + self.w ^ 2)
end

-- Returns the distance between this vector and another.
---@param b vector4
---@return float
function vector4:distance(b)
	self:assert(b)
	local dist_x = (self.x - b.x) ^ 2
	local dist_y = (self.y - b.y) ^ 2
	local dist_z = (self.z - b.z) ^ 2
	local dist_w = (self.w - b.w) ^ 2

	return math.sqrt(dist_x + dist_y + dist_z + dist_w)
end

-- Returns a normalized version of the vector.
---@return vector4
function vector4:normalize()
	local len = self:length()

	if len < 1e-8 then
		return vector4:zero()
	end

	return self / len
end

-- Cross product of this vector and another (XYZ components only).
---@param b vector4
---@return vector4
function vector4:cross_product_xyz(b)
	self:assert(b)

	return vector4:new(
		self.y * b.z - self.z * b.y,
		self.z * b.x - self.x * b.z,
		self.x * b.y - self.y * b.x
	)
end

-- Dot product of this vector and another.
---@param b vector4
---@return float
function vector4:dot_product(b)
	self:assert(b)
	return self.x * b.x + self.y * b.y + self.z * b.z + self.w * b.w
end

-- Linearly interpolates between this vector and another.
---@param to vector4
---@param dt float Interpolation factor *(progress/delta time/...)*
---@return vector4
function vector4:lerp(to, dt)
	return vector4:new(
		self.x + (to.x - self.x) * dt,
		self.y + (to.y - self.y) * dt,
		self.z + (to.z - self.z) * dt,
		self.w + (to.w - self.w) * dt
	)
end

-- Returns the inverse (negated) vector.
---@return vector4
function vector4:inverse()
	return vector4:__unm()
end

-- Trims the vector to a maximum length.
---@param atLength float
---@return vector4
function vector4:trim(atLength)
	local len = self:length()
	if len == 0 then
		return vector4:zero()
	end

	local s = atLength / len
	s = (s > 1) and 1 or s
	return self * s
end

--------------------------------------
-- Conversions
--------------------------------------

-- Returns the heading angle (XY plane).
---@return float
function vector4:heading()
	return math.atan(self.y, self.x)
end

-- Returns a new vec4 with the z component replaced.
---@param z float
---@return vector4
function vector4:with_z(z)
	return vector4:new(self.x, self.y, z, self.w)
end

-- Returns a new vec4 with the w component replaced.
---@param w float
---@return vector4
function vector4:with_w(w)
	return vector4:new(self.x, self.y, self.w, w)
end

-- Converts the vector into a plain table (for serialization).
---@return table
function vector4:serialize()
	return {
		__type = self.__type,
		x = self.x or 0,
		y = self.y or 0,
		z = self.z or 0,
		w = self.w or 0
	}
end

-- Deserializes a table into a vec4 **(static method)**.
---@param t { __type: string, x: float, y: float, z: float, w: float }
---@return vector4
function vector4.deserialize(t)
	if (type(t) ~= "table" or not (t.x and t.y and t.z and t.w)) then
		return vector4:zero()
	end

	return vector4:new(t.x, t.y, t.z, t.w)
end

--------------------------------------
-- Conversion Helpers (Optional)
--------------------------------------

---@return vector2
function vector4:as_vec2()
	return vec2:new(self.x, self.y)
end

function vector4:as_vec3()
	return vec3:new(self.x, self.y, self.z)
end

vector4.magnitude = vector4.length
vector4.mag       = vector4.length

return vector4
