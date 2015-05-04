class Job < ActiveRecord::Base
  include AASM
  include JobStateMachineActions

  before_save :default_values
  has_many :instances, dependent: :destroy
  
  validates :callback_server, presence: true
  validates :image, {
    presence: true, 
    format: { with: /\A[a-zA-Z0-9\-_.:\/]+\z/, message: "only allows /\\A[a-z0-9\-_.:\\/]+\\z/" }
  }

  scope :create_and_schedule, ->(params) do
    create!(params).tap { |job| job.schedule! }
  end

  aasm column: :state do
    state :created, initial: true
    state :scheduled
    state :warming
    state :running
    state :finished

    event :schedule do
      transitions from: :created, to: :scheduled, after: :schedule_current_job
    end

    event :prepare do
      transitions from: :scheduled, to: :warming, after: :execute_current_job
    end

    event :running do
      transitions from: :warming, to: :running
    end

    event :finished do
      transitions from: :running, to: :finished, after: :destroy_job_runtime
    end
  end

  def formatted_callback_server
    "#{callback_server}/jobs/#{id}/callback.json"
  end

  private
    def default_values
      @time = Time.now if @time.blank?
    end
end
