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

def valid_transaction_params
  buyer, seller = User.all.sample(2)
  price = rand(0..100)
  n_actions = rand(1..20)
  event = Event.all.sample
  while (price * n_actions) > buyer.points || n_actions > seller.investments.find_by(event: event).n_actions
    price = rand(0..100)
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
  puts "> Created User ##{i + 1}"
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

puts "Creating a seed of #{number_of_transactions} fake transactions..."

number_of_transactions.times do |i|
  transaction = Transaction.create!(valid_transaction_params[:params])
  transaction.update(buyer_id: valid_transaction_params[:buyer].id)
  print "." if (i)%10 == 0
  puts "#{i+1} transactions created" if (i+1)%40 == 0
end

number_of_transactions.times do |i|
  Transaction.create!(valid_transaction_params[:params])
  print "." if (i)%10 == 0
  puts "#{i+1} offers created" if (i+1)%40 == 0
end


puts ""
puts "Users table now contains #{Transaction.count} Transactions."
puts "Users table now contains #{Investment.count} Investments."
