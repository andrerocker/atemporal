class JobService
  attr_reader :job

  def initialize(job)
    @job = job
  end

  def enqueue_service
    RunnerJob.set(wait_until: job.time).perform_later(job.id)
  end

  def prepare_service
    configuration = {
        min_count: 1, 
        max_count: 1, 
        image_id: ENV['AWS_IMAGE_ID'],
        instance_type: ENV['AWS_INSTANCE_TYPE'],
        security_groups: [ENV['AWS_SECURITY_GROUP']], 
        key_name: ENV['AWS_KEY_NAME'],
        user_data: build_user_data
    }

    instance_name_tag = {
      key: "Name",
      value: "Atemporal - Job #{job.id}"
    }

    resource = Aws::EC2::Resource.new
    servers = resource.create_instances(configuration)
    resource.create_tags(resources: servers.collect(&:id), tags: [instance_name_tag])
    store_instance_ids(servers)
  end

  def destroy_service
    Aws::EC2::Client.new.terminate_instances(instance_ids: job.instances.collect(&:aws_id))
  end

  private
    def store_instance_ids(result)
      job.instances.create!(result.collect{|current| { aws_id: current.id }})
    end

    def build_user_data
      content = open(Rails.root.join('config/worker-cloud-config.yml')).read
      Base64.encode64(ERB.new(content).result(job.instance_eval { binding }))
    end
end
