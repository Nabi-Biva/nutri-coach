class RecipesController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = current_user
    @recipes = @user.recipes.order(created_at: :desc)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
