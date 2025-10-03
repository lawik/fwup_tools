defmodule FwupTools do
  @moduledoc """
  A DSL for defining fwup configuration files.

  FwupTools provides a Spark-based DSL for creating fwup firmware update
  configuration files. This allows you to define firmware update configurations
  using structured Elixir code instead of the traditional fwup.conf format.

  """

  use Spark.Dsl,
    default_extensions: [
      extensions: [FwupTools.DSL]
    ]
end
