require "spec"
require "../src/parallel"

def build_code(code)
  code = <<-CODE
    require "../src/parallel"

    #{code}
    CODE
  input_io = IO::Memory.new(code)
  output_io = IO::Memory.new
  status = Process.run("crystal build -o /dev/null --stdin-filename build_test.cr", input: input_io, output: output_io, error: output_io, chdir: __DIR__, shell: true)
  {status, output_io.to_s}
end
