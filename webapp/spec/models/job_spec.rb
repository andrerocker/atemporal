require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:params) do
    { image: "andrerocker/wheezy", callback_server: "localhost" }
  end

  context "create a job" do
    it "should valid job with default values" do
      current = subject.class.create(params) 
      expect(current.image).to eql "andrerocker/wheezy"
      expect(current.callback_server).to eql "localhost"
      expect(current.time).to_not be_blank
      expect(current.payload).to be_blank
      expect(current.state).to eql "created"
    end

    it "should not create a job with invalid image" do
      current = subject.class.create(image: "andrerocker;wheezy", callback_server: "localhost")
      expect(current.errors).to be_present
    end

    it "should not create a job without callback_server " do
      current = subject.class.create callback_server: "localhost"
      expect(current.errors).to be_present
    end

    it "should respond to methods of job service" do
      expect(subject).to respond_to(:enqueue_service)
      expect(subject).to respond_to(:prepare_service)
      expect(subject).to respond_to(:destroy_service)
    end

    it "should create and schedule a job" do
      allow_any_instance_of(subject.class).to receive(:enqueue_service)
      current = subject.class.create_and_schedule(params)
      expect(current.state).to eql "scheduled"
    end

    it "should responds to state machine events" do
      expect(subject).to respond_to(:schedule!)
      expect(subject).to respond_to(:prepare!)
      expect(subject).to respond_to(:running!)
      expect(subject).to respond_to(:finished!)
    end
  end

  context "transion job states" do
    it "from created to scheduled" do
      current = subject.class.create(params)
      expect(current.state).to eql "created"
      expect(current).to receive(:enqueue_service)

      current.schedule!
      expect(current.state).to eql "scheduled"
    end

    it "from scheduled to warming" do
      current = FactoryGirl.create :job, state: "scheduled"
      expect(current).to receive(:prepare_service)

      current.prepare!
      expect(current.state).to eql "warming"
    end

    it "from warming to running" do
      current = FactoryGirl.create :job, state: "warming"

      current.running!
      expect(current.state).to eql "running"
    end

    it "from warming to finished" do
      current = FactoryGirl.create :job, state: "warming"
      expect(current).to receive(:destroy_service)

      current.finished!
      expect(current.state).to eql "finished"
    end

    it "from running to finished" do
      current = FactoryGirl.create :job, state: "running"
      expect(current).to receive(:destroy_service)

      current.finished!
      expect(current.state).to eql "finished"
    end
  end
end
