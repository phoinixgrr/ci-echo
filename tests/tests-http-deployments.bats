#!/usr/bin/env bats

@test "foo.localhost returns 'foo'" {
  result=$(curl -s http://foo.localhost)
  [ "$result" == "foo" ]
}

@test "bar.localhost returns 'bar'" {
  result=$(curl -s http://bar.localhost)
  [ "$result" == "bar" ]
}
