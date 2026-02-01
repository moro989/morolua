-- tests.lua - Comprehensive test suite for morolua library
local typex = require("core.typex")
local tablex = require("core.tablex")
local stringx = require("core.stringx")
local mathx = require("core.mathx")
local iterx = require("core.iterx")
local oopx = require("core.oopx")
local coroutinex = require("core.coroutinex")
local eventx = require("core.eventx")
local taskx = require("core.taskx")
local assertx = require("core.assertx")

-- Test utilities
local tests_passed = 0
local tests_failed = 0
local current_module = ""

local function start_module(name)
    current_module = name
    print("\n" .. string.rep("=", 50))
    print("Testing module: " .. name)
    print(string.rep("=", 50))
end

local function ok(name)
    print("[OK] " .. current_module .. "." .. name)
    tests_passed = tests_passed + 1
end

local function eq(a, b, name)
    if a ~= b then
        print("[FAIL] " .. current_module .. "." .. name .. ": Expected " .. tostring(a) .. " == " .. tostring(b))
        tests_failed = tests_failed + 1
        return false
    end
    ok(name)
    return true
end

local function truthy(v, name)
    if not v then
        print("[FAIL] " .. current_module .. "." .. name .. ": Expected truthy value")
        tests_failed = tests_failed + 1
        return false
    end
    ok(name)
    return true
end

local function falsy(v, name)
    if v then
        print("[FAIL] " .. current_module .. "." .. name .. ": Expected falsy value")
        tests_failed = tests_failed + 1
        return false
    end
    ok(name)
    return true
end

local function throws(func, name)
    local success, err = pcall(func)
    if success then
        print("[FAIL] " .. current_module .. "." .. name .. ": Expected error but none was thrown")
        tests_failed = tests_failed + 1
        return false
    end
    ok(name)
    return true
end

local function approx_eq(a, b, name, epsilon)
    epsilon = epsilon or 0.0001

    if math.abs(a - b) > epsilon then
        print(
            "[FAIL] " .. current_module .. "." .. name ..
            ": Expected " .. tostring(a) ..
            " ≈ " .. tostring(b) ..
            " (within " .. epsilon .. ")"
        )
        tests_failed = tests_failed + 1
        return false
    end

    ok(name)
    return true
end


-- Test suite runner
local function run_tests()
    -- Test typex module
    start_module("typex")
    
    -- Test isNumber
    truthy(typex.isNumber(42), "isNumber(42)")
    truthy(typex.isNumber(3.14), "isNumber(3.14)")
    truthy(typex.isNumber(0), "isNumber(0)")
    falsy(typex.isNumber("42"), "isNumber('42')")
    falsy(typex.isNumber({}), "isNumber({})")
    falsy(typex.isNumber(nil), "isNumber(nil)")
    
    -- Test isString
    truthy(typex.isString("hello"), "isString('hello')")
    truthy(typex.isString(""), "isString('')")
    falsy(typex.isString(42), "isString(42)")
    
    -- Test isTable
    truthy(typex.isTable({}), "isTable({})")
    truthy(typex.isTable({1,2,3}), "isTable({1,2,3})")
    falsy(typex.isTable("table"), "isTable('table')")
    
    -- Test isNil
    truthy(typex.isNil(nil), "isNil(nil)")
    falsy(typex.isNil(false), "isNil(false)")
    falsy(typex.isNil(0), "isNil(0)")
    
    -- Test isCallable
    truthy(typex.isCallable(function() end), "isCallable(function)")
    falsy(typex.isCallable("not a function"), "isCallable('string')")
    
    -- Test isCallable with metatable __call
    local callable_table = setmetatable({}, {__call = function() end})
    truthy(typex.isCallable(callable_table), "isCallable(table with __call)")
    
    -- Test isThread
    local co = coroutine.create(function() end)
    truthy(typex.isThread(co), "isThread(coroutine)")
    falsy(typex.isThread({}), "isThread(table)")
    
    -- Test isType
    truthy(typex.isType(42, "number"), "isType(42, 'number')")
    falsy(typex.isType(42, "string"), "isType(42, 'string')")
    
    -- Test assertType
    local success = pcall(typex.assertType, 42, "number")
    truthy(success, "assertType(42, 'number') - should succeed")
    
    throws(function()
        typex.assertType(42, "string")
    end, "assertType(42, 'string') - should throw")
    
    -- Test isSameType
    truthy(typex.isSameType(1, 2, 3), "isSameType(1, 2, 3)")
    falsy(typex.isSameType(1, "2", 3), "isSameType(1, '2', 3)")
    truthy(typex.isSameType("a", "b", "c"), "isSameType('a', 'b', 'c')")
    
    throws(function()
        typex.isSameType(1)
    end, "isSameType with single arg - should throw")
    
    -- Test tablex module
    start_module("tablex")
    
    -- Test clear
    local t1 = {a = 1, b = 2, c = 3}
    tablex.clear(t1)
    eq(next(t1), nil, "clear() removes all elements")
    
    -- Test isArray
    truthy(tablex.isArray({1, 2, 3}), "isArray({1,2,3})")
    truthy(tablex.isArray({}), "isArray({})")
    falsy(tablex.isArray({a = 1, b = 2}), "isArray({a=1,b=2})")
    falsy(tablex.isArray({1, 2, nil, 4}), "isArray({1,2,nil,4})")
    falsy(tablex.isArray("not a table"), "isArray('string')")
    
    -- Test contains
    local t2 = {1, 2, 3, "hello", key = "value"}
    truthy(tablex.contains(t2, 2), "contains(t, 2)")
    truthy(tablex.contains(t2, "hello"), "contains(t, 'hello')")
    truthy(tablex.contains(t2, "value"), "contains(t, 'value')")
    falsy(tablex.contains(t2, 99), "contains(t, 99)")
    
    -- Test keys
    local t3 = {a = 1, b = 2, c = 3}
    local keys = tablex.keys(t3)
    table.sort(keys)
    eq(#keys, 3, "keys() returns correct count")
    truthy(tablex.contains(keys, "a"), "keys contains 'a'")
    truthy(tablex.contains(keys, "b"), "keys contains 'b'")
    truthy(tablex.contains(keys, "c"), "keys contains 'c'")
    
    -- Test values
    local values = tablex.values(t3)
    eq(#values, 3, "values() returns correct count")
    truthy(tablex.contains(values, 1), "values contains 1")
    truthy(tablex.contains(values, 2), "values contains 2")
    truthy(tablex.contains(values, 3), "values contains 3")
    
    -- Test indexOf
    local array = {10, 20, 30, 20}
    eq(tablex.indexOf(array, 20), 2, "indexOf finds first occurrence")
    eq(tablex.indexOf(array, 10), 1, "indexOf finds element")
    eq(tablex.indexOf(array, 99), nil, "indexOf returns nil for missing")
    
    throws(function()
        tablex.indexOf({a=1,b=2}, 1)
    end, "indexOf on non-array throws")
    
    -- Test copy
    local original = {a=1, b={c=2}}
    local copy = tablex.shallowCopy(original)
    eq(copy.a, 1, "copy preserves values")
    original.a = 99
    eq(copy.a, 1, "copy is shallow")
    
    -- Test merge
    local t4 = {a=1, b=2}
    local t5 = {b=99, c=3}
    local merged = tablex.merge(t4, t5)
    eq(merged.a, 1, "merge preserves first table values")
    eq(merged.b, 99, "merge overwrites with second table")
    eq(merged.c, 3, "merge adds new keys")
    
    -- Test circularIndex
    local circular = {1, 2, 3, 4, 5}
    eq(tablex.circularIndex(circular, 1), 1, "circularIndex 1 -> 1")
    eq(tablex.circularIndex(circular, 3), 3, "circularIndex 3 -> 3")
    eq(tablex.circularIndex(circular, 5), 5, "circularIndex 5 -> 5")
    eq(tablex.circularIndex(circular, 6), 1, "circularIndex 6 -> 1")
    eq(tablex.circularIndex(circular, 7), 2, "circularIndex 7 -> 2")
    eq(tablex.circularIndex(circular, 0), 5, "circularIndex 0 -> 5")
    eq(tablex.circularIndex(circular, -1), 4, "circularIndex -1 -> 4")
    
    -- Test iterx module
    start_module("iterx")
    
    -- Test each
    local each_arr = {1, 2, 3}
    local each_result = {}
    for val in iterx.each(each_arr) do
        table.insert(each_result, val)
    end
    eq(#each_result, 3, "each iterates all elements")
    eq(each_result[1], 1, "each gets correct first value")
    
    -- Test map
    local map_gen = iterx.map({1,2,3}, function(x) return x * 2 end)
    local map_result = {}
    for val in map_gen do
        table.insert(map_result, val)
    end
    eq(table.concat(map_result, ","), "2,4,6", "map transforms correctly")
    
    -- Test filter
    local filter_gen = iterx.filter({1,2,3,4,5}, function(x) return x % 2 == 0 end)
    local filter_result = {}
    for val in filter_gen do
        table.insert(filter_result, val)
    end
    eq(table.concat(filter_result, ","), "2,4", "filter works correctly")
    
    -- Test take
    local range_gen = iterx.range(1, 10)
    local take_result = {}
    for val in iterx.take(range_gen, 3) do
        table.insert(take_result, val)
    end
    eq(#take_result, 3, "take takes correct number")
    eq(table.concat(take_result, ","), "1,2,3", "take gets correct values")
    
    -- Test toTable
    local range = iterx.range(1, 5)
    local table_result = iterx.toTable(range)
    eq(#table_result, 5, "toTable converts all elements")
    eq(table.concat(table_result, ","), "1,2,3,4,5", "toTable preserves order")
    
    -- Test range
    local range1 = iterx.range(1, 5)
    local range1_result = iterx.toTable(range1)
    eq(table.concat(range1_result, ","), "1,2,3,4,5", "range 1 to 5")
    
    local range2 = iterx.range(5, 1, -1)
    local range2_result = iterx.toTable(range2)
    eq(table.concat(range2_result, ","), "5,4,3,2,1", "range 5 to 1 step -1")
    
    local range3 = iterx.range(0, 10, 2)
    local range3_result = iterx.toTable(range3)
    eq(table.concat(range3_result, ","), "0,2,4,6,8,10", "range step 2")
    
    -- Test mathx module
    start_module("mathx")
    
    -- Test round
    eq(mathx.round(3.4), 3, "round(3.4)")
    eq(mathx.round(3.6), 4, "round(3.6)")
    eq(mathx.round(-3.4), -3, "round(-3.4)")
    eq(mathx.round(-3.6), -4, "round(-3.6)")
    
    -- Test clamp
    eq(mathx.clamp(5, 1, 10), 5, "clamp within range")
    eq(mathx.clamp(0, 1, 10), 1, "clamp below range")
    eq(mathx.clamp(15, 1, 10), 10, "clamp above range")
    
    -- Test lerp
    approx_eq(mathx.lerp(0, 10, 0.5), 5, "lerp middle")
    approx_eq(mathx.lerp(0, 10, 0), 0, "lerp start")
    approx_eq(mathx.lerp(0, 10, 1), 10, "lerp end")
    
    -- Test isInteger
    truthy(mathx.isInteger(42), "isInteger(42)")
    truthy(mathx.isInteger(0), "isInteger(0)")
    truthy(mathx.isInteger(-7), "isInteger(-7)")
    falsy(mathx.isInteger(3.14), "isInteger(3.14)")
    falsy(mathx.isInteger("42"), "isInteger('42')")
    
    -- Test factorial
    eq(mathx.factorial(0), 1, "factorial(0)")
    eq(mathx.factorial(1), 1, "factorial(1)")
    eq(mathx.factorial(5), 120, "factorial(5)")
    
    throws(function()
        mathx.factorial(-1)
    end, "factorial(-1) throws")
    
    throws(function()
        mathx.factorial(3.14)
    end, "factorial(3.14) throws")
    
    -- Test gcd
    eq(mathx.gcd(48, 18), 6, "gcd(48, 18)")
    eq(mathx.gcd(17, 5), 1, "gcd(17, 5)")
    eq(mathx.gcd(0, 5), 5, "gcd(0, 5)")
    eq(mathx.gcd(5, 0), 5, "gcd(5, 0)")
    eq(mathx.gcd(-48, 18), 6, "gcd(-48, 18)")
    
    -- Test lcm
    eq(mathx.lcm(4, 6), 12, "lcm(4, 6)")
    eq(mathx.lcm(21, 6), 42, "lcm(21, 6)")
    eq(mathx.lcm(0, 5), 0, "lcm(0, 5)")
    
    -- Test sign
    eq(mathx.sign(10), 1, "sign(10)")
    eq(mathx.sign(-5), -1, "sign(-5)")
    eq(mathx.sign(0), 0, "sign(0)")
    
    -- Test randomFloat (statistical test - just verify it's in range)
    local r = mathx.randomFloat(10, 20)
    truthy(r >= 10 and r <= 20, "randomFloat in range")
    
    -- Test roundTo
    approx_eq(mathx.roundTo(3.14159, 2), 3.14, "roundTo 2 decimals")
    approx_eq(mathx.roundTo(3.14159, 3), 3.142, "roundTo 3 decimals")
    eq(mathx.roundTo(3.14159), 3, "roundTo 0 decimals")
    
    start_module("eventx")

-- Setup

local bus = eventx.new() -- IMPORTANT: instance

local event_log = {}

local function log_event(name)
    return function(...)
        table.insert(event_log, {
            name = name,
            args = { ... }
        })
    end
end

    -- Test on and emit
    local handler1 = log_event("test1")
    bus:on("test", handler1)
    bus:emit("test", "arg1", "arg2")

    eq(#event_log, 1, "event fired once")
    eq(event_log[1].name, "test1", "correct handler called")
    eq(event_log[1].args[1], "arg1", "correct arg1")
    eq(event_log[1].args[2], "arg2", "correct arg2")

    -- Test multiple handlers
    local handler2 = log_event("test2")
    bus:on("test", handler2)
    bus:emit("test", "arg3")

    eq(#event_log, 3, "both handlers called")

    -- Test off
    bus:off("test", handler1)
    event_log = {}

    bus:emit("test", "after_off")

    eq(#event_log, 1, "only one handler after off")
    eq(event_log[1].name, "test2", "correct handler remains")

    -- Test once
    event_log = {}

    bus:once("once_event", log_event("once"))
    bus:emit("once_event")
    bus:emit("once_event")

    eq(#event_log, 1, "once handler called only once")

    -- Test clear (single event)
    bus:on("clear_test", function() end)
    bus:clear("clear_test")
    bus:emit("clear_test") -- should do nothing, no error

    -- Test clear all
    bus:on("a", function() end)
    bus:on("b", function() end)
    bus:clear()

    bus:emit("a")
    bus:emit("b") -- no errors = pass
    
    -- Test taskx module
    start_module("taskx")
    
    local task_log = {}
    
    -- Test spawn and update
    local function test_task()
        table.insert(task_log, "start")
        taskx.sleep(0.1)
        table.insert(task_log, "middle")
        taskx.sleep(0.1)
        table.insert(task_log, "end")
    end
    
    local task = taskx.spawn(test_task)
    truthy(task, "task spawned")
    
    -- Update with small dt to progress task
    for i = 1, 5 do
        taskx.update(0.05)
    end
    
    eq(#task_log, 3, "task executed all steps")
    eq(task_log[1], "start", "task started")
    eq(task_log[2], "middle", "task continued")
    eq(task_log[3], "end", "task ended")
    
    -- Test cancel
    task_log = {}
    local task2 = taskx.spawn(function()
        table.insert(task_log, "running")
        taskx.sleep(1)
        table.insert(task_log, "should not reach")
    end)
    
    taskx.update(0.1)
    truthy(taskx.cancel(task2), "cancel returns true when task exists")
    taskx.update(0.1)
    eq(#task_log, 1, "cancelled task didn't continue")
    falsy(taskx.cancel(task2), "cancel returns false for non-existent task")
    
    -- Test oopx module
    start_module("oopx")
    
    -- Test class inheritance
    local Animal = oopx.class()
    
    function Animal:init(name)
        self.name = name
    end
    
    function Animal:speak()
        return "I am " .. self.name
    end
    
    local Dog = oopx.class(Animal)
    
    function Dog:init(name, breed)
        Animal.init(self, name)
        self.breed = breed
    end
    
    function Dog:bark()
        return "Woof! I'm a " .. self.breed
    end
    
    local myDog = Dog:new("Rex", "Golden Retriever")
    
    truthy(oopx.isInstance(myDog, Dog), "isInstance - Dog instance")
    truthy(oopx.isInstance(myDog, Animal), "isInstance - also Animal instance")
    falsy(oopx.isInstance({}, Dog), "isInstance - plain table not instance")
    
    eq(myDog:speak(), "I am Rex", "inherited method works")
    eq(myDog:bark(), "Woof! I'm a Golden Retriever", "child method works")
    
    -- Test mixin
    local Walker = {
        walk = function(self)
            return self.name .. " is walking"
        end
    }
    
    oopx.mixin(Dog, Walker)
    local dog2 = Dog:new("Buddy", "Labrador")
    eq(dog2:walk(), "Buddy is walking", "mixin method works")
    
    -- Test interface
    local Speaker = oopx.interface({
        speak = true,
        getName = true
    })
    
    local Person = oopx.class()
    function Person:init(name)
        self.name = name
    end
    
    function Person:speak()
        return "Hello, I'm " .. self.name
    end
    
    function Person:getName()
        return self.name
    end
    
    -- This should succeed
    oopx.implements(Person, Speaker)
    
    -- Test trait
    local HasID = oopx.trait({
        id = 0,
        setId = function(self, id)
            self.id = id
        end,
        getId = function(self)
            return self.id
        end
    })
    
    local Product = oopx.class()
    oopx.use(Product, HasID)
    
    function Product:init(name)
        self.name = name
    end
    
    local prod = Product:new("Widget")
    prod:setId(123)
    eq(prod:getId(), 123, "trait method works")
    
    -- Test abstract method
    local AbstractClass = oopx.class()
    AbstractClass.abstractMethod = oopx.abstract("abstractMethod")
    
    throws(function()
        local obj = AbstractClass:new()
        obj:abstractMethod()
    end, "abstract method throws")
    
    -- Test final method (commented out as it requires overriding)
    -- local Base = oopx.class()
    -- function Base:finalMethod()
    --     return "base"
    -- end
    -- oopx.final(Base, "finalMethod")
    
    -- stringx module tests
    start_module("stringx")
    
    -- Test isEmpty
    truthy(stringx.isEmpty(""), "isEmpty('')")
    truthy(stringx.isEmpty(nil), "isEmpty(nil)")
    falsy(stringx.isEmpty("hello"), "isEmpty('hello')")
    
    -- Test startsWith
    truthy(stringx.startsWith("hello world", "hello"), "startsWith('hello')")
    falsy(stringx.startsWith("hello world", "world"), "startsWith('world')")
    falsy(stringx.startsWith(nil, "test"), "startsWith(nil, 'test')")
    
    -- Test endsWith
    truthy(stringx.endsWith("hello world", "world"), "endsWith('world')")
    falsy(stringx.endsWith("hello world", "hello"), "endsWith('hello')")
    
    -- Test trim
    eq(stringx.trim("  hello  "), "hello", "trim spaces")
    eq(stringx.trim("\thello\t"), "hello", "trim tabs")
    eq(stringx.trim("  hello world  "), "hello world", "trim middle preserved")
    eq(stringx.trim(nil), "", "trim nil returns empty")
    
    -- Test split
    local split_result = stringx.split("a,b,c", ",")
    eq(#split_result, 3, "split returns 3 parts")
    eq(split_result[1], "a", "split part 1")
    eq(split_result[2], "b", "split part 2")
    eq(split_result[3], "c", "split part 3")
    
    local words = stringx.split("hello world from lua", " ")
    eq(#words, 4, "split by space")
    
    -- Test repeatString
    eq(stringx.repeatString("a", 3), "aaa", "repeatString 3 times")
    eq(stringx.repeatString("ab", 2), "abab", "repeatString pattern")
    eq(stringx.repeatString("test", 0), "", "repeatString 0 times")
    eq(stringx.repeatString(nil, 3), "", "repeatString nil")
    
    -- Test buffer
    local buf = stringx.buffer()
    buf:push("Hello")
    buf:push(" ")
    buf:push("World")
    eq(buf:concat(), "Hello World", "buffer concatenation")
    
    buf:clear()
    buf:push("a")
    buf:push("b")
    buf:push("c")
    eq(buf:concat("-"), "a-b-c", "buffer with separator")
    
    -- Test progressiveString
    local prog = stringx.progressiveString("abc")
    eq(prog:update(), "a", "progressiveString first update")
    eq(prog:update(), "ab", "progressiveString second update")
    eq(prog:update(), "abc", "progressiveString third update")
    eq(prog:update(), "abc", "progressiveString no more chars")
    eq(prog:isDone(), true, "progressiveString isDone")
    
    prog:reset()
    eq(prog:get(), "", "progressiveString reset")
    eq(prog:isDone(), false, "progressiveString not done after reset")
    
    -- Test coroutinex module
    start_module("coroutinex")
    
    -- Test run
    local co_run = coroutinex.run(function()
        return "test"
    end)
    truthy(type(co_run) == "thread", "coroutinex.run returns thread")
    
    -- Test wrap
    local wrapped = coroutinex.wrap(function(x)
        coroutine.yield(x * 2)
        return x * 3
    end)
    
    local ok1, result1 = wrapped(5)
    truthy(ok1, "wrapped coroutine first resume")
    eq(result1, 10, "wrapped coroutine first yield")
    
    local ok2, result2 = wrapped()
    truthy(ok2, "wrapped coroutine second resume")
    eq(result2, 15, "wrapped coroutine return")
    
    -- Test status
    local co = coroutine.create(function() end)
    eq(coroutinex.status(co), "suspended", "coroutinex.status suspended")
    
    coroutine.resume(co)
    eq(coroutinex.status(co), "dead", "coroutinex.status dead")
    eq(coroutinex.status("not a thread"), "invalid", "coroutinex.status invalid")
    
    -- Test sleep (requires coroutine environment)
    local sleep_co = coroutine.create(function()
        -- Note: sleep uses coroutine.yield internally, 
        -- so we can't test it directly without a scheduler
        return "sleep requires task-like environment"
    end)
    
    -- Summary
    print("\n" .. string.rep("=", 50))
    print("TEST SUMMARY")
    print(string.rep("=", 50))
    print("Tests passed: " .. tests_passed)
    print("Tests failed: " .. tests_failed)
    
    if tests_failed == 0 then
        print("✓ All tests passed!")
    else
        print("✗ Some tests failed")
        os.exit(1)
    end
end

-- Run all tests
run_tests()
-- should pass
assertx.type(5, "number")
assertx.oneOf("easy", {"easy", "hard"})

-- should fail (wrap in pcall)
local ok = pcall(function()
    assertx.range(20, 0, 10, "volume")
end)
assert(ok == false)
--assert stuff above didnt error so i think good to go