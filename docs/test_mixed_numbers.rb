#!/usr/bin/env ruby
# frozen_string_literal: true

# Script de prueba para validar números mixtos
puts "=" * 60
puts "Testing Mixed Numbers Fix"
puts "=" * 60

# Simular la función parse_quantity
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

# Tests de números mixtos
test_cases = [
  { input: "1 1/4", expected: 1.25, description: "One and one quarter" },
  { input: "2 1/2", expected: 2.5, description: "Two and a half" },
  { input: "3 3/4", expected: 3.75, description: "Three and three quarters" },
  { input: "1/2", expected: 0.5, description: "Simple fraction: one half" },
  { input: "1/4", expected: 0.25, description: "Simple fraction: one quarter" },
  { input: "2", expected: 2.0, description: "Simple integer" },
  { input: "2.5", expected: 2.5, description: "Decimal number" }
]

puts "\nTest Results:"
puts "-" * 60

passed = 0
failed = 0

test_cases.each do |test|
  result = parse_quantity(test[:input])
  status = result == test[:expected] ? "✓ PASS" : "✗ FAIL"
  
  if result == test[:expected]
    passed += 1
    puts "#{status} | #{test[:description]}"
    puts "       Input: '#{test[:input]}' → Output: #{result}"
  else
    failed += 1
    puts "#{status} | #{test[:description]}"
    puts "       Input: '#{test[:input]}'"
    puts "       Expected: #{test[:expected]}, Got: #{result}"
  end
  puts
end

puts "=" * 60
puts "Summary: #{passed} passed, #{failed} failed"
puts "=" * 60

# Test regex patterns
puts "\nRegex Pattern Tests:"
puts "-" * 60

regex = /(?<qty>\d+(?:\s+\d+\/\d+)?(?:\/\d+)?(?:\.\d+)?)\s+(?<unit>[a-zA-Z]+)\s+(?<name>.+)/i

ingredient_tests = [
  "1 1/4 cups flour",
  "2 1/2 tablespoons butter",
  "3 3/4 teaspoons baking powder",
  "1/2 cup sugar",
  "2 cups flour",
  "3 eggs"
]

ingredient_tests.each do |ingredient|
  match = ingredient.match(regex)
  if match
    qty = parse_quantity(match[:qty])
    puts "✓ '#{ingredient}'"
    puts "  Quantity: #{match[:qty]} → #{qty}"
    puts "  Unit: #{match[:unit]}"
    puts "  Name: #{match[:name]}"
  else
    puts "✗ Failed to parse: '#{ingredient}'"
  end
  puts
end

puts "=" * 60
puts "Testing Complete!"
puts "=" * 60
