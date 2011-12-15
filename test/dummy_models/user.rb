class User < ActiveRecord::Base
  auto_validate
  has_secure_password

  has_many :widget_requests
  has_many :taggings
  has_many :tags, :through => :taggings
end
