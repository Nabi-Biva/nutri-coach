class PagesController < ApplicationController
  def home
    redirect_to new_profile_path if user_signed_in? && current_user.profile.nil?
  end
end
