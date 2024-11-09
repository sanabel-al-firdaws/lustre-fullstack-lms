import gleam/pgo

pub type Context {

  //   Context(db: pgo.Connection, user: Option(auth.User))
  Context(db: pgo.Connection)
}
