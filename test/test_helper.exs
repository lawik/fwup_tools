ExUnit.start()

# Load fixture DSL modules
Code.require_file("fixtures/dsl/fat.ex", __DIR__)
Code.require_file("fixtures/dsl/raw.ex", __DIR__)
Code.require_file("fixtures/dsl/raw_add_file.ex", __DIR__)
Code.require_file("fixtures/dsl/raw_encrypted.ex", __DIR__)
Code.require_file("fixtures/dsl/pi_style.ex", __DIR__)
Code.require_file("fixtures/dsl/pi_style_delta.ex", __DIR__)
Code.require_file("fixtures/dsl/mixed.ex", __DIR__)
Code.require_file("fixtures/dsl/mixed_no_deltas.ex", __DIR__)
