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

  # Interprétation IMC
  def imc_interpretation
    if imc < 18.5
      "Sous-poids"
    elsif imc < 25
      " Poids Normal"
    elsif imc < 30
      "Surpoids"
    elsif imc < 35
      "Obesité"
    else
      "Obesité sevère"
    end
  end

  def imc_color
    if imc < 18.5
      "#0d6efd" # Bleu
    elsif imc < 25
      "#198754" # Vert
    elsif imc < 30
      "#ffc107" # Jaune
    elsif imc < 35
      "#fd7e14" # orange
    else
      "#dc3545" # rouge
    end

  end

  def complete?
    sex.present? && birthday.present? && weight.present? &&
      height.present? && goal.present? && allergy.present? && lifestyle.present?
  end

  private

  def calculate_imc
    self.imc = weight / (height**2)
  end
end
