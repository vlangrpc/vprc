module vrpc

pub struct RequestMeta {
mut:
	service_name string @[required]
	method_name  string @[required]
	log_id       i64
	// correspond to x-request-id in http header
	request_id i64
	// client's timeout setting for current call
	timeout_ms i32
}

pub struct ResponseMeta {
mut:
	error_code i32
	error_text string
}

pub struct Meta {
mut:
	request_meta  RequestMeta
	response_meta ResponseMeta
	compress_type CompressType
	// Used by the client to associate a request with a response
	correlation_id  i64
	attachment_size u32
	// key value property map
	properties map[string]string
}
