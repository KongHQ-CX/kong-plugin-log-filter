-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------


local plugin = {
  PRIORITY = 15, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1",
}

function plugin:rewrite(plugin_conf)

  if plugin_conf.request_body or plugin_conf.response_body then
  -- enable buffering for body
    kong.service.request.enable_buffering()
  end

  if plugin_conf.request_body then
    kong.log.debug("******* Adding request body ***********")
    local body, err, mimetype = kong.request.get_body()
    kong.log.set_serialize_value("request.body", "req. body")
  else
    kong.log.debug("******* NOT Adding request body ***********")
  end

end

function plugin:log(plugin_conf)

  -- Adds a new value to the serialized table
  for k, v in pairs(plugin_conf.add_fields) do
    kong.log.set_serialize_value(tostring(k), v)
  end

  -- Remove configured fields from log message
  for k, v in pairs(plugin_conf.remove_fields) do
    kong.log.set_serialize_value(v, nil)
  end

  -- Mask configured fields from log message
  for k, v in pairs(plugin_conf.mask_fields) do
    kong.log.set_serialize_value(v, "*****")
  end

  if plugin_conf.response_body then
    kong.log.debug("******* Adding response body ***********")
    --kong.log.set_serialize_value("response.body", kong.service.response.get_body())
    kong.log.set_serialize_value("response.body", "resp. body")
  else
    kong.log.debug("******* NOT Adding response body ***********")
  end

end

return plugin
