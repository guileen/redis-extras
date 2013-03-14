local redisMock = require('redis-mock')
local inspect = require('inspect')

local redis = redisMock.createMock('127.0.0.1', 6379)
local client = redis._client

-- runScript {filename='scripts/zremsadd.lua', redis=redis, KEYS={'a', '1', '2', 'd'}}
-- runScript {filename='scripts/s_hget_rem.lua', redis=redis, KEYS={'a', 'b', 'c', 'd'}}

-- redis.call('set', 'foo', 'bar')
-- print(redis.call('get', 'foo'))
-- redis.call('hset', 'foo', 'bar', 'v')
-- print(redis.call('hget', 'foo', 'bar'));

function run(scriptname, keys, argv)
    runScript {filename='scripts/' .. scriptname .. '.lua', redis = redis, KEYS = keys, ARGV = argv}
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

-- start test
client:zadd('foo', 1, 'a', 2, 'b', 3, 'c', 4, 'd')
run('zremsadd', {'foo', 2, 3, 'bar'})
local members = client:smembers('bar')

assert(table.contains(members, 'b') and table.contains(members, 'c'), 'should contains b, c')
