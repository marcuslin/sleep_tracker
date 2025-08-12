# Clear existing data
User.destroy_all
SleepRecord.destroy_all
Follow.destroy_all

puts "Creating regular users..."
# Create 50 regular users (more for performance testing)
users = 50.times.map { User.create!(name: Faker::Name.name) }

puts "Creating heavy user for performance testing..."
# Create one user that follows EVERYONE (performance test)
heavy_user = User.create!(name: "Heavy User (Performance Test)")

# Heavy user follows all other users
users.each do |user|
  heavy_user.follows.create!(followee: user)
end

puts "Creating follow relationships between regular users..."
# Regular users follow each other randomly
users.each do |user|
  followers = users.sample(rand(3..8)) - [user]
  followers.each do |followee|
    user.follows.find_or_create_by(followee: followee)
  end
end

puts "Creating sleep records..."
# Generate more sleep records per user for performance testing
users.each do |user|
  # Generate 3 weeks of data (21 records per user = 1000+ total records)
  21.times do |i|
    date = Date.current - i.days
    bedtime = date + rand(21..24).hours + rand(60).minutes
    duration = rand(550..600) / 100.0  # 5.5-10 hours

    SleepRecord.create!(
      user: user,
      clock_in_time: bedtime,
      clock_out_time: bedtime + duration.hours,
      duration: duration,
      status: :awake,
      created_at: bedtime
    )
  end
end

# One regular user gets an active sleep session
active_user = users.sample
SleepRecord.create!(
  user: active_user,
  clock_in_time: 2.hours.ago,
  status: :sleeping
)

puts "\n=== Seed Summary ==="
puts "Users: #{User.count}"
puts "Sleep Records: #{SleepRecord.count}"
puts "Follows: #{Follow.count}"
puts "\n=== Performance Testing ==="
puts "Heavy User ID: #{heavy_user.id} (follows #{heavy_user.follows.count} users)"
puts "Test friends_weekly with heavy user to see pagination performance"
puts "\n=== Regular Testing ==="
puts "Active sleeper: #{active_user.name} (ID: #{active_user.id})"
puts "Use any user ID for regular API testing"
