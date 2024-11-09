import cors_builder as cors
import gleam/erlang/os
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

  let assert Ok(secret_key_base) = os.get_env("SECRET_KEY_BASE")
  let assert Ok(url) = os.get_env("DATABASE_URL")
  let assert Ok(config) = pgo.url_config(url)
  let db = pgo.connect(config)

  wisp.configure_logger()
  // let secret_key_base = wisp.random_string(64)

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
