class ChatsController < ApplicationController

  def create
    @chat = Chat.new(title: "Untitled")
    @chat.user = current_user
    if @chat.save!
      redirect_to chat_path(@chat), notice: "chat was successfully created."
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @chat    = Chat.find(params[:id])
    @message = Message.new
  end

  def index
    @chats = Chat.all
  end

  # private

  # def chat_params
  #   params.require(:chat).permit(:title)
  # end
end
