module vrpc

pub enum MessageFlag {
	json_add_whitespace
	json_use_enum_value
}

@[heap]
pub struct Message {
mut:
	protocol_type ProtocolType
	compress_type CompressType
	flags         MessageFlag
}

pub fn (mut m Message) set_protocol_type(protocol_type ProtocolType) {
	m.protocol_type = protocol_type
}

pub fn (m &Message) get_protocol_type() ProtocolType {
	return m.protocol_type
}

pub fn (mut m Message) set_compress_type(compress_type CompressType) {
	m.compress_type = compress_type
}

pub fn (m &Message) get_compress_type() CompressType {
	return m.compress_type
}

pub fn (m &Message) compress() {
}

pub fn (m &Message) decompress() {
}
