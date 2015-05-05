class Job < ActiveRecord::Base
  include AASM

  before_save :default_values
  has_many :instances, dependent: :destroy
  
  validates :callback_server, presence: true
  validates :image, {
    presence: true, 
    format: { with: /\A[a-zA-Z0-9\-_.:\/]+\z/, message: "only allows /\\A[a-z0-9\-_.:\\/]+\\z/" }
  }

  delegate :enqueue_service, to: :service
  delegate :prepare_service, to: :service
  delegate :destroy_service, to: :service

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
      transitions from: :created, to: :scheduled, after: :enqueue_service
    end

    event :prepare do
      transitions from: :scheduled, to: :warming, after: :prepare_service
    end

    event :running do
      transitions from: :warming, to: :running
    end

    event :finished do
      transitions from: :running, to: :finished, after: :destroy_service
    end
  end

  def formatted_callback_server
    "#{callback_server}/jobs/#{id}/callback.json"
  end

  private
    def default_values
      self.time = Time.now if @time.blank?
    end

    def service
      @service ||= JobService.new(self)
    end
end
