///|
fn get_git_repo_url() -> String? {
  let url = sh("git config --get remote.origin.url").output.trim_space()
  if url.has_prefix("git@") {
    let parts = url.split(":").collect()
    guard parts.length() == 2
    Some("https://github.com/\{parts[1]}")
  } else {
    None
  }
}

///|
test "get_git_repo_url" {
  @json.inspect!(get_git_repo_url(), content=[
    "https://github.com/zhuguiyuan/Oops.git",
  ])
}
