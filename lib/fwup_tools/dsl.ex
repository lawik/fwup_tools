defmodule FwupTools.DSL do
  # Entity definitions
  defmodule FileResource do
    @moduledoc """
    Defines a file resource to be included in the firmware archive.
    """
    defstruct [
      :name,
      :host_path,
      :contents,
      :assert_size_lte,
      :assert_size_gte,
      :skip_holes,
      :__spark_metadata__
    ]
  end

  defmodule Partition do
    @moduledoc """
    Defines a partition within an MBR or GPT.
    """
    defstruct [
      :number,
      :block_offset,
      :block_count,
      :type,
      :guid,
      :name,
      :flags,
      :boot,
      :expand,
      :__spark_metadata__
    ]
  end

  defmodule Osii do
    @moduledoc """
    Defines an OSII (OS Image and Information) record for Intel Edison OSIP support.
    """
    defstruct [
      :number,
      :os_major,
      :os_minor,
      :start_block_offset,
      :ddr_load_address,
      :entry_point,
      :image_size_blocks,
      :attribute,
      :__spark_metadata__
    ]
  end

  defmodule MBR do
    @moduledoc """
    Defines Master Boot Record contents.
    """
    defstruct [
      :name,
      :bootstrap_code_host_path,
      :signature,
      :include_osip,
      :osip_major,
      :osip_minor,
      :osip_num_pointers,
      :__spark_metadata__
    ]
  end

  defmodule GPT do
    @moduledoc """
    Defines GUID Partition Table contents.
    """
    defstruct [
      :name,
      :guid,
      :__spark_metadata__
    ]
  end

  defmodule UbootEnvironment do
    @moduledoc """
    Defines U-Boot environment block configuration.
    """
    defstruct [
      :name,
      :block_offset,
      :block_count,
      :block_offset_redund,
      :__spark_metadata__
    ]
  end

  defmodule ErrorAction do
    @moduledoc """
    Immediately fail a firmware update with an error.
    """
    defstruct [:name, :message, :__spark_metadata__]
  end

  defmodule ExecuteAction do
    @moduledoc """
    Execute a command on the host. Requires the --unsafe flag.
    """
    defstruct [:name, :command, :__spark_metadata__]
  end

  defmodule InfoAction do
    @moduledoc """
    Print out an informational message.
    """
    defstruct [:name, :message, :__spark_metadata__]
  end

  defmodule FatAttribAction do
    @moduledoc """
    Modify a file's attributes on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :filename, :attrib, :__spark_metadata__]
  end

  defmodule FatCpAction do
    @moduledoc """
    Copy a file on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :from, :to, :from_offset, :to_offset, :__spark_metadata__]
  end

  defmodule FatMkdirAction do
    @moduledoc """
    Create a directory on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :filename, :__spark_metadata__]
  end

  defmodule FatMkfsAction do
    @moduledoc """
    Create a FAT filesystem at the specified block offset and count.
    """
    defstruct [:name, :block_offset, :block_count, :__spark_metadata__]
  end

  defmodule FatMvAction do
    @moduledoc """
    Rename a file on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :oldname, :newname, :force, :__spark_metadata__]
  end

  defmodule FatRmAction do
    @moduledoc """
    Delete the specified file on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :filename, :__spark_metadata__]
  end

  defmodule FatSetlabelAction do
    @moduledoc """
    Set the volume label on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :label, :__spark_metadata__]
  end

  defmodule FatTouchAction do
    @moduledoc """
    Create an empty file if it doesn't exist on a FAT filesystem.
    """
    defstruct [:name, :block_offset, :filename, :__spark_metadata__]
  end

  defmodule FatWriteAction do
    @moduledoc """
    Write a resource to a FAT filesystem.
    """
    defstruct [:name, :block_offset, :filename, :__spark_metadata__]
  end

  defmodule GptWriteAction do
    @moduledoc """
    Write the specified GPT to the target.
    """
    defstruct [:name, :gpt, :__spark_metadata__]
  end

  defmodule MbrWriteAction do
    @moduledoc """
    Write the specified MBR to the target.
    """
    defstruct [:name, :mbr, :__spark_metadata__]
  end

  defmodule PathWriteAction do
    @moduledoc """
    Write a resource to a path on the host. Requires the --unsafe flag.
    """
    defstruct [:name, :destination_path, :__spark_metadata__]
  end

  defmodule PipeWriteAction do
    @moduledoc """
    Pipe a resource through a command on the host. Requires the --unsafe flag.
    """
    defstruct [:name, :command, :__spark_metadata__]
  end

  defmodule RawMemsetAction do
    @moduledoc """
    Write the specified byte value repeatedly for the specified blocks.
    """
    defstruct [:name, :block_offset, :block_count, :value, :__spark_metadata__]
  end

  defmodule RawWriteAction do
    @moduledoc """
    Write the resource to the specified block offset.
    """
    defstruct [
      :name,
      :block_offset,
      :cipher,
      :secret,
      :delta_source_raw_offset,
      :delta_source_raw_count,
      :delta_source_raw_options,
      :delta_source_fat_offset,
      :delta_source_fat_path,
      :__spark_metadata__
    ]
  end

  defmodule RebootParamAction do
    @moduledoc """
    Set reboot parameters that will be enqueued to the reboot command if supported.
    """
    defstruct [:name, :args, :__spark_metadata__]
  end

  defmodule TrimAction do
    @moduledoc """
    Discard any data previously written to the range. TRIM requests are issued if --enable-trim is passed.
    """
    defstruct [:name, :block_offset, :count, :__spark_metadata__]
  end

  defmodule UbootClearenvAction do
    @moduledoc """
    Initialize a clean, variable-free U-Boot environment.
    """
    defstruct [:name, :uboot_env, :__spark_metadata__]
  end

  defmodule UbootRecoverAction do
    @moduledoc """
    If the U-Boot environment is corrupt, reinitialize it. If not, do nothing.
    """
    defstruct [:name, :uboot_env, :__spark_metadata__]
  end

  defmodule UbootSetenvAction do
    @moduledoc """
    Set the specified U-Boot variable.
    """
    defstruct [:name, :uboot_env, :variable_name, :value, :__spark_metadata__]
  end

  defmodule UbootUnsetenvAction do
    @moduledoc """
    Unset the specified U-Boot variable.
    """
    defstruct [:name, :uboot_env, :variable_name, :__spark_metadata__]
  end

  defmodule On do
    @moduledoc """
    Defines an event handler within a task.
    """
    defstruct [
      :event,
      :name,
      :resource_name,
      :__spark_metadata__
    ]
  end

  defmodule RequireConstraint do
    @moduledoc """
    Defines a requirement constraint for a task.
    """
    defstruct [
      :name,
      :type,
      :args,
      :__spark_metadata__
    ]
  end

  defmodule Task do
    @moduledoc """
    Defines a firmware update task.
    """
    defstruct [
      :name,
      :__spark_metadata__
    ]
  end

  # Entity definitions for Spark
  @file_resource %Spark.Dsl.Entity{
    name: :file_resource,
    args: [:name],
    target: FileResource,
    describe: "Defines a file resource to be included in the firmware archive",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the file resource"
      ],
      host_path: [
        type: :string,
        doc: "Path to the file on the host system. Can be semicolon-separated for concatenation."
      ],
      contents: [
        type: :string,
        doc: "String contents to create the file from instead of reading from host_path"
      ],
      assert_size_lte: [
        type: :integer,
        doc: "Assert that file size is less than or equal to this value (in 512-byte blocks)"
      ],
      assert_size_gte: [
        type: :integer,
        doc: "Assert that file size is greater than or equal to this value (in 512-byte blocks)"
      ],
      skip_holes: [
        type: :boolean,
        default: false,
        doc: "Skip holes in sparse files to reduce write operations"
      ]
    ]
  }

  @partition %Spark.Dsl.Entity{
    name: :partition,
    args: [:number],
    target: Partition,
    describe: "Defines a partition",
    schema: [
      number: [
        type: :integer,
        required: true,
        doc: "Partition number (0-based for MBR, 0-127 for GPT)"
      ],
      block_offset: [
        type: :integer,
        doc: "Starting block offset (512-byte blocks)"
      ],
      block_count: [
        type: :integer,
        doc: "Number of blocks in the partition"
      ],
      type: [
        type: {:or, [:integer, :string]},
        doc: "Partition type (integer for MBR, UUID string for GPT)"
      ],
      guid: [
        type: :string,
        doc: "GUID for GPT partition"
      ],
      name: [
        type: :string,
        doc: "Partition name (GPT only)"
      ],
      flags: [
        type: :integer,
        doc: "Partition flags/attributes"
      ],
      boot: [
        type: :boolean,
        default: false,
        doc: "Mark partition as bootable"
      ],
      expand: [
        type: :boolean,
        default: false,
        doc: "Expand partition to fill remaining space (final partition only)"
      ]
    ]
  }

  @osii %Spark.Dsl.Entity{
    name: :osii,
    args: [:number],
    target: Osii,
    describe: "Defines an OSII record for Intel Edison OSIP support",
    schema: [
      number: [
        type: :integer,
        required: true,
        doc: "OSII record number"
      ],
      os_major: [
        type: :integer,
        doc: "OS major version"
      ],
      os_minor: [
        type: :integer,
        doc: "OS minor version"
      ],
      start_block_offset: [
        type: :integer,
        doc: "Starting block offset for the image"
      ],
      ddr_load_address: [
        type: :integer,
        doc: "DDR load address"
      ],
      entry_point: [
        type: :integer,
        doc: "Entry point address"
      ],
      image_size_blocks: [
        type: :integer,
        doc: "Image size in blocks"
      ],
      attribute: [
        type: :integer,
        doc: "Image attributes"
      ]
    ]
  }

  @mbr %Spark.Dsl.Entity{
    name: :mbr,
    args: [:name],
    target: MBR,
    describe: "Defines Master Boot Record contents",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the MBR"
      ],
      bootstrap_code_host_path: [
        type: :string,
        doc: "Path to bootstrap code (should be 440 bytes)"
      ],
      signature: [
        type: :integer,
        doc: "MBR signature (4 bytes)"
      ],
      include_osip: [
        type: :boolean,
        default: false,
        doc: "Include OSIP header for Intel Edison"
      ],
      osip_major: [
        type: :integer,
        doc: "OSIP major version"
      ],
      osip_minor: [
        type: :integer,
        doc: "OSIP minor version"
      ],
      osip_num_pointers: [
        type: :integer,
        doc: "Number of OSIP pointers"
      ]
    ]
  }

  @gpt %Spark.Dsl.Entity{
    name: :gpt,
    args: [:name],
    target: GPT,
    describe: "Defines GUID Partition Table contents",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the GPT"
      ],
      guid: [
        type: :string,
        doc: "GUID for the entire disk"
      ]
    ]
  }

  @uboot_environment %Spark.Dsl.Entity{
    name: :uboot_environment,
    args: [:name],
    target: UbootEnvironment,
    describe: "Defines U-Boot environment block configuration",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the U-Boot environment"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Starting block offset for the environment"
      ],
      block_count: [
        type: :integer,
        required: true,
        doc: "Number of blocks for the environment"
      ],
      block_offset_redund: [
        type: :integer,
        doc: "Starting block offset for redundant environment copy"
      ]
    ]
  }

  @error_action %Spark.Dsl.Entity{
    name: :error,
    args: [:name],
    target: ErrorAction,
    describe: "Immediately fail a firmware update with an error",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      message: [
        type: :string,
        required: true,
        doc: "Error message to display"
      ]
    ]
  }

  @execute_action %Spark.Dsl.Entity{
    name: :execute,
    args: [:name],
    target: ExecuteAction,
    describe: "Execute a command on the host. Requires the --unsafe flag",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      command: [
        type: :string,
        required: true,
        doc: "Command to execute"
      ]
    ]
  }

  @info_action %Spark.Dsl.Entity{
    name: :info,
    args: [:name],
    target: InfoAction,
    describe: "Print out an informational message",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      message: [
        type: :string,
        required: true,
        doc: "Message to display"
      ]
    ]
  }

  @fat_attrib_action %Spark.Dsl.Entity{
    name: :fat_attrib,
    args: [:name],
    target: FatAttribAction,
    describe: "Modify a file's attributes on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      filename: [
        type: :string,
        required: true,
        doc: "Name of the file to modify"
      ],
      attrib: [
        type: :string,
        required: true,
        doc: "Attributes to set (e.g., 'RHS' where R=readonly, H=hidden, S=system)"
      ]
    ]
  }

  @fat_cp_action %Spark.Dsl.Entity{
    name: :fat_cp,
    args: [:name],
    target: FatCpAction,
    describe: "Copy a file on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        doc: "Block offset of the source FAT filesystem"
      ],
      from: [
        type: :string,
        required: true,
        doc: "Source file path"
      ],
      to: [
        type: :string,
        required: true,
        doc: "Destination file path"
      ],
      from_offset: [
        type: :integer,
        doc: "Block offset of the source FAT filesystem (for cross-partition copy)"
      ],
      to_offset: [
        type: :integer,
        doc: "Block offset of the destination FAT filesystem (for cross-partition copy)"
      ]
    ]
  }

  @fat_mkdir_action %Spark.Dsl.Entity{
    name: :fat_mkdir,
    args: [:name],
    target: FatMkdirAction,
    describe: "Create a directory on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      filename: [
        type: :string,
        required: true,
        doc: "Directory name to create"
      ]
    ]
  }

  @fat_mkfs_action %Spark.Dsl.Entity{
    name: :fat_mkfs,
    args: [:name],
    target: FatMkfsAction,
    describe: "Create a FAT filesystem at the specified block offset and count",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Starting block offset for the filesystem"
      ],
      block_count: [
        type: :integer,
        required: true,
        doc: "Number of blocks for the filesystem"
      ]
    ]
  }

  @fat_mv_action %Spark.Dsl.Entity{
    name: :fat_mv,
    args: [:name],
    target: FatMvAction,
    describe: "Rename a file on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      oldname: [
        type: :string,
        required: true,
        doc: "Current file name"
      ],
      newname: [
        type: :string,
        required: true,
        doc: "New file name"
      ],
      force: [
        type: :boolean,
        default: false,
        doc: "Force rename even if newname already exists"
      ]
    ]
  }

  @fat_rm_action %Spark.Dsl.Entity{
    name: :fat_rm,
    args: [:name],
    target: FatRmAction,
    describe: "Delete the specified file on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      filename: [
        type: :string,
        required: true,
        doc: "Name of the file to delete"
      ]
    ]
  }

  @fat_setlabel_action %Spark.Dsl.Entity{
    name: :fat_setlabel,
    args: [:name],
    target: FatSetlabelAction,
    describe: "Set the volume label on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      label: [
        type: :string,
        required: true,
        doc: "Volume label to set"
      ]
    ]
  }

  @fat_touch_action %Spark.Dsl.Entity{
    name: :fat_touch,
    args: [:name],
    target: FatTouchAction,
    describe: "Create an empty file if it doesn't exist on a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      filename: [
        type: :string,
        required: true,
        doc: "Name of the file to create"
      ]
    ]
  }

  @fat_write_action %Spark.Dsl.Entity{
    name: :fat_write,
    args: [:name],
    target: FatWriteAction,
    describe: "Write a resource to a FAT filesystem",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset of the FAT filesystem"
      ],
      filename: [
        type: :string,
        doc: "Filename to write (defaults to resource name if not specified)"
      ]
    ]
  }

  @gpt_write_action %Spark.Dsl.Entity{
    name: :gpt_write,
    args: [:name],
    target: GptWriteAction,
    describe: "Write the specified GPT to the target",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      gpt: [
        type: :atom,
        required: true,
        doc: "Name of the GPT configuration to write"
      ]
    ]
  }

  @mbr_write_action %Spark.Dsl.Entity{
    name: :mbr_write,
    args: [:name],
    target: MbrWriteAction,
    describe: "Write the specified MBR to the target",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      mbr: [
        type: :atom,
        required: true,
        doc: "Name of the MBR configuration to write"
      ]
    ]
  }

  @path_write_action %Spark.Dsl.Entity{
    name: :path_write,
    args: [:name],
    target: PathWriteAction,
    describe: "Write a resource to a path on the host. Requires the --unsafe flag",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      destination_path: [
        type: :string,
        required: true,
        doc: "Path on the host to write the resource to"
      ]
    ]
  }

  @pipe_write_action %Spark.Dsl.Entity{
    name: :pipe_write,
    args: [:name],
    target: PipeWriteAction,
    describe: "Pipe a resource through a command on the host. Requires the --unsafe flag",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      command: [
        type: :string,
        required: true,
        doc: "Command to pipe the resource through"
      ]
    ]
  }

  @raw_memset_action %Spark.Dsl.Entity{
    name: :raw_memset,
    args: [:name],
    target: RawMemsetAction,
    describe: "Write the specified byte value repeatedly for the specified blocks",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Starting block offset"
      ],
      block_count: [
        type: :integer,
        required: true,
        doc: "Number of blocks to fill"
      ],
      value: [
        type: :integer,
        required: true,
        doc: "Byte value to write (0-255)"
      ]
    ]
  }

  @raw_write_action %Spark.Dsl.Entity{
    name: :raw_write,
    args: [:name],
    target: RawWriteAction,
    describe: "Write the resource to the specified block offset",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Block offset to write to"
      ],
      cipher: [
        type: :string,
        doc: "Encryption cipher (e.g., 'aes-cbc-plain')"
      ],
      secret: [
        type: :string,
        doc: "Encryption secret key (hex-encoded)"
      ],
      delta_source_raw_offset: [
        type: :integer,
        doc: "Starting block offset for delta source data"
      ],
      delta_source_raw_count: [
        type: :integer,
        doc: "Number of blocks in the delta source region"
      ],
      delta_source_raw_options: [
        type: :string,
        doc: "Source encryption options for delta updates"
      ],
      delta_source_fat_offset: [
        type: :integer,
        doc: "Starting block offset of the source FAT partition for delta updates"
      ],
      delta_source_fat_path: [
        type: :string,
        doc: "Path inside the FAT partition of the source file for delta updates"
      ]
    ]
  }

  @reboot_param_action %Spark.Dsl.Entity{
    name: :reboot_param,
    args: [:name],
    target: RebootParamAction,
    describe: "Set reboot parameters that will be enqueued to the reboot command if supported",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      args: [
        type: :string,
        required: true,
        doc: "Reboot parameter string"
      ]
    ]
  }

  @trim_action %Spark.Dsl.Entity{
    name: :trim,
    args: [:name],
    target: TrimAction,
    describe:
      "Discard any data previously written to the range. TRIM requests are issued if --enable-trim is passed",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      block_offset: [
        type: :integer,
        required: true,
        doc: "Starting block offset"
      ],
      count: [
        type: :integer,
        required: true,
        doc: "Number of blocks to trim"
      ]
    ]
  }

  @uboot_clearenv_action %Spark.Dsl.Entity{
    name: :uboot_clearenv,
    args: [:name],
    target: UbootClearenvAction,
    describe: "Initialize a clean, variable-free U-Boot environment",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      uboot_env: [
        type: :atom,
        required: true,
        doc: "Name of the U-Boot environment configuration"
      ]
    ]
  }

  @uboot_recover_action %Spark.Dsl.Entity{
    name: :uboot_recover,
    args: [:name],
    target: UbootRecoverAction,
    describe: "If the U-Boot environment is corrupt, reinitialize it. If not, do nothing",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      uboot_env: [
        type: :atom,
        required: true,
        doc: "Name of the U-Boot environment configuration"
      ]
    ]
  }

  @uboot_setenv_action %Spark.Dsl.Entity{
    name: :uboot_setenv,
    args: [:name],
    target: UbootSetenvAction,
    describe: "Set the specified U-Boot variable",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      uboot_env: [
        type: :atom,
        required: true,
        doc: "Name of the U-Boot environment configuration"
      ],
      variable_name: [
        type: :string,
        required: true,
        doc: "Name of the U-Boot variable to set"
      ],
      value: [
        type: :string,
        required: true,
        doc: "Value to set the variable to"
      ]
    ]
  }

  @uboot_unsetenv_action %Spark.Dsl.Entity{
    name: :uboot_unsetenv,
    args: [:name],
    target: UbootUnsetenvAction,
    describe: "Unset the specified U-Boot variable",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      uboot_env: [
        type: :atom,
        required: true,
        doc: "Name of the U-Boot environment configuration"
      ],
      variable_name: [
        type: :string,
        required: true,
        doc: "Name of the U-Boot variable to unset"
      ]
    ]
  }

  @require_constraint %Spark.Dsl.Entity{
    name: :require_constraint,
    args: [:name, :type],
    target: RequireConstraint,
    describe: "Defines a requirement constraint for a task",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the constraint"
      ],
      type: [
        type:
          {:one_of,
           [
             :fat_file_exists,
             :fat_file_match,
             :partition_offset,
             :path_on_device,
             :path_at_offset,
             :uboot_variable
           ]},
        required: true,
        doc: "Type of requirement constraint"
      ],
      args: [
        type: {:list, :any},
        required: true,
        doc: "Arguments for the constraint"
      ]
    ]
  }

  @on %Spark.Dsl.Entity{
    name: :on,
    args: [:event, :name],
    target: On,
    describe: "Defines an event handler within a task",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the event handler"
      ],
      event: [
        type: {:one_of, [:init, :finish, :error, :resource]},
        required: true,
        doc: "Event type to handle"
      ],
      resource_name: [
        type: :atom,
        doc: "Resource name for on-resource events"
      ]
    ]
  }

  @task %Spark.Dsl.Entity{
    name: :task,
    args: [:name],
    target: Task,
    describe: "Defines a firmware update task",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the task"
      ]
    ]
  }

  # Section definitions
  @global %Spark.Dsl.Section{
    name: :global,
    describe: "Global configuration options",
    schema: [
      require_fwup_version: [
        type: :string,
        doc: "Minimum required fwup version"
      ],
      meta_product: [
        type: :string,
        doc: "Product name"
      ],
      meta_description: [
        type: :string,
        doc: "Description of product or firmware update"
      ],
      meta_version: [
        type: :string,
        doc: "Firmware version"
      ],
      meta_author: [
        type: :string,
        doc: "Author or company behind the update"
      ],
      meta_platform: [
        type: :string,
        doc: "Platform that this update runs on (e.g., rpi or bbb)"
      ],
      meta_architecture: [
        type: :string,
        doc: "Platform architecture (e.g., arm)"
      ],
      meta_vcs_identifier: [
        type: :string,
        doc: "Version control identifier for reproducing this image"
      ],
      meta_misc: [
        type: :string,
        doc: "Miscellaneous additional data"
      ],
      meta_creation_date: [
        type: :string,
        doc: "Timestamp when the update was created"
      ],
      meta_uuid: [
        type: :string,
        doc: "UUID to represent this firmware"
      ]
    ]
  }

  @file_resources %Spark.Dsl.Section{
    name: :file_resources,
    describe: "File resources to include in the firmware archive",
    entities: [@file_resource]
  }

  @partitions %Spark.Dsl.Section{
    name: :partitions,
    describe: "Partition definitions",
    entities: [@partition]
  }

  @osii_records %Spark.Dsl.Section{
    name: :osii_records,
    describe: "OSII record definitions for Intel Edison OSIP support",
    entities: [@osii]
  }

  @mbrs %Spark.Dsl.Section{
    name: :mbrs,
    describe: "Master Boot Record definitions",
    entities: [@mbr]
  }

  @gpts %Spark.Dsl.Section{
    name: :gpts,
    describe: "GUID Partition Table definitions",
    entities: [@gpt]
  }

  @uboot_environments %Spark.Dsl.Section{
    name: :uboot_environments,
    describe: "U-Boot environment configurations",
    entities: [@uboot_environment]
  }

  @actions %Spark.Dsl.Section{
    name: :actions,
    describe: "Action definitions",
    entities: [
      @error_action,
      @execute_action,
      @info_action,
      @fat_attrib_action,
      @fat_cp_action,
      @fat_mkdir_action,
      @fat_mkfs_action,
      @fat_mv_action,
      @fat_rm_action,
      @fat_setlabel_action,
      @fat_touch_action,
      @fat_write_action,
      @gpt_write_action,
      @mbr_write_action,
      @path_write_action,
      @pipe_write_action,
      @raw_memset_action,
      @raw_write_action,
      @reboot_param_action,
      @trim_action,
      @uboot_clearenv_action,
      @uboot_recover_action,
      @uboot_setenv_action,
      @uboot_unsetenv_action
    ]
  }

  @require_constraints %Spark.Dsl.Section{
    name: :require_constraints,
    describe: "Requirement constraint definitions",
    entities: [@require_constraint]
  }

  @event_handlers %Spark.Dsl.Section{
    name: :event_handlers,
    describe: "Event handler definitions",
    entities: [@on]
  }

  @tasks %Spark.Dsl.Section{
    name: :tasks,
    describe: "Firmware update tasks",
    entities: [@task]
  }

  # Main DSL Extension
  use Spark.Dsl.Extension,
    sections: [
      @global,
      @file_resources,
      @partitions,
      @osii_records,
      @mbrs,
      @gpts,
      @uboot_environments,
      @actions,
      @require_constraints,
      @event_handlers,
      @tasks
    ]
end
