class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_profile!, only: [:show]

  def index
    @chats = current_user.chats
  end

  def create
    @chat = current_user.chats.new(title: "Nouveau chat")
    if @chat.save
      redirect_to chat_path(@chat), notice: "Chat créé avec succès.", status: :see_other
    else
      @chats = current_user.chats
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @chat     = current_user.chats.find(params[:id])
    @messages = @chat.messages.order(:created_at)
    @message  = Message.new
  end

  def update
    @chat = current_user.chats.find(params[:id])
    if @chat.update(chat_params)
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { status: "ok" } }
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def require_profile!
    return if current_user.profile

    redirect_to new_profile_path, alert: "Complète ton profil nutritionnel d'abord !"
  end

  def chat_params
    params.require(:chat).permit(:title)
  end
end
