<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center mb-4">
        <router-link to="/" class="text-indigo-600 hover:text-indigo-800 mr-3">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <h1 class="text-3xl font-bold text-gray-900">Shopping List Setup</h1>
      </div>
      <p class="text-gray-600">Adjust servings for each recipe and generate your shopping list</p>
    </div>

    <!-- Empty State -->
    <div v-if="!shoppingListStore.hasItems" class="text-center py-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No recipes selected</h3>
      <p class="mt-1 text-sm text-gray-500">Go back to recipes and add some to your shopping list</p>
      <div class="mt-6">
        <router-link
          to="/"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700"
        >
          Browse Recipes
        </router-link>
      </div>
    </div>

    <!-- Recipe List -->
    <div v-else>
      <!-- Summary Card -->
      <div class="bg-indigo-50 border border-indigo-200 rounded-lg p-4 mb-6">
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <svg class="h-5 w-5 text-indigo-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
            </svg>
            <span class="text-sm font-medium text-indigo-900">
              {{ shoppingListStore.selectedCount }} {{ shoppingListStore.selectedCount === 1 ? 'recipe' : 'recipes' }} selected
            </span>
          </div>
          <button
            @click="clearAll"
            class="text-sm text-indigo-600 hover:text-indigo-800 font-medium"
          >
            Clear All
          </button>
        </div>
      </div>

      <!-- Selected Recipes -->
      <div class="space-y-4 mb-8">
        <div
          v-for="item in shoppingListStore.selectedRecipes"
          :key="item.recipe.id"
          class="bg-white rounded-lg shadow p-4"
        >
          <div class="flex items-start">
            <!-- Recipe Image -->
            <div class="shrink-0 w-20 h-20 rounded-lg bg-gray-200 overflow-hidden mr-4">
              <img
                v-if="item.recipe.attributes.imageUrl"
                :src="item.recipe.attributes.imageUrl"
                :alt="item.recipe.attributes.title"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center text-gray-400">
                <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
            </div>

            <!-- Recipe Info -->
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-900 mb-1">
                {{ item.recipe.attributes.title }}
              </h3>
              <p class="text-sm text-gray-500 mb-3">
                Original: {{ item.recipe.attributes.servings }} servings
              </p>

              <!-- Servings Adjuster -->
              <div class="flex items-center space-x-3">
                <label class="text-sm font-medium text-gray-700">
                  Servings:
                </label>
                <div class="flex items-center">
                  <button
                    @click="decrementServings(item.recipe.id)"
                    :disabled="item.desiredServings <= 1"
                    class="inline-flex items-center justify-center w-8 h-8 border border-gray-300 rounded-l-md bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <svg class="h-4 w-4 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4" />
                    </svg>
                  </button>
                  <input
                    type="number"
                    min="1"
                    :value="item.desiredServings"
                    @input="updateServings(item.recipe.id, $event.target.value)"
                    class="w-16 text-center border-t border-b border-gray-300 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                  />
                  <button
                    @click="incrementServings(item.recipe.id)"
                    class="inline-flex items-center justify-center w-8 h-8 border border-gray-300 rounded-r-md bg-white hover:bg-gray-50"
                  >
                    <svg class="h-4 w-4 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                  </button>
                </div>
                <span v-if="item.desiredServings !== item.recipe.attributes.servings" class="text-sm text-indigo-600">
                  ({{ getScaleFactor(item) }}x)
                </span>
              </div>
            </div>

            <!-- Remove Button -->
            <button
              @click="removeRecipe(item.recipe.id)"
              class="shrink-0 ml-4 text-gray-400 hover:text-red-600 transition-colors"
            >
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="shoppingListStore.error" class="bg-red-50 border-l-4 border-red-500 p-4 mb-6">
        <div class="flex">
          <div class="shrink-0">
            <svg class="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <p class="text-sm text-red-700">{{ shoppingListStore.error }}</p>
          </div>
        </div>
      </div>

      <!-- Generate Button -->
      <div class="flex justify-end space-x-3">
        <router-link
          to="/"
          class="px-6 py-3 border border-gray-300 rounded-md text-base font-medium text-gray-700 bg-white hover:bg-gray-50"
        >
          Add More Recipes
        </router-link>
        <button
          @click="generateList"
          :disabled="shoppingListStore.isLoading"
          class="px-6 py-3 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
        >
          <svg v-if="shoppingListStore.isLoading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <svg v-else class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
          </svg>
          {{ shoppingListStore.isLoading ? 'Generating...' : 'Generate Shopping List' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useShoppingListStore } from '../stores/shoppingList'
import { useRouter } from 'vue-router'

const shoppingListStore = useShoppingListStore()
const router = useRouter()

const updateServings = (recipeId, value) => {
  const servings = parseInt(value)
  if (servings > 0) {
    shoppingListStore.updateServings(recipeId, servings)
  }
}

const incrementServings = (recipeId) => {
  const item = shoppingListStore.selectedRecipes.find(i => i.recipe.id === recipeId)
  if (item) {
    shoppingListStore.updateServings(recipeId, item.desiredServings + 1)
  }
}

const decrementServings = (recipeId) => {
  const item = shoppingListStore.selectedRecipes.find(i => i.recipe.id === recipeId)
  if (item && item.desiredServings > 1) {
    shoppingListStore.updateServings(recipeId, item.desiredServings - 1)
  }
}

const removeRecipe = (recipeId) => {
  if (confirm('Remove this recipe from your shopping list?')) {
    shoppingListStore.removeFromCart(recipeId)
  }
}

const clearAll = () => {
  if (confirm('Clear all recipes from your shopping list?')) {
    shoppingListStore.clearCart()
    router.push('/')
  }
}

const getScaleFactor = (item) => {
  const factor = item.desiredServings / item.recipe.attributes.servings
  return factor.toFixed(1).replace(/\.0$/, '')
}

const generateList = async () => {
  const success = await shoppingListStore.generateList()
  if (success) {
    router.push('/shopping-list')
  }
}
</script>
