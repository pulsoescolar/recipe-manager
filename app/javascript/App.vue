<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="shrink-0 flex items-center">
              <router-link to="/" class="text-xl font-bold text-indigo-600">
                Recipe Manager
              </router-link>
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <router-link 
                to="/" 
                class="inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
                active-class="border-indigo-500 text-gray-900"
                exact
              >
                Recipes
              </router-link>
              <router-link 
                to="/categories" 
                class="inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
                active-class="border-indigo-500 text-gray-900"
              >
                Categories
              </router-link>
            </div>
          </div>
          
          <!-- Shopping List Badge -->
          <div class="flex items-center">
            <router-link
              v-if="shoppingListStore.hasItems"
              to="/shopping-list/setup"
              class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-indigo-600 hover:text-indigo-800 transition-colors"
            >
              <svg class="h-6 w-6 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <span class="hidden sm:inline">Shopping List</span>
              <span class="absolute -top-1 -right-1 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-indigo-600 rounded-full">
                {{ shoppingListStore.selectedCount }}
              </span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRecipeStore } from './stores/recipe'
import { useCategoryStore } from './stores/category'
import { useShoppingListStore } from './stores/shoppingList'

const recipeStore = useRecipeStore()
const categoryStore = useCategoryStore()
const shoppingListStore = useShoppingListStore()

onMounted(async () => {
  await categoryStore.fetchCategories()
  await recipeStore.fetchRecipes()
  shoppingListStore.loadFromLocalStorage()
})
</script>
