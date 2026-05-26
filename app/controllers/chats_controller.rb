class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
  end

  def create
    @chat = current_user.chats.new(title: "Nouveau chat")
    if @chat.save
      redirect_to chat_path(@chat), notice: "Chat créé avec succès."
    else
      @chats = current_user.chats
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @chat    = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
