# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @recipe1 = recipes(:one)
        @recipe2 = recipes(:two)
        
        @recipe1.update!(
          title: 'Pancakes',
          servings: 4,
          ingredients: "2 cups flour\n1 cup milk\n3 eggs"
        )
        
        @recipe2.update!(
          title: 'Cake',
          servings: 8,
          ingredients: "3 cups flour\n2 cups sugar"
        )
      end

      test "should generate shopping list successfully" do
        post api_v1_shopping_lists_generate_url, 
          params: {
            items: [
              { recipe_id: @recipe1.id, servings: 4 },
              { recipe_id: @recipe2.id, servings: 8 }
            ]
          },
          as: :json

        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert json_response['success']
        assert_not_nil json_response['shopping_list']
        assert_not_nil json_response['shopping_list']['ingredients']
        assert_equal 2, json_response['metadata']['recipes_count']
      end

      test "should return error for empty items" do
        post api_v1_shopping_lists_generate_url,
          params: { items: [] },
          as: :json

        assert_response :bad_request
        json_response = JSON.parse(response.body)
        assert json_response['error']
      end

      test "should return error for missing recipe_id" do
        post api_v1_shopping_lists_generate_url,
          params: {
            items: [{ servings: 4 }]
          },
          as: :json

        assert_response :bad_request
        json_response = JSON.parse(response.body)
        assert json_response['error']
      end

      test "should return error for invalid servings" do
        post api_v1_shopping_lists_generate_url,
          params: {
            items: [{ recipe_id: @recipe1.id, servings: 0 }]
          },
          as: :json

        assert_response :bad_request
        json_response = JSON.parse(response.body)
        assert json_response['error']
      end

      test "should return not found for non-existent recipe" do
        post api_v1_shopping_lists_generate_url,
          params: {
            items: [{ recipe_id: 99999, servings: 4 }]
          },
          as: :json

        assert_response :not_found
        json_response = JSON.parse(response.body)
        assert json_response['error']
      end

      test "should aggregate ingredients from multiple recipes" do
        post api_v1_shopping_lists_generate_url,
          params: {
            items: [
              { recipe_id: @recipe1.id, servings: 4 },
              { recipe_id: @recipe2.id, servings: 8 }
            ]
          },
          as: :json

        assert_response :success
        
        json_response = JSON.parse(response.body)
        ingredients = json_response['shopping_list']['ingredients']
        
        # Verificar que flour se agregó (2 + 3 = 5 cups)
        flour = ingredients.find { |i| i['name'].include?('flour') }
        assert_not_nil flour
        assert_equal 5, flour['quantity']
      end

      test "should scale ingredients correctly" do
        post api_v1_shopping_lists_generate_url,
          params: {
            items: [
              { recipe_id: @recipe1.id, servings: 8 } # Doblar la receta
            ]
          },
          as: :json

        assert_response :success
        
        json_response = JSON.parse(response.body)
        ingredients = json_response['shopping_list']['ingredients']
        
        flour = ingredients.find { |i| i['name'].include?('flour') }
        assert_equal 4, flour['quantity'] # 2 * 2
      end
    end
  end
end
