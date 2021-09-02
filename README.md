Kong log-filter plugin
======================

:exclamation: :exclamation: :exclamation: This is an untested and unsupported plugin and should be used as a proof of concept only

This repository contains a plugin to allow the *-log plugins content to be customised. This plugin requires the PDK *kong.log.set_serialize_value* function which is available from Kong 2.3 and the *custom_fields_by_lua* typedefs which are available from Kong 2.4. As such, please ensure you are on at least Kong 2.4 or this plugin will not work.

| form parameter             | default             |example |  description              |
| ---                        | ---                 | ---    | ---                       |
| `config.add_fields`        | |`add:this,and:this-too`|The `name:value` pairs of fields to add to the log message|
| `config.mask_fields`       | |`client_ip,request.method`|The `name` of fields to mask in the log message|
| `config.remove_fields`     | |`latencies`|The `name` of fields to remove from in the log message|
| `config.request_body`      |false||Include the request body in the log message|
| `config.response_body`     |false||Include the response body in the log message|
| `config.workspace_name`    |false||Add the workspace name to the log message|
| `config.inspect`           |false||Add debug messages to the logs with request/response payloads|
| `config.custom_fields_by_lua`           | | |Add custom lua code to set a field value


Note, including the request/response body will increase memory requirements for Kong and also force request buffering to be enabled. You can review the standard log entries that can be altered [here](https://docs.konghq.com/gateway-oss/2.3.x/pdk/kong.log/#konglogserialize)

This plugin will alter the data for any plugin that uses the [log.serialize](https://docs.konghq.com/gateway-oss/2.3.x/pdk/kong.log/#konglogserialize) function. It does not provide logging to an endpoint and is purely used to change the content that will be sent via one of the standard logging plugins.

An example curl call to create the plugin with custom_fields_by_lua values;

```
curl -X POST 'https://api.kong.lan:8444/default/routes/{{route}}/plugins/' \
-H 'Content-Type: application/json' \
--data-raw '{
	"name": "log-filter",
	"config": {
		"request_body": false,
		"response_body": false,
		"remove_fields": null,
		"inspect": false,
		"mask_fields": null,
		"workspace_name": false,
		"node_details": false,
		"add_fields": null,
		"custom_fields_by_lua": {
			"pdk": "return kong.ip.is_trusted(kong.client.get_ip())",
			"latencies": "return nil",
			"abc": "return '\''abc'\''",
			"request.headers.apikey": "return '******'"
		}
	}
}'
```
