class User < ActiveRecord::Base
  auto_validate
  has_secure_password
end
