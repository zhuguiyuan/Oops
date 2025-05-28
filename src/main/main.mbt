///| [Folder -> [Filename -> Index]]
typealias DirMap = Map[String, Map[String, Int]]

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
  let md_dir = CONFIG_MARKDOWN_FOLDER
  match argv {
    ["init"] => oops_init(md_dir)
    ["new", filename] => oops_new(md_dir, ".", filename)
    ["new", sub_dir, filename] => oops_new(md_dir, sub_dir, filename)
    ["build"] => println("build")
    _ => println(usage)
  }
}

///|
fnalias @utils.(dir_exists, file_exists, verbose_unwrap_with_log)

///|
fn oops_init(md_dir : String) -> Unit {
  // Ensure md_dir exists
  if dir_exists(md_dir) {
    @utils.warn("\{md_dir} already exists")
  } else {
    @utils.info("create \{md_dir} folder")
    @fs.create_dir?(md_dir)
    |> verbose_unwrap_with_log("failed to create \{md_dir} folder")
  }
  // Create dir.json
  let dir_json_file = "\{md_dir}/dir.json"
  if file_exists(dir_json_file) {
    @utils.warn("\{dir_json_file} already exists")
  } else {
    @utils.info("create \{dir_json_file} file")
    let dir_json_content : Json = { ".": { "README": 1 } }
    @fs.write_string_to_file?("\{dir_json_file}", dir_json_content.stringify())
    |> verbose_unwrap_with_log("failed to write \{dir_json_file}")
  }
  // Copy README.md
  let readme_note_file = "\{md_dir}/README.md"
  if file_exists(readme_note_file) {
    @utils.warn("\{readme_note_file} already exists")
  } else {
    @utils.info("create \{readme_note_file} file")
    let readme_note_content = if file_exists("README.md") {
      @fs.read_file_to_string?("README.md")
      |> verbose_unwrap_with_log("failed to read README.md")
    } else {
      ""
    }
    @fs.write_string_to_file?("\{readme_note_file}", readme_note_content)
    |> verbose_unwrap_with_log("failed to write to \{readme_note_file}")
  }
}

///|
fn oops_new(md_dir : String, sub_dir : String, filename : String) -> Unit {
  // Validate md_dir and dir.json
  let dir_json_file = "\{md_dir}/dir.json"
  if not(dir_exists(md_dir)) || not(file_exists(dir_json_file)) {
    oops_init(md_dir)
  }
  let dir_json_content = @fs.read_file_to_string?(dir_json_file)
    |> verbose_unwrap_with_log("failed to read \{dir_json_file}")
  if not(@json.valid(dir_json_content)) {
    @utils.err("\{dir_json_file} is broken")
    return
  }
  // Ensure parent folders exist
  let target_dir = "\{md_dir}/\{sub_dir}"
  if not(dir_exists(target_dir)) {
    @utils.info("create \{target_dir}")
    @utils.run("mkdir -p \{target_dir}") |> ignore
  }
  // Initialize the target file
  let target_file = "\{target_dir}/\{filename}.md"
  if file_exists(target_file) {
    @utils.warn("\{target_file} already exists")
    return
  }
  @fs.write_string_to_file?(
    target_file,
    $|# \{filename}
    #|
    ,
  )
  |> verbose_unwrap_with_log("failed to create \{target_file} file")
  // Update dir.json
  let dir_json_map : DirMap = @json.parse?(dir_json_content)
    |> verbose_unwrap_with_log("failed to parse \{dir_json_file}")
    |> @json.from_json?() // know from illusory0x0
    |> verbose_unwrap_with_log("failed to convert \{dir_json_file} to a map")
  if dir_json_map.contains(sub_dir) {
    let filelist = dir_json_map.get(sub_dir).unwrap()
    let max_idx = filelist
      .values()
      .fold(init=0, fn(x, y) { if x > y { x } else { y } })
    filelist[filename] = max_idx + 1
  } else {
    let default_filelist : Map[String, Int] = {}
    default_filelist[filename] = 1
    dir_json_map[sub_dir] = default_filelist
  }
  @fs.write_string_to_file?(
    "\{dir_json_file}",
    dir_json_map.to_json().stringify(),
  )
  |> verbose_unwrap_with_log("failed to write \{dir_json_file}")
  @utils.info("\{target_file} has been created")
}
