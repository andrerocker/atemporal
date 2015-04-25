class Job < ActiveRecord::Base
  include AASM
  
  validates :image, presence: true
  validates :time, presence: true

  aasm column: :state do
    state :created, initial: true
    state :warming
    state :running
    state :failure
    state :shutdown
    state :callback
    state :finished
  end
end
