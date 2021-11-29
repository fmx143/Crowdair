class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :buyer_transactions, class_name: 'Transaction', foreign_key: 'buyer_id'
  has_many :seller_transactions, class_name: 'Transaction', foreign_key: 'seller_id'
  has_many :investments

  # validates :username, length: { in: 3..40 }, format: { with: /\A[a-zA-Z0-9]+\z/,
  #  message: "Only numbers and letters allowed" }

  def transactions
    buyer_transactions + seller_transactions
  end
end
