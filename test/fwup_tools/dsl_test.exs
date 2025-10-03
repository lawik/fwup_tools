defmodule FwupTools.DSLTest do
  use ExUnit.Case, async: true

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

      file_resource :kernel do
        host_path("output/images/zImage")
        assert_size_gte(1024)
      end

      file_resource :config do
        contents("test=true\nversion=1.0.0\n")
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

      partition 2 do
        block_offset(1_050_624)
        block_count(1_048_576)
        type(0x83)
      end

      partition 3 do
        block_offset(2_099_200)
        block_count(2_097_152)
        type(0x83)
        expand(true)
      end
    end

    osii_records do
      osii 0 do
        os_major(0)
        os_minor(0)
        start_block_offset(2048)
        ddr_load_address(0x01100000)
        entry_point(0x01101000)
        image_size_blocks(0x0000C000)
        attribute(0x0F)
      end
    end

    mbrs do
      mbr :default do
        bootstrap_code_host_path("boot/bootstrap.bin")
        signature(0x01020304)
        include_osip(false)
      end
    end

    gpts do
      gpt :my_gpt do
        guid("b443fbeb-2c93-481b-88b3-0ecb0aeba911")
      end
    end

    uboot_environments do
      uboot_environment :main_env do
        block_offset(2048)
        block_count(16)
      end

      uboot_environment :backup_env do
        block_offset(2048)
        block_count(16)
        block_offset_redund(2064)
      end
    end

    actions do
      action :info_start, :info do
        args(["Starting complete firmware installation"])
      end

      action :write_mbr, :mbr_write do
        args([:default])
      end

      action :write_rootfs, :raw_write do
        args([2048])
        options(cipher: "aes-cbc-plain", secret: "${SECRET_KEY}")
      end

      action :write_kernel, :fat_write do
        args([63, "zImage"])
      end

      action :info_complete, :info do
        args(["Complete firmware installation finished"])
      end

      action :set_reboot_param, :reboot_param do
        args(["0 tryboot"])
      end

      action :error_install, :error do
        args(["Installation failed"])
      end

      action :info_upgrade, :info do
        args(["Upgrading partition A"])
      end

      action :set_active_partition, :uboot_setenv do
        args([:main_env, "active_partition", "a"])
      end

      action :info_upgrade_complete, :info do
        args(["Partition A upgrade complete"])
      end
    end

    require_constraints do
      require_constraint :fat_file_check, :fat_file_exists do
        args([63, "config.txt"])
      end

      require_constraint :partition_check, :partition_offset do
        args([0, 63])
      end

      require_constraint :uboot_check, :uboot_variable do
        args([:main_env, "active_partition", "b"])
      end
    end

    event_handlers do
      event_handler(:init_complete, :init)

      event_handler :resource_rootfs, :resource do
        resource_name(:rootfs)
      end

      event_handler :resource_kernel, :resource do
        resource_name(:kernel)
      end

      event_handler(:finish_complete, :finish)

      event_handler(:error_complete, :error)

      event_handler(:init_upgrade_a, :init)

      event_handler :resource_upgrade_a, :resource do
        resource_name(:rootfs)
      end

      event_handler(:finish_upgrade_a, :finish)
    end

    tasks do
      task(:complete)

      task(:upgrade_a)
    end
  end

  describe "DSL structure" do
    test "can access global configuration" do
      assert FwupTools.Info.global_meta_product!(TestFirmware) == "Test Product"
      assert FwupTools.Info.global_meta_version!(TestFirmware) == "1.0.0"
      assert FwupTools.Info.global_meta_author!(TestFirmware) == "Test Author"
      assert FwupTools.Info.global_meta_platform!(TestFirmware) == "rpi"
      assert FwupTools.Info.global_meta_architecture!(TestFirmware) == "arm"
      assert FwupTools.Info.global_require_fwup_version!(TestFirmware) == "1.0.0"
    end

    test "can access file resources" do
      file_resources = FwupTools.Info.file_resources(TestFirmware)
      assert length(file_resources) == 3

      rootfs = FwupTools.Info.file_resource(TestFirmware, :rootfs)
      assert rootfs.name == :rootfs
      assert rootfs.host_path == "output/images/rootfs.squashfs"
      assert rootfs.assert_size_lte == 1_048_576
      assert rootfs.skip_holes == true

      kernel = FwupTools.Info.file_resource(TestFirmware, :kernel)
      assert kernel.name == :kernel
      assert kernel.host_path == "output/images/zImage"
      assert kernel.assert_size_gte == 1024

      config = FwupTools.Info.file_resource(TestFirmware, :config)
      assert config.name == :config
      assert config.contents == "test=true\nversion=1.0.0\n"
    end

    test "can access partitions" do
      partitions = FwupTools.Info.partitions(TestFirmware)
      assert length(partitions) == 4

      boot_partition = FwupTools.Info.partition(TestFirmware, 0)
      assert boot_partition.number == 0
      assert boot_partition.block_offset == 63
      assert boot_partition.block_count == 77
      assert boot_partition.type == 0x1
      assert boot_partition.boot == true

      expand_partition = FwupTools.Info.partition(TestFirmware, 3)
      assert expand_partition.expand == true
    end

    test "can access OSII records" do
      osii_records = FwupTools.Info.osii_records(TestFirmware)
      assert length(osii_records) == 1

      osii = FwupTools.Info.osii_record(TestFirmware, 0)
      assert osii.number == 0
      assert osii.os_major == 0
      assert osii.os_minor == 0
      assert osii.start_block_offset == 2048
      assert osii.ddr_load_address == 0x01100000
      assert osii.entry_point == 0x01101000
      assert osii.image_size_blocks == 0x0000C000
      assert osii.attribute == 0x0F
    end

    test "can access MBR configuration" do
      mbrs = FwupTools.Info.mbrs(TestFirmware)
      assert length(mbrs) == 1

      mbr = FwupTools.Info.mbr(TestFirmware, :default)
      assert mbr.name == :default
      assert mbr.bootstrap_code_host_path == "boot/bootstrap.bin"
      assert mbr.signature == 0x01020304
      assert mbr.include_osip == false
    end

    test "can access GPT configuration" do
      gpts = FwupTools.Info.gpts(TestFirmware)
      assert length(gpts) == 1

      gpt = FwupTools.Info.gpt(TestFirmware, :my_gpt)
      assert gpt.name == :my_gpt
      assert gpt.guid == "b443fbeb-2c93-481b-88b3-0ecb0aeba911"
    end

    test "can access U-Boot environment configuration" do
      environments = FwupTools.Info.uboot_environments(TestFirmware)
      assert length(environments) == 2

      main_env = FwupTools.Info.uboot_environment(TestFirmware, :main_env)
      assert main_env.name == :main_env
      assert main_env.block_offset == 2048
      assert main_env.block_count == 16
      assert main_env.block_offset_redund == nil

      backup_env = FwupTools.Info.uboot_environment(TestFirmware, :backup_env)
      assert backup_env.block_offset_redund == 2064
    end

    test "can access actions" do
      actions = FwupTools.Info.actions(TestFirmware)
      assert length(actions) == 10

      info_action = FwupTools.Info.action(TestFirmware, :info_start)
      assert info_action.name == :info_start
      assert info_action.type == :info
      assert info_action.args == ["Starting complete firmware installation"]

      write_action = FwupTools.Info.action(TestFirmware, :write_rootfs)
      assert write_action.name == :write_rootfs
      assert write_action.type == :raw_write
      assert write_action.args == [2048]
      assert write_action.options[:cipher] == "aes-cbc-plain"
      assert write_action.options[:secret] == "${SECRET_KEY}"
    end

    test "can access require constraints" do
      constraints = FwupTools.Info.require_constraints(TestFirmware)
      assert length(constraints) == 3

      fat_constraint = FwupTools.Info.require_constraint(TestFirmware, :fat_file_check)
      assert fat_constraint.name == :fat_file_check
      assert fat_constraint.type == :fat_file_exists
      assert fat_constraint.args == [63, "config.txt"]

      uboot_constraint = FwupTools.Info.require_constraint(TestFirmware, :uboot_check)
      assert uboot_constraint.name == :uboot_check
      assert uboot_constraint.type == :uboot_variable
      assert uboot_constraint.args == [:main_env, "active_partition", "b"]
    end

    test "can access event handlers" do
      handlers = FwupTools.Info.event_handlers(TestFirmware)
      assert length(handlers) == 8

      init_handler = FwupTools.Info.event_handler(TestFirmware, :init_complete)
      assert init_handler.name == :init_complete
      assert init_handler.event == :init

      resource_handler = FwupTools.Info.event_handler(TestFirmware, :resource_rootfs)
      assert resource_handler.name == :resource_rootfs
      assert resource_handler.event == :resource
      assert resource_handler.resource_name == :rootfs
    end

    test "can access task configuration" do
      tasks = FwupTools.Info.tasks(TestFirmware)
      assert length(tasks) == 2

      complete_task = FwupTools.Info.task(TestFirmware, :complete)
      assert complete_task.name == :complete

      upgrade_task = FwupTools.Info.task(TestFirmware, :upgrade_a)
      assert upgrade_task.name == :upgrade_a
    end
  end
end
