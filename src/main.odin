package main

import "core:fmt"
import "core:strconv"
import os "core:os/os2"

main :: proc()
{
  if len(os.args) == 1
  {
    fmt.print("usage:\n       insert <file> <offset> <string>\n")
    os.exit(0)
  }
  else if len(os.args) != 4
  {
    fmt.eprintf("insert: Expected 3 arguments. Got %i.\n", len(os.args)-1)
    os.exit(1)
  }

  file_path := os.args[1]
  file, open_err := os.open(file_path, {.Read})
  if open_err != nil
  {
    fmt.eprintln("insert: Failed to open file.")
    fmt.eprintln("error:", open_err)
    os.exit(1)
  }
  
  file_contents, _ := os.read_entire_file(file, context.allocator)

  file, _ = os.open(file_path, {.Write, .Trunc})

  input_str := transmute([]byte) os.args[3]
  bytes_to_insert := make([]byte, len(input_str))
  bytes_to_insert_idx: int
  for input_str_idx := 0; input_str_idx < len(bytes_to_insert);
  {
    if input_str_idx < len(input_str) - 1 &&
       string(input_str[input_str_idx:input_str_idx+2]) == "\\n"
    {
      bytes_to_insert[bytes_to_insert_idx] = '\n'
      bytes_to_insert_idx += 1
      input_str_idx += 2
    }
    else
    {
      bytes_to_insert[bytes_to_insert_idx] = input_str[input_str_idx]
      bytes_to_insert_idx += 1
      input_str_idx += 1
    }
  }

  bytes_to_insert = bytes_to_insert[:bytes_to_insert_idx]

  write_err: os.Error

  insert_off, parse_ok := strconv.parse_int(os.args[2])
  if !parse_ok
  {
    fmt.eprintln("insert: Failed to parse file.")
    os.exit(1)
  }

  insert_off = min(insert_off, len(file_contents))

  if insert_off != 0
  {
    _, write_err = os.write(file, file_contents[:insert_off])
    if write_err != nil
    {
      fmt.eprintln("append: Failed to write file.")
      fmt.eprintln("error:", write_err)
      os.exit(1) 
    }
  }

  _, write_err = os.write(file, bytes_to_insert)
  if write_err != nil
  {
    fmt.eprintln("insert: Failed to write file.")
    fmt.eprintln("error:", write_err)
    os.exit(1)
  }

  if insert_off != len(file_contents)
  {
    _, write_err = os.write(file, file_contents[insert_off:])
    if write_err != nil
    {
      fmt.eprintln("append: Failed to write file.")
      fmt.eprintln("error:", write_err)
      os.exit(1) 
    }
  }
}
