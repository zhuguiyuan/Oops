///|
extern "C" fn ffi_chdir(dir : Bytes) -> Unit = "chdir"

///|
pub fn chdir(dir : String) -> Unit {
  ffi_chdir(string_to_c_str(dir))
}

///|
priv type ShResult

///|
pub type! PlatformError (String, String)

///|
#borrow(cmd)
extern "C" fn ffi_execute_command(cmd : Bytes) -> ShResult = "execute_command"

///|
#borrow(self)
extern "C" fn ShResult::ffi_get_output(self : ShResult) -> Bytes = "sh_result_get_output"

///|
#borrow(self)
extern "C" fn ShResult::ffi_get_exit_code(self : ShResult) -> Int = "sh_result_get_exit_code"

///|
#borrow(self)
extern "C" fn ShResult::ffi_get_stopped(self : ShResult) -> Bool = "sh_result_get_stopped"

///|
#borrow(self)
extern "C" fn ShResult::ffi_get_signaled(self : ShResult) -> Bool = "sh_result_get_signaled"

///|
pub fn sh![T](cmd : String, ret : (String, Int) -> T) -> T {
  let ffi_sh_result = ffi_execute_command(string_to_c_str(cmd))
  if ffi_sh_result.ffi_get_stopped() {
    raise PlatformError((cmd, "Stopped."))
  } else if ffi_sh_result.ffi_get_signaled() {
    raise PlatformError((cmd, "Signaled."))
  } else {
    let output = c_str_to_string(ffi_sh_result.ffi_get_output())
    let exit_code = ffi_sh_result.ffi_get_exit_code()
    ret(output, exit_code)
  }
}

///|
pub fn run(cmd : String) -> String {
  fn ret(output : String, code : Int) -> String {
    if code != 0 {
      verbose_abort("\"bash -c \{cmd}\" exited with code = \{code}")
    }
    output
  }

  sh?(cmd, ret).unwrap()
}

///|
test "sh" {
  let id = fn(x, y) { (x, y) }
  @json.inspect!(sh!("echo 42", id), content=["42\n", 0])
  @json.inspect!(sh!("echo 42 > /dev/null", id), content=["", 0])
}

///|
fn string_to_utf8(str : String) -> Bytes {
  @encoding.encode(@encoding.UTF8, str)
}

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
