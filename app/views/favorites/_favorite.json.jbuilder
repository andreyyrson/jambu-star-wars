json.extract! favorite, :id, :favoritable_type, :favoritable_id, :created_at, :updated_at
json.url favorite_url(favorite, format: :json)
