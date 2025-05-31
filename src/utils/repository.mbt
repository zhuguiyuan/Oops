///|
fn get_git_repo_url_opt() -> String? {
  sh?("git config --get remote.origin.url", fn(s, _) { s.trim_space() })
  .to_option()
  .bind(fn(url) {
    if url.has_prefix("git@") {
      let parts = url.split(":").collect()
      guard parts.length() == 2
      Some("https://github.com/\{parts[1]}")
    } else if url.has_prefix("https://") {
      Some(url.to_string())
    } else {
      None
    }
  })
  .map(fn(url) {
    if url.has_suffix(".git") {
      url.substring(start=0, end=url.length() - 4)
    } else {
      url
    }
  })
}

///|
test "get_git_repo_url" {
  @json.inspect!(get_git_repo_url_opt(), content=[
    "https://github.com/zhuguiyuan/Oops",
  ])
}
