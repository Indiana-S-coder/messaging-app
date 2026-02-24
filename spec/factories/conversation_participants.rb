FactoryBot.define do
  factory :conversation_participant do
    association :user
    association :conversation
  end
end
