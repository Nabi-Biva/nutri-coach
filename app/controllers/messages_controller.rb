class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = current_user.chats.find(params[:chat_id])
    return redirect_to new_profile_path, alert: "Complète ton profil d'abord !" unless current_user.profile

    @user_message = @chat.messages.create!(role: "user", content: message_params[:content])

    begin
      @ai_message = @chat.messages.create!(role: "assistant", content: call_llm)
    rescue StandardError
      @user_message.destroy
      return redirect_to chat_path(@chat), alert: "L'IA n'a pas pu répondre. Réessaie dans un instant."
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def call_llm
    llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
    llm_chat.with_instructions(build_system_prompt)
    @chat.messages.where(role: %w[user assistant]).order(:created_at).each do |msg|
      llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
    end
    llm_chat.complete.content
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def build_system_prompt
    profile = current_user.profile
    age = ((Date.today - profile.birthday) / 365).to_i

    <<~PROMPT
      Tu es un assistant nutritionniste personnel.
      Profil de l'utilisateur :
      - Prénom : #{current_user.first_name}
      - Sexe : #{profile.sex}
      - Âge : #{age} ans
      - Poids : #{profile.weight} kg
      - Taille : #{profile.height} m
      - IMC : #{profile.imc.round(1)}
      - Objectif : #{profile.goal}
      - Allergies / intolérances : #{profile.allergy}
      - Mode de vie : #{profile.lifestyle}
      Réponds toujours en français, de façon concise et personnalisée.
    PROMPT
  end
end
