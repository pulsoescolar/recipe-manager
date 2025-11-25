# frozen_string_literal: true

require 'test_helper'

class ShoppingListGeneratorTest < ActiveSupport::TestCase
  setup do
    @recipe1 = recipes(:one) # Asume que existe en fixtures
    @recipe2 = recipes(:two)
    
    # Configurar ingredientes de prueba
    @recipe1.update!(
      title: 'Pancakes',
      servings: 4,
      ingredients: "2 cups flour\n1 cup milk\n3 eggs\n1/2 teaspoon salt"
    )
    
    @recipe2.update!(
      title: 'Cake',
      servings: 8,
      ingredients: "3 cups flour\n2 cups sugar\n4 eggs\n1 teaspoon vanilla extract"
    )
  end

  test "should parse ingredients with quantity and unit" do
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    assert_not_nil result[:ingredients]
    assert result[:ingredients].any? { |i| i[:name].include?('flour') }
    assert result[:ingredients].any? { |i| i[:name].include?('milk') }
  end

  test "should scale ingredients correctly" do
    # Doblar la receta (de 4 a 8 porciones)
    items = [{ recipe_id: @recipe1.id, servings: 8 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_not_nil flour_item
    assert_equal 4, flour_item[:quantity] # 2 cups * 2
  end

  test "should aggregate ingredients from multiple recipes" do
    # Ambas recetas usan flour y eggs
    items = [
      { recipe_id: @recipe1.id, servings: 4 },
      { recipe_id: @recipe2.id, servings: 8 }
    ]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_not_nil flour_item
    assert_equal 5, flour_item[:quantity] # 2 + 3 cups

    eggs_item = result[:ingredients].find { |i| i[:name].include?('eggs') }
    assert_not_nil eggs_item
    assert_equal 7, eggs_item[:quantity] # 3 + 4 eggs
  end

  test "should handle fractional quantities" do
    @recipe1.update!(ingredients: "1/2 cup sugar\n1/4 teaspoon salt")
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    assert result[:ingredients].any? { |i| i[:name].include?('sugar') }
    assert result[:ingredients].any? { |i| i[:name].include?('salt') }
  end

  test "should handle mixed numbers like 1 1/4 or 2 1/2" do
    @recipe1.update!(
      ingredients: "1 1/4 cups flour\n2 1/2 tablespoons butter\n3 3/4 teaspoons baking powder"
    )
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    # Verificar que flour fue parseado correctamente
    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_not_nil flour_item, "Flour should be found"
    assert_equal 1.25, flour_item[:quantity], "1 1/4 should equal 1.25"
    
    # Verificar butter
    butter_item = result[:ingredients].find { |i| i[:name].include?('butter') }
    assert_not_nil butter_item, "Butter should be found"
    assert_equal 2.5, butter_item[:quantity], "2 1/2 should equal 2.5"
    
    # Verificar baking powder
    powder_item = result[:ingredients].find { |i| i[:name].include?('baking powder') }
    assert_not_nil powder_item, "Baking powder should be found"
    assert_equal 3.75, powder_item[:quantity], "3 3/4 should equal 3.75"
  end

  test "should scale mixed numbers correctly" do
    @recipe1.update!(
      servings: 4,
      ingredients: "1 1/2 cups flour"
    )
    # Doblar la receta (4 -> 8 servings)
    items = [{ recipe_id: @recipe1.id, servings: 8 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_not_nil flour_item
    # 1.5 * 2 = 3.0
    assert_equal 3, flour_item[:quantity], "1 1/2 doubled should be 3"
  end

  test "should aggregate mixed numbers from multiple recipes" do
    @recipe1.update!(
      servings: 4,
      ingredients: "1 1/4 cups flour"
    )
    @recipe2.update!(
      servings: 4,
      ingredients: "2 3/4 cups flour"
    )
    items = [
      { recipe_id: @recipe1.id, servings: 4 },
      { recipe_id: @recipe2.id, servings: 4 }
    ]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_not_nil flour_item
    # 1.25 + 2.75 = 4.0
    assert_equal 4, flour_item[:quantity], "1 1/4 + 2 3/4 should equal 4"
  end

  test "should normalize units" do
    @recipe1.update!(ingredients: "2 cups flour\n3 tablespoons butter")
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    flour_item = result[:ingredients].find { |i| i[:name].include?('flour') }
    assert_equal 'cup', flour_item[:unit]

    butter_item = result[:ingredients].find { |i| i[:name].include?('butter') }
    assert_equal 'tablespoon', butter_item[:unit]
  end

  test "should handle ingredients without quantity" do
    @recipe1.update!(ingredients: "2 cups flour\nsalt to taste")
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    assert_not_nil result[:ingredients_without_quantity]
    assert result[:ingredients_without_quantity].any? { |i| i[:name].include?('salt') }
  end

  test "should return correct total items count" do
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    expected_count = result[:ingredients].count + result[:ingredients_without_quantity].count
    assert_equal expected_count, result[:total_items]
  end

  test "should format display strings correctly" do
    items = [{ recipe_id: @recipe1.id, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    result[:ingredients].each do |item|
      assert_not_nil item[:display]
      assert item[:display].is_a?(String)
      assert item[:display].length > 0
    end
  end

  test "should handle empty items array" do
    generator = ShoppingListGenerator.new([])
    result = generator.generate

    assert_equal 0, result[:total_items]
    assert_empty result[:ingredients]
    assert_empty result[:ingredients_without_quantity]
  end

  test "should handle recipe not found gracefully" do
    items = [{ recipe_id: 99999, servings: 4 }]
    generator = ShoppingListGenerator.new(items)
    result = generator.generate

    # Debería devolver lista vacía o manejar el error
    assert_not_nil result
  end
end
