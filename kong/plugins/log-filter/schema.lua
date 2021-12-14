local typedefs = require "kong.db.schema.typedefs"
local pl_template = require "pl.template"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")



local function check_for_value(entry)
  local name, value = entry:match("^([^:]+):*(.-)$")
  if not name or not value or value == "" then
    return false, "key '" ..name.. "' has no value"
  end

  return true
end


local strings_array = {
  type = "array",
  default = {},
  elements = { type = "string" },
  }

local colon_strings_array = {
  type = "array",
  default = {},
  elements = { type = "string", custom_validator = check_for_value }
  }


local schema = {
  name = plugin_name,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer |
    { route = typedefs.no_route },  -- this plugin cannot be configured on a route          | Can only be globally configured
    { service = typedefs.no_service },  -- this plugin cannot be configured on a service    |
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { add_fields = { type = "array", elements = { type = "string", custom_validator = check_for_value } } },
          { mask_fields = { type = "array", elements = { type = "string" } } },
          { remove_fields = { type = "array", elements = { type = "string" } } },
	  { request_body = { type = "boolean", default = false } },
	  { response_body = { type = "boolean", default = false } },
	  { inspect = { type = "boolean", default = false } },
	  { node_details = { type = "boolean", default = false } },
	  { workspace_name = { type = "boolean", default = false } },
	  { custom_fields_by_lua = typedefs.lua_code }
        },
      },
    },
  },
}

return schema
