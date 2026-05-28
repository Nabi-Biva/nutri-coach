class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_message!, only: [:create]

  MAX_MESSAGE_LENGTH = 4000

  def create
    @chat = current_user.chats.find(params[:chat_id])
    return redirect_to new_profile_path, alert: "Complète ton profil d'abord !" unless current_user.profile&.complete?

    ActiveRecord::Base.transaction do
      @user_message = @chat.messages.create!(role: "user", content: message_params[:content])

      if @chat.messages.where(role: "user").count == 1
        @chat.update!(title: @user_message.content.truncate(50))
      end

      @ai_message = @chat.messages.create!(role: "assistant", content: call_llm)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  rescue RubyLLM::Error, Faraday::Error => e
    Rails.logger.error "LLM Error: #{e.class} — #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    redirect_to chat_path(@chat), alert: "L'IA n'a pas pu répondre. Réessaie dans un instant.", status: :see_other
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def call_llm
    llm_chat = RubyLLM.chat(model: "gpt-4.1-nano")
    llm_chat.with_instructions(build_system_prompt)

    @chat.messages.where(role: %w[user assistant]).order(:created_at).last(20).each do |msg|
      llm_chat.add_message(role: msg.role.to_sym, content: msg.content)
    end

    llm_chat.complete.content
  end

  def validate_message!
    content = params.dig(:message, :content)
    if content.blank?
      redirect_to chat_path(params[:chat_id]), alert: "Le message ne peut pas être vide.", status: :see_other
    elsif content.length > MAX_MESSAGE_LENGTH
      redirect_to chat_path(params[:chat_id]), alert: "Le message est trop long (max #{MAX_MESSAGE_LENGTH} caractères).", status: :see_other
    end
  end

  def build_system_prompt
    profile = current_user.profile
    return "" unless profile

    age = ((Date.today - profile.birthday) / 365).to_i

    imc = profile.imc
    imc = imc ? imc.round(1) : 0

    bmr_mifflin =
      if profile.sex == "homme"
        (10 * profile.weight) + (6.25 * (profile.height * 100)) - (5 * age) + 5
      else
        (10 * profile.weight) + (6.25 * (profile.height * 100)) - (5 * age) - 161
      end

    <<~PROMPT
      Tu es Coach Nutrition IA...

      - Prénom : #{current_user.first_name}
      - Sexe : #{profile.sex}
      - Âge : #{age} ans
      - Poids : #{profile.weight} kg
      - Taille : #{profile.height} m
      - IMC : #{imc}
      - Métabolisme de base : #{bmr_mifflin.round(0)} kcal/jour
      - Objectif : #{profile.goal}
      - Allergies : #{profile.allergy}
      - Mode de vie : #{profile.lifestyle}

      Saisonnalité : #{current_season}
    PROMPT
  end

  def current_season
    case Date.today.month
    when 3..5 then "printemps"
    when 6..8 then "été"
    when 9..11 then "automne"
    else "hiver"
    end
  end
end
