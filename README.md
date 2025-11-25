# Recipe Manager

A modern web application for managing and organizing your favorite recipes. Built with Ruby on Rails 7.2 on the backend and Vue.js 3 with Tailwind CSS on the frontend, this application provides a clean, responsive interface for browsing, searching, and managing your recipe collection.

## Features

- 🍽️ Browse and search through your recipe collection
- 📝 Create and edit recipes with rich text formatting
- 🏷️ Categorize recipes with custom categories and colors
- 📱 Responsive design that works on desktop and mobile
- 🖼️ Upload and manage recipe images
- 🔍 Full-text search capabilities
- 📱 Progressive Web App (PWA) ready
- 🛒 **Shopping List Generator** - NEW! Generate aggregated shopping lists from multiple recipes

## Tech Stack

- **Backend**: Ruby on Rails 7.2
- **Frontend**: Vue.js 3, Pinia (state management)
- **Styling**: Tailwind CSS
- **Database**: SQLite (development), PostgreSQL (production-ready)
- **Build Tool**: esbuild
- **Icons**: Heroicons

## Prerequisites

- Ruby 3.4.4
- Node.js 16+ & Yarn
- SQLite3

## Getting Started

### Prerequisites

- Docker (recommended for easiest setup)
- OR for manual setup:
  - Ruby 3.4.4
  - Node.js 16+ & Yarn
  - SQLite3 (development)

### 1. Clone the repository

```bash
git clone https://github.com/pulsoescolar/recipe-manager.git
cd recipe-manager
```

### 2. Choose your setup method:

#### Option A: Quick Start with Docker (Recommended)

```bash
# Make the script executable if needed
chmod +x docker-dev.sh

# Start the development environment
./docker-dev.sh
```

This will:
- Build the development Docker image
- Set up the database
- Start the development servers
- The application will be available at http://localhost:3000

#### Option B: Manual Setup (without Docker)

1. **Install dependencies**
   ```bash
   # Install Ruby dependencies
   bundle install
   
   # Install JavaScript dependencies
   yarn install
   ```

3. **Set up the database**
   ```bash
   # Create and migrate the database
   rails db:create db:migrate
   
   # Optional: Seed with sample data
   rails db:seed
   ```

4. **Start the development servers**
   ```bash
   # Start Rails server and assets watchers
   bin/dev
   ```
   The application will be available at http://localhost:3000

## 🛒 Shopping List Feature

### NEW: Generate Smart Shopping Lists!

Select multiple recipes, adjust servings, and automatically generate an aggregated shopping list. The system intelligently:
- Parses ingredient quantities and units
- Scales recipes based on desired servings
- Combines duplicate ingredients
- Groups items alphabetically for easy shopping

**Quick Start:**
1. Browse recipes and click "Add to Shopping List"
2. Click the shopping list badge in the navbar
3. Adjust servings for each recipe
4. Click "Generate Shopping List"
5. Check off items as you shop!

**Documentation:**
- [Quick Start Guide](docs/SHOPPING_LIST_QUICKSTART.md)
- [API Documentation](docs/SHOPPING_LIST_API.md)
- [Frontend Guide](docs/SHOPPING_LIST_FRONTEND.md)
- [Full Plan](docs/SHOPPING_LIST_PLAN.md)

**API Endpoint:**
```bash
POST /api/v1/shopping_lists/generate
{
  "items": [
    { "recipe_id": 1, "servings": 4 },
    { "recipe_id": 5, "servings": 2 }
  ]
}
```

**Testing:**
```bash
# Run shopping list tests
bin/rails test test/services/shopping_list_generator_test.rb
bin/rails test test/controllers/api/v1/shopping_lists_controller_test.rb
```
