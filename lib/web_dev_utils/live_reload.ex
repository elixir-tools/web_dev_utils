defmodule WebDevUtils.LiveReload do
  @moduledoc """
  Notifications (usually sent to a web browser) when files on disk change.
  """
  require Logger

  def init(opts \\ []) do
    name = Keyword.get(opts, :name, :web_dev_utils_file_watcher)

    FileSystem.subscribe(name)
  end

  def reload!({:file_event, _watcher_pid, {path, _event}}, opts \\ []) do
    patterns = Keyword.get(opts, :patterns, [])
    debounce = Keyword.get(opts, :debounce, 100)

    Process.sleep(debounce)

    paths = flush([Path.relative_to_cwd(to_string(path))])

    path = Enum.find(paths, fn path -> Enum.any?(patterns, &String.match?(path, &1)) end)

    if path do
      Logger.debug("Live reload: #{Path.relative_to_cwd(path)}")

      send(self(), :reload)
    end
  end

  defp flush(acc) do
    receive do
      {:file_event, _, {path, _event}} ->
        flush([Path.relative_to_cwd(to_string(path)) | acc])
    after
      0 -> acc
    end
  end
end
