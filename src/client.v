module vrpc

import net
import time

@[params]
pub struct ClientOptions {
mut:
	connect_timeout time.Duration = 500 * time.microsecond
	timeout         time.Duration = 1000 * time.microsecond
	// Send another request if RPC does not finish after so many time.
	backup_request_delay   ?time.Duration
	max_retry              i32  = 3
	enable_circuit_breaker bool = true
	protocol_type          ProtocolType
	connection_type        ConnectionType
}

@[heap]
pub struct Client {
mut:
	service_name       string
	server_id          int
	naming_service_url string
	balancer           IBalancer = RoundRobinBalancer{}
	options            ClientOptions
	preferred_index    int
	// serialize_request SerializeRequest @[required]
	// pack_request PackRequest @[required]
	// get_method_name GetMethodName @[required]
}

// init initiates connections to a group of servers whose addresses can be
// got from `naming_service_url`.
//
// Supported naming service("protocol://service_name"):
//   ns://<node-name>             # Naming Service
//   file://<file-path>           # Load addresses from the file
//   list://addr1,addr2,...       # Use the addresses separated by comma
//   http://<url>                 # Domain Naming Service, aka DNS
pub fn (mut c Client) init(naming_service_url string, balancer_type BalancerType) ! {
	match balancer_type {
		.rr {
			c.balancer = RoundRobinBalancer{}
		}
		else {
			return error('unsupport balancer ${balancer_type}')
		}
	}
	c.naming_service_url = naming_service_url
	typ, value := naming_service_url.split_once('://')
	match typ {
		'ns' {
			// TODO
		}
		'file' {
			// TODO
		}
		'list' {
			// list://ip1:port1,ip2:port2
			c.balancer.set_server_addrs(value.split(','))
		}
		'http' {
			// TODO
		}
		else {
			return error('unsupport naming service url ${naming_service_url}')
		}
	}
}

pub fn (mut c Client) get_connection() !&net.TcpConn {
	match c.options.connection_type {
		.short {
			addr := c.balancer.get_server_addr() or { return error('empty server address') }
			mut conn := net.dial_tcp(addr)!
			conn.set_read_timeout(c.options.timeout)
			conn.set_write_timeout(c.options.timeout)
			return conn
		}
		else {
			return error('unsupport connection type ${c.options.connection_type}')
		}
	}
}

// call_method calls `method` of the remote service with `request` as input, and
// `response` as output. `context` contains options and extra data.
pub fn (mut c Client) call_method(context Context, request Request, response chan Response) {
	mut conn := c.get_connection() or { panic('error ${err}') }
	conn.write('VRPC'.bytes()) or { panic('error ${err}') }
}

pub fn (c &Client) get_service_name() string {
	return c.service_name
}

pub fn (c &Client) check_health() {
}
