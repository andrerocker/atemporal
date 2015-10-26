require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  describe "GET #home" do
    it "success with a message" do
      get :home
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['message']).to_not be_blank
    end
  end

  describe "GET #index" do
    it "returns a list jobs" do
      FactoryGirl.create(:job); get :index
      results = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(results["total"]).to eq 1
      expect(results["jobs"].size).to eq 1
      expect(results["jobs"].first.keys).to include("id", "image", "time", "state")
    end
  end

  describe "POST #create" do
    it "create a job" do
      post :create, image: "andrerocker/wheezy"
      results = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(results.keys).to include("id", "image", "time", "state")
    end

    it "create a job with payload" do
      post :create, image: "andrerocker/wheezy", payload: "bacon", time: "acme"
      results = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(results.keys).to include("id", "image", "time", "state", "payload")
      expect(results["state"]).to eq "scheduled"
    end

    it "return 422 cannot create" do
      post :create, image: "andrerocker; sh -c ' echo RAHHH!'"
      results = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(results.keys).to include("error")
    end
  end

  describe "GET #show" do
    it "return a especific job" do
      get :show, id: FactoryGirl.create(:job).id
      results = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(results.keys).to include("id", "image", "time", "state")
    end

    it "return 404 not found" do
      get :show, id: 666
      results = JSON.parse(response.body)

      expect(response.status).to eq 404
      expect(results.keys).to include("error")
    end
  end

  describe "PATCH #running" do
    it "put a job on running state" do
      job = FactoryGirl.create(:job, state: "warming")
      allow_any_instance_of(JobService).to receive(:metadata_service).and_return(true)

      patch :running, id: job.id
      expect(response.status).to eq 204
    end

    it "return 422 invalid transition" do
      job = FactoryGirl.create(:job)
      patch :running, id: job.id
      expect(response.status).to eq 422
    end
  end

  describe "DELETE #finished" do
    it "put a job on finished state (from running)" do
      job = FactoryGirl.create(:job, state: "running")
      allow_any_instance_of(JobService).to receive(:destroy_service).and_return(true)

      delete :finished, id: job.id
      expect(response.status).to eq 204
    end

    it "put a job on finished state (from warming)" do
      job = FactoryGirl.create(:job, state: "warming")
      allow_any_instance_of(JobService).to receive(:destroy_service).and_return(true)

      delete :finished, id: job.id
      expect(response.status).to eq 204
    end

    it "return 422 invalid transition" do
      job = FactoryGirl.create(:job)

      delete :finished, id: job.id
      expect(response.status).to eq 422
    end
  end
end
