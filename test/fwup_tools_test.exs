defmodule FwupToolsTest do
  use ExUnit.Case
  doctest FwupTools

  defmodule TestFirmware do
    use FwupTools

    global do
      require_fwup_version("1.0.0")
      meta_product("Test Product")
      meta_description("A test firmware configuration")
      meta_version("1.0.0")
      meta_author("Test Author")
      meta_platform("rpi")
      meta_architecture("arm")
      meta_vcs_identifier("abc123")
    end

    file_resources do
      file_resource :rootfs do
        host_path("output/images/rootfs.squashfs")
        assert_size_lte(1_048_576)
        skip_holes(true)
      end

      file_resource :config do
        contents("test=true\nversion=1.0.0\n")
      end
    end

    mbrs do
      mbr :default do
        bootstrap_code_host_path("boot/bootstrap.bin")
        signature(0x01020304)
        include_osip(false)
      end
    end

    partitions do
      partition 0 do
        block_offset(63)
        block_count(77)
        type(0x1)
        boot(true)
      end

      partition 1 do
        block_offset(2048)
        block_count(1_048_576)
        type(0x83)
      end
    end

    uboot_environments do
      uboot_environment :main_env do
        block_offset(2048)
        block_count(16)
      end
    end

    actions do
      info :info_start do
        message("Starting complete firmware installation")
      end

      mbr_write :write_mbr do
        mbr(:default)
      end

      raw_write :write_rootfs do
        block_offset(2048)
      end

      fat_write :write_config do
        block_offset(63)
        filename("config.txt")
      end
    end

    require_constraints do
      require_constraint :fat_file_check, :fat_file_exists do
        args([63, "config.txt"])
      end
    end

    event_handlers do
      on(:init, :init_complete)

      on :resource, :resource_rootfs do
        resource_name(:rootfs)
      end

      on(:finish, :finish_complete)
    end

    tasks do
      task(:complete)
    end
  end

  describe "to_fwup_conf/1" do
    test "generates basic fwup.conf structure" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      # Should contain global metadata
      assert config =~ "meta-product = \"Test Product\""
      assert config =~ "meta-version = \"1.0.0\""
      assert config =~ "meta-author = \"Test Author\""
      assert config =~ "meta-platform = \"rpi\""
      assert config =~ "meta-architecture = \"arm\""
      assert config =~ "require-fwup-version = \"1.0.0\""
    end

    test "generates file resources" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      assert config =~ "file-resource rootfs {"
      assert config =~ "host-path = \"output/images/rootfs.squashfs\""
      assert config =~ "assert-size-lte = 1048576"
      assert config =~ "skip-holes = true"

      assert config =~ "file-resource config {"
      assert config =~ "contents = \"test=true\\nversion=1.0.0\\n\""
    end

    test "generates MBR with partitions" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      assert config =~ "mbr default {"
      assert config =~ "bootstrap-code-host-path = \"boot/bootstrap.bin\""
      assert config =~ "signature = 0x1020304"
      assert config =~ "include-osip = false"

      # Should include partitions within MBR
      assert config =~ "partition 0 {"
      assert config =~ "block-offset = 63"
      assert config =~ "block-count = 77"
      assert config =~ "type = 0x1"
      assert config =~ "boot = true"
    end

    test "generates U-Boot environments" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      assert config =~ "uboot-environment main_env {"
      assert config =~ "block-offset = 2048"
      assert config =~ "block-count = 16"
    end

    test "generates tasks with constraints and event handlers" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      assert config =~ "task complete {"
      assert config =~ "require-fat-file-exists(63, \"config.txt\")"
      assert config =~ "on-init {"
      assert config =~ "on-resource rootfs {"
      assert config =~ "on-finish {"
    end

    test "formats actions correctly" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      assert config =~ "info(\"Starting complete firmware installation\")"
      assert config =~ "mbr_write(default)"
      assert config =~ "raw_write(2048)"
      assert config =~ "fat_write(63, \"config.txt\")"
    end

    test "returns valid configuration string" do
      config = FwupTools.to_fwup_conf(TestFirmware)

      # Should be a non-empty string
      assert is_binary(config)
      assert String.length(config) > 0

      # Should not contain any obvious syntax errors
      refute config =~ "nil"
      refute config =~ "%"
    end
  end
end
