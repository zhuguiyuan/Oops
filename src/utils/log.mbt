///|
pub fn info(x : String) -> Unit {
  println(x)
}

///|
fn verbose_abort[T](msg : String) -> T {
  println(msg)
  abort(msg)
}

///|
pub fn verbose_unwrap[T, E](x : Result[T, E]) -> T {
  match x {
    Ok(x) => x
    Err(_) => verbose_abort("called `Result::unwrap()` on an `Err` value")
  }
}

///|
pub fn verbose_unwrap_with_log[T, E](x : Result[T, E], log : String) -> T {
  match x {
    Ok(x) => x
    Err(_) =>
      verbose_abort(
        $|\{log}
        #|called `Result::unwrap()` on an `Err` value
        ,
      )
  }
}
