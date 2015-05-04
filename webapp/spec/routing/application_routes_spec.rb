describe "home controller routes" do
  it "routes / to jobs#index" do
    expect(:get => "/").to route_to(:controller => "jobs", :action => "home")
  end
end

describe "jobs controller routes" do
  it "routes get /jobs to jobs#index" do
    expect(:get => "/jobs").to route_to(
      :controller => "jobs", 
      :action => "index" 
    )
  end

  it "routes post /jobs to jobs#create" do
    expect(:post => "/jobs").to route_to(
      :controller => "jobs", 
      :action => "create"
    )
  end

  it "routes get /jobs/1 to jobs#show" do
    expect(:get => "/jobs/1").to route_to(
      :controller => "jobs", 
      :action => "show",
      "id": "1"
    )
  end

  it "routes patch /jobs/1/callback to jobs#running" do
    expect(:patch => "/jobs/1/callback").to route_to(
      :controller => "jobs", 
      :action => "running", 
      "id": "1"
    )
  end

  it "routes delete /jobs/1/callback to jobs#finished" do
    expect(:delete => "/jobs/1/callback").to route_to(
      :controller => "jobs", 
      :action => "finished", 
      "id": "1"
    )
  end
end
