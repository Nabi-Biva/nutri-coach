class RecipesController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = current_user
    @recipes = @user.recipes.order(created_at: :desc)
  end

  def show
    @recipe = current_user.recipes.find(params[:id])
  end
end
