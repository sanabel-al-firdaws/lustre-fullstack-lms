import cors_builder as cors
import gleam/http.{Post}

import gleam/list
import gleam/result

import wisp.{type Request, type Response}

pub type Login {
  Login(username: String, password: String)
}

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_method(http.Post)
}

pub fn handle_request(req: Request) -> Response {
  use req <- cors.wisp_middleware(req, cors())

  // For GET requests, show the form,
  // for POST requests we use the data from the form
  case req.method {
    // Get -> show_form()
    Post -> handle_form_submission(req)
    _ -> wisp.method_not_allowed(allowed: [Post])
  }
}

pub fn handle_form_submission(req: Request) -> Response {
  use formdata <- wisp.require_form(req)

  let result = {
    use email <- result.try(list.key_find(formdata.values, "email"))
    use password <- result.try(list.key_find(formdata.values, "password"))
    case email {
      "admin@gmail.com" ->
        case password {
          "admin" -> Ok("admin")

          _ -> Ok("")
        }
      "student@gmail.com" ->
        case password {
          "student" -> Ok("student")
          _ -> Ok("")
        }
      _ -> Ok("")
    }
  }

  case result {
    Ok(content) -> {
      case content {
        "admin" -> {
          wisp.ok() |> wisp.string_body(content)
        }
        "student" -> {
          wisp.ok() |> wisp.string_body(content)
        }
        _ -> {
          wisp.no_content() |> wisp.string_body("none")
        }
      }
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}
