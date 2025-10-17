# db/seeds.rb

require 'httparty'

# URLs da API SWAPI
SWAPI_ENDPOINTS = {
  Person:    'https://swapi.dev/api/people/',
  Planet:    'https://swapi.dev/api/planets/',
  Starship:  'https://swapi.dev/api/starships/'
}.freeze

# Função principal para buscar todas as páginas de um endpoint
def fetch_all_data(url)
  data = []
  current_url = url
  
  puts "Iniciando busca em: #{url}"

  while current_url
    response = HTTParty.get(current_url)
    
    unless response.code == 200
      puts "ERRO na requisição para #{current_url}: Código #{response.code}"
      break
    end
    
    body = response.parsed_response
    data.concat(body['results'])
    current_url = body['next'] # Pega o URL da próxima página (se houver)

    # Pequena pausa para evitar sobrecarregar a SWAPI
    sleep(0.5) if current_url
  end
  
  puts "Busca concluída. Total de #{data.count} itens."
  return data
rescue StandardError => e
  puts "Falha ao buscar dados: #{e.message}"
  return []
end

# Função para popular um modelo específico
def populate_model(model_name, data)
  model_class = model_name.to_s.constantize
  
  puts "\n--- Populando #{model_name} (Total: #{data.count}) ---"

  data.each do |item|
    # A SWAPI usa a URL para identificar o ID
    # Ex: "https://swapi.dev/api/people/1/" -> ID é 1
    swapi_id = item['url'].split('/').last.to_i 
    
    # Se o ID não for válido, pula o registro
    next if swapi_id == 0

    # Usa find_or_initialize_by para evitar duplicatas e apenas atualizar
    record = model_class.find_or_initialize_by(id: swapi_id)
    
    # Os dados da SWAPI são mapeados diretamente para a coluna 'name'
    record.name = item['name'] || item['title']
    
    if record.new_record?
      print "Criando #{model_name}: #{record.name} (ID: #{record.id})\n"
    else
      print "Atualizando #{model_name}: #{record.name} (ID: #{record.id})\n"
    end

    unless record.save
      puts "ERRO ao salvar #{record.name}: #{record.errors.full_messages.to_sentence}"
    end
  end
end

# --- Execução Principal ---

puts "Iniciando o script de população de banco de dados..."

# 1. Popula Person
people_data = fetch_all_data(SWAPI_ENDPOINTS[:Person])
populate_model(:Person, people_data)

# 2. Popula Planet
planet_data = fetch_all_data(SWAPI_ENDPOINTS[:Planet])
populate_model(:Planet, planet_data)

# 3. Popula Starship
starship_data = fetch_all_data(SWAPI_ENDPOINTS[:Starship])
populate_model(:Starship, starship_data)

puts "\nPopulação concluída com sucesso!"