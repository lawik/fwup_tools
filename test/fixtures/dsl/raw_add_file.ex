defmodule FwupTools.Test.Fixtures.DSL.RawAddFile do
  use FwupTools

  file_resources do
    file_resource :first do
      host_path("${TEST_1}")
    end

    file_resource :second do
      host_path("${TEST_1}")
    end
  end

  actions do
    raw_memset :clear_rootfs_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(2048)
      # ROOTFS_B_PART_COUNT
      block_count(1024)
      value(0)
    end

    raw_write :write_first_a do
      # ROOTFS_A_PART_OFFSET
      block_offset(1024)
    end

    raw_write :write_second_a do
      # ROOTFS_A_PART_OFFSET
      block_offset(1024)
    end

    raw_write :write_first_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(2048)
      # Delta source configuration
      delta_source_raw_offset(1024)
      delta_source_raw_count(1024)
    end

    raw_write :write_second_b do
      # ROOTFS_B_PART_OFFSET
      block_offset(2048)
      # Delta source configuration
      delta_source_raw_offset(1024)
      delta_source_raw_count(1024)
    end
  end

  event_handlers do
    on(:init, :init_complete)

    on :resource, :resource_first_complete do
      resource_name(:first)
    end

    on :resource, :resource_second_complete do
      resource_name(:second)
    end

    on :resource, :resource_first_upgrade do
      resource_name(:first)
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
