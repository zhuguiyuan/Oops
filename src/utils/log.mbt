///|
const COLOR_GREEN = "\u001B[32m"

///|
const COLOR_YELLOW = "\u001B[33m"

///|
const COLOR_RED = "\u001B[31m"

///|
const COLOR_CLEAR = "\u001B[0m"

///|
fn log(color : String, s : String) -> Unit {
  println(color + s + COLOR_CLEAR)
}

///|
pub fn info(s : String) -> Unit {
  log(COLOR_GREEN, s)
}

///|
pub fn warn(s : String) -> Unit {
  log(COLOR_YELLOW, s)
}

///|
pub fn err(s : String) -> Unit {
  log(COLOR_RED, s)
}

///|
pub fn verbose_abort[T](msg : String, loc~ : SourceLoc = _) -> T {
  let abort_msg =
    $|\{msg}
    $|  at \{loc}
  err(abort_msg)
  abort(abort_msg)
}

///|
pub fn verbose_unwrap[T, E](x : Result[T, E], loc~ : SourceLoc = _) -> T {
  match x {
    Ok(x) => x
    Err(_) =>
      verbose_abort(
        #|called `Result::unwrap()` on an `Err` value
        $|  at \{loc}
        ,
      )
  }
}

///|
pub fn verbose_unwrap_with_log[T, E](
  x : Result[T, E],
  log : String,
  loc~ : SourceLoc = _
) -> T {
  match x {
    Ok(x) => x
    Err(_) =>
      verbose_abort(
        $|\{log}
        #|called `Result::unwrap()` on an `Err` value
        $|  at \{loc}
        ,
      )
  }
}
