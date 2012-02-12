require 'test_helper'

class UniquenessTest < Test::Unit::TestCase

  def test_should_not_be_able_to_use_the_same_email_address_twice
    f = User.new(:email => "test@test.com",
                 :password => "test",
                 :password_confirmation => "test")
    assert f.save
    g = User.new(:email => "test@test.com",
                 :password => "test",
                 :password_confirmation => "test")
    deny g.save
    assert g.errors[:email].any?
  end

  def test_should_correctly_enforce_case_insensitivity_for_lower_unique_index
    f = User.new(:email => "test@test.com",
                 :password => "test",
                 :password_confirmation => "test")
    assert f.save
    g = User.new(:email => "TEST@test.com",
                 :password => "test",
                 :password_confirmation => "test")
    deny g.save
    assert g.errors[:email].any?
  end

  def test_should_correctly_enforce_case_sensitivity_for_unique_index
    p = PromoCode.new(:code => "FOOBAR",
                      :description => "Adds foos to your bar")
    assert p.save
    q = PromoCode.new(:code => "FOOBAR",
                      :description => "Adds foos to your bar")
    deny q.save
    assert q.errors[:code].any?
  end

  def test_should_correcty_enforce_uniqueness_on_multicolumn_indexes
    f = User.new(:email => "test@test.com",
                 :password => "test",
                 :password_confirmation => "test")
    assert f.save
    t = Tag.create(:name => "Foo")
    tagging = f.taggings.build(:tag => t)
    assert tagging.save
    another_tagging = f.taggings.build(:tag => t)
    deny another_tagging.save
  end

end
