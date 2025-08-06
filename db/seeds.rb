5.times do
  User.find_or_create_by!(name: Faker::Name.name)
end
