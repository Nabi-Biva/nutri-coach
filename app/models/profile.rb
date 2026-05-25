class Profile < ApplicationRecord
  belongs_to :user

  before_save :calculate_imc

  validates :sex, presence: true
  validates :birthday, presence: true
  validates :weight, presence: true
  validates :height, presence: true
  validates :goal, presence: true
  validates :allergy, presence: true
  validates :lifestyle, presence: true

  private

  def calculate_imc
    self.imc = weight / (height**2)
  end
end
