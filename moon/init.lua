if not moon or not moon.inject then
  module("moon", package.seeall)
end
local util = require("moonscript.util")
dump = util.dump
run_with_scope = function(fn, scope, ...)
  local old_env = getfenv(fn)
  local env = setmetatable({ }, {
    __index = function(self, name)
      local val = scope[name]
      if val ~= nil then
        return val
      else
        return old_env[name]
      end
    end
  })
  setfenv(fn, env)
  return fn(...)
end
bind_methods = function(obj)
  return setmetatable({ }, {
    __index = function(self, name)
      local val = obj[name]
      if val and type(val) == "function" then
        local bound
        bound = function(...)
          return val(obj, ...)
        end
        self[name] = bound
        return bound
      else
        return val
      end
    end
  })
end
defaultbl = function(t, fn)
  if not fn then
    fn = t
    t = { }
  end
  return setmetatable(t, {
    __index = function(self, name)
      local val = fn(self, name)
      rawset(self, name, val)
      return val
    end
  })
end
extend = function(...)
  local tbls = {
    ...
  }
  if #tbls < 2 then
    return 
  end
  for i = 1, #tbls - 1 do
    local a = tbls[i]
    local b = tbls[i + 1]
    setmetatable(a, {
      __index = b
    })
  end
  return tbls[1]
end
copy = function(self)
  local t = { }
  for key, val in pairs(self) do
    t[key] = val
  end
  return t
end
mixin = function(self, cls, ...)
  local meta = getmetatable(cls)
  for key, val in pairs(meta.__index) do
    if not key:match("^__") then
      self[key] = val
    end
  end
  return cls.__init(self, ...)
end
mixin_object = function(self, object, methods)
  local _list_0 = methods
  for _index_0 = 1, #_list_0 do
    local name = _list_0[_index_0]
    self[name] = function(parent, ...)
      return object[name](object, ...)
    end
  end
end
mixin_table = function(self, tbl, keys)
  if keys then
    local _list_0 = keys
    for _index_0 = 1, #_list_0 do
      local key = _list_0[_index_0]
      self[key] = tbl[key]
    end
  else
    for key, val in pairs(tbl) do
      self[key] = val
    end
  end
end
