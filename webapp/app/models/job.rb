class Job < ActiveRecord::Base
  include AASM

  scope :create_and_schedule, ->(params) {
    create!(params).tap { |job| job.schedule! }
  }

  validates :time, presence: true
  validates :image, presence: true

  aasm column: :state do
    state :created, initial: true
    state :scheduled
    state :running
    state :failure
    state :shutdown
    state :callback
    state :finished

    event :schedule do
      transitions from: :created, to: :scheduled

      after do
        RunnerJob.set(wait_until: self.time).perform_later(self.id)
      end
    end

    event :execute do
      transitions from: :scheduled, to: :running
  
      after do
        puts "Truta"
      end
    end
  end
end
