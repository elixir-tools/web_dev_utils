defmodule WebDevUtils.FileSystem do
  @moduledoc """
  The file watcher process.
  """
  def child_spec(_) do
    %{
      id: FileSystem,
      start:
        {FileSystem, :start_link, [[dirs: [Path.absname("")], name: :web_dev_utils_file_watcher]]}
    }
  end
end
