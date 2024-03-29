local json = require "cjson"
local workspaces = require "kong.workspaces"
local tostring = tostring
local sandbox = require "kong.tools.sandbox".sandbox

local sandbox_opts = { env = { kong = kong, ngx = ngx } }

local plugin = {
  PRIORITY = 15, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1",
}

function plugin:access(plugin_conf)

  if plugin_conf.inspect then
    kong.log.inspect.on()
  else
    kong.log.inspect.off()
  end

  if plugin_conf.request_body or plugin_conf.response_body then
  -- enable buffering for body
    kong.service.request.enable_buffering()
  end

  if plugin_conf.request_body then
    local body = kong.request.get_raw_body()
    kong.log.inspect("request body", body)
    kong.log.set_serialize_value("request.body", body)
--    kong.log.set_serialize_value("request.mimetype", mimetype)
  end

  if plugin_conf.inspect then
    kong.log.inspect.off()
  end

end

function plugin:log(plugin_conf)

  if plugin_conf.inspect then
    kong.log.inspect.on()
  else
    kong.log.inspect.off()
  end

  if plugin_conf.add_fields then
    -- Adds a new value to the serialized table
    for k, v in pairs(plugin_conf.add_fields) do
      local name, value = v:match("^([^:]+):*(.-)$")
      kong.log.set_serialize_value(name, value)
    end
  end

  if plugin_conf.remove_fields then
    -- Remove configured fields from log message
    for k, v in pairs(plugin_conf.remove_fields) do
      kong.log.set_serialize_value(v, nil)
    end
  end

  if plugin_conf.mask_fields then
    -- Mask configured fields from log message
    for k, v in pairs(plugin_conf.mask_fields) do
      kong.log.set_serialize_value(v, "*****")
    end
  end

  -- Add response body
  if plugin_conf.response_body then
    -- Check for a proxy-cache body
    local body = nil
    if kong.ctx.shared.proxy_cache_hit and kong.ctx.shared.proxy_cache_hit.res ~= nil then
      body = kong.ctx.shared.proxy_cache_hit.res
    else
      body = kong.service.response.get_raw_body()
    end
    kong.log.inspect("response body", body)
    kong.log.set_serialize_value("response.body", body)
  end

  -- Add Kong node details
  if plugin_conf.node_details then
    kong.log.set_serialize_value("kong.node_id", kong.node.get_id())
    kong.log.set_serialize_value("kong.hostname", tostring(kong.node.get_hostname()))
  end

  -- Add Workspace name
  if plugin_conf.workspace_name then
    local ws_id = ngx.ctx.workspace
    local ws_name = workspaces.get_workspace()
    kong.log.set_serialize_value("workspace", { id = ws_id, name = ws_name.name})
  end

  -- Run any custom lua
  if plugin_conf.custom_fields_by_lua then
    for key, expression in pairs(plugin_conf.custom_fields_by_lua) do
      kong.log.set_serialize_value(key, sandbox(expression, sandbox_opts)())
    end
  end

  if plugin_conf.inspect then
    kong.log.inspect.off()
  end

end

return plugin
