require 'sinatra'
require 'pg'


# Methods

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

def find_recipes
  @page_number = params["page"].to_i

  query = "SELECT * FROM recipes WHERE recipes.name ILIKE $1 ORDER BY recipes.name LIMIT 20 OFFSET #{@page_number}"
  db_connection do |conn|
    recipes = conn.exec_params(query,["%#{params[:search]}%"])
  end
end

def find_ingredients
  id = params[:id]
  query = "SELECT ingredients.id AS ingredient_id, ingredients.name AS ingredient_name,
          recipes.id AS recipe_id, recipes.name AS recipe_name, recipes.instructions, recipes.description
          FROM ingredients
            JOIN recipes ON recipes.id = ingredients.recipe_id
          WHERE recipes.id = #{id}"

  db_connection do |conn|
    ingredients = conn.exec(query)
  end
end

# Get Requests

get '/' do

  erb :index
end

get '/recipes' do
  @recipe_list = find_recipes
  # @pagination = pagination

  erb :recipes
end

get '/recipes/:id' do
  @ingredients_detail = find_ingredients

  erb :show
end
