module vrpc

import rand
import time

@[heap]
pub struct Context {
mut:
	log_id                ?i64
	request_code          ?i64
	timeout               ?time.Duration
	connection_type       ConnectionType
	request_compress_type CompressType
	request_sent_time     ?time.Time
	backup_request_delay  ?time.Duration
	sent_backup_request   bool
	max_retry             ?i32
	retried_count         u32
	error_text            ?string
}

pub fn (c &Context) success() bool {
	return c.error_text == none
}

// set_timeout set timeout for the RPC call. Default to
// ClientOptions.timeout on unset.
pub fn (mut c Context) set_timeout(timeout ?time.Duration) {
	c.timeout = timeout
}

// get_timeout get timeout for the RPC call. Default to
// ClientOptions.timeout on unset.
pub fn (c &Context) get_timeout() ?time.Duration {
	return c.timeout
}

// set_backup_request_delay set the delay to send backup request. Default to
// ClientOptions.backup_request_delay on unset.
pub fn (mut c Context) set_backup_request_delay(backup_request_delay ?time.Duration) {
	c.backup_request_delay = backup_request_delay
}

// get_backup_request_delay set the delay to send backup request. Default to
// ClientOptions.backup_request_delay on unset.
pub fn (c &Context) get_backup_request_delay() ?time.Duration {
	return c.backup_request_delay
}

// set_max_retry set maxinum times for retrying(exclude the RPC request). Default to
// ClientOptions.max_retry on unset.
pub fn (mut c Context) set_max_retry(max_retry ?i32) {
	c.max_retry = max_retry
}

// get_max_retry get maxinum times for retrying(exclude the RPC request). Default to
// ClientOptions.max_retry on unset.
pub fn (c &Context) get_max_retry() ?i32 {
	return c.max_retry
}

// retried_count returns the already retried number.
pub fn (c &Context) retried_count() u32 {
	return c.retried_count
}

// has_backup_request returns true if a backup request was sent during the RPC.
pub fn (c &Context) has_backup_request() bool {
	return c.sent_backup_request
}

// latency returns latency of the RPC call for client side, and returns queue time before server
// process the RPC call for server side.
pub fn (c &Context) latency() ?time.Duration {
	if sent_time := c.request_sent_time {
		return time.now() - sent_time
	}
	return none
}

// response returns the RPC call result.
pub fn (c &Context) response() VrpcResponse {
	return VrpcResponse{
		meta: Meta{
			request_meta: RequestMeta{
				service_name: 'service'
				method_name: 'method'
			}
		}
	}
}

// set_log_id set an identifier to send to server along with request.
pub fn (mut c Context) set_log_id(log_id ?i64) {
	c.log_id = log_id
}

// rand_set_log_id random set an identifier to send to server along with request.
pub fn (mut c Context) rand_set_log_id() ?i64 {
	c.log_id = rand.i64()
	return c.log_id
}

// set_connection_type sets type of connections for sending RPC.
// Use ClientOptions.connection_type on unset.
pub fn (mut c Context) set_connection_type(connection_type ConnectionType) {
	c.connection_type = connection_type
}

// get_connection_type gets type of connections for sending RPC.
// Use ClientOptions.connection_type on unset.
pub fn (c &Context) get_connection_type() ConnectionType {
	return c.connection_type
}

// set_request_compress_type sets compression method for request.
pub fn (mut c Context) set_request_compress_type(compress_type CompressType) {
	c.request_compress_type = compress_type
}

// get_request_compress_type gets compression method for request.
pub fn (c &Context) get_request_compress_type() CompressType {
	return c.request_compress_type
}

// set_request_code sets a request code to calculate the hash code for some load balancers.
pub fn (mut c Context) set_request_code(request_code ?i64) {
	c.request_code = request_code
}

// get_request_code gets the request code.
pub fn (c &Context) get_request_code() ?i64 {
	return c.request_code
}
