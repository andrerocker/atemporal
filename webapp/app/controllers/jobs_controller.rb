class JobsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  def home
    render json: { message: "see -> github.com/andrerocker/atemporal :p" }
  end

  def index
    respond_to do |format|
      format.json do
        render json: Job.all.extend(JobsRepresenter)
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: Job.find(params[:id]).extend(JobRepresenter)
      end
    end
  end

  def create
    respond_to do |format|
      format.json do 
        render status: 201, json: Job.create_and_schedule(job_params).extend(JobRepresenter)
      end
    end
  end

  def callback
    respond_to do |format|
      format.json do
        render json: Job.find(params[:id]).tap { |job| job.touch }
      end
    end
  end

  def running
    respond_to do |format|
      format.json do
        render json: Job.find(params[:id]).tap { |job| job.running! }
      end
    end
  end

  private
    def not_found
      respond_to do |format|
        format.json do
          render status: 404, json: { error: "Job #{params[:id]} not found" }
        end 
      end
    end

    def unprocessable_entity(exception)
      respond_to do |format|
        format.json do
          render status: 422, json: {error: exception.message}
        end
      end
    end

    def job_params
      params.permit(:image, :time, :payload).merge({ callback_server: request.base_url })
    end
end
