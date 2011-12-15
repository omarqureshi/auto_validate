class Tagging < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  auto_validate
end
