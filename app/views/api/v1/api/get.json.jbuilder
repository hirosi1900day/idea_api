json.data @ideas do |idea|
  json.id idea.id
  json.category idea.category.name
  json.body idea.body
  json.created_at idea.created_at.to_i
end
