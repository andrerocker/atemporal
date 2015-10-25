class JobsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from AASM::InvalidTransition, with: :unprocessable_entity

  def home
    render json: { message: "see -> github.com/andrerocker/atemporal :p", now: Time.now.utc }
  end

  def index
    render json: Job.all.order(:id).extend(JobsRepresenter)
  end

  def create
    render status: 201, json: Job.create_and_schedule(job_params).extend(JobRepresenter)
  end

  def show
    render json: resolve_job.extend(JobRepresenter)
  end

  def running
    resolve_job.running!
    render status: 204, nothing: true
  end

  def finished
    resolve_job.finished!
    render status: 204, nothing: true
  end

  private
    def not_found
      render status: 404, json: { error: "Job #{params[:id]} not found" }
    end

    def unprocessable_entity(exception)
      render status: 422, json: { error: exception.message }
    end

    def resolve_job
      Job.find(params[:id])
    end

    def job_params
      params.permit(:image, :time, :payload).merge({ callback_server: request.base_url })
    end
end
