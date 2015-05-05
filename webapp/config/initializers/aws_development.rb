if Rails.env.development?
  credentials = open(Rails.root.join("../.credentials")).read.split
  ENV["AWS_ACCESS_KEY"] = credentials.first
  ENV["AWS_SECRET_ACCESS_KEY"] = credentials.last
end
