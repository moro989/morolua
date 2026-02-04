---@diagnostic disable: unknown-operator

local vec2 = require("core.vector2")

--------------------------------------
-- Class: vector3
--------------------------------------
-- A 3D vector utility class with arithmetic, geometric, and serialization helpers.
---@class vector3
---@field private assert function
---@field public x float
---@field public y float
---@field public z float
---@operator add(vector3|float): vector3
---@operator sub(vector3|float): vector3
---@operator mul(vector3|float): vector3
---@operator div(vector3|float): vector3
---@operator unm: vector3
---@operator eq(vector3): boolean
---@operator le(vector3): boolean
---@operator lt(vector3): boolean
local vector3 = { __type = "vector3" }
vector3.__index = vector3

--------------------------------------
-- Constructors & Utils
--------------------------------------
-- Creates a new vec3 instance.
---@param x float
---@param y float
---@param z float
---@return vector3
function vector3:new(x, y, z)
	return setmetatable(
		{
			x = x or 0,
			y = y or 0,
			z = z or 0,
		},
		vector3
	)
end

-- Checks if the given argument is a valid vec3, raises on failure.
---@param arg any
---@return boolean
function vector3:assert(arg)
	if (type(arg) == "table") or (type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" and type(arg.z) == "number" then
		return true
	else
		error(
			string.format("Invalid argument. Expected 3D vector, got %s instead", type(arg))
		)
	end
end

-- Returns a copy of this vector.
---@return vector3
function vector3:copy()
	return vector3:new(self.x, self.y, self.z)
end

-- Unpacks the components of the vector.
---@return float x, float y, float z
function vector3:unpack()
	return self.x, self.y, self.z
end

-- Returns a zero vector (0, 0, 0).
---@return vector3
function vector3:zero()
	return vector3:new(0, 0, 0)
end

-- Returns true if all components are zero.
---@return boolean
function vector3:is_zero()
	return (self.x == 0) and (self.y == 0) and (self.z == 0)
end

--------------------------------------
-- Arithmetic Metamethods
--------------------------------------

-- Addition between vectors or vector + number.
---@param b float|vector3
---@return vector3
function vector3:__add(b)
	if type(b) == "number" then
		return vector3:new(self.x + b, self.y + b, self.z + b)
	end

	self:assert(b)
	return vector3:new(self.x + b.x, self.y + b.y, self.z + b.z)
end

-- Subtraction between vectors or vector - number.
---@param b float|vector3
---@return vector3
function vector3:__sub(b)
	if type(b) == "number" then
		return vector3:new(self.x - b, self.y - b, self.z - b)
	end

	self:assert(b)
	return vector3:new(self.x - b.x, self.y - b.y, self.z - b.z)
end

-- Multiplication between vectors or vector * number.
---@param b float|vector3
---@return vector3
function vector3:__mul(b)
	if type(b) == "number" then
		return vector3:new(self.x * b, self.y * b, self.z * b)
	end

	self:assert(b)
	return vector3:new(self.x * b.x, self.y * b.y, self.z * b.z)
end

-- Division between vectors or vector / number.
---@param b float|vector3
---@return vector3
function vector3:__div(b)
	if type(b) == "number" then
		return vector3:new(self.x / b, self.y / b, self.z / b)
	end

	self:assert(b)
	return vector3:new(self.x / b.x, self.y / b.y, self.z / b.z)
end

-- Equality check between two vectors.
---@param b float|vector3
---@return boolean
function vector3:__eq(b)
	self:assert(b)
	return self.x == b.x and self.y == b.y and self.z == b.z
end

-- Less-than check between two vectors.
---@param b float|vector3
---@return boolean
function vector3:__lt(b)
	self:assert(b)
	return self.x < b.x and self.y < b.y and self.z < b.z
end

-- Less-or-equal check between two vectors.
---@param b float|vector3
---@return boolean
function vector3:__le(b)
	self:assert(b)
	return self.x <= b.x and self.y <= b.y and self.z <= b.z
end

-- Unary negation (returns the inverse vector).
---@return vector3
function vector3:__unm()
	return vector3:new(-self.x, -self.y, -self.z)
end

--------------------------------------
-- Vector Operations
--------------------------------------

-- Returns the magnitude (length) of the vector.
---@return float
function vector3:length()
	return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

-- Returns the distance between this vector and another.
---@param b vector3
---@return float
function vector3:distance(b)
	self:assert(b)
	local dist_x = (self.x - b.x) ^ 2
	local dist_y = (self.y - b.y) ^ 2
	local dist_z = (self.z - b.z) ^ 2

	return math.sqrt(dist_x + dist_y + dist_z)
end

-- Returns a normalized version of the vector.
---@return vector3
function vector3:normalize()
	local len = self:length()

	if len < 1e-8 then
		return vector3:zero()
	end

	return self / len
end

-- Cross product of this vector and another.
---@param b vector3
---@return vector3
function vector3:cross_product(b)
	self:assert(b)

	return vector3:new(
		self.y * b.z - self.z * b.y,
		self.z * b.x - self.x * b.z,
		self.x * b.y - self.y * b.x
	)
end

-- Dot product of this vector and another.
---@param b vector3
---@return float
function vector3:dot_product(b)
	self:assert(b)
	return self.x * b.x + self.y * b.y + self.z * b.z
end

-- Linearly interpolates between this vector and another.
---@param to vector3
---@param dt float Delta time
---@return vector3
function vector3:lerp(to, dt)
	return vector3:new(
		self.x + (to.x - self.x) * dt,
		self.y + (to.y - self.y) * dt,
		self.z + (to.z - self.z) * dt
	)
end

-- Returns the inverse (negated) vector.
---@param includeZ? boolean Whether to also negate the z component
---@return vector3
function vector3:inverse(includeZ)
	return vector3:new(-self.x, -self.y, includeZ and -self.z or self.z)
end

-- Trims the vector to a maximum length.
---@return vector3
function vector3:trim(atLength)
	local len = self:length()
	if len == 0 then
		return vector3:zero()
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
function vector3:heading()
	return math.atan(self.y, self.x)
end

-- Returns a new vec3 with the z component replaced.
---@param z float
---@return vector3
function vector3:with_z(z)
	return vector3:new(self.x, self.y, z)
end

-- Converts a rotation vector to direction
---@return vector3
function vector3:to_direction()
	local radians = self * (math.pi / 180)
	return vector3:new(
		-math.sin(radians.z) * math.abs(math.cos(radians.x)),
		math.cos(radians.z) * math.abs(math.cos(radians.x)),
		math.sin(radians.x)
	)
end

-- Converts the vector into a plain table (for serialization).
---@return table
function vector3:serialize()
	return {
		__type = self.__type,
		x = self.x or 0,
		y = self.y or 0,
		z = self.z or 0
	}
end

-- Deserializes a table into a vec3 **(static method)**.
---@param t { __type: string, x: float, y: float, z: float }
---@return vector3
function vector3.deserialize(t)
	if (type(t) ~= "table" or not (t.x and t.y and t.z)) then
		return vector3:zero()
	end

	return vector3:new(t.x, t.y, t.z)
end

--------------------------------------
-- Conversion Helpers (Optional)
--------------------------------------

---@return vector2
function vector3:as_vec2()
	return vec2:new(self.x, self.y)
end

vector3.magnitude = vector3.length
vector3.mag       = vector3.length

return vector3
