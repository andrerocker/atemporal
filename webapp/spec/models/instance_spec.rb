require 'rails_helper'

RSpec.describe Instance, type: :model do
  context "create a job" do
    it "should create instance with default values" do
      job = Job.create! image: "andrerocker/nginx", callback_server: "localhost"
      current = subject.class.create(aws_id: "bacon", job_id: job.id) 

      expect(current.aws_id).to eql "bacon"
      expect(current.job_id).to eql job.id
    end

    it "should not create a instance without required fields " do
      current = subject.class.create
      expect(current.errors).to be_present

      current = subject.class.create(aws_id: "bacon")
      expect(current.errors).to be_present

      current = subject.class.create(job_id: "bacon")
      expect(current.errors).to be_present
    end
  end
end
