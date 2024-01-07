module vrpc

import net.http

pub struct HttpRequest {
	http.Request
}

pub struct HttpResponse {
	http.Response
}
