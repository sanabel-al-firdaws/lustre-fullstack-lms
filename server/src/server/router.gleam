import cors_builder as cors
import gleam/http.{Get, Post}

import gleam/list
import gleam/result
import gleam/string_builder

import wisp.{type Request, type Response}

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
    Get -> show_form()
    Post -> handle_form_submission(req)
    _ -> wisp.method_not_allowed(allowed: [Get, Post])
  }
}

pub fn show_form() -> Response {
  // In a larger application a template library or HTML form library might
  // be used here instead of a string literal.
  let html =
    string_builder.from_string(
      "<form method='post'>
        <label>email:
          <input type='text' password='email'>
        </label>
        <label>password:
          <input type='text' password='password'>
        </label>
        <input type='submit' value='Submit'>
      </form>",
    )
  wisp.ok()
  |> wisp.html_body(html)
}

pub fn handle_form_submission(req: Request) -> Response {
  // This middleware parses a `wisp.FormData` from the request body.
  // It returns an error response if the body is not valid form data, or
  // if the content-type is not `application/x-www-form-urlencoded` or
  // `multipart/form-data`, or if the body is too large.
  use formdata <- wisp.require_form(req)

  // The list and result module are used here to extract the values from the
  // form data.
  // Alternatively you could also pattern match on the list of values (they are
  // sorted into alphabetical order), or use a HTML form library.
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

  // An appropriate response is returned depending on whether the form data
  // could be successfully handled or not.
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
      //   |> wisp.html_body(string_builder.from_string( int.to_string(content)))
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}
