import { defineStore } from 'pinia'
import axios from 'axios'

export const useShoppingListStore = defineStore('shoppingList', {
  state: () => ({
    selectedRecipes: [], // [{ recipe, desiredServings }]
    shoppingList: null, // Resultado del API
    isLoading: false,
    error: null,
    checkedItems: {} // { 'flour': true, 'eggs': false } - persisted to localStorage
  }),

  getters: {
    selectedCount: (state) => state.selectedRecipes.length,
    
    totalRecipeServings: (state) => {
      return state.selectedRecipes.reduce((total, item) => total + item.desiredServings, 0)
    },
    
    isRecipeSelected: (state) => (recipeId) => {
      return state.selectedRecipes.some(item => item.recipe.id === recipeId)
    },
    
    hasItems: (state) => state.selectedRecipes.length > 0,
    
    hasGeneratedList: (state) => state.shoppingList !== null,
    
    // Group ingredients by first letter
    groupedIngredients: (state) => {
      if (!state.shoppingList?.ingredients) return {}
      
      return state.shoppingList.ingredients.reduce((groups, ingredient) => {
        const firstLetter = ingredient.name.charAt(0).toUpperCase()
        if (!groups[firstLetter]) {
          groups[firstLetter] = []
        }
        groups[firstLetter].push(ingredient)
        return groups
      }, {})
    },
    
    // Calculate progress
    completionProgress: (state) => {
      if (!state.shoppingList?.ingredients?.length) return 0
      
      const totalItems = state.shoppingList.ingredients.length
      const checkedCount = Object.values(state.checkedItems).filter(Boolean).length
      
      return Math.round((checkedCount / totalItems) * 100)
    }
  },

  actions: {
    // Add recipe to shopping cart
    addToCart(recipe) {
      // Check if already added
      const exists = this.selectedRecipes.find(item => item.recipe.id === recipe.id)
      if (exists) {
        console.warn('Recipe already in cart')
        return
      }
      
      this.selectedRecipes.push({
        recipe: recipe,
        desiredServings: recipe.attributes.servings // Default to original servings
      })
      
      this.saveToLocalStorage()
    },
    
    // Remove recipe from cart
    removeFromCart(recipeId) {
      this.selectedRecipes = this.selectedRecipes.filter(
        item => item.recipe.id !== recipeId
      )
      this.saveToLocalStorage()
    },
    
    // Update servings for a recipe
    updateServings(recipeId, servings) {
      const item = this.selectedRecipes.find(item => item.recipe.id === recipeId)
      if (item && servings > 0) {
        item.desiredServings = parseInt(servings)
        this.saveToLocalStorage()
      }
    },
    
    // Clear entire cart
    clearCart() {
      this.selectedRecipes = []
      this.shoppingList = null
      this.checkedItems = {}
      this.saveToLocalStorage()
    },
    
    // Generate shopping list from selected recipes
    async generateList() {
      if (this.selectedRecipes.length === 0) {
        this.error = 'Please add at least one recipe'
        return false
      }
      
      this.isLoading = true
      this.error = null
      
      try {
        // Prepare items for API
        const items = this.selectedRecipes.map(item => ({
          recipe_id: item.recipe.id,
          servings: item.desiredServings
        }))
        
        const response = await axios.post('/api/v1/shopping_lists/generate', {
          items: items
        })
        
        if (response.data.success) {
          this.shoppingList = response.data.shopping_list
          this.checkedItems = {} // Reset checked items
          this.loadCheckedItems() // Load from localStorage if exists
          return true
        } else {
          this.error = 'Failed to generate shopping list'
          return false
        }
      } catch (error) {
        console.error('Error generating shopping list:', error)
        this.error = error.response?.data?.error || 'Failed to generate shopping list. Please try again.'
        return false
      } finally {
        this.isLoading = false
      }
    },
    
    // Toggle item checked status
    toggleItemChecked(itemKey) {
      this.checkedItems[itemKey] = !this.checkedItems[itemKey]
      this.saveCheckedItems()
    },
    
    // Check all items
    checkAllItems() {
      if (!this.shoppingList?.ingredients) return
      
      this.shoppingList.ingredients.forEach(item => {
        const key = this.getItemKey(item)
        this.checkedItems[key] = true
      })
      this.saveCheckedItems()
    },
    
    // Uncheck all items
    uncheckAllItems() {
      this.checkedItems = {}
      this.saveCheckedItems()
    },
    
    // Get unique key for an ingredient
    getItemKey(item) {
      return `${item.unit || 'no-unit'}-${item.name}`.toLowerCase()
    },
    
    // Reset shopping list but keep selected recipes
    resetShoppingList() {
      this.shoppingList = null
      this.checkedItems = {}
      this.error = null
      localStorage.removeItem('shopping_list_checked')
    },
    
    // Start over - clear everything
    startOver() {
      this.clearCart()
      localStorage.removeItem('shopping_list_selected')
      localStorage.removeItem('shopping_list_checked')
    },
    
    // Persistence methods
    saveToLocalStorage() {
      try {
        // Save only minimal data (recipe IDs and servings)
        const data = this.selectedRecipes.map(item => ({
          recipeId: item.recipe.id,
          desiredServings: item.desiredServings,
          // Store minimal recipe data for offline access
          recipeData: {
            id: item.recipe.id,
            title: item.recipe.attributes.title,
            servings: item.recipe.attributes.servings,
            imageUrl: item.recipe.attributes.imageUrl
          }
        }))
        localStorage.setItem('shopping_list_selected', JSON.stringify(data))
      } catch (error) {
        console.error('Error saving to localStorage:', error)
      }
    },
    
    loadFromLocalStorage() {
      try {
        const stored = localStorage.getItem('shopping_list_selected')
        if (stored) {
          const data = JSON.parse(stored)
          this.selectedRecipes = data.map(item => ({
            recipe: {
              id: item.recipeId,
              attributes: item.recipeData
            },
            desiredServings: item.desiredServings
          }))
        }
      } catch (error) {
        console.error('Error loading from localStorage:', error)
        localStorage.removeItem('shopping_list_selected')
      }
    },
    
    saveCheckedItems() {
      try {
        localStorage.setItem('shopping_list_checked', JSON.stringify(this.checkedItems))
      } catch (error) {
        console.error('Error saving checked items:', error)
      }
    },
    
    loadCheckedItems() {
      try {
        const stored = localStorage.getItem('shopping_list_checked')
        if (stored) {
          this.checkedItems = JSON.parse(stored)
        }
      } catch (error) {
        console.error('Error loading checked items:', error)
        localStorage.removeItem('shopping_list_checked')
      }
    }
  }
})
