defmodule FwupTools.Info do
  @moduledoc """
  Provides convenient access to FwupTools DSL data.

  This module generates functions to easily access the various sections and
  entities defined in a FwupTools DSL module.

  ## Usage

      # Get all file resources
      FwupTools.Info.file_resources(MyFirmware)

      # Get global metadata
      FwupTools.Info.global(MyFirmware)

      # Get a specific MBR by name
      FwupTools.Info.mbr(MyFirmware, :default)

      # Get all tasks
      FwupTools.Info.tasks(MyFirmware)

  ## Generated Functions

  This module automatically generates functions for accessing:

  - Global configuration options
  - File resources
  - MBR definitions
  - GPT definitions
  - U-Boot environment configurations
  - Task definitions

  Each section has corresponding getter functions that return the structured
  data defined in the DSL.
  """

  use Spark.InfoGenerator,
    extension: FwupTools.DSL,
    sections: [
      :global,
      :file_resources,
      :partitions,
      :osii_records,
      :mbrs,
      :gpts,
      :uboot_environments,
      :actions,
      :require_constraints,
      :event_handlers,
      :tasks
    ]

  @doc """
  Gets a specific file resource by name.

  ## Examples

      FwupTools.Info.file_resource(MyFirmware, :rootfs)

  """
  def file_resource(dsl_or_extended, name) do
    file_resources(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific MBR by name.

  ## Examples

      FwupTools.Info.mbr(MyFirmware, :default)

  """
  def mbr(dsl_or_extended, name) do
    mbrs(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific GPT by name.

  ## Examples

      FwupTools.Info.gpt(MyFirmware, :my_gpt)

  """
  def gpt(dsl_or_extended, name) do
    gpts(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific U-Boot environment by name.

  ## Examples

      FwupTools.Info.uboot_environment(MyFirmware, :main_env)

  """
  def uboot_environment(dsl_or_extended, name) do
    uboot_environments(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific task by name.

  ## Examples

      FwupTools.Info.task(MyFirmware, :complete)

  """
  def task(dsl_or_extended, name) do
    tasks(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific partition by number.

  ## Examples

      FwupTools.Info.partition(MyFirmware, 0)

  """
  def partition(dsl_or_extended, number) do
    partitions(dsl_or_extended)
    |> Enum.find(&(&1.number == number))
  end

  @doc """
  Gets a specific OSII record by number.

  ## Examples

      FwupTools.Info.osii_record(MyFirmware, 0)

  """
  def osii_record(dsl_or_extended, number) do
    osii_records(dsl_or_extended)
    |> Enum.find(&(&1.number == number))
  end

  @doc """
  Gets a specific action by name.

  ## Examples

      FwupTools.Info.action(MyFirmware, :write_rootfs)

  """
  def action(dsl_or_extended, name) do
    actions(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific require constraint by name.

  ## Examples

      FwupTools.Info.require_constraint(MyFirmware, :check_partition)

  """
  def require_constraint(dsl_or_extended, name) do
    require_constraints(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end

  @doc """
  Gets a specific event handler by name.

  ## Examples

      FwupTools.Info.event_handler(MyFirmware, :on_init)

  """
  def event_handler(dsl_or_extended, name) do
    event_handlers(dsl_or_extended)
    |> Enum.find(&(&1.name == name))
  end
end
