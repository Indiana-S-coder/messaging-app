FactoryBot.define do
  factory :message do
    association :conversation
    association :user
    content { "Test message"}
  end
end
