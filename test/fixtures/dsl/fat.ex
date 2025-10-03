defmodule FwupTools.Test.Fixtures.DSL.Fat do
  use FwupTools

  file_resources do
    file_resource :second do
      host_path("${TEST_1}")
    end
  end

  partitions do
    partition 0 do
      # BOOT_A_PART_OFFSET
      block_offset(4096)
      # BOOT_A_PART_COUNT
      block_count(154_476)
      # FAT32
      type(0xC)
      boot(true)
    end

    partition 1 do
      # BOOT_B_PART_OFFSET (4096 + 154476)
      block_offset(158_572)
      # BOOT_B_PART_COUNT
      block_count(154_476)
      # FAT32
      type(0xC)
      boot(false)
    end
  end

  mbrs do
    mbr :mbr_a do
    end
  end

  actions do
    mbr_write :write_mbr do
      mbr(:mbr_a)
    end

    fat_mkfs :mkfs_boot_a do
      # BOOT_A_PART_OFFSET
      block_offset(4096)
      # BOOT_A_PART_COUNT
      block_count(154_476)
    end

    fat_mkfs :mkfs_boot_b do
      # BOOT_B_PART_OFFSET
      block_offset(158_572)
      # BOOT_B_PART_COUNT
      block_count(154_476)
    end

    fat_write :write_second_a do
      # BOOT_A_PART_OFFSET
      block_offset(4096)
      filename("second")
    end

    fat_write :write_second_b do
      # BOOT_B_PART_OFFSET
      block_offset(158_572)
      filename("second")
    end
  end

  event_handlers do
    on(:init, :init_complete)

    on :resource, :resource_second do
      resource_name(:second)
    end

    on :resource, :resource_second_upgrade do
      resource_name(:second)
    end
  end

  tasks do
    task(:complete)
    task(:upgrade)
  end
end
