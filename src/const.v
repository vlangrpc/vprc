module vrpc

pub const vrpc_header_length = 16
// pub const vrpc_buffer_length = 65535
pub const vrpc_buffer_length = 128

pub enum ProtocolType {
	unknown = 0
	http    = 1
	vrpc    = 2
}

pub enum CompressType {
	@none  = 0
	gzip   = 1
	snappy = 2
	zlib   = 3
}

pub enum ConnectionType {
	// short connection, like HTTP/1.0
	short  = 0
	single = 1
	pooled = 2
}
