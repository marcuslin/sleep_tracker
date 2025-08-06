FactoryBot.define do
  factory :sleep_record do
    association :user
    clock_in_time { 1.hour.ago }
    status { :sleeping }

    trait :awake do
      status { :awake }
      clock_out_time { Time.current }
      duration { 8.0 }
    end

    trait :completed do
      status { :awake }
      clock_out_time { clock_in_time + 8.hours }
      duration { 8.0 }
    end
  end
end