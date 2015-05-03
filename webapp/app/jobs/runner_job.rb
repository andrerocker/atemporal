class RunnerJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts "YeahhhhhhhhhhhhhhhhhhhhHH #{args.inspect}"
    current = Job.find(args.first)

    puts current.inspect
    current.execute!
  end
end
