# lib/tasks/import.rake
require 'net/http'
require 'json'

# Módulo utilitário para centralizar a lógica de requisição e inserção
module SwapiImporter
  def self.import_resource(model_class, api_endpoint, resource_name_plural)
    begin
      puts "Iniciando importação de #{resource_name_plural} da SWAPI..."

      current_url = "https://swapi.dev/api/#{api_endpoint}/"
      model = model_class

      while current_url
        puts "Buscando dados em: #{current_url}"
        
        uri = URI(current_url)
        response = Net::HTTP.get(uri)
        data = JSON.parse(response)
        
        records_to_insert = data['results'].map do |resource_data|
          { 
            name: resource_data['name'], 
            url:  resource_data['url'],
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        if records_to_insert.any?
          model.insert_all(records_to_insert) 
          puts "  -> Inseridos #{records_to_insert.size} novos registros."
        end

        current_url = data['next']
      end
      
      puts "Importação de #{resource_name_plural} concluída! Total de #{model.count}."
      
    rescue => e
      puts "ERRO FATAL durante a importação de #{resource_name_plural}: #{e.message}"
    end
  end
end


namespace :import do
  
  #TASK PARA PEOPLE 
  desc "Importa todos os People da SWAPI para o banco de dados"
  task swapi_people: :environment do
    SwapiImporter.import_resource(Person, 'people', 'People')
  end

  #TASK PARA PLANETS
  desc "Importa todos os Planets da SWAPI para o banco de dados"
  task swapi_planets: :environment do
    SwapiImporter.import_resource(Planet, 'planets', 'Planets')
  end

  ##TASK PARA STARSHIPS
  desc "Importa todos as Starships da SWAPI para o banco de dados"
  task swapi_starships: :environment do
    SwapiImporter.import_resource(Starship, 'starships', 'Starships')
  end
  
  # 4. TAREFA CENTRALIZADA para rodar todas de uma vez
  desc "Importa todos os recursos (People, Planets, Starships) da SWAPI"
  task all: %w[swapi_people swapi_planets swapi_starships]
end