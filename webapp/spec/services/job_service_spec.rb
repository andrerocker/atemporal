require 'rails_helper'

RSpec.describe JobService do
  let(:job) do
    FactoryGirl.create :job
  end

  context "enqueue a job service" do
    it "should enqueue a job" do
      service = JobService.new(job)

      allow(RunnerJob).to receive(:perform_later).with(job.id)
      allow(RunnerJob).to receive(:set).with(wait_until: job.time).and_return(RunnerJob)

      service.enqueue_service
    end
  end

  context "prepare service (warmup ec2 instance)" do
    it "should call ec2 api to start our instance" do
      service = JobService.new(job)

      # ENV = {
      #   'AWS_IMAGE_ID': 'xxx',
      #   'AWS_INSTANCE_TYPE': 'yyy', 
      #   'AWS_SECURITY_GROUP': 'bbb',
      #   'AWS_KEY_NAME': 'bbb'
      # }

      # config = { 
      #   min_count: 1, 
      #   max_count: 1, 
      #   image_id: ENV['AWS_IMAGE_ID'], 
      #   instance_type: ENV['AWS_INSTANCE_TYPE'],
      #   security_groups: [ENV['AWS_SECURITY_GROUP']],
      #   key_name: ENV['AWS_KEY_NAME'],
      # }

      servers = [OpenStruct.new({id: "acme"})]

      # :(
      allow_any_instance_of(Aws::EC2::Resource).to receive(:create_instances).and_return(servers)
      allow_any_instance_of(Aws::EC2::Resource).to receive(:create_tags)

      service.prepare_service
      expect(job.instances.size).to eq 1
    end
  end
end
