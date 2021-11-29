require 'faker'

number_of_users = 10
number_of_events = 20
number_of_transactions = 30
min_points = 10
max_points = 100


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
    title: Faker::Lorem.question,
    end_date: Date.today+rand(100),
    description: Faker::Lorem.paragraph_by_chars(number: 200)
  })
end
puts "Users table now contains #{Event.count} users."

puts "Creating a seed of #{number_of_transactions} fake transactions..."

number_of_transactions.times do |i|
  buyer, seller = User.all.sample(2)
  Transaction.create!({
    price: rand(),
    n_actions: rand(1..20),
    buyer: buyer,
    seller: seller,
    event: Event.all.sample
  })
end

number_of_transactions.times do |i|
  Transaction.create!({
    price: rand(),
    n_actions: rand(1..20),
    seller: User.all.sample,
    event: Event.all.sample
  })
end

puts "Users table now contains #{Transaction.count} Transaction."
puts "Users table now contains #{Investment.count} Investment."
