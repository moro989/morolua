---@diagnostic disable: unknown-operator

---@class float: number

--------------------------------------
-- Class: vector2
--------------------------------------
-- A 2D vector utility class with arithmetic and geometric helpers.
---@class vector2
---@field private assert function
---@field public x float
---@field public y float
---@operator add(vector2|float): vector2
---@operator sub(vector2|float): vector2
---@operator mul(vector2|float): vector2
---@operator div(vector2|float): vector2
---@operator unm: vector2
---@operator eq(vector2): boolean
---@operator le(vector2): boolean
---@operator lt(vector2): boolean
local vector2 = { __type = "vector2" }
vector2.__index = vector2

--------------------------------------
-- Constructors & Utils
--------------------------------------

-- Creates a new vec2 instance.
---@param x float
---@param y float
---@return vector2
function vector2:new(x, y)
	return setmetatable(
		{
			x = x or 0,
			y = y or 0
		},
		vector2
	)
end

-- Checks if the given argument is a valid vec2, raises on failure.
---@param arg any
---@return boolean
function vector2:assert(arg)
	if (type(arg) == "table" or type(arg) == "userdata") and type(arg.x) == "number" and type(arg.y) == "number" then
		return true
	else
		error(
			string.format("Invalid argument! Expected 2D vector, got %s instead", type(arg))
		)
	end
end

-- Returns a copy of this vector.
---@return vector2
function vector2:copy()
	return vector2:new(self.x, self.y)
end

-- Unpacks the components of the vector.
---@return float x, float y
function vector2:unpack()
	return self.x, self.y
end

-- Returns a zero vector (0, 0).
---@return vector2
function vector2:zero()
	return vector2:new(0, 0)
end

-- Returns true if all components are zero.
---@return boolean
function vector2:is_zero()
	return (self.x == 0) and (self.y == 0)
end

-- Returns the string representation of the vector
function vector2:__tostring()
	return string.format(
		"(%.3f, %.3f)",
		self.x,
		self.y
	)
end

--------------------------------------
-- Arithmetic Metamethods
--------------------------------------

-- Addition between vectors or vector + number.
---@param b float|vector2
---@return vector2
function vector2:__add(b)
	if type(b) == "number" then
		return vector2:new(self.x + b, self.y + b)
	end

	self:assert(b)
	return vector2:new(self.x + b.x, self.y + b.y)
end

-- Subtraction between vectors or vector - number.
---@param b float|vector2
---@return vector2
function vector2:__sub(b)
	if type(b) == "number" then
		return vector2:new(self.x - b, self.y - b)
	end

	self:assert(b)
	return vector2:new(self.x - b.x, self.y - b.y)
end

-- Multiplication between vectors or vector * number.
---@param b float|vector2
---@return vector2
function vector2:__mul(b)
	if type(b) == "number" then
		return vector2:new(self.x * b, self.y * b)
	end

	self:assert(b)
	return vector2:new(self.x * b.x, self.y * b.y)
end

-- Division between vectors or vector / number.
---@param b float|vector2
---@return vector2
function vector2:__div(b)
	if type(b) == "number" then
		return vector2:new(self.x / b, self.y / b)
	end

	self:assert(b)
	return vector2:new(self.x / b.x, self.y / b.y)
end

-- Equality check between two vectors.
---@param b float|vector2
---@return boolean
function vector2:__eq(b)
	self:assert(b)
	return self.x == b.x and self.y == b.y
end

-- Less-than check between two vectors.
---@param b float|vector2
---@return boolean
function vector2:__lt(b)
	self:assert(b)
	return self.x < b.x and self.y < b.y
end

-- Less-or-equal check between two vectors.
---@param b float|vector2
---@return boolean
function vector2:__le(b)
	self:assert(b)
	return self.x <= b.x and self.y <= b.y
end

-- Unary negation (returns the inverse vector).
---@return vector2
function vector2:__unm()
	return vector2:new(-self.x, -self.y)
end

--------------------------------------
-- Vector Operations
--------------------------------------

-- Returns the magnitude (length) of the vector.
---@return float
function vector2:length()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

-- Returns the distance between this vector and another.
---@param b vector2
---@return float
function vector2:distance(b)
	self:assert(b)

	local dist_x = (self.x - b.x) ^ 2
	local dist_y = (self.y - b.y) ^ 2

	return math.sqrt(dist_x + dist_y)
end

-- Returns a normalized version of the vector.
---@return vector2
function vector2:normalize()
	local len = self:length()

	if len < 1e-8 then
		return vector2:new(0, 0)
	end

	return self / len
end

-- Cross product of this vector and another.
---@return float
function vector2:cross_product(b)
	self:assert(b)
	return self.x * b.y - self.y * b.x
end

-- Dot product of this vector and another.
---@return float
function vector2:dot_product(b)
	self:assert(b)
	return self.x * b.x + self.y * b.y
end

-- Linearly interpolates between this vector and another.
---@param b vector2
---@param dt float Delta time
---@return vector2
function vector2:lerp(b, dt)
	return vector2:new(
		self.x + (b.x - self.x) * dt,
		self.y + (b.y - self.y) * dt
	)
end

-- Returns the inverse (negated) vector.
---@return vector2
function vector2:inverse()
	return self:__unm()
end

-- Returns a vec2 perpendicular to this.
---@return vector2
function vector2:perpendicular()
	return vector2:new(-self.y, self.x)
end

-- Returns the angle between the x and y components of the vector.
---@return float
function vector2:angle()
	return math.atan(self.y, self.x)
end

-- Rotates the vector.
---@param n float
---@return vector2
function vector2:rotate(n)
	local a, b = math.cos(n), math.sin(n)

	return vector2:new(
		a * self.x - b * self.y,
		b * self.x + a * self.y
	)
end

-- Trims the vector to a maximum length.
---@param atLength float
---@return vector2
function vector2:trim(atLength)
	local len = self:length()

	if (len == 0) then
		return vector2:zero()
	end

	local s = atLength / len

	s = (s > 1) and 1 or s
	return self * s
end

--------------------------------------
-- Conversions
--------------------------------------

-- Returns the angle and radius of the vector.
---@return float angle, float radius
function vector2:to_polar()
	return math.atan(self.y, self.x), self:length()
end

-- Creates a new vec2 from angle and radius.
---@param angle float
---@param radius? float
---@return vector2
function vector2:from_polar(angle, radius)
	radius = radius or 1
	return vector2:new(math.cos(angle) * radius, math.sin(angle) * radius)
end

-- Converts the vector into a plain table (for serialization).
---@return table
function vector2:serialize()
	return {
		__type = self.__type,
		x = self.x or 0,
		y = self.y or 0
	}
end

-- Deserializes a table into a vec3 **(static method)**.
---@param t { x: float, y: float }
function vector2.deserialize(t)
	if (type(t) ~= "table" or not (t.x and t.y)) then
		return vector2:zero()
	end

	return vector2:new(t.x, t.y)
end

--------------------------------------
-- Conversion Helpers (Optional)
--------------------------------------

vector2.magnitude = vector2.length
vector2.magn      = vector2.length

return vector2
