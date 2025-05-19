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
    ["init"] => println("init")
    ["new", filename] => println("new \{filename}")
    ["new", sub_dir, filename] => println("new \{sub_dir} \{filename}")
    ["build"] => println("build")
    _ => println(usage)
  }
}
