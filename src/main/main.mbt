///|
fn main {
  println(@utils.sh?("echo 0 > /dev/null", fn(a, _) { a }))
}
