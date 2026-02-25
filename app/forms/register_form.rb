# app/forms/register_form.rb
class RegisterForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :email, :password, :password_confirmation

  validates :email, presence: true
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validates :password, confirmation: true

  def save
    return false unless valid?

    @user = User.new(
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )

    if @user.save
      true
    else
      errors.merge!(@user.errors)
      false
    end
  end

  def user
    @user
  end
end
