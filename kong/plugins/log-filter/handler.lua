local json = require "cjson"
local workspaces = require "kong.workspaces"
local tostring = tostring

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
    local body, err, mimetype = kong.request.get_body()
    local json_body = json.encode(body)
    kong.log.inspect("request body", json_body)
    kong.log.set_serialize_value("request.body", json_body)
    kong.log.set_serialize_value("request.mimetype", mimetype)
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

  -- Adds a new value to the serialized table
  for k, v in pairs(plugin_conf.add_fields) do
    local name, value = v:match("^([^:]+):*(.-)$")
    kong.log.set_serialize_value(name, value)
  end

  -- Remove configured fields from log message
  for k, v in pairs(plugin_conf.remove_fields) do
    kong.log.set_serialize_value(v, nil)
  end

  -- Mask configured fields from log message
  for k, v in pairs(plugin_conf.mask_fields) do
    kong.log.set_serialize_value(v, "*****")
  end

  -- Add response body
  if plugin_conf.response_body then
    local body = kong.service.response.get_body()
    local json_body = json.encode(body)
    kong.log.inspect("response body", json_body)
    kong.log.set_serialize_value("response.body", json_body)
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

  if plugin_conf.inspect then
    kong.log.inspect.off()
  end

end

return plugin
