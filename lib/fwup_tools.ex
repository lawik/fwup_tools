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
          meta_product("My Product")
          meta_version("1.0.0")
          # ... other global options
        end

        # ... define resources, partitions, tasks, etc.
      end

      # Generate fwup.conf file
      config = FwupTools.to_fwup_conf(MyFirmware)
      File.write!("fwup.conf", config)

  """

  use Spark.Dsl,
    default_extensions: [
      extensions: [FwupTools.DSL]
    ]

  @doc """
  Generates a fwup.conf configuration file from a DSL definition.

  Takes a module that uses the FwupTools DSL and converts it to the standard
  fwup.conf format that can be used with the fwup utility.

  ## Parameters

    - `dsl_module` - A module that uses FwupTools DSL

  ## Returns

  A string containing the fwup.conf configuration.

  ## Examples

      defmodule MyFirmware do
        use FwupTools

        global do
          meta_product("My Product")
          meta_version("1.0.0")
        end

        file_resources do
          file_resource :rootfs do
            host_path("rootfs.squashfs")
          end
        end

        tasks do
          task :complete
        end
      end

      config = FwupTools.to_fwup_conf(MyFirmware)
      File.write!("fwup.conf", config)

  """
  def to_fwup_conf(dsl_module) do
    []
    |> add_global_section(dsl_module)
    |> add_file_resources(dsl_module)
    |> add_mbrs(dsl_module)
    |> add_gpts(dsl_module)
    |> add_uboot_environments(dsl_module)
    |> add_tasks(dsl_module)
    |> Enum.join("\n\n")
  end

  # Private helper functions for generating each section

  defp add_global_section(acc, dsl_module) do
    global_lines =
      []
      |> maybe_add_line(
        "require-fwup-version",
        get_global_option(dsl_module, :require_fwup_version),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-product",
        get_global_option(dsl_module, :meta_product),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-description",
        get_global_option(dsl_module, :meta_description),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-version",
        get_global_option(dsl_module, :meta_version),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-author",
        get_global_option(dsl_module, :meta_author),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-platform",
        get_global_option(dsl_module, :meta_platform),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-architecture",
        get_global_option(dsl_module, :meta_architecture),
        &quote_value/1
      )
      |> maybe_add_line(
        "meta-vcs-identifier",
        get_global_option(dsl_module, :meta_vcs_identifier),
        &quote_value/1
      )
      |> maybe_add_line("meta-misc", get_global_option(dsl_module, :meta_misc), &quote_value/1)
      |> maybe_add_line(
        "meta-creation-date",
        get_global_option(dsl_module, :meta_creation_date),
        &quote_value/1
      )
      |> maybe_add_line("meta-uuid", get_global_option(dsl_module, :meta_uuid), &quote_value/1)

    case global_lines do
      [] -> acc
      lines -> acc ++ [Enum.join(lines, "\n")]
    end
  end

  defp get_global_option(dsl_module, option) do
    try do
      function_name = String.to_atom("global_#{option}")

      case apply(FwupTools.Info, function_name, [dsl_module]) do
        {:ok, value} -> value
        {:error, _} -> nil
        :error -> nil
        value -> value
      end
    rescue
      UndefinedFunctionError -> nil
      _ -> nil
    end
  end

  defp add_file_resources(acc, dsl_module) do
    file_resources = FwupTools.Info.file_resources(dsl_module)

    resource_blocks =
      Enum.map(file_resources, fn resource ->
        lines =
          ["file-resource #{resource.name} {"]
          |> maybe_add_indented_line("host-path", resource.host_path, &quote_value/1)
          |> maybe_add_indented_line("contents", resource.contents, &quote_value/1)
          |> maybe_add_indented_line("assert-size-lte", resource.assert_size_lte)
          |> maybe_add_indented_line("assert-size-gte", resource.assert_size_gte)
          |> maybe_add_indented_line("skip-holes", resource.skip_holes, &format_boolean/1)

        (lines ++ ["}"])
        |> Enum.join("\n")
      end)

    acc ++ resource_blocks
  end

  defp add_mbrs(acc, dsl_module) do
    mbrs = FwupTools.Info.mbrs(dsl_module)
    partitions = FwupTools.Info.partitions(dsl_module)
    osii_records = FwupTools.Info.osii_records(dsl_module)

    mbr_blocks =
      Enum.map(mbrs, fn mbr ->
        lines =
          ["mbr #{mbr.name} {"]
          |> maybe_add_indented_line(
            "bootstrap-code-host-path",
            mbr.bootstrap_code_host_path,
            &quote_value/1
          )
          |> maybe_add_indented_line("signature", mbr.signature, &format_hex/1)
          |> maybe_add_indented_line("include-osip", mbr.include_osip, &format_boolean/1)
          |> maybe_add_indented_line("osip-major", mbr.osip_major)
          |> maybe_add_indented_line("osip-minor", mbr.osip_minor)
          |> maybe_add_indented_line("osip-num-pointers", mbr.osip_num_pointers)

        # Add OSII records if OSIP is enabled
        lines =
          if mbr.include_osip do
            osii_lines =
              Enum.flat_map(osii_records, fn osii ->
                osii_block =
                  ["    osii #{osii.number} {"]
                  |> maybe_add_indented_line("os-major", osii.os_major, nil, "        ")
                  |> maybe_add_indented_line("os-minor", osii.os_minor, nil, "        ")
                  |> maybe_add_indented_line(
                    "start-block-offset",
                    osii.start_block_offset,
                    nil,
                    "        "
                  )
                  |> maybe_add_indented_line(
                    "ddr-load-address",
                    osii.ddr_load_address,
                    &format_hex/1,
                    "        "
                  )
                  |> maybe_add_indented_line(
                    "entry-point",
                    osii.entry_point,
                    &format_hex/1,
                    "        "
                  )
                  |> maybe_add_indented_line(
                    "image-size-blocks",
                    osii.image_size_blocks,
                    &format_hex/1,
                    "        "
                  )
                  |> maybe_add_indented_line(
                    "attribute",
                    osii.attribute,
                    &format_hex/1,
                    "        "
                  )

                osii_block ++ ["    }"]
              end)

            lines ++ osii_lines
          else
            lines
          end

        # Add partitions
        partition_lines =
          Enum.flat_map(partitions, fn partition ->
            partition_block =
              ["    partition #{partition.number} {"]
              |> maybe_add_indented_line("block-offset", partition.block_offset, nil, "        ")
              |> maybe_add_indented_line("block-count", partition.block_count, nil, "        ")
              |> maybe_add_indented_line(
                "type",
                partition.type,
                &format_partition_type/1,
                "        "
              )
              |> maybe_add_indented_line("guid", partition.guid, &quote_value/1, "        ")
              |> maybe_add_indented_line("name", partition.name, &quote_value/1, "        ")
              |> maybe_add_indented_line("flags", partition.flags, &format_hex/1, "        ")
              |> maybe_add_indented_line("boot", partition.boot, &format_boolean/1, "        ")
              |> maybe_add_indented_line(
                "expand",
                partition.expand,
                &format_boolean/1,
                "        "
              )

            partition_block ++ ["    }"]
          end)

        (lines ++ partition_lines ++ ["}"])
        |> Enum.join("\n")
      end)

    acc ++ mbr_blocks
  end

  defp add_gpts(acc, dsl_module) do
    gpts = FwupTools.Info.gpts(dsl_module)
    partitions = FwupTools.Info.partitions(dsl_module)

    gpt_blocks =
      Enum.map(gpts, fn gpt ->
        lines =
          ["gpt #{gpt.name} {"]
          |> maybe_add_indented_line("guid", gpt.guid, &quote_value/1)

        # Add partitions for GPT
        partition_lines =
          Enum.flat_map(partitions, fn partition ->
            partition_block =
              ["    partition #{partition.number} {"]
              |> maybe_add_indented_line("block-offset", partition.block_offset, nil, "        ")
              |> maybe_add_indented_line("block-count", partition.block_count, nil, "        ")
              |> maybe_add_indented_line("type", partition.type, &quote_value/1, "        ")
              |> maybe_add_indented_line("guid", partition.guid, &quote_value/1, "        ")
              |> maybe_add_indented_line("name", partition.name, &quote_value/1, "        ")
              |> maybe_add_indented_line("flags", partition.flags, &format_hex/1, "        ")
              |> maybe_add_indented_line("boot", partition.boot, &format_boolean/1, "        ")
              |> maybe_add_indented_line(
                "expand",
                partition.expand,
                &format_boolean/1,
                "        "
              )

            partition_block ++ ["    }"]
          end)

        (lines ++ partition_lines ++ ["}"])
        |> Enum.join("\n")
      end)

    acc ++ gpt_blocks
  end

  defp add_uboot_environments(acc, dsl_module) do
    environments = FwupTools.Info.uboot_environments(dsl_module)

    env_blocks =
      Enum.map(environments, fn env ->
        lines =
          ["uboot-environment #{env.name} {"]
          |> maybe_add_indented_line("block-offset", env.block_offset)
          |> maybe_add_indented_line("block-count", env.block_count)
          |> maybe_add_indented_line("block-offset-redund", env.block_offset_redund)

        (lines ++ ["}"])
        |> Enum.join("\n")
      end)

    acc ++ env_blocks
  end

  defp add_tasks(acc, dsl_module) do
    tasks = FwupTools.Info.tasks(dsl_module)
    actions = FwupTools.Info.actions(dsl_module)
    constraints = FwupTools.Info.require_constraints(dsl_module)
    event_handlers = FwupTools.Info.event_handlers(dsl_module)

    task_blocks =
      Enum.map(tasks, fn task ->
        lines = ["task #{task.name} {"]

        # Add require constraints
        constraint_lines =
          Enum.flat_map(constraints, fn constraint ->
            args_str = format_constraint_args(constraint.type, constraint.args)

            [
              "    require-#{constraint.type |> Atom.to_string() |> String.replace("_", "-")}(#{args_str})"
            ]
          end)

        # Add event handlers with their actions
        handler_lines =
          Enum.flat_map(event_handlers, fn handler ->
            event_name =
              case handler.event do
                :init -> "on-init"
                :finish -> "on-finish"
                :error -> "on-error"
                :resource -> "on-resource #{handler.resource_name}"
              end

            handler_block = ["    #{event_name} {"]

            # Find actions for this handler (this is a simplification - in reality you'd need
            # to associate actions with handlers somehow in your DSL)
            action_lines =
              Enum.flat_map(actions, fn action ->
                ["        " <> format_action(action)]
              end)

            handler_block ++ action_lines ++ ["    }"]
          end)

        (lines ++ constraint_lines ++ handler_lines ++ ["}"])
        |> Enum.join("\n")
      end)

    acc ++ task_blocks
  end

  # Formatting helper functions

  defp maybe_add_line(lines, _key, nil, _formatter), do: lines

  defp maybe_add_line(lines, key, value, formatter) when is_function(formatter) do
    lines ++ ["#{key} = #{formatter.(value)}"]
  end

  defp maybe_add_line(lines, key, value, nil) do
    lines ++ ["#{key} = #{value}"]
  end

  defp maybe_add_indented_line(lines, key, value, formatter \\ nil, indent \\ "    ")

  defp maybe_add_indented_line(lines, _key, nil, _formatter, _indent), do: lines

  defp maybe_add_indented_line(lines, key, value, formatter, indent)
       when is_function(formatter) do
    lines ++ ["#{indent}#{key} = #{formatter.(value)}"]
  end

  defp maybe_add_indented_line(lines, key, value, nil, indent) do
    lines ++ ["#{indent}#{key} = #{value}"]
  end

  defp quote_value(value) when is_binary(value), do: "\"#{String.replace(value, "\n", "\\n")}\""
  defp quote_value(value), do: to_string(value)

  defp format_boolean(true), do: "true"
  defp format_boolean(false), do: "false"

  defp format_hex(value) when is_integer(value),
    do: "0x#{Integer.to_string(value, 16) |> String.upcase()}"

  defp format_hex(value), do: to_string(value)

  defp format_partition_type(value) when is_integer(value), do: format_hex(value)
  defp format_partition_type(value), do: quote_value(value)

  defp format_constraint_args(:fat_file_exists, [block_offset, filename]) do
    "#{block_offset}, \"#{filename}\""
  end

  defp format_constraint_args(:fat_file_match, [block_offset, filename, pattern]) do
    "#{block_offset}, \"#{filename}\", \"#{pattern}\""
  end

  defp format_constraint_args(:partition_offset, [partition, block_offset]) do
    "#{partition}, #{block_offset}"
  end

  defp format_constraint_args(:path_on_device, [path, device]) do
    "\"#{path}\", \"#{device}\""
  end

  defp format_constraint_args(:path_at_offset, [path, offset]) do
    "\"#{path}\", #{offset}"
  end

  defp format_constraint_args(:uboot_variable, [env, varname, value]) do
    "#{env}, \"#{varname}\", \"#{value}\""
  end

  defp format_constraint_args(_, args) do
    Enum.map_join(args, ", ", &inspect/1)
  end

  defp format_action(action) do
    case action.__struct__ do
      FwupTools.DSL.ErrorAction ->
        "error(\"#{action.message}\")"

      FwupTools.DSL.ExecuteAction ->
        "execute(\"#{action.command}\")"

      FwupTools.DSL.InfoAction ->
        "info(\"#{action.message}\")"

      FwupTools.DSL.FatAttribAction ->
        "fat_attrib(#{action.block_offset}, \"#{action.filename}\", \"#{action.attrib}\")"

      FwupTools.DSL.FatCpAction ->
        if action.from_offset && action.to_offset do
          "fat_cp(#{action.from_offset}, \"#{action.from}\", #{action.to_offset}, \"#{action.to}\")"
        else
          "fat_cp(#{action.block_offset}, \"#{action.from}\", \"#{action.to}\")"
        end

      FwupTools.DSL.FatMkdirAction ->
        "fat_mkdir(#{action.block_offset}, \"#{action.filename}\")"

      FwupTools.DSL.FatMkfsAction ->
        "fat_mkfs(#{action.block_offset}, #{action.block_count})"

      FwupTools.DSL.FatMvAction ->
        action_name = if action.force, do: "fat_mv!", else: "fat_mv"
        "#{action_name}(#{action.block_offset}, \"#{action.oldname}\", \"#{action.newname}\")"

      FwupTools.DSL.FatRmAction ->
        "fat_rm(#{action.block_offset}, \"#{action.filename}\")"

      FwupTools.DSL.FatSetlabelAction ->
        "fat_setlabel(#{action.block_offset}, \"#{action.label}\")"

      FwupTools.DSL.FatTouchAction ->
        "fat_touch(#{action.block_offset}, \"#{action.filename}\")"

      FwupTools.DSL.FatWriteAction ->
        if action.filename do
          "fat_write(#{action.block_offset}, \"#{action.filename}\")"
        else
          "fat_write(#{action.block_offset})"
        end

      FwupTools.DSL.GptWriteAction ->
        "gpt_write(#{action.gpt})"

      FwupTools.DSL.MbrWriteAction ->
        "mbr_write(#{action.mbr})"

      FwupTools.DSL.PathWriteAction ->
        "path_write(\"#{action.destination_path}\")"

      FwupTools.DSL.PipeWriteAction ->
        "pipe_write(\"#{action.command}\")"

      FwupTools.DSL.RawMemsetAction ->
        "raw_memset(#{action.block_offset}, #{action.block_count}, #{action.value})"

      FwupTools.DSL.RawWriteAction ->
        args = [action.block_offset]
        args = if action.cipher, do: args ++ ["\"cipher=#{action.cipher}\""], else: args
        args = if action.secret, do: args ++ ["\"secret=#{action.secret}\""], else: args
        "raw_write(#{Enum.join(args, ", ")})"

      FwupTools.DSL.RebootParamAction ->
        "reboot_param(\"#{action.args}\")"

      FwupTools.DSL.TrimAction ->
        "trim(#{action.block_offset}, #{action.count})"

      FwupTools.DSL.UbootClearenvAction ->
        "uboot_clearenv(#{action.uboot_env})"

      FwupTools.DSL.UbootRecoverAction ->
        "uboot_recover(#{action.uboot_env})"

      FwupTools.DSL.UbootSetenvAction ->
        "uboot_setenv(#{action.uboot_env}, \"#{action.variable_name}\", \"#{action.value}\")"

      FwupTools.DSL.UbootUnsetenvAction ->
        "uboot_unsetenv(#{action.uboot_env}, \"#{action.variable_name}\")"

      _ ->
        "# Unknown action: #{inspect(action)}"
    end
  end
end
