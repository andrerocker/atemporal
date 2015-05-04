module JobStateMachineActions
  def schedule_current_job
    RunnerJob.set(wait_until: self.time).perform_later(self.id)
  end

  def execute_current_job
    configuration = {
        min_count: 1, 
        max_count: 1, 
        image_id: ENV['AWS_IMAGE_ID'],
        instance_type: ENV['AWS_INSTANCE_TYPE'],
        security_groups: [ENV['AWS_SECURITY_GROUP']], 
        key_name: ENV['AWS_KEY_NAME'],
        user_data: build_user_data
    }

    instance_name = {
      key: "Name",
      value: "Atemporal - Job #{id}"
    }

    resource = Aws::EC2::Resource.new
    instances = resource.create_instances(configuration)
    resource.create_tags(resources: instances.collect(&:id), tags: [instance_name])
    store_instance_ids(instances)
  end

  def destroy_job_runtime
    Aws::EC2::Client.new.terminate_instances(instance_ids: instances.collect(&:aws_id))
  end

  private
    def store_instance_ids(result)
      instances.create!(result.collect{|current| { aws_id: current.id }})
    end

    def build_user_data
      content = open(Rails.root.join('config/worker-cloud-config.yml')).read
      parser = ERB.new(content)
      Base64.encode64(parser.result(binding))
    end
end
