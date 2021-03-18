Kong log-filter plugin
======================

This repository contains a plugin to allow the *-log plugins content to be customised

| form parameter             | default             |example |  description              |
| ---                        | ---                 | ---    | ---                       |
| `config.add_fields`        | |`add:this,and:this-too`|The `name:value` pairs of fields to add to the log message|
| `config.mask_fields`        | |`client_ip,request.method`|The `name` of fields to mask in the log message|
| `config.remove_fields`        | |`latencies`|The `name` of fields to remove from in the log message|
| `config.request_body`        |false||Include the request body in the log message|
| `config.response_body`        |false||Include the response body in the log message|

Note, including the request/response body will increase memory requirements for Kong and also force request buffering to be enabled. You can review the standard log entries that can be altered [here](https://docs.konghq.com/gateway-oss/2.3.x/pdk/kong.log/#konglogserialize)

This plugin will alter the data for any plugin that uses the [log.serialize](https://docs.konghq.com/gateway-oss/2.3.x/pdk/kong.log/#konglogserialize) function. It does not provide logging to an endpoint and is purely used to change the content that will be sent via one of the standard logging plugins.
