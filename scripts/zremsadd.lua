-- keys: 4
local zkey, min, max, skey = KEYS[1], KEYS[2], KEYS[3], KEYS[4]
local members = redis.call("ZRANGEBYSCORE", zkey, min, max)
for i = 1, #members do
  redis.call("SADD", skey, members[i])
end
redis.call("ZREMRANGEBYSCORE", zkey, min, max)
