import { createRouter, createWebHistory } from 'vue-router'

// Lazy load route components
const HomeView = () => import('../views/HomeView.vue')
const RecipeView = () => import('../views/RecipeView.vue')
const RecipeForm = () => import('../views/RecipeForm.vue')
const CategoriesView = () => import('../views/CategoriesView.vue')
const ShoppingListSetupView = () => import('../views/ShoppingListSetupView.vue')
const ShoppingListView = () => import('../views/ShoppingListView.vue')

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/recipes/new',
    name: 'new-recipe',
    component: RecipeForm
  },
  {
    path: '/recipes/:id/edit',
    name: 'edit-recipe',
    component: RecipeForm,
    props: true
  },
  {
    path: '/recipes/:id',
    name: 'recipe',
    component: RecipeView,
    props: true
  },
  {
    path: '/categories',
    name: 'categories',
    component: CategoriesView
  },
  {
    path: '/shopping-list/setup',
    name: 'shopping-list-setup',
    component: ShoppingListSetupView,
    meta: { title: 'Shopping List Setup' }
  },
  {
    path: '/shopping-list',
    name: 'shopping-list',
    component: ShoppingListView,
    meta: { title: 'Shopping List' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

export default router
