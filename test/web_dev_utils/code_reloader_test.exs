defmodule WebDevUtils.CodeReloaderTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias WebDevUtils.CodeReloader

  setup do
    on_exit(fn ->
      File.rm("test/support/editable.ex")
    end)

    :ok
  end

  test "noops when nothing has changed" do
    start_supervised!(CodeReloader)

    assert {_, []} = CodeReloader.reload()
    assert {:noop, []} == CodeReloader.reload()
  end

  test "recompiles code" do
    File.write!("test/support/editable.ex", """
    defmodule Editable do
    end
    """)

    start_supervised!(CodeReloader)

    capture_io(:stderr, fn ->
      assert {:ok, []} == CodeReloader.reload()
    end)
  end

  test "recompiles code and something fails" do
    File.write!("test/support/editable.ex", """
    defmodule Editable d
    end
    """)

    start_supervised!(CodeReloader)

    capture_io(:stderr, fn ->
      assert {:error, [%Mix.Task.Compiler.Diagnostic{}]} = CodeReloader.reload()
    end)
  end
end
