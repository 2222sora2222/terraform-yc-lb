output "lb_external_ip" {
  value = [
    for l in yandex_lb_network_load_balancer.web-lb.listener : [
      for spec in l.external_address_spec : spec.address
    ][0]
  ][0]
}