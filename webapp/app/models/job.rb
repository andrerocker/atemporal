class Job < ActiveRecord::Base
  include AASM
  include JobStateMachineActions

  has_many :instances
  validates :image, presence: true

  scope :create_and_schedule, ->(params) do
    create!(params).tap { |job| job.schedule! }
  end

  aasm column: :state do
    state :created, initial: true
    state :scheduled
    state :warming
    state :running
    state :failure
    state :shutdown
    state :callback
    state :finished

    event :schedule do
      transitions from: :created, to: :scheduled, after: :schedule_current_job
    end

    event :prepare do
      transitions from: :scheduled, to: :warming, after: :execute_current_job
    end

    event :execute do
      transitions from: :warming, to: :running, after: :execute_current_job
    end
  end

  def time
    return @time if @time.present?
    Time.now
  end
end
