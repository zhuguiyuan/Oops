///|
fn main {
  let argv = @sys.get_cli_args()[1:]
  let usage =
    #|Oops document generate tool! (https://github.com/zhuguiyuan/Oops)
    #|
    #|Usage: Oops command [args...]
    #|
    #|Command:
    #|  init                      Create a new note project.
    #|  new [sub-dir] filename    Create a new note.
    #|  build                     Build the website form notes.
    #|  help                      Print this message.
    #|
    #|Created by Guiyuan <zhugy2022@qq.com>
    #|Inspired by https://github.com/luzhixing12345/zood
  match argv {
    ["init"] => oops_init(CONFIG_MARKDOWN_FOLDER)
    ["new", filename] => println("new \{filename}")
    ["new", sub_dir, filename] => println("new \{sub_dir} \{filename}")
    ["build"] => println("build")
    _ => println(usage)
  }
}

///|
fnalias @utils.(verbose_unwrap, verbose_unwrap_with_log)

///|
fn oops_init(md_dir_name : String) -> Unit {
  fn dir_exists(path : String) {
    @fs.path_exists(path) && (@fs.is_dir?(path) |> verbose_unwrap)
  }

  fn read_file(file : String) {
    if @fs.path_exists(file) && (@fs.is_file?(file) |> verbose_unwrap) {
      @fs.read_file_to_string?(file)
      |> verbose_unwrap_with_log("failed to read README.md")
    } else {
      ""
    }
  }

  if dir_exists(md_dir_name) {
    @utils.info("\{md_dir_name} already exists.")
    return
  }
  @fs.create_dir?(md_dir_name)
  |> verbose_unwrap_with_log("failed to create \{md_dir_name}")
  let readme_note_content = read_file("README.md")
  let readme_note_file = "\{md_dir_name}/README.md"
  @fs.write_string_to_file?("\{readme_note_file}", readme_note_content)
  |> verbose_unwrap_with_log("failed to write to \{readme_note_file}")
}
