///|
extern "C" fn system(command : Bytes) -> Int = "system"

///|
test "string_to_utf8" {
  inspect!(
    string_to_utf8("echo 42"),
    content=
      #|b"\x65\x63\x68\x6f\x20\x34\x32"
    ,
  )
}

///|
fn string_to_c_str(str : String) -> Bytes {
  string_to_utf8(str) + b"\x00"
}

///|
fn string_to_utf8(str : String) -> Bytes {
  @encoding.encode(@encoding.UTF8, str)
}

///|
fn c_str_to_string(str : Bytes) -> String {
  guard str.to_array() is [.. xs, b'\x00']
  @encoding.decode?(
    @encoding.decoder(@encoding.UTF8),
    Bytes::from_array(xs.to_array()),
  ).unwrap()
}

///|
test "c_str_to_string" {
  inspect!(c_str_to_string(string_to_c_str("你好！")), content="你好！")
}

///|
fn guard_zero(code : Int) -> Unit {
  guard code == 0

}

///|
pub fn sh(cmd : String, callback~ : (Int) -> Unit = guard_zero) -> Unit {
  callback(system(string_to_c_str(cmd)))
}

///|
test "sh" {
  inspect!(sh("echo 10 > /dev/null"), content="()")
}
