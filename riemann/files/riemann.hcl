template {
  source = "/etc/consul-template/templates.d/riemann/kafka.tmpl"
  destination = "/srv/config/riemann/helpers/01-kafka.clj"
  command = "for c in $(docker ps -q --filter='label=riemann');do docker kill -s 1 $c;done || true"
}

template {
  source = "/etc/consul-template/templates.d/riemann/elasticsearch.tmpl"
  destination = "/srv/config/riemann/helpers/02-elasticsearch.clj"
  command = "for c in $(docker ps -q --filter='label=riemann');do docker kill -s 1 $c;done || true"
}
