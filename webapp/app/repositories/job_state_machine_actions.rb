module JobStateMachineActions
  def schedule_current_job
    RunnerJob.set(wait_until: self.time).perform_later(self.id)
  end

  def execute_current_job
    store_instance_ids(client.create_instances({
        min_count: 1, 
        max_count: 1, 
        image_id: ENV['AWS_IMAGE_ID'],
        instance_type: ENV['AWS_INSTANCE_TYPE'],
        security_groups: [ENV['AWS_SECURITY_GROUP']], 
        key_name: ENV['AWS_KEY_NAME'],
        user_data: build_user_data
      }))
  end

  private
    def store_instance_ids(result)
      self.instances.create!(result.collect{|current| { aws_id: current.id }})
    end

    def client
      Aws::EC2::Resource.new
    end

    def build_user_data
      content = open(Rails.root.join('config/worker-cloud-config.yml')).read
      parser = ERB.new(content)
      Base64.encode64(parser.result(binding))
    end
end
