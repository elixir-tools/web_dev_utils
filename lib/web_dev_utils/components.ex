defmodule WebDevUtils.Components do
  @moduledoc """
  Builtin components.
  """
  require EEx

  @doc """
  A component for triggering live reloading via a websocket.

  The url for the websocket connectino is controlled by the `:reload_url` applicaiton config key.

  ## Example

  ```elixir
  # config/config.exs

  config :web_dev_utils, :reload_url, "wss://sometunnelingdomain/ws"
  ```
  """
  EEx.function_from_string(
    :def,
    :live_reload,
    ~s'''
    <script>
      function log(message) {
        if (<%= inspect(Application.get_env(:web_dev_utils, :reload_log, false)) %>) {
          console.log(`[web_dev_utils] ${message}`)
        }
      }
      function connect() {
        try {
          window.socket = new WebSocket(<%= Application.get_env(:web_dev_utils, :reload_url, "'ws://' + location.host + '/ws'") %>);

          window.socket.onmessage = function(e) {
            if (e.data === "reload") {
              log("reloading!");
              location.reload();
            } else if (e.data === "subscribed") {
              log("connected and subscribed!");
            }
          }

          window.socket.onopen = () => {
            waitForConnection(() => {
              log("sending 'subscribe' message");
              window.socket.send("subscribe")
            }
            , 300);
          };

          window.socket.onclose = () => {
            setTimeout(() => connect(), 500);
          };

          function waitForConnection(callback, interval) {
            log("waiting for connection!")
            if (window.socket.readyState === 1) {
              callback();
            } else {
              log("setting a timeout")
              setTimeout(() => waitForConnection(callback, interval), interval);
            }
          }
        } catch (e) {
          log(e);
          setTimeout(() => connect(), 500);
        }
      }

      log("about to connect");
      connect();
    </script>
    ''',
    [:_]
  )
end
