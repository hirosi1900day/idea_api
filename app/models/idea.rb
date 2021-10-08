class Idea < ApplicationRecord
  belongs_to :category

  scope :get_with_category_name, lambda { |query|
    left_joins(:category).where(categories: { name: query[:category_name] })
  }
end
