require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'association' do
    it { should have_many(:conversation_participants)}
    it {should have_many(:conversations).through(:conversation_participants)}
    it {should have_many(:messages)}
  end
end
