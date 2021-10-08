class Api::V1::ApiController < ApplicationController
  def get
    if params[:category_name].present?
      @ideas = Idea.get_with_category_name({ category_name: api_params[:category_name] })
      if @ideas.blank?
        render status: :not_found, json: { status: 404, message: 'Not Found' }
        return
      end
    else
      @ideas = Idea.includes(:category).references(:category).all
    end
    render 'get', status: :ok, formats: :json, handlers: 'jbuilder'
  end

  def create
    if params[:category_name].blank? || params[:body].blank?
      render status: :unprocessable_entity, json: { status: 422, message: 'Validation error' }
      return
    end

    @category = Category.find_by(name: api_params[:category_name])
    if @category.blank?
      @category = Category.new
      @category.name = api_params[:category_name]
      @category.save
    end

    @idea = @category.ideas.new
    @idea.body = api_params[:body]

    if @idea.save
      render status: :created, json: { status: 201, message: 'Idea created' }
    else
      render status: :unprocessable_entity, json: { status: 422, message: 'Validation error' }
    end
  end

  private

  def api_params
    params.permit(:category_name, :body)
  end
end
