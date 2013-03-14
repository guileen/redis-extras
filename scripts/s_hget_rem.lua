local inspect = require('inspect');
print(inspect(KEYS))
local skeyprefix, hkey, hfield, member = KEYS[1], KEYS[2], KEYS[3], KEYS[4]
print(skeyprefix);
print(hkey)
print('hfield'.. hfield)
local value = redis.call("HGET", hkey, hfield)
return value and redis.srem(skeyprefix .. value, member)

