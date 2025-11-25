# frozen_string_literal: true

module Api
  module V1
    class ShoppingListsController < BaseController
      # POST /api/v1/shopping_lists/generate
      # Body: { items: [{ recipe_id: 1, servings: 4 }, { recipe_id: 5, servings: 2 }] }
      def generate
        items = shopping_list_params[:items]
        
        if items.blank? || !items.is_a?(Array)
          return render json: { 
            error: 'Items array is required' 
          }, status: :bad_request
        end

        # Validar que todos los items tengan recipe_id y servings
        invalid_items = items.select do |item|
          item[:recipe_id].blank? || item[:servings].blank? || item[:servings].to_i <= 0
        end

        if invalid_items.any?
          return render json: {
            error: 'All items must have recipe_id and servings (greater than 0)',
            invalid_items: invalid_items
          }, status: :bad_request
        end

        # Generar la lista de compras
        begin
          generator = ShoppingListGenerator.new(items)
          shopping_list = generator.generate
          
          render json: {
            success: true,
            shopping_list: shopping_list,
            metadata: {
              recipes_count: items.count,
              generated_at: Time.current.iso8601
            }
          }, status: :ok
        rescue ActiveRecord::RecordNotFound => e
          render json: { 
            error: "Recipe not found: #{e.message}" 
          }, status: :not_found
        rescue StandardError => e
          Rails.logger.error "ShoppingListGenerator error: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: { 
            error: 'An error occurred while generating the shopping list',
            details: Rails.env.development? ? e.message : nil
          }, status: :internal_server_error
        end
      end

      private

      def shopping_list_params
        params.permit(items: [:recipe_id, :servings])
      end
    end
  end
end
