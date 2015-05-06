FactoryGirl.define do
  factory :job do
    image "andrerocker/nginx"
    callback_server "localhost"
  end
end
