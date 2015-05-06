class Instance < ActiveRecord::Base
  belongs_to :job

  validates :aws_id, presence: true
  validates :job_id, presence: true
end
