module JobsRepresenter
  include Roar::JSON

  property :total
  collection :jobs, extend: JobRepresenter

  def total
    self.count
  end

  def jobs
    self
  end
end
