template {
  source = "/etc/consul-template/templates.d/collectd/riemann.tmpl"
  destination = "/etc/collectd/collectd.conf.d/90-riemann.conf"
  command = "sv reload collectd || true"
}
