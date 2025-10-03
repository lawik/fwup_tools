defmodule FwupTools.Test.Fixtures.DSL.PiStyleDelta do
  use FwupTools

  global do
    meta_product("${NERVES_FW_PRODUCT}")
    meta_description("${NERVES_FW_DESCRIPTION}")
    meta_version("${NERVES_FW_VERSION}")
    meta_platform("${NERVES_FW_PLATFORM}")
    meta_architecture("${NERVES_FW_ARCHITECTURE}")
    meta_author("${NERVES_FW_AUTHOR}")
    meta_vcs_identifier("${NERVES_FW_VCS_IDENTIFIER}")
    meta_misc("${NERVES_FW_MISC}")
  end

  file_resources do
    file_resource :first do
      host_path("${TEST_1}")
    end

    file_resource :second do
      host_path("${TEST_1}")
      # Error out if the rootfs size exceeds the partition size
      # ROOTFS_A_PART_COUNT
      assert_size_lte(578_088)
    end
  end

  partitions do
    # Boot A partition
    partition 0 do
      # BOOT_A_PART_OFFSET
      block_offset(63)
      # BOOT_A_PART_COUNT
      block_count(77_260)
      # FAT32
      type(0xC)
      boot(true)
    end

    # RootFS A partition
    partition 1 do
      # ROOTFS_A_PART_OFFSET (63 + 77260)
      block_offset(77_323)
      # ROOTFS_A_PART_COUNT
      block_count(578_088)
      # Linux
      type(0x83)
    end

    # App partition
    partition 2 do
      # APP_PART_OFFSET (77323 + 578088 + 578088)
      block_offset(1_233_499)
      # APP_PART_COUNT
      block_count(1_048_576)
      # Linux
      type(0x83)
      expand(true)
    end

    # Boot B partition (for mbr-b)
    partition 0 do
      # BOOT_B_PART_OFFSET (63 + 77260)
      block_offset(77_323)
      # BOOT_B_PART_COUNT
      block_count(77_260)
      # FAT32
      type(0xC)
      boot(true)
    end

    # RootFS B partition (for mbr-b)
    partition 1 do
      # ROOTFS_B_PART_OFFSET (77323 + 578088)
      block_offset(655_411)
      # ROOTFS_B_PART_COUNT
      block_count(578_088)
      # Linux
      type(0x83)
    end
  end

  mbrs do
    mbr :mbr_a do
    end

    mbr :mbr_b do
    end
  end

  uboot_environments do
    uboot_environment :uboot_env do
      # UBOOT_ENV_OFFSET
      block_offset(16)
      # UBOOT_ENV_COUNT (8 KB)
      block_count(16)
    end
  end

  actions do
    # MBR write actions
    mbr_write :write_mbr_a do
      mbr(:mbr_a)
    end

    mbr_write :write_mbr_b do
      mbr(:mbr_b)
    end

    # FAT filesystem operations
    fat_mkfs :mkfs_boot_a do
      # BOOT_A_PART_OFFSET
      block_offset(63)
      # BOOT_A_PART_COUNT
      block_count(77_260)
    end

    fat_setlabel :setlabel_boot_a do
      # BOOT_A_PART_OFFSET
      block_offset(63)
      label("BOOT-A")
    end

    fat_mkdir :mkdir_overlays_a do
      # BOOT_A_PART_OFFSET
      block_offset(63)
      filename("overlays")
    end

    fat_mkfs :mkfs_boot_b do
      # BOOT_B_PART_OFFSET
      block_offset(77_323)
      # BOOT_B_PART_COUNT
      block_count(77_260)
    end

    fat_setlabel :setlabel_boot_b do
      # BOOT_B_PART_OFFSET
      block_offset(77_323)
      label("BOOT-B")
    end

    fat_mkdir :mkdir_overlays_b do
      # BOOT_B_PART_OFFSET
      block_offset(77_323)
      filename("overlays")
    end

    # U-Boot environment operations
    uboot_clearenv :clear_uboot_env do
      uboot_env(:uboot_env)
    end

    # Set initial environment variables
    uboot_setenv :set_nerves_fw_active_a do
      uboot_env(:uboot_env)
      variable_name("nerves_fw_active")
      value("a")
    end

    uboot_setenv :set_nerves_fw_devpath do
      uboot_env(:uboot_env)
      variable_name("nerves_fw_devpath")
      value("${NERVES_FW_DEVPATH}")
    end

    # Set A partition variables
    uboot_setenv :set_a_app_devpath do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_application_part0_devpath")
      value("${NERVES_FW_APPLICATION_PART0_DEVPATH}")
    end

    uboot_setenv :set_a_app_fstype do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_application_part0_fstype")
      value("${NERVES_FW_APPLICATION_PART0_FSTYPE}")
    end

    uboot_setenv :set_a_app_target do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_application_part0_target")
      value("${NERVES_FW_APPLICATION_PART0_TARGET}")
    end

    uboot_setenv :set_a_product do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_product")
      value("${NERVES_FW_PRODUCT}")
    end

    uboot_setenv :set_a_description do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_description")
      value("${NERVES_FW_DESCRIPTION}")
    end

    uboot_setenv :set_a_version do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_version")
      value("${NERVES_FW_VERSION}")
    end

    uboot_setenv :set_a_platform do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_platform")
      value("${NERVES_FW_PLATFORM}")
    end

    uboot_setenv :set_a_architecture do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_architecture")
      value("${NERVES_FW_ARCHITECTURE}")
    end

    uboot_setenv :set_a_author do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_author")
      value("${NERVES_FW_AUTHOR}")
    end

    uboot_setenv :set_a_vcs do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_vcs_identifier")
      value("${NERVES_FW_VCS_IDENTIFIER}")
    end

    uboot_setenv :set_a_misc do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_misc")
      value("${NERVES_FW_MISC}")
    end

    uboot_setenv :set_a_uuid do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_uuid")
      value("${FWUP_META_UUID}")
    end

    # Set B partition variables (similar to A)
    uboot_setenv :set_b_app_devpath do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_application_part0_devpath")
      value("${NERVES_FW_APPLICATION_PART0_DEVPATH}")
    end

    uboot_setenv :set_b_app_fstype do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_application_part0_fstype")
      value("${NERVES_FW_APPLICATION_PART0_FSTYPE}")
    end

    uboot_setenv :set_b_app_target do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_application_part0_target")
      value("${NERVES_FW_APPLICATION_PART0_TARGET}")
    end

    uboot_setenv :set_b_product do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_product")
      value("${NERVES_FW_PRODUCT}")
    end

    uboot_setenv :set_b_description do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_description")
      value("${NERVES_FW_DESCRIPTION}")
    end

    uboot_setenv :set_b_version do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_version")
      value("${NERVES_FW_VERSION}")
    end

    uboot_setenv :set_b_platform do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_platform")
      value("${NERVES_FW_PLATFORM}")
    end

    uboot_setenv :set_b_architecture do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_architecture")
      value("${NERVES_FW_ARCHITECTURE}")
    end

    uboot_setenv :set_b_author do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_author")
      value("${NERVES_FW_AUTHOR}")
    end

    uboot_setenv :set_b_vcs do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_vcs_identifier")
      value("${NERVES_FW_VCS_IDENTIFIER}")
    end

    uboot_setenv :set_b_misc do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_misc")
      value("${NERVES_FW_MISC}")
    end

    uboot_setenv :set_b_uuid do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_uuid")
      value("${FWUP_META_UUID}")
    end

    # Unset environment variables for upgrades
    uboot_unsetenv :unset_a_version do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_version")
    end

    uboot_unsetenv :unset_a_platform do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_platform")
    end

    uboot_unsetenv :unset_a_architecture do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_architecture")
    end

    uboot_unsetenv :unset_a_uuid do
      uboot_env(:uboot_env)
      variable_name("a.nerves_fw_uuid")
    end

    uboot_unsetenv :unset_b_version do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_version")
    end

    uboot_unsetenv :unset_b_platform do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_platform")
    end

    uboot_unsetenv :unset_b_architecture do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_architecture")
    end

    uboot_unsetenv :unset_b_uuid do
      uboot_env(:uboot_env)
      variable_name("b.nerves_fw_uuid")
    end

    uboot_setenv :set_nerves_fw_active_b do
      uboot_env(:uboot_env)
      variable_name("nerves_fw_active")
      value("b")
    end

    # File write operations
    fat_write :write_first_boot_a do
      # BOOT_A_PART_OFFSET
      block_offset(63)
      filename("first")
      # Delta source from BOOT_B
      delta_source_fat_offset(77_323)
      delta_source_fat_path("first")
    end

    fat_write :write_first_boot_b do
      # BOOT_B_PART_OFFSET
      block_offset(77_323)
      filename("first")
      # Delta source from BOOT_A
      delta_source_fat_offset(63)
      delta_source_fat_path("first")
    end

    uboot_setenv :set_nerves_serial_number do
      uboot_env(:uboot_env)
      variable_name("nerves_serial_number")
      value("foo")
    end

    raw_write :write_second_rootfs_a do
      # ROOTFS_A_PART_OFFSET
      block_offset(77_323)
    end

    raw_write :write_second_rootfs_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(655_411)
      # ROOTFS_A_PART_OFFSET
      delta_source_raw_offset(77_323)
      # ROOTFS_A_PART_COUNT
      delta_source_raw_count(578_088)
    end

    raw_write :write_second_rootfs_a_upgrade do
      # ROOTFS_A_PART_OFFSET
      block_offset(77_323)
      # ROOTFS_B_PART_OFFSET
      delta_source_raw_offset(655_411)
      # ROOTFS_B_PART_COUNT
      delta_source_raw_count(578_088)
    end

    # Memory clear operations
    raw_memset :clear_boot_b do
      # BOOT_B_PART_OFFSET
      block_offset(77_323)
      block_count(256)
      value(0xFF)
    end

    raw_memset :clear_rootfs_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(655_411)
      block_count(256)
      value(0xFF)
    end

    raw_memset :clear_app do
      # APP_PART_OFFSET
      block_offset(1_233_499)
      block_count(256)
      value(0xFF)
    end

    # TRIM operations for upgrades
    trim :trim_rootfs_a do
      # ROOTFS_A_PART_OFFSET
      block_offset(77_323)
      # ROOTFS_A_PART_COUNT
      count(578_088)
    end

    trim :trim_rootfs_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(655_411)
      # ROOTFS_B_PART_COUNT
      count(578_088)
    end

    # Info messages
    info :info_upgrade_a do
      message("Upgrading partition A")
    end

    info :info_upgrade_b do
      message("Upgrading partition B")
    end
  end

  require_constraints do
    require_constraint :require_partition_b, :partition_offset do
      # partition 1, ROOTFS_B_PART_OFFSET
      args([1, 655_411])
    end

    require_constraint :require_b_platform, :uboot_variable do
      args([:uboot_env, "b.nerves_fw_platform", "${NERVES_FW_PLATFORM}"])
    end

    require_constraint :require_b_architecture, :uboot_variable do
      args([:uboot_env, "b.nerves_fw_architecture", "${NERVES_FW_ARCHITECTURE}"])
    end

    require_constraint :require_partition_a, :partition_offset do
      # partition 1, ROOTFS_A_PART_OFFSET
      args([1, 77_323])
    end

    require_constraint :require_a_platform, :uboot_variable do
      args([:uboot_env, "a.nerves_fw_platform", "${NERVES_FW_PLATFORM}"])
    end

    require_constraint :require_a_architecture, :uboot_variable do
      args([:uboot_env, "a.nerves_fw_architecture", "${NERVES_FW_ARCHITECTURE}"])
    end
  end

  event_handlers do
    # Complete task event handlers
    on(:init, :init_complete)

    on(:resource, :resource_first_complete) do
      resource_name(:first)
    end

    on(:resource, :resource_second_complete) do
      resource_name(:second)
    end

    on(:finish, :finish_complete)

    # Upgrade A task event handlers
    on(:init, :init_upgrade_a)

    on(:resource, :resource_first_upgrade_a) do
      resource_name(:first)
    end

    on(:resource, :resource_second_upgrade_a) do
      resource_name(:second)
    end

    on(:finish, :finish_upgrade_a)
    on(:error, :error_upgrade_a)

    # Upgrade B task event handlers
    on(:init, :init_upgrade_b)

    on(:resource, :resource_first_upgrade_b) do
      resource_name(:first)
    end

    on(:resource, :resource_second_upgrade_b) do
      resource_name(:second)
    end

    on(:finish, :finish_upgrade_b)
    on(:error, :error_upgrade_b)
  end

  tasks do
    task(:complete)
    task(:upgrade_a)
    task(:upgrade_b)
  end
end
