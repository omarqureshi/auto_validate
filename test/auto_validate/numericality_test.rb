require 'test_helper'

class NumericalityTest < Test::Unit::TestCase

  def test_should_not_allow_less_than_1_widget
    u = User.create(:email => "test@test.com",
                    :password => "test",
                    :password_confirmation => "test")
    wr = u.widget_requests.build(:quantity => 0, :user_id => u.id)
    deny wr.valid?
  end

  def test_should_not_allow_more_widgets_than_maximum_integer_size
    u = User.create(:email => "test@test.com",
                    :password => "test",
                    :password_confirmation => "test")
    wr = u.widget_requests.build(:quantity => 100000000000000000000000000000000000000000000000000, :user_id => u.id)
    deny wr.valid?
  end

  def test_should_allow_normal_amount_of_widgets
    u = User.create(:email => "test@test.com",
                    :password => "test",
                    :password_confirmation => "test")
    wr = u.widget_requests.build(:quantity => 1, :user_id => u.id)
    assert wr.valid?
  end


end
