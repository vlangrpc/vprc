module vrpc

// RPC service
@[heap]
struct Service {
	// Service name
	name string
mut:
	// Service methods
	methods map[string]Method
}

// get_name gets service name
pub fn (s &Service) get_name() string {
	return s.name
}

// add_method adds a method to service
pub fn (mut s Service) add_method(method_name string, method Method) {
	s.methods[method_name] = method
}

// get_method gets a method from service
pub fn (s &Service) get_method(method_name string) ?Method {
	return s.methods[method_name] or { return none }
}
