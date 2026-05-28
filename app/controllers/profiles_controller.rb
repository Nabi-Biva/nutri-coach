class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: %i[edit update]

  def new
    redirect_to edit_profile_path(current_user.profile) if current_user.profile.present?
    @profile = current_user.build_profile
  end

  def create
    @profile = current_user.build_profile(profile_params)

    if @profile.save
      redirect_to profile_path(@profile), notice: "Profil créé avec succès"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profil mis à jour"

    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @profile = current_user.profile
  end

  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    params.require(:profile).permit(:sex, :birthday, :weight, :height, :goal, :allergy, :lifestyle)
  end
end
