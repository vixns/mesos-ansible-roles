template {
  source = "/etc/consul-template/templates.d/haproxy.tmpl"
  destination = "/etc/haproxy/haproxy.cfg"
  command = "sv reload haproxy"
}