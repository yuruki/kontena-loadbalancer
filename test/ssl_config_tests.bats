#!/usr/bin/env bats

load "common"

@test "sets etcd certs/bundle to true when configured with SSL_CERTS" {
  run etcdctl get /kontena/haproxy/lb/certs/bundle

  [ "$status" -eq 0 ]
  [ "$output" = 'true' ]
}

@test "configures haproxy to load certs when configured with SSL_CERTS" {
  run config
  assert_output_contains "bind *:443 ssl crt /etc/haproxy/certs/"
}
