require 'faker'
require 'json'

number_of_users = 4
number_of_events = 6
number_of_transactions = 200
number_of_offers = number_of_events * number_of_users

filepath = 'app/assets/data/kalshi.json'
kalshi_json = File.read(filepath)
kalshi_markets = JSON.parse(kalshi_json)

def real_price(event)
  if event.transactions.last
    new_price = event.current_price + (rand(0...4) * [-1, 1].sample)
    while new_price > 100 || new_price < 1
      new_price = event.current_price + (rand(0...4) * [-1, 1].sample)
    end
    price = new_price
  else
    price = rand(0...100)
  end
  price
end

dates = []
number_of_transactions.times do
  dates << Faker::Time.between(from: 1.day.ago, to: DateTime.now)
end

dates.sort_by! { |s| s}
def valid_transaction_params
  event = Event.all.sample
  price = real_price(event)
  n_actions = rand(1..5)
  buyer, seller = User.all.where.not(admin: true).sample(2)  # Filter out the bank here
  actions_on_offer = event.transactions.where(buyer_id: nil, seller_id: seller.id).sum(:n_actions)
  seller_investments = seller.investments.find_by(event: event).n_actions

  while (price * n_actions) > buyer.points || n_actions > seller_investments - actions_on_offer
    event = Event.all.sample
    price = real_price(event)
    n_actions = rand(1..20)
    buyer, seller = User.all.where.not(admin: true).sample(2) # Same
    actions_on_offer = event.transactions.where(buyer_id: nil, seller_id: seller.id).sum(:n_actions)
    seller_investments = seller.investments.find_by(event: event).n_actions
  end
  {
    params: {
      price: price,
      n_actions: n_actions,
      seller: seller,
      event: event
    },
    buyer: buyer
  }
end

puts "Destroying all Investment... 💣"
Investment.destroy_all
puts "Destroying all Transaction... 💣"
Transaction.destroy_all
puts "Destroying all Users... 💣"
User.destroy_all
puts "Destroying all Event... 💣"
Event.destroy_all

users_list = [
  {
    username: "Crowdair",
    email: "crowdair@gmail.com",
    password: "abcdef",
    points: 10_000_000,
    admin: true
  },
  {
    username: "marcel",
    email: "mbower@gmail.com",
    password: "abcdef"
  },
  {
    username: "jane",
    email: "janetarzan@hotmail.com",
    password: "abcdef"
  }
]

(number_of_users - 2).times do
  users_list << {
    username: Faker::Internet.unique.username,
    email: Faker::Internet.email,
    password: "abcdef"
  }
end

puts "Creating a seed of #{users_list.size} fake Users..."

users_list.each_with_index do |user, i|
  User.create!(user)
  print "> Created User ##{i + 1} \r"
end

puts "Users table now contains #{User.count} users."

puts "Creating a seed of #{number_of_events} fake events..."
number_of_events.times do
  kalshi_event = kalshi_markets["markets"].sample
  Event.create!({
    title: kalshi_event["title"].truncate(100),
    end_date: Faker::Time.forward(days: 100),
    description: kalshi_event["settle_details"].truncate(300),
    img_url: kalshi_event["image_url"]
  })
end
puts "Events table now contains #{Event.count} events."

puts "Creating a seed of #{number_of_transactions*2} fake transactions..."

number_of_transactions.times do |i|
  transaction_params = valid_transaction_params
  transaction = Transaction.create!(transaction_params[:params])
  transaction.update(buyer_id: transaction_params[:buyer].id, updated_at: dates[i])
  User.update_all_portfolios
  print "#{i + 1} transactions created \r"
end

puts "#{number_of_transactions} transactions created"

number_of_offers.times do |i|
  transaction = Transaction.create!(valid_transaction_params[:params])
  transaction.update(updated_at: dates[i])
  print "#{i + 1} offers created \r"
end

puts "#{number_of_offers} offers created"

puts ""
puts "Users table now contains #{Transaction.count} Transactions."
puts "Users table now contains #{Investment.count} Investments."
puts "Portfolio table now contains #{Portfolio.count} Investments."
