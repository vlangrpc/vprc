module vrpc

pub enum BalancerType {
	// round robin, choose next server
	rr
	// randomly choose a server
	random
	// weighted random
	wr
	// weighted round robin
	wrr
	// locality aware
	la
	// consistent hashing with murmurhash3
	c_murmurhash
	// consistent hashing with md5
	c_md5
}

@[heap]
pub interface IBalancer {
	balancer_type BalancerType
mut:
	server_addrs shared []string
	set_server_addrs(addrs []string)
	get_server_addr() ?string
}

pub struct RoundRobinBalancer {
	balancer_type BalancerType = .rr
mut:
	server_addrs shared []string
	index        int
}

pub fn (mut b RoundRobinBalancer) set_server_addrs(addrs []string) {
	lock b.server_addrs {
		b.server_addrs = addrs
	}
}

pub fn (mut b RoundRobinBalancer) get_server_addr() ?string {
	mut addr := ''
	rlock b.server_addrs {
		b.index++
		if b.server_addrs.len == 0 {
			return none
		}
		n := b.index % b.server_addrs.len
		addr = b.server_addrs[n]
	}
	return addr
}
