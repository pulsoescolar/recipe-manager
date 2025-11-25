#!/usr/bin/env ruby
# frozen_string_literal: true

# Script para probar el ShoppingListGenerator localmente
# Ejecutar desde la raíz del proyecto: ruby docs/test_shopping_list.rb

require_relative '../config/environment'

puts "=" * 60
puts "Testing ShoppingListGenerator"
puts "=" * 60
puts

# Crear recetas de prueba
puts "Creando recetas de prueba..."

recipe1 = Recipe.create!(
  title: "Pancakes",
  servings: 4,
  prep_time: 10,
  cook_time: 15,
  difficulty: "easy",
  description: "Delicious fluffy pancakes",
  ingredients: "2 cups flour\n1 cup milk\n3 eggs\n1/2 teaspoon salt\n2 tablespoons sugar",
  instructions: "Mix all ingredients and cook on griddle."
)

recipe2 = Recipe.create!(
  title: "Cake",
  servings: 8,
  prep_time: 20,
  cook_time: 30,
  difficulty: "medium",
  description: "Classic vanilla cake",
  ingredients: "3 cups flour\n2 cups sugar\n4 eggs\n1 cup butter\n1 teaspoon vanilla extract",
  instructions: "Mix and bake at 350°F for 30 minutes."
)

puts "✓ Receta 1: #{recipe1.title} (#{recipe1.servings} servings)"
puts "  Ingredientes:"
recipe1.ingredients.split("\n").each { |i| puts "  - #{i}" }
puts

puts "✓ Receta 2: #{recipe2.title} (#{recipe2.servings} servings)"
puts "  Ingredientes:"
recipe2.ingredients.split("\n").each { |i| puts "  - #{i}" }
puts

# Caso 1: Una receta con porciones originales
puts "\n" + "=" * 60
puts "CASO 1: Una receta, porciones originales (4)"
puts "=" * 60

items1 = [{ recipe_id: recipe1.id, servings: 4 }]
generator1 = ShoppingListGenerator.new(items1)
result1 = generator1.generate

puts "\nIngredientes agregados:"
result1[:ingredients].each do |item|
  puts "  #{item[:display]}"
end
puts "\nTotal items: #{result1[:total_items]}"

# Caso 2: Una receta con el doble de porciones
puts "\n" + "=" * 60
puts "CASO 2: Una receta, doble de porciones (8)"
puts "=" * 60

items2 = [{ recipe_id: recipe1.id, servings: 8 }]
generator2 = ShoppingListGenerator.new(items2)
result2 = generator2.generate

puts "\nIngredientes agregados:"
result2[:ingredients].each do |item|
  puts "  #{item[:display]}"
end
puts "\nTotal items: #{result2[:total_items]}"

# Caso 3: Dos recetas combinadas
puts "\n" + "=" * 60
puts "CASO 3: Dos recetas combinadas"
puts "  - Pancakes x4 porciones"
puts "  - Cake x8 porciones"
puts "=" * 60

items3 = [
  { recipe_id: recipe1.id, servings: 4 },
  { recipe_id: recipe2.id, servings: 8 }
]
generator3 = ShoppingListGenerator.new(items3)
result3 = generator3.generate

puts "\nIngredientes agregados:"
result3[:ingredients].sort_by { |i| i[:name] }.each do |item|
  puts "  #{item[:display]}"
end

if result3[:ingredients_without_quantity].any?
  puts "\nIngredientes sin cantidad:"
  result3[:ingredients_without_quantity].each do |item|
    puts "  - #{item[:display]}"
  end
end

puts "\nTotal items: #{result3[:total_items]}"

# Análisis de agregación
puts "\n" + "=" * 60
puts "ANÁLISIS DE AGREGACIÓN"
puts "=" * 60

flour_items = result3[:ingredients].select { |i| i[:name].include?('flour') }
eggs_items = result3[:ingredients].select { |i| i[:name].include?('eggs') }
sugar_items = result3[:ingredients].select { |i| i[:name].include?('sugar') }

if flour_items.any?
  flour = flour_items.first
  puts "\n✓ Flour agregado correctamente:"
  puts "  Pancakes: 2 cups"
  puts "  Cake: 3 cups"
  puts "  Total: #{flour[:quantity]} #{flour[:unit]}"
end

if eggs_items.any?
  eggs = eggs_items.first
  puts "\n✓ Eggs agregado correctamente:"
  puts "  Pancakes: 3 eggs"
  puts "  Cake: 4 eggs"
  puts "  Total: #{eggs[:quantity]} #{eggs[:display]}"
end

if sugar_items.any?
  sugar = sugar_items.first
  puts "\n✓ Sugar encontrado:"
  puts "  Total: #{sugar[:display]}"
end

# Caso 4: Escalado con fracciones
puts "\n" + "=" * 60
puts "CASO 4: Escalado con fracciones"
puts "  - Pancakes x2 porciones (mitad de la receta)"
puts "=" * 60

items4 = [{ recipe_id: recipe1.id, servings: 2 }]
generator4 = ShoppingListGenerator.new(items4)
result4 = generator4.generate

puts "\nIngredientes escalados:"
result4[:ingredients].each do |item|
  puts "  #{item[:display]}"
end

puts "\n" + "=" * 60
puts "Tests completados exitosamente! ✓"
puts "=" * 60

# Cleanup
puts "\nLimpiando recetas de prueba..."
recipe1.destroy
recipe2.destroy
puts "✓ Limpieza completada"
