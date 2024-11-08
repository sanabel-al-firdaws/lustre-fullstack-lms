import cors_builder as cors
import gleam/erlang/process
import gleam/http
import gleam/io
import gleam/option.{Some}
import gleam/pgo
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
  // Start a database connection pool.
  // Typically you will want to create one pool for use in your program
  let _db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        password: Some("postgres"),
        pool_size: 15,
      ),
    )

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let server =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  case server {
    Ok(_) -> process.sleep_forever()
    Error(err) -> {
      io.debug(err)
      Nil
    }
  }
}
