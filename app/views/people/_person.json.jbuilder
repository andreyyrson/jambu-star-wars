json.extract! person, :id, :name, :url, :created_at, :updated_at
json.url person_url(person, format: :json)
