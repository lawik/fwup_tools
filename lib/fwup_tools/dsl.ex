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

  defmodule Action do
    @moduledoc """
    Defines an action within a task event handler.
    """
    defstruct [
      :name,
      :type,
      :args,
      :options,
      :__spark_metadata__
    ]
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

  @action %Spark.Dsl.Entity{
    name: :action,
    args: [:name, :type],
    target: Action,
    describe: "Defines an action within a task event handler",
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "Unique name for the action"
      ],
      type: [
        type:
          {:one_of,
           [
             :error,
             :execute,
             :info,
             :fat_attrib,
             :fat_cp,
             :fat_mkdir,
             :fat_mkfs,
             :fat_mv,
             :fat_mv!,
             :fat_rm,
             :fat_setlabel,
             :fat_touch,
             :fat_write,
             :gpt_write,
             :mbr_write,
             :path_write,
             :pipe_write,
             :raw_memset,
             :raw_write,
             :reboot_param,
             :trim,
             :uboot_clearenv,
             :uboot_recover,
             :uboot_setenv,
             :uboot_unsetenv
           ]},
        required: true,
        doc: "Type of action to perform"
      ],
      args: [
        type: {:list, :any},
        default: [],
        doc: "Arguments for the action"
      ],
      options: [
        type: :keyword_list,
        default: [],
        doc: "Options for the action"
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

  @event_handler %Spark.Dsl.Entity{
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
    entities: [@action]
  }

  @require_constraints %Spark.Dsl.Section{
    name: :require_constraints,
    describe: "Requirement constraint definitions",
    entities: [@require_constraint]
  }

  @event_handlers %Spark.Dsl.Section{
    name: :event_handlers,
    describe: "Event handler definitions",
    entities: [@event_handler]
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
