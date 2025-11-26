<template>
  <div class="container mx-auto px-4 py-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center">
          <router-link to="/shopping-list/setup" class="text-indigo-600 hover:text-indigo-800 mr-3">
            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
          </router-link>
          <h1 class="text-3xl font-bold text-gray-900">Shopping List</h1>
        </div>
        <div class="flex items-center space-x-3">
          <button
            @click="printList"
            class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            <svg class="h-4 w-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
            </svg>
            Print
          </button>
          <button
            @click="startOver"
            class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            <svg class="h-4 w-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Start Over
          </button>
        </div>
      </div>
    </div>

    <!-- No List State -->
    <div v-if="!shoppingListStore.hasGeneratedList" class="text-center py-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No shopping list generated</h3>
      <p class="mt-1 text-sm text-gray-500">Create a shopping list from your selected recipes</p>
      <div class="mt-6">
        <router-link
          to="/shopping-list/setup"
          class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700"
        >
          Go to Setup
        </router-link>
      </div>
    </div>

    <!-- Shopping List Content -->
    <div v-else>
      <!-- Progress Card -->
      <div class="bg-white rounded-lg shadow p-6 mb-6">
        <div class="flex items-center justify-between mb-3">
          <div>
            <h3 class="text-lg font-semibold text-gray-900">Your Shopping List</h3>
            <p class="text-sm text-gray-500">
              {{ shoppingListStore.shoppingList.total_items }} items from {{ shoppingListStore.selectedCount }} recipes
            </p>
          </div>
          <div class="text-right">
            <div class="text-2xl font-bold text-indigo-600">{{ completionProgress }}%</div>
            <div class="text-xs text-gray-500">Complete</div>
          </div>
        </div>
        
        <!-- Progress Bar -->
        <div class="w-full bg-gray-200 rounded-full h-2.5">
          <div
            class="bg-indigo-600 h-2.5 rounded-full transition-all duration-300"
            :style="{ width: `${completionProgress}%` }"
          ></div>
        </div>
        
        <!-- Quick Actions -->
        <div class="mt-4 flex space-x-2">
          <button
            @click="checkAll"
            class="text-sm text-indigo-600 hover:text-indigo-800 font-medium"
          >
            Check All
          </button>
          <span class="text-gray-300">|</span>
          <button
            @click="uncheckAll"
            class="text-sm text-indigo-600 hover:text-indigo-800 font-medium"
          >
            Uncheck All
          </button>
        </div>
      </div>

      <!-- Grouped Ingredients -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <div v-for="(items, letter) in groupedIngredients" :key="letter" class="border-b border-gray-200 last:border-b-0">
          <!-- Letter Header -->
          <div class="bg-gray-50 px-6 py-3 sticky top-0 z-10">
            <h3 class="text-lg font-bold text-gray-900">{{ letter }}</h3>
          </div>
          
          <!-- Ingredients List -->
          <ul class="divide-y divide-gray-100">
            <li
              v-for="(item, index) in items"
              :key="index"
              class="px-6 py-4 hover:bg-gray-50 transition-colors"
            >
              <label class="flex items-start cursor-pointer">
                <input
                  type="checkbox"
                  :checked="isItemChecked(item)"
                  @change="toggleItem(item)"
                  class="mt-1 h-5 w-5 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                />
                <div class="ml-4 flex-1">
                  <div class="flex items-center justify-between">
                    <span
                      class="text-base font-medium transition-all"
                      :class="isItemChecked(item) ? 'text-gray-400 line-through' : 'text-gray-900'"
                    >
                      {{ item.display }}
                    </span>
                    <span
                      v-if="item.quantity"
                      class="text-sm font-semibold px-2 py-1 rounded"
                      :class="isItemChecked(item) ? 'text-gray-400 bg-gray-100' : 'text-indigo-600 bg-indigo-50'"
                    >
                      {{ item.quantity }} {{ item.unit }}
                    </span>
                  </div>
                </div>
              </label>
            </li>
          </ul>
        </div>
      </div>

      <!-- Ingredients Without Quantity -->
      <div v-if="shoppingListStore.shoppingList.ingredients_without_quantity?.length" class="bg-white rounded-lg shadow overflow-hidden mt-6">
        <div class="bg-amber-50 px-6 py-3">
          <h3 class="text-lg font-bold text-amber-900">Optional Items (To Taste)</h3>
        </div>
        <ul class="divide-y divide-gray-100">
          <li
            v-for="(item, index) in shoppingListStore.shoppingList.ingredients_without_quantity"
            :key="`no-qty-${index}`"
            class="px-6 py-4 hover:bg-gray-50"
          >
            <div class="flex items-start">
              <svg class="h-5 w-5 text-amber-500 mt-0.5 mr-3 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <div>
                <p class="text-base font-medium text-gray-900">{{ item.name }}</p>
                <p class="text-sm text-gray-500">{{ item.note || 'As needed' }}</p>
              </div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Bottom Actions -->
      <div class="mt-8 flex justify-between items-center">
        <router-link
          to="/"
          class="inline-flex items-center text-indigo-600 hover:text-indigo-800"
        >
          <svg class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to Recipes
        </router-link>
        
        <button
          v-if="completionProgress === 100"
          @click="celebrate"
          class="inline-flex items-center px-6 py-3 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-green-600 hover:bg-green-700"
        >
          <svg class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Shopping Complete!
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useShoppingListStore } from '../stores/shoppingList'
import { useRouter } from 'vue-router'

const shoppingListStore = useShoppingListStore()
const router = useRouter()

const groupedIngredients = computed(() => shoppingListStore.groupedIngredients)
const completionProgress = computed(() => shoppingListStore.completionProgress)

const isItemChecked = (item) => {
  const key = shoppingListStore.getItemKey(item)
  return shoppingListStore.checkedItems[key] || false
}

const toggleItem = (item) => {
  const key = shoppingListStore.getItemKey(item)
  shoppingListStore.toggleItemChecked(key)
}

const checkAll = () => {
  shoppingListStore.checkAllItems()
}

const uncheckAll = () => {
  shoppingListStore.uncheckAllItems()
}

const printList = () => {
  window.print()
}

const startOver = () => {
  if (confirm('This will clear your shopping list and selected recipes. Continue?')) {
    shoppingListStore.startOver()
    router.push('/')
  }
}

const celebrate = () => {
  alert('🎉 Congratulations! You\'ve completed your shopping!')
}
</script>

<style scoped>
@media print {
  .container {
    max-width: 100%;
  }
  
  button,
  a[href] {
    display: none !important;
  }
  
  .bg-white {
    box-shadow: none !important;
  }
}
</style>
