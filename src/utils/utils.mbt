///|
extern "C" fn ffi_chdir(dir : Bytes) -> Unit = "chdir"

///|
pub fn chdir(dir : String) -> Unit {
  ffi_chdir(string_to_c_str(dir))
}

///|
type FFI_ShResult

///|
pub struct ShResult {
  output : String
  exit_code : Int
  exited : Bool
  signaled : Bool
} derive(Show, ToJson)

///|
#borrow(cmd)
extern "C" fn ffi_execute_command(cmd : Bytes) -> FFI_ShResult = "execute_command"

///|
#borrow(self)
extern "C" fn FFI_ShResult::ffi_get_output(self : FFI_ShResult) -> Bytes = "sh_result_get_output"

///|
#borrow(self)
extern "C" fn FFI_ShResult::ffi_get_exit_code(self : FFI_ShResult) -> Int = "sh_result_get_exit_code"

///|
#borrow(self)
extern "C" fn FFI_ShResult::ffi_get_exited(self : FFI_ShResult) -> Bool = "sh_result_get_exited"

///|
#borrow(self)
extern "C" fn FFI_ShResult::ffi_get_signaled(self : FFI_ShResult) -> Bool = "sh_result_get_signaled"

///|
pub fn FFI_ShResult::get_output(self : FFI_ShResult) -> String {
  c_str_to_string(self.ffi_get_output())
}

///|
pub fn sh(cmd : String) -> ShResult {
  let ffi_sh_result = ffi_execute_command(string_to_c_str(cmd))
  {
    output: ffi_sh_result.get_output(),
    exit_code: ffi_sh_result.ffi_get_exit_code(),
    exited: ffi_sh_result.ffi_get_exited(),
    signaled: ffi_sh_result.ffi_get_signaled(),
  }
}

///|
test "sh" {
  @json.inspect!(sh("echo 42"), content={
    "output": "42\n",
    "exit_code": 0,
    "exited": true,
    "signaled": false,
  })
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
