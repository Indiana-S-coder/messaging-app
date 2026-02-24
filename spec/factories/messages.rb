FactoryBot.define do
  factory :message do
    association :conversation
    association :user
    content { Faker::Lorem.sentence }
  end
end
