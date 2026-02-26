# app/forms/register_form.rb
class RegisterForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :email, :password, :password_confirmation

  validates :email, presence: true
  validate :email_uniqueness
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validates :password, confirmation: true

  def save
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    User.create!(
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
  end

  private

  def email_uniqueness
    return unless User.exists?(email: email)

    errors.add(:email, 'has already been taken')
    raise ActiveRecord::RecordInvalid.new(self)
  end
end
