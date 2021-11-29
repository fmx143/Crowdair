class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :buyer_transactions, class_name: 'Transactions', foreign_key: 'buyer_id'
  has_many :seller_transactions, class_name: 'Transactions', foreign_key: 'seller_id'

  def transactions
    buyer_transactions + seller_transactions
  end
end
