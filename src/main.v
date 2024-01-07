module main

import vrpc { Client, ClientOptions, Context, Meta, RequestMeta, VrpcRequest, Response }

fn main() {
	options := ClientOptions{
		protocol_type: .vrpc
		connection_type: .short
	}
	mut client := Client{
		options: options
	}
	client.init('list://127.0.0.1:10000', .rr)!

	for {
		request := VrpcRequest{
			meta: Meta{
				request_meta: RequestMeta{
					service_name: 'service'
					method_name: 'method'
				}
			}
		}
		context := Context{}
		ch := chan Response{}
		client.call_method(context, request, ch)
		println('start ${request}')
		break
	}
}
