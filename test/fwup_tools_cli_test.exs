defmodule FwupToolsCliTest do
  use ExUnit.Case, async: true

  @raw File.read!("test/fixtures/config/raw.conf")
  @raw_dsl FwupTools.Test.Fixtures.DSL.Raw

  @pairs [
    {@raw, @raw_dsl}
  ]

  setup_all do
    with path_1 when is_binary(path_1) <- System.find_executable("mdir"),
         path_2 when is_binary(path_2) <- System.find_executable("mcopy") do
      :ok
    else
      _ ->
        flunk("Please install mtools to run these tests.")
    end
  end

  describe "firmware archive" do
    defp offsets(start, parts_with_sizes) do
      {offsets, _} =
        parts_with_sizes
        |> Enum.reduce({[], start}, fn {field, size}, {fields, offset} ->
          fields = [{field, {offset, size}} | fields]
          {fields, offset + size}
        end)

      Enum.reverse(offsets)
    end

    defp build_fw!(path, fwup_path, data_path) do
      case System.cmd("fwup", ["-c", "-f", fwup_path, "-o", path],
             stderr_to_stdout: true,
             env: [
               {"TEST_1", data_path}
             ]
           ) do
        {_, 0} ->
          path

        {output, status} ->
          flunk("Error in fwup with status #{status}:\n#{output}")
      end
    end

    defp complete!(fw_path, image_path) do
      case System.cmd("fwup", ["-a", "-d", image_path, "-i", fw_path, "-t", "complete"],
             stderr_to_stdout: true,
             env: []
           ) do
        {_, 0} ->
          image_path

        {output, status} ->
          flunk("Error in fwup with status #{status}:\n#{output}")
      end
    end

    defp upgrade!(fw_path, image_path) do
      case System.cmd("fwup", ["-a", "-d", image_path, "-i", fw_path, "-t", "upgrade"],
             stderr_to_stdout: true,
             env: []
           ) do
        {_, 0} ->
          image_path

        {output, status} ->
          flunk("Error in fwup with status #{status}:\n#{output}")
      end
    end

    defp sha256sum(path) do
      data = File.read!(path)
      :sha256 |> :crypto.hash(data) |> Base.encode64()
    end

    defp mcopy(img_path, offset, files, to_dir) do
      File.mkdir_p(to_dir)

      file_args =
        files
        |> Enum.map(fn file ->
          "::#{file}"
        end)

      args = ["-i", "#{img_path}@@#{offset * 512}"] ++ file_args ++ [to_dir]
      {_output, 0} = System.cmd("mdir", ["-i", "#{img_path}@@#{offset * 512}"], env: [])

      {_, 0} =
        System.cmd("mcopy", args, env: [])
    end

    defp same_fat_files?(base_dir, {img_a, offset_a}, {img_b, offset_b}, files) do
      path_a = Path.join(base_dir, "fat_a")
      path_b = Path.join(base_dir, "fat_b")
      mcopy(img_a, offset_a, files, path_a)
      mcopy(img_b, offset_b, files, path_b)

      for file <- files do
        a = File.read!(Path.join(path_a, file))
        b = File.read!(Path.join(path_b, file))
        assert a == b
      end
    end

    defp compare_images?({img_a, offset_a, size_a}, {img_b, offset_b, size_b}) do
      # fwup uses 512 byte blocks
      offset_a = offset_a * 512
      size_a = size_a * 512
      offset_b = offset_b * 512
      size_b = size_b * 512
      data_a = File.read!(img_a)
      data_b = File.read!(img_b)
      <<_::binary-size(offset_a), d1::binary-size(size_a), _::binary>> = data_a
      <<_::binary-size(offset_b), d2::binary-size(size_b), _::binary>> = data_b
      compare_data?(d1, d2, 0, true)
    end

    defp compare_data?(
           <<chunk_1::binary-size(512), d1::binary>>,
           <<chunk_2::binary-size(512), d2::binary>>,
           offset,
           valid?
         ) do
      valid? =
        if chunk_1 != chunk_2 do
          IO.puts("Difference at offset: #{offset} (#{trunc(offset / 512)})")
          find_diff(chunk_1, chunk_2)
          false
        else
          valid?
        end

      compare_data?(d1, d2, offset + 512, valid?)
    end

    defp compare_data?(<<chunk_1::binary>>, <<chunk_2::binary>>, offset, valid?) do
      if chunk_1 != chunk_2 do
        IO.puts("Difference at final offset: #{offset} (#{trunc(offset / 512)})")
        find_diff(chunk_1, chunk_2)
        false
      else
        valid?
      end
    end

    defp find_diff(chunk_1, chunk_2, byte \\ 0) do
      case {chunk_1, chunk_2} do
        {<<b1::8, r1::binary>>, <<b2::8, r2::binary>>} when b1 == b2 ->
          find_diff(r1, r2, byte + 1)

        {<<b1::8, r1::binary>>, <<b2::8, r2::binary>>} when b1 != b2 ->
          IO.puts("#{byte} @\t\t#{h(b1)}  #{h(b2)}")
          find_diff(r1, r2, byte + 1)

        {<<>>, <<>>} ->
          :ok
      end
    end

    defp h(b), do: inspect(b, as: :binary, base: :hex)

    @tag :tmp_dir
    test "generate valid image", %{tmp_dir: dir} do
      Enum.each(@pairs, fn {conf, dsl} ->
        content_1 = random_bytes(36)
        content_2 = random_bytes(36)

        [a, b] =
          [conf, FwupTools.to_fwup_conf(dsl)]
          |> Enum.map(fn conf ->
            fwup_conf_path = Path.join(dir, "fwup.conf")
            File.write!(fwup_conf_path, conf)

            data_path_1 = Path.join(dir, "data-1")
            data_1 = for _ <- 1..100, into: <<>>, do: content_1
            File.write!(data_path_1, data_1)
            data_path_2 = Path.join(dir, "data-1")
            data_2 = for _ <- 1..100, into: <<>>, do: content_2
            File.write!(data_path_2, data_2)

            fw_a = build_fw!(Path.join(dir, "a.fw"), fwup_conf_path, data_path_1)
            fw_b = build_fw!(Path.join(dir, "b.fw"), fwup_conf_path, data_path_2)
            %{size: source_size} = File.stat!(fw_a)
            %{size: target_size} = File.stat!(fw_b)

            img_a = complete!(fw_a, Path.join(dir, "a.img"))
            hash_a = sha256sum(img_a)

            upgrade!(fw_b, img_a)
            hash_b = sha256sum(img_a)
            %{source_size: source_size, target_size: target_size, hash_a: hash_a, hash_b: hash_b}
          end)

        assert a.source_size == b.source_size
        assert a.target_size == b.target_size
        assert a.hash_a == b.hash_b
      end)
    end
  end

  defp random_bytes(size) do
    :rand.bytes(size)
  end
end
