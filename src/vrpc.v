module vrpc

@[heap]
pub struct VrpcRequest {
	Message
mut:
	// number of received bytes, include header, meta and data
	nr_received u64
	// vrpc header: "VRPC" + meta_len(4byte) + data_len(4byte) + reversed(4byte)
	header [vrpc_header_length]u8
	// meta length in bytes
	meta_len u32
	// data length in bytes
	data_len u32
	meta     Meta
	data     [vrpc_buffer_length]u8
}

fn (mut r VrpcRequest) process() {
	mut meta := Meta{
		request_meta: RequestMeta{
			service_name: 'service'
			method_name: 'method'
		}
	}
	r.parse_meta(mut meta)
}

fn (mut r VrpcRequest) parse_meta(mut meta Meta) {
}

pub fn (mut r VrpcRequest) set_service_name(service_name string) {
	r.meta.request_meta.service_name = service_name
}

pub fn (r &VrpcRequest) get_service_name() string {
	return r.meta.request_meta.service_name
}

pub fn (mut r VrpcRequest) set_method_name(method_name string) {
	r.meta.request_meta.method_name = method_name
}

pub fn (r &VrpcRequest) get_method_name() string {
	return r.meta.request_meta.method_name
}

pub fn (r &VrpcRequest) serialize_meta() ! {
}

pub fn (r &VrpcRequest) deserialize_meta() !Meta {
	return Meta{
		request_meta: RequestMeta{
			service_name: 'service'
			method_name: 'method'
		}
	}
}

@[heap]
pub struct VrpcResponse {
	Message
mut:
	// number of received bytes, include header, meta and data
	nr_received u64
	// vrpc header: "VRPC" + meta_len(4byte) + data_len(4byte) + reversed(4byte)
	header [vrpc_header_length]u8
	// meta length in bytes
	meta_len u32
	// data length in bytes
	data_len u32
	meta     Meta
	data     [vrpc_buffer_length]u8
}
