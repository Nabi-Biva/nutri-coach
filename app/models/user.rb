class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable
  validates :first_name, presence: true
  validates :last_name, presence: true

  has_one :profile, dependent: :destroy
  has_many :chats, dependent: :destroy

  has_many :recipes, through: :chats
  has_many :messages, through: :chats
end
