class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :users, :through => :taggings
  auto_validate
end
