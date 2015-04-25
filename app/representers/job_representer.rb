module JobRepresenter
  include Roar::JSON
  
  property :id  
  property :image  
  property :time  
  property :payload  
  property :state  
end
