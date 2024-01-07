module vrpc

import strings { Builder }

pub type ParseResult = int
pub type ParseMessage = fn (mut sb Builder, read_eof bool) !ParseResult

pub type SerializeRequest = fn (mut sb_out Builder, request Request, context Context)

pub type PackRequest = fn (mut sb_out Builder, mut user_msg_out Builder, sb_req Builder, correlation_id i64, context Context)

pub type ProcessRequest = fn (request Request)

pub type ProcessResponse = fn (response Response)

pub type Verify = fn (request Request) bool

pub type GetMethodName = fn () string

pub type Method = fn (request Request, response Response, context Context) !

@[heap]
pub struct Protocol {
	// Name of this protocol
	name string
	// [Client & Server side]
	// parse_message cuts a message from `sb`, the message will be passed to
	// process_request() and process_response().
	//
	// Errors:
	//   error(PARSE_ERROR_NOT_ENOUGH_DATA):
	//	 `sb` does not form a complete message yet.
	//   error(PARSE_ERROR_TRY_OTHERS).
	//	 `sb` does not fit the protocol, the data should be tried by
	//	 other protocols. If the data is definitely corrupted (e.g. magic
	//	 header matches but other fields are wrong), pop corrupted part
	//	 from `sb' before returning.
	parse_message ?ParseMessage
	// [Client side]
	// serialize_request serializes `req` into `sb_out` which later will be
	// passed to pack_request().
	// `ctx` provides the additional data needed by some protocol (e.g. HTTP).
	// It will call ctx->set_failed() on error.
	serialize_request ?SerializeRequest
	// pack_request packs `sb_req` into `sb_out' or `user_msg_out'
	// It will be called before sending each request (including retries).
	// It will call ctx->set_failed() on error.
	pack_request ?PackRequest
	// process_response handles response `msg` created by a successful parse().
	// May be called in a different thread from parse().
	process_response ?ProcessResponse
	// [Server side]
	// process_request handles request `msg` created by a successful parse().
	// May be called in a different thread from parse().
	process_request ?ProcessRequest
	// verify verifies authentication of this socket. Only called
	// on the first message that a socket receives. Can be NULL when
	// authentication is not needed or this is the client side.
	// Returns true on successful authentication.
	verify ?Verify
mut:
	protocols map[ProtocolType]Protocol
}

// add_protocol register a protocol.
pub fn (mut p Protocol) add_protocol(protocol_type ProtocolType, protocol Protocol) ! {
	if protocol_type !in p.protocols {
		p.protocols[protocol_type] = protocol
	}
	return error('protocol already registered: ${protocol_type}')
}

// get_protocol gets a registered protocol by type.
pub fn (p &Protocol) get_protocol(protocol_type ProtocolType) ?Protocol {
	return p.protocols[protocol_type] or { return none }
}

// list_protocols list all registered protocol.
pub fn (p &Protocol) list_protocols() []Protocol {
	return p.protocols.values()
}

// support_client returns True if this protocol is supported at client-side.
pub fn (p &Protocol) support_client() bool {
	return p.serialize_request != none && p.pack_request != none && p.process_response != none
}

// support_server returns True if this protocol is supported at server-side.
pub fn (p &Protocol) support_server() bool {
	return p.process_request != none
}

pub interface Request {
	get_service_name() string
	get_method_name() string
mut:
	set_service_name(service_name string)
	set_method_name(method_name string)
	serialize_meta() !
	deserialize_meta() !Meta
}

pub interface Response {
	get_error_code() ErrorCode
	get_error_text() string
mut:
	set_error_code(error_code ErrorCode)
	set_error_text(error_text string)
}
