class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[edit update]

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to edit_profile_path(@profile), notice: "Profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to edit_profile_path(@profile), notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:sex, :birthday, :weight, :height, :goal, :allergy, :lifestyle)
  end
end
