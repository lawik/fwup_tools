defmodule FwupTools do
  @moduledoc """
  A DSL for defining fwup configuration files.

  FwupTools provides a Spark-based DSL for creating fwup firmware update
  configuration files. This allows you to define firmware update configurations
  using structured Elixir code instead of the traditional fwup.conf format.

  ## Usage

      defmodule MyFirmware do
        use FwupTools

        global do
          meta_product "My Product"
          meta_version "1.0.0"
          meta_author "My Company"
          meta_platform "rpi"
          meta_architecture "arm"
        end

        file_resources do
          file_resource :rootfs do
            host_path "output/images/rootfs.squashfs"
            skip_holes true
          end

          file_resource :kernel do
            host_path "output/images/zImage"
          end
        end

        mbrs do
          mbr :default do
            signature 0x01020304

            partition 0 do
              block_offset 63
              block_count 77
              type 0x1
              boot true
            end

            partition 1 do
              block_offset 2048
              block_count 1048576
              type 0x83
            end
          end
        end

        tasks do
          task :complete do
            on_event :init do
              action :info do
                args ["Starting firmware installation"]
              end
            end

            on_event :resource do
              resource_name :rootfs

              action :raw_write do
                args [2048]
              end
            end

            on :finish do
              action :info do
                args ["Firmware installation complete"]
              end
            end
          end
        end
      end

  ## Sections

  The DSL supports the following sections:

  - `global` - Global configuration and metadata
  - `file_resources` - Files to include in the firmware archive
  - `mbrs` - Master Boot Record definitions
  - `gpts` - GUID Partition Table definitions
  - `uboot_environments` - U-Boot environment configurations
  - `tasks` - Firmware update task definitions
  """

  use Spark.Dsl,
    default_extensions: [
      extensions: [FwupTools.DSL]
    ]
end
