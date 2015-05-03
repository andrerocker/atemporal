class RunnerJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    current = Job.find(args.first)
    current.prepare!
  end
end
