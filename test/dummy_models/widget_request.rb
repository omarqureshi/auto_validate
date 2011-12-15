class WidgetRequest < ActiveRecord::Base
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  auto_validate
  belongs_to :user
end
