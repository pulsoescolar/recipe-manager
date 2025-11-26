# frozen_string_literal: true

# Service Object para generar listas de compras desde recetas
# Parsea ingredientes, escala cantidades y agrega items similares
class ShoppingListGenerator
  # Regex para parsear ingredientes con formato: "2 cups flour" o "1 1/4 cups flour" (números mixtos)
  # Captura: cantidad (qty - puede ser número mixto como "1 1/4"), unidad (unit), nombre (name)
  INGREDIENT_REGEX = /(?<qty>\d+(?:\s+\d+\/\d+)?(?:\/\d+)?(?:\.\d+)?)\s+(?<unit>[a-zA-Z]+)\s+(?<name>.+)/i
  
  # Regex alternativa para ingredientes sin unidad: "2 eggs" o "1 1/2 eggs"
  INGREDIENT_NO_UNIT_REGEX = /(?<qty>\d+(?:\s+\d+\/\d+)?(?:\/\d+)?(?:\.\d+)?)\s+(?<name>.+)/i
  
  # Regex para ingredientes sin cantidad: "salt to taste"
  INGREDIENT_NO_QTY_REGEX = /(?<name>.+)/i

  def initialize(items)
    @items = items # Array de { recipe_id:, servings: }
    @aggregated_ingredients = Hash.new { |h, k| h[k] = 0 }
    @no_quantity_ingredients = []
  end

  def generate
    parse_and_aggregate
    format_result
  end

  private

  def parse_and_aggregate
    @items.each do |item|
      recipe = Recipe.find_by(id: item[:recipe_id])
      next unless recipe

      desired_servings = item[:servings].to_f
      scale_factor = desired_servings / recipe.servings.to_f

      # Parsear cada línea de ingredientes
      recipe.ingredients.split("\n").each do |line|
        line = line.strip
        next if line.empty?

        parse_and_add_ingredient(line, scale_factor, recipe.title)
      end
    end
  end

  def parse_and_add_ingredient(line, scale_factor, recipe_title)
    # Intentar parsear con cantidad y unidad
    match = line.match(INGREDIENT_REGEX)
    
    if match
      qty = parse_quantity(match[:qty])
      unit = normalize_unit(match[:unit])
      name = normalize_name(match[:name])
      
      scaled_qty = qty * scale_factor
      key = "#{unit}|#{name}"
      @aggregated_ingredients[key] += scaled_qty
      return
    end

    # Intentar parsear sin unidad (ej: "2 eggs")
    match = line.match(INGREDIENT_NO_UNIT_REGEX)
    
    if match
      qty = parse_quantity(match[:qty])
      name = normalize_name(match[:name])
      
      scaled_qty = qty * scale_factor
      key = "piece|#{name}"
      @aggregated_ingredients[key] += scaled_qty
      return
    end

    # Sin cantidad (ej: "salt to taste")
    @no_quantity_ingredients << {
      name: line,
      recipe: recipe_title
    }
  end

  def parse_quantity(qty_string)
    qty_string = qty_string.strip
    
    # Manejar números mixtos como "1 1/4" (entero + espacio + fracción)
    if qty_string =~ /^(\d+)\s+(\d+)\/(\d+)$/
      whole = $1.to_f
      numerator = $2.to_f
      denominator = $3.to_f
      return whole + (numerator / denominator)
    end
    
    # Manejar fracciones simples como "1/2"
    if qty_string.include?('/')
      parts = qty_string.split('/')
      return parts[0].to_f / parts[1].to_f
    end
    
    # Manejar números enteros o decimales
    qty_string.to_f
  end

  def normalize_unit(unit)
    # Convertir a minúsculas y singularizar unidades comunes
    unit = unit.downcase.strip
    
    # Mapeo de plurales a singulares
    unit_map = {
      'cups' => 'cup',
      'tablespoons' => 'tablespoon',
      'tbsp' => 'tablespoon',
      'teaspoons' => 'teaspoon',
      'tsp' => 'teaspoon',
      'ounces' => 'ounce',
      'oz' => 'ounce',
      'pounds' => 'pound',
      'lbs' => 'pound',
      'lb' => 'pound',
      'grams' => 'gram',
      'g' => 'gram',
      'kilograms' => 'kilogram',
      'kg' => 'kilogram',
      'milliliters' => 'milliliter',
      'ml' => 'milliliter',
      'liters' => 'liter',
      'l' => 'liter',
      'pieces' => 'piece',
      'cloves' => 'clove',
      'slices' => 'slice',
      'cans' => 'can',
      'jars' => 'jar',
      'packages' => 'package',
      'pkg' => 'package'
    }
    
    unit_map[unit] || unit
  end

  def normalize_name(name)
    # Limpiar y normalizar el nombre del ingrediente
    name = name.strip.downcase
    
    # Remover artículos comunes y palabras descriptivas al inicio
    name = name.gsub(/^(of|the|a|an)\s+/, '')
    
    # Remover comentarios entre paréntesis
    name = name.gsub(/\([^)]*\)/, '').strip
    
    name
  end

  def format_result
    # Convertir el hash agregado a un array formateado
    ingredients_list = @aggregated_ingredients.map do |key, qty|
      unit, name = key.split('|')
      
      {
        name: name,
        quantity: format_quantity(qty),
        unit: unit == 'piece' ? '' : unit,
        display: format_display(qty, unit, name)
      }
    end.sort_by { |item| item[:name] }

    # Agregar ingredientes sin cantidad
    no_qty_list = @no_quantity_ingredients.uniq.map do |item|
      {
        name: item[:name],
        quantity: nil,
        unit: '',
        display: "#{item[:name]} (from #{item[:recipe]})",
        note: "to taste"
      }
    end

    {
      ingredients: ingredients_list,
      ingredients_without_quantity: no_qty_list,
      total_items: ingredients_list.count + no_qty_list.count
    }
  end

  def format_quantity(qty)
    # Redondear a 2 decimales y convertir a fracción común si es apropiado
    rounded = (qty * 4).round / 4.0
    
    if rounded == rounded.to_i
      rounded.to_i
    elsif rounded % 0.5 == 0
      rounded
    else
      qty.round(2)
    end
  end

  def format_display(qty, unit, name)
    formatted_qty = format_quantity(qty)
    unit_display = unit == 'piece' ? '' : "#{unit} "
    
    "#{formatted_qty} #{unit_display}#{name}".strip
  end
end
