local mathx = {}

-- Round a number to nearest integer
function mathx.round(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

-- Clamp a number between min and max
function mathx.clamp(x, minVal, maxVal)
    if x < minVal then return minVal end
    if x > maxVal then return maxVal end
    return x
end

-- Linear interpolation between a and b
function mathx.lerp(a, b, t)
    return a + (b - a) * t
end

-- Check if a number is integer
function mathx.isInteger(x)
    return type(x) == "number" and x % 1 == 0
end

-- Factorial (n!)
function mathx.factorial(n)
    if n < 0 or n % 1 ~= 0 then
        error("factorial requires a non-negative integer")
    end
    local f = 1
    for i = 2, n do
        f = f * i
    end
    return f
end

-- Greatest common divisor
function mathx.gcd(a, b)
    while b ~= 0 do
        a, b = b, a % b
    end
    return math.abs(a)
end

-- Least common multiple
function mathx.lcm(a, b)
    if a == 0 or b == 0 then return 0 end
    return math.abs(a * b) / mathx.gcd(a, b)
end

-- Sign of a number (-1, 0, 1)
function mathx.sign(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
    else return 0
    end
end

-- Random float between min and max
function mathx.randomFloat(min, max)
    min = min or 0
    max = max or 1
    return min + math.random() * (max - min)
end

-- Round to certain number of decimals
function mathx.roundTo(x, decimals)
    local factor = 10 ^ (decimals or 0)
    return mathx.round(x * factor) / factor
end

function mathx.mapRange(x, inMin, inMax, outMin, outMax)
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function mathx.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function mathx.lerpAngle(a, b, t)
    local diff = (b - a + math.pi) % (2 * math.pi) - math.pi
    return a + diff * t
end

function mathx.smoothstep(a, b, t)
    t = mathx.clamp(t, 0, 1)
    t = t * t * (3 - 2 * t)
    return a + (b - a) * t
end

function mathx.approach(x, target, step)
    if x < target then
        return math.min(x + step, target)
    else
        return math.max(x - step, target)
    end
end


return mathx
