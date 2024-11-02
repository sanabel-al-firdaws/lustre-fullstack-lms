import cors_builder as cors
import gleam/erlang/process
import gleam/http
import mist
import server/router
import wisp
import wisp/wisp_mist

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_method(http.Post)
}

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
