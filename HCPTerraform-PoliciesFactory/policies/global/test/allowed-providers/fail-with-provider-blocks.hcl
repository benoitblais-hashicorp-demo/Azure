mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-with-provider-blocks.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}