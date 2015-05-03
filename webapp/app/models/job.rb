class Job < ActiveRecord::Base
  include AASM
  include JobStateMachineActions

  validates :time, presence: true
  validates :image, presence: true
  has_many :instances

  scope :create_and_schedule, ->(params) do
    create!(params).tap { |job| job.schedule! }
  end

  aasm column: :state do
    state :created, initial: true
    state :scheduled
    state :running
    state :failure
    state :shutdown
    state :callback
    state :finished

    event :schedule do
      transitions from: :created, to: :scheduled, after: :schedule_current_job
    end

    event :execute do
      transitions from: :scheduled, to: :running, after: :execute_current_job
    end
  end

  def format_payload
    payload
  end
end
