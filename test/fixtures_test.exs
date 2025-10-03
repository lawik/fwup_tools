defmodule FwupTools.FixturesTest do
  use ExUnit.Case, async: true

  @fixture_modules [
    FwupTools.Test.Fixtures.DSL.Fat,
    FwupTools.Test.Fixtures.DSL.Raw,
    FwupTools.Test.Fixtures.DSL.RawAddFile,
    FwupTools.Test.Fixtures.DSL.RawEncrypted,
    FwupTools.Test.Fixtures.DSL.PiStyle,
    FwupTools.Test.Fixtures.DSL.PiStyleDelta,
    FwupTools.Test.Fixtures.DSL.Mixed,
    FwupTools.Test.Fixtures.DSL.MixedNoDeltas
  ]

  describe "DSL fixture modules" do
    test "all fixture modules compile without errors" do
      for module <- @fixture_modules do
        assert Code.ensure_loaded?(module), "Module #{module} failed to load"
      end
    end

    test "all fixture modules can be introspected" do
      for module <- @fixture_modules do
        # Test that we can access basic DSL sections
        assert is_list(FwupTools.Info.file_resources(module))
        assert is_list(FwupTools.Info.tasks(module))
        assert is_list(FwupTools.Info.actions(module))
        assert is_list(FwupTools.Info.event_handlers(module))
      end
    end

    test "all fixture modules can generate fwup.conf" do
      for module <- @fixture_modules do
        config = FwupTools.to_fwup_conf(module)

        # Basic structure checks
        assert is_binary(config)
        assert String.length(config) > 0

        # Should not contain obvious errors
        refute config =~ "nil"
        refute config =~ "%"
        refute config =~ "Elixir."

        # Should contain expected fwup constructs
        assert config =~ "file-resource"
        assert config =~ "task"
      end
    end

    test "Fat fixture has expected structure" do
      module = FwupTools.Test.Fixtures.DSL.Fat

      # Check file resources
      resources = FwupTools.Info.file_resources(module)
      assert length(resources) == 1
      assert Enum.any?(resources, &(&1.name == :second))

      # Check tasks
      tasks = FwupTools.Info.tasks(module)
      assert length(tasks) == 2
      assert Enum.any?(tasks, &(&1.name == :complete))
      assert Enum.any?(tasks, &(&1.name == :upgrade))

      # Check MBR
      mbrs = FwupTools.Info.mbrs(module)
      assert length(mbrs) == 1
      assert Enum.any?(mbrs, &(&1.name == :mbr_a))
    end

    test "Raw fixture has expected structure" do
      module = FwupTools.Test.Fixtures.DSL.Raw

      # Check file resources
      resources = FwupTools.Info.file_resources(module)
      assert length(resources) == 1
      assert Enum.any?(resources, &(&1.name == :first))

      # Check actions include raw operations
      actions = FwupTools.Info.actions(module)

      raw_actions =
        Enum.filter(actions, fn action ->
          action.__struct__ in [FwupTools.DSL.RawMemsetAction, FwupTools.DSL.RawWriteAction]
        end)

      assert length(raw_actions) > 0
    end

    test "PiStyle fixture has expected structure" do
      module = FwupTools.Test.Fixtures.DSL.PiStyle

      # Check file resources
      resources = FwupTools.Info.file_resources(module)
      assert length(resources) == 2
      assert Enum.any?(resources, &(&1.name == :first))
      assert Enum.any?(resources, &(&1.name == :second))

      # Check U-Boot environment
      environments = FwupTools.Info.uboot_environments(module)
      assert length(environments) == 1
      assert Enum.any?(environments, &(&1.name == :uboot_env))

      # Check tasks
      tasks = FwupTools.Info.tasks(module)
      assert length(tasks) == 3
      assert Enum.any?(tasks, &(&1.name == :complete))
      assert Enum.any?(tasks, &(&1.name == :upgrade_a))
      assert Enum.any?(tasks, &(&1.name == :upgrade_b))
    end

    test "Mixed fixture has expected structure" do
      module = FwupTools.Test.Fixtures.DSL.Mixed

      # Check file resources
      resources = FwupTools.Info.file_resources(module)
      assert length(resources) == 2
      assert Enum.any?(resources, &(&1.name == :first))
      assert Enum.any?(resources, &(&1.name == :second))

      # Check that it has both raw and fat actions
      actions = FwupTools.Info.actions(module)
      raw_actions = Enum.filter(actions, &(&1.__struct__ == FwupTools.DSL.RawWriteAction))
      fat_actions = Enum.filter(actions, &(&1.__struct__ == FwupTools.DSL.FatWriteAction))

      assert length(raw_actions) > 0
      assert length(fat_actions) > 0
    end

    test "encrypted fixture has encryption parameters" do
      module = FwupTools.Test.Fixtures.DSL.RawEncrypted

      actions = FwupTools.Info.actions(module)

      encrypted_actions =
        Enum.filter(actions, fn action ->
          action.__struct__ == FwupTools.DSL.RawWriteAction and
            action.cipher != nil
        end)

      assert length(encrypted_actions) > 0

      # Check that encryption parameters are set
      encrypted_action = Enum.find(encrypted_actions, &(&1.cipher == "aes-cbc-plain"))
      assert encrypted_action != nil
      assert encrypted_action.secret != nil
    end

    test "generated configs contain proper syntax" do
      for module <- @fixture_modules do
        config = FwupTools.to_fwup_conf(module)

        # Check for proper block structure
        assert config =~ ~r/\w+\s+\w+\s+\{/

        # Check for proper key-value pairs
        assert config =~ ~r/\w+\s*=\s*.+/

        # Check that braces are balanced
        open_braces = String.graphemes(config) |> Enum.count(&(&1 == "{"))
        close_braces = String.graphemes(config) |> Enum.count(&(&1 == "}"))
        assert open_braces == close_braces, "Unbalanced braces in #{module}"
      end
    end

    test "configs with delta sources include delta parameters" do
      delta_modules = [
        FwupTools.Test.Fixtures.DSL.Raw,
        FwupTools.Test.Fixtures.DSL.RawAddFile,
        FwupTools.Test.Fixtures.DSL.RawEncrypted,
        FwupTools.Test.Fixtures.DSL.PiStyle,
        FwupTools.Test.Fixtures.DSL.PiStyleDelta,
        FwupTools.Test.Fixtures.DSL.Mixed
      ]

      for module <- delta_modules do
        actions = FwupTools.Info.actions(module)

        # Check if any actions have delta source parameters
        delta_actions =
          Enum.filter(actions, fn action ->
            case action.__struct__ do
              FwupTools.DSL.RawWriteAction ->
                action.delta_source_raw_offset != nil or action.delta_source_fat_offset != nil

              FwupTools.DSL.FatWriteAction ->
                Map.get(action, :delta_source_fat_offset, nil) != nil

              _ ->
                false
            end
          end)

        # For upgrade tasks, we expect delta sources
        if Enum.any?(
             FwupTools.Info.tasks(module),
             &(&1.name in [:upgrade, :upgrade_a, :upgrade_b])
           ) do
          assert length(delta_actions) > 0, "Expected delta actions in #{module}"
        end
      end
    end

    test "no-delta variant has no delta parameters" do
      module = FwupTools.Test.Fixtures.DSL.MixedNoDeltas
      actions = FwupTools.Info.actions(module)

      # Check that no actions have delta source parameters
      delta_actions =
        Enum.filter(actions, fn action ->
          case action.__struct__ do
            FwupTools.DSL.RawWriteAction ->
              action.delta_source_raw_offset != nil or action.delta_source_fat_offset != nil

            FwupTools.DSL.FatWriteAction ->
              Map.get(action, :delta_source_fat_offset, nil) != nil

            _ ->
              false
          end
        end)

      assert length(delta_actions) == 0, "Expected no delta actions in MixedNoDeltas"
    end
  end

  describe "config generation roundtrip" do
    test "generated configs contain expected file resources" do
      for module <- @fixture_modules do
        config = FwupTools.to_fwup_conf(module)
        resources = FwupTools.Info.file_resources(module)

        for resource <- resources do
          assert config =~ "file-resource #{resource.name}"
        end
      end
    end

    test "generated configs contain expected tasks" do
      for module <- @fixture_modules do
        config = FwupTools.to_fwup_conf(module)
        tasks = FwupTools.Info.tasks(module)

        for task <- tasks do
          assert config =~ "task #{task.name}"
        end
      end
    end
  end
end
