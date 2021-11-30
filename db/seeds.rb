require 'faker'
require 'json'


number_of_users = 10
number_of_events = 10
number_of_transactions = 600
min_points = 10
max_points = 100

filepath = 'app/assets/data/kalshi.json'
kalshi_json = File.read(filepath)
kalshi_markets = JSON.parse(kalshi_json)

def real_price(event)
  if event.transactions.last
    new_price = event.transactions.last.price + ((rand(0...100)/rand(1000..4000).to_f) * [-1,1].sample)
    while new_price > 1.0 || new_price < 0.0
      new_price = event.transactions.last.price + ((rand(0...100)/rand(1000..4000).to_f)* [-1,1].sample)
    end
    price = new_price
  else
    price = rand(0...100)/100.0
  end
  price
end

def created_time(event)
  time = Faker::Time.backward(days: 1)
  while time < event.transactions.last(2).first.created_at
    time = Faker::Time.backward(days: 1)
  end
  time
end

def valid_transaction_params
  event = Event.all.sample
  buyer, seller = User.all.sample(2)
  price = real_price(event)
  n_actions = rand(1..20)
  while (price * n_actions) > buyer.points || n_actions > seller.investments.find_by(event: event).n_actions
    price = real_price(event)
    n_actions = rand(1..20)
    buyer, seller = User.all.sample(2)
  end
  {
    params: {
    price: price,
    n_actions: n_actions,
    seller: seller,
    event: event
    },
  buyer: buyer}
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
    username: "marcel",
    email: "mbower@gmail.com",
    password: "abcdef",
    points: 89
  },
  {
    username: "jane",
    email: "janetarzan@hotmail.com",
    password: "abcdef",
    points: 67
  }
]

(number_of_users-2).times do
  users_list << {
    username: Faker::Internet.unique.username,
    email: Faker::Internet.email,
    points: rand(min_points..max_points),
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
number_of_events.times do |i|
  Event.create!({
    title: kalshi_markets["markets"].sample["title"],
    end_date: Faker::Time.forward(days: 100),
    description: Faker::Lorem.paragraph_by_chars(number: 200)
  })
end
puts "Users table now contains #{Event.count} users."

puts "Creating a seed of #{number_of_transactions*2} fake transactions..."

number_of_transactions.times do |i|
  transaction = Transaction.create!(valid_transaction_params[:params])
  transaction.update(buyer_id: valid_transaction_params[:buyer].id)
  transaction.created_at = Faker::Time.backward(days: 1)
  transaction.created_at = created_time(transaction.event)
  print "#{i+1} transactions created \r"
end
puts "#{number_of_transactions} transactions created"
number_of_transactions.times do |i|
  Transaction.create!(valid_transaction_params[:params])
  transaction.created_at = Faker::Time.backward(days: 1)
  transaction.created_at = created_time(transaction.event)
  print "#{i+1} offers created \r"
end
puts "#{number_of_transactions} offers created"


puts ""
puts "Users table now contains #{Transaction.count} Transactions."
puts "Users table now contains #{Investment.count} Investments."
