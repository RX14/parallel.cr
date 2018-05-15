require "../src/parallel"

lib LibC
  fun sleep(seconds : UInt)
end

def do_work(job)
  LibC.sleep(1)

  job * 2
end

def worker(in_channel, out_channel, fork_id)
  loop do
    job = in_channel.receive
    result = do_work(job)
    out_channel.send(result)
  end
end

job_channel = PChan(Int32).new
results_channel = PChan(Int32).new

# spawn 4 workers
4.times do |i|
  pspawn { worker(job_channel, results_channel, i) }
end

spawn do
  10.times { |i| job_channel.send i }
end

time = Time.measure do
  10.times { p results_channel.receive }
end
p time
