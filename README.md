# parallel.cr

Parallel is a shard which provides tools for parallelism similar to how Crystal
provides tools for concurrency. It provides an analogue of fibers and channels
using processes, and a special type of channel to communicate between processes.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  parallel:
    github: RX14/parallel.cr
```

## Usage

In the following example, you would expect to complete the tasks in 3 seconds because it processes 4 jobs at a time. However, currently Crystal can only execute code on a single core at a time, and it will take the full 12 seconds to execute.

```crystal
lib LibC
  fun sleep(seconds : UInt)
end

def do_work(job)
  LibC.sleep(1)

  job * 2
end

def worker(in_channel, out_channel)
  loop do
    job = in_channel.receive
    result = do_work(job)
    out_channel.send(result)
  end
end

job_channel = Channel(Int32).new
results_channel = Channel(Int32).new

# spawn 4 workers
4.times do
  spawn worker(job_channel, results_channel)
end

spawn do
  12.times { |i| job_channel.send i }
end

time = Time.measure do
  12.times { p results_channel.receive }
end
p time
```

Simply by requiring `"parallel"`, replacing `spawn` with `pspawn`, and `Channel` with `PChan`, this simple example will execute in only 3 seconds.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/RX14/parallel.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [RX14](https://github.com/RX14) RX14 - creator, maintainer
