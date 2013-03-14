package.path = package.path .. ';./redis-lua/src/?.lua'
local redis_lua = require 'redis'
local lsf = require 'lfs'
local inspect = require 'inspect'

function redis_debug(str, value)
    print(str .. inspect(value))
end

function redis_log(...)
    print(...)
end

-- Runscript
function runScript(args)
  assert(type(args)       == "table",  "Call runScript with a table like this: runScript {filename=\"/my/script.lua\", redis=redis, KEYS=KEYS}")
  assert(type(args.redis) == "table", "A instance of Redis() is required")

  -- quick&dirty find a way to provide keys & redis inside their own context
  redis = args.redis
  KEYS = args.KEYS or {}
  ARGV = args.ARGV or {}
  DEBUG = redis_debug
  local f = assert(loadfile(lfs.currentdir() .. "/" .. args.filename), "Couldn't load ".. lfs.currentdir() .. "/" .. args.filename)
  return f()
end

function createMock(ip, port)
    local client = redis_lua.connect(ip, port)
    local redisMock = {}
    redisMock.call = function(cmd, ...)
        cmd = cmd:lower()
        assert(client[cmd], 'wrong command '..cmd)
        return client[cmd](client, ...)
    end
    redisMock.pcall = redisMock.call
    redisMock.log = redis_log
    redisMock._client = client;
    return redisMock
end

return {
    runScript = runScript,
    createMock = createMock,
}
