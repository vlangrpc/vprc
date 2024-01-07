module vrpc

import io
import net
import time

@[params]
pub struct ServerOptions {
	backlog            int = 128
	max_connections    u32 = 2000
	request_size_limit u32 = max_u32
	accept_timeout     time.Duration = 10 * time.second
	read_timeout       time.Duration = 10 * time.second
	write_timeout      time.Duration = 10 * time.second
	// timeout of receiving the whole message
	message_timeout    time.Duration = 0 * time.second
	keep_alive_timeout time.Duration = 60 * time.second
}

pub struct ServerStat {
mut:
	ok_server_accepts   int
	fail_server_accepts int

	ok_server_close   int
	fail_server_close int
}

pub enum ServerState {
	closed
	running
	stopped
}

@[heap]
pub struct Server {
mut:
	state    ServerState = .closed
	addr     string
	listener net.TcpListener
	options  ServerOptions
	services map[string]Service
	stat     shared ServerStat
	// callbacks
	on_running fn (mut s Server) = unsafe { nil } // Blocking cb. If set, ran by the web server on transitions to its .running state.
	on_stopped fn (mut s Server) = unsafe { nil } // Blocking cb. If set, ran by the web server on transitions to its .stopped state.
	on_closed  fn (mut s Server) = unsafe { nil } // Blocking cb. If set, ran by the web server on transitions to its .closed state.
}

// start listen socket and start serve thread
pub fn (mut s Server) start(ip string, port_range [2]u16, options ServerOptions) ! {
	for port in port_range {
		ip_and_port := '${ip}:${port}'
		s.listener = net.listen_tcp(.ip, ip_and_port, backlog: options.backlog) or {
			if port >= port_range[1] {
				// already retried all the port in range
				return err
			} else {
				continue
			}
		}
		s.listener.set_accept_timeout(options.accept_timeout)
	}
	s.options = options
	s.state = .running
	if s.on_running != unsafe { nil } {
		s.on_running(mut s)
	}

	spawn s.serve()
}

// serve accept sockets and start handle data thread
pub fn (mut s Server) serve() {
	for {
		if s.state != .running {
			break
		}
		mut conn := s.listener.accept() or {
			if err.code() == net.err_timed_out_code {
				// just skip the normal accept timeout
				continue
			}
			eprintln('skip failing accept: ${err}')
			lock s.stat {
				s.stat.fail_server_accepts++
			}
			continue
		}
		conn.set_read_timeout(s.options.read_timeout)
		conn.set_write_timeout(s.options.write_timeout)

		lock s.stat {
			s.stat.ok_server_accepts++
		}
		spawn s.handle_data(mut conn)
	}
	if s.state == .stopped {
		s.close()
	}
}

// handle_data handles connection data
pub fn (mut s Server) handle_data(mut conn net.TcpConn) {
	mut reader := io.new_buffered_reader(reader: conn)
	mut buf := []u8{len: 1024}
	mut protocol := ProtocolType.unknown
	for {
		bytes := reader.read(mut buf) or { -1 }
		if bytes < 0 {
			break
		}
		if bytes > 0 {
			eprintln('receive data: ${conn.peer_ip()} receive ${bytes} bytes')
			if protocol == .unknown {
				protocol = s.detect_protocol(buf) or {
					// close connection
					println('close connection: ${err}')
					conn.close() or { eprintln('close connection fail: ${err}') }
					return
				}
			}

			match protocol {
				.unknown {
					continue
				}
				.http {
					// req := s.parse_request(reader)
					// println('http ${req}')
					println('todo http')
				}
				.vrpc {
					// todo
					println('todo vrpc')
				}
			}
		}
	}
	conn.close() or {
		lock s.stat {
			s.stat.fail_server_close++
		}
		return
	}
	lock s.stat {
		s.stat.ok_server_close++
	}
}

pub fn (s &Server) detect_protocol(buf []u8) !ProtocolType {
	if buf.len < 4 {
		return .unknown
	}
	match buf[..4].bytestr() {
		'VRPC' {
			return .vrpc
		}
		'GET ', 'POST ', 'PUT ', 'DELE', 'OPTI', 'PATC', 'HEAD' {
			return .http
		}
		else {
			return error('cannot detect protocol')
		}
	}
}

// stop signals the server that is should not respond anymore.
pub fn (mut s Server) stop() {
	s.state = .stopped
	if s.on_stopped != unsafe { nil } {
		s.on_stopped(mut s)
	}
}

// close immediately closes the port and signals the server that it has been closed.
pub fn (mut s Server) close() {
	s.state = .closed
	s.listener.close() or { return }
	if s.on_closed != unsafe { nil } {
		s.on_closed(mut s)
	}
}

// add_service adds a service to server
pub fn (mut s Server) add_service(service Service) ! {
	if service.name in s.services {
		return error('service ${service.name} already added in server')
	}
	s.services[service.name] = service
}

// get_service gets a service by name
pub fn (s &Server) get_service(service_name string) ?Service {
	return s.services[service_name] or { return none }
}

// process handles client requests
pub fn (s &Server) process(mut request Request, response Response, context Context) ! {
	meta := request.deserialize_meta() or { return error('fail to deserialize request meta') }
	service := s.get_service(meta.request_meta.service_name) or {
		return error('fail to get service ${meta.request_meta.service_name}')
	}
	method := service.get_method(meta.request_meta.method_name) or {
		return error('fail to get method ${meta.request_meta.method_name}')
	}
	method(request, response, context)!
}
