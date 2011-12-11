require 'test_helper'

class NullConstraintTest < Test::Unit::TestCase

  def test_should_not_allow_nil_email
    f = User.new(:password => "password",
                 :password_confirmation => "password",
                 :admin => false)
    deny f.save
    assert f.errors[:email].any?
  end

  def test_should_not_allow_nil_password_digest
    f = User.new(:email => "foo@bar.com",
                 :admin => false)
    deny f.save
    assert f.errors[:password_digest].any?
  end

  def test_should_allow_nil_admin
    f = User.new(:email => "test@test.com",
                 :password => "password",
                 :password_confirmation => "password")
    assert f.save
    deny f.errors[:admin].any?
  end

end
