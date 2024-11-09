import config.{type Lang}
import gleam/http
import gleam/http/request
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event
import lustre_http.{type HttpError}

pub type Route {
  Admin
  Student
  Login
}

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(
    route: Route,
    email: String,
    password: String,
    input_color: String,
    lang: Lang,
  )
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(
    Model(
      route: Login,
      email: "",
      password: "",
      input_color: "",
      lang: config.en,
    ),
    effect.none(),
  )
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ChangeLang(String)
  Sumbitted
  PasswordChanged(String)
  EmailChanged(String)
  GotLoginData(Result(String, HttpError))
}

fn login(model: Model) -> Effect(Msg) {
  lustre_http.send(
    request.to("http://localhost:8000" <> "/login")
      |> result.lazy_unwrap(fn() { request.new() })
      |> request.set_method(http.Post)
      |> request.set_header("Content-Type", "application/x-www-form-urlencoded")
      |> request.set_body(
        "email=" <> model.email <> "&password=" <> model.password,
      ),
    lustre_http.expect_text(GotLoginData),
  )
}

fn update(model: Model, msg: Msg) {
  case msg {
    Sumbitted -> #(model, login(model))

    GotLoginData(Ok(user)) ->
      case user {
        "admin" -> #(
          Model(..model, input_color: "", route: Admin),
          effect.none(),
        )
        "student" -> #(
          Model(..model, input_color: "", route: Student),
          effect.none(),
        )
        _ -> #(
          Model(..model, route: Login, input_color: "input-secondary"),
          effect.none(),
        )
      }

    GotLoginData(Error(_)) -> #(
      Model(..model, input_color: "input-secondary"),
      effect.none(),
    )

    PasswordChanged(password) -> #(
      Model(..model, password: password),
      effect.none(),
    )

    EmailChanged(email) -> #(Model(..model, email: email), effect.none())

    ChangeLang(lang) -> #(
      Model(
        ..model,
        lang: case lang {
          "ar" -> config.ar
          "en" -> config.en
          _ -> config.en
        },
      ),
      effect.none(),
    )
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  case model.route {
    Login -> {
      html.div([], [
        navbar(model),
        html.div(
          [
            attribute.class("bg-base-200"),
            attribute.style([#("direction", model.lang.direction)]),
          ],
          [
            html.div([attribute.class("hero-content flex-col")], [
              html.div([attribute.class("text-center")], [
                html.h1([attribute.class("p-10 text-center text-5xl")], [
                  html.text(model.lang.university_name),
                ]),
              ]),
              html.div(
                [
                  attribute.class(
                    "shadow-4xl card w-full max-w-lg shrink-0 border border-secondary bg-base-300",
                  ),
                ],
                [
                  html.h4([attribute.class("mt-5 text-center text-2xl")], [
                    html.text(model.lang.login_title),
                  ]),
                  html.form(
                    [
                      event.on_submit(Sumbitted),
                      attribute.method("post"),
                      attribute.class("card-body"),
                    ],
                    [
                      html.div([attribute.class("form-control")], [
                        html.label([attribute.class("label")], [
                          html.span([attribute.class("text-lg")], [
                            html.text(model.lang.email),
                          ]),
                        ]),
                        html.input([
                          attribute.required(True),
                          attribute.class(
                            "input "
                            <> model.input_color
                            <> " placeholder-gray-200",
                          ),
                          event.on_input(EmailChanged),
                          attribute.placeholder(model.lang.email_placeholder),
                          attribute.type_("email"),
                          attribute.name("email"),
                        ]),
                      ]),
                      html.div([attribute.class("form-control")], [
                        html.label([attribute.class("label")], [
                          html.span([attribute.class("text-lg")], [
                            html.text(model.lang.password),
                          ]),
                        ]),
                        html.input([
                          attribute.required(True),
                          attribute.class(
                            "input "
                            <> model.input_color
                            <> " placeholder-gray-200",
                          ),
                          attribute.placeholder(model.lang.password_placeholder),
                          event.on_input(PasswordChanged),
                          attribute.type_("password"),
                          attribute.name("password"),
                        ]),
                        html.label([attribute.class("label")], [
                          html.a(
                            [
                              attribute.class(
                                "link-hover link label-text-alt mt-2 text-base",
                              ),
                              attribute.href("#"),
                            ],
                            [html.text(model.lang.did_you_forget_password)],
                          ),
                        ]),
                      ]),
                      html.div([attribute.class("form-control mt-6")], [
                        html.button(
                          [
                            attribute.type_("submit"),
                            attribute.value("Submit"),
                            attribute.class(
                              "btn btn-outline btn-secondary text-base",
                            ),
                          ],
                          [html.text(model.lang.login)],
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ]),
          ],
        ),
      ])
    }
    Admin ->
      html.div([], [
        navbar(model),
        html.h1([], [html.text(model.lang.hi_admin)]),
      ])
    Student ->
      html.div([], [
        navbar(model),
        html.h1([], [html.text(model.lang.hi_student)]),
      ])
  }
}

fn navbar(_model: Model) {
  html.div(
    [
      attribute.class("navbar bg-base-100"),
      // attribute.style([#("direction", model.lang.direction)]),
    ],
    [
      html.div([attribute.class("flex-1")], [
        html.a([attribute.class("btn btn-ghost text-xl")], [html.text("Gleam")]),
      ]),
      html.div(
        [
          attribute.class("dropdown dropdown-end"),
          attribute.attribute("title", "Change Language"),
        ],
        [
          html.div(
            [
              attribute.attribute("aria-label", "Language"),
              attribute.class("btn btn-ghost"),
              attribute.role("button"),
              attribute.attribute("tabindex", "0"),
            ],
            [
              svg.svg(
                [
                  attribute.class("h-4 w-4"),
                  attribute.attribute("fill", "currentColor"),
                  attribute.attribute("viewBox", "0 0 16 16"),
                  attribute.attribute("xmlns", "http://www.w3.org/2000/svg"),
                ],
                [
                  svg.path([
                    attribute.attribute("clip-rule", "evenodd"),
                    attribute.attribute(
                      "d",
                      "M11 5a.75.75 0 0 1 .688.452l3.25 7.5a.75.75 0 1 1-1.376.596L12.89 12H9.109l-.67 1.548a.75.75 0 1 1-1.377-.596l3.25-7.5A.75.75 0 0 1 11 5Zm-1.24 5.5h2.48L11 7.636 9.76 10.5ZM5 1a.75.75 0 0 1 .75.75v1.261a25.27 25.27 0 0 1 2.598.211.75.75 0 1 1-.2 1.487c-.22-.03-.44-.056-.662-.08A12.939 12.939 0 0 1 5.92 8.058c.237.304.488.595.752.873a.75.75 0 0 1-1.086 1.035A13.075 13.075 0 0 1 5 9.307a13.068 13.068 0 0 1-2.841 2.546.75.75 0 0 1-.827-1.252A11.566 11.566 0 0 0 4.08 8.057a12.991 12.991 0 0 1-.554-.938.75.75 0 1 1 1.323-.707c.049.09.099.181.15.271.388-.68.708-1.405.952-2.164a23.941 23.941 0 0 0-4.1.19.75.75 0 0 1-.2-1.487c.853-.114 1.72-.185 2.598-.211V1.75A.75.75 0 0 1 5 1Z",
                    ),
                    attribute.attribute("fill-rule", "evenodd"),
                  ]),
                ],
              ),
              svg.svg(
                [
                  attribute.attribute("viewBox", "0 0 2048 2048"),
                  attribute.attribute("xmlns", "http://www.w3.org/2000/svg"),
                  attribute.class(
                    "hidden h-2 w-2 fill-current opacity-60 sm:inline-block",
                  ),
                  attribute.attribute("height", "12px"),
                  attribute.attribute("width", "12px"),
                ],
                [
                  svg.path([
                    attribute.attribute(
                      "d",
                      "M1799 349l242 241-1017 1017L7 590l242-241 775 775 775-775z",
                    ),
                  ]),
                ],
              ),
            ],
          ),
          html.div(
            [
              attribute.class(
                "dropdown-content bg-base-200 text-xl rounded-box top-px mt-16 max-h-[calc(100vh-10rem)] w-56 overflow-y-auto border border-white/5 shadow-2xl outline outline-1 outline-black/5",
              ),
              attribute.attribute("tabindex", "0"),
            ],
            [
              html.ul([attribute.class("menu menu-sm gap-1")], [
                html.li([], [
                  html.button([event.on_click(ChangeLang("ar"))], [
                    html.span([], [html.text("عربي")]),
                  ]),
                ]),
                html.li([], [
                  html.button([event.on_click(ChangeLang("en"))], [
                    html.span([], [html.text("English")]),
                  ]),
                ]),
              ]),
            ],
          ),
        ],
      ),
    ],
  )
}
