class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = current_user.recipes.order(created_at: :desc)
  end

  def show
    @recipe = current_user.recipes.find(params[:id])
  end
  # aujourhui
def edit
  @recipe = Recipe.find(params[:id])
end

def update
  @recipe = Recipe.find(params[:id])
  if @recipe.update(recipe_params)
    redirect_to chat_recipe_path(@recipe.chat, @recipe), notice: "Recette mise à jour !"
  else
    render :edit
  end
end

def destroy
  @recipe = Recipe.find(params[:id])
  @chat = @recipe.chat
  @recipe.destroy
  redirect_to chat_recipes_path(@chat), notice: "Recette supprimée !"
end

  def create
    @chat = current_user.chats.find(params[:chat_id])
    last_ai_message = @chat.messages.where(role: "assistant").last

    return redirect_to chat_path(@chat), alert: "Aucune réponse de l'IA à sauvegarder." if last_ai_message.nil?

    @recipe = @chat.recipes.new(name: last_ai_message.content.truncate(40), content: last_ai_message.content)
    redirect_path = @recipe.save ? recipes_path : chat_path(@chat)
    redirect_to redirect_path, notice: @recipe.persisted? ? "Recette sauvegardée !" : nil,
                               alert: @recipe.persisted? ? nil : "Impossible de sauvegarder la recette."
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content)
  end

end
