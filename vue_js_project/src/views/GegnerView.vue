<template>
  <div class="gegner-view">
    <div class="header">
      <h1>Gegner</h1>
      <div class="search-wrapper">
        <input
          type="text"
          class="search-input"
          placeholder="Gegner suchen..."
        >
        <span class="search-icon">🔍</span>
      </div>
      <button class="filter-btn" @click="toggleFilter">
        ⚙️ Filter
      </button>
      <router-link to="/" class="close-btn">✕</router-link>
    </div>

    <!-- Filter Panel -->
    <transition name="slide">
      <div v-if="showFilter" class="filter-panel">
        <div class="filter-section">
          <h3>Attribute</h3>
          <div class="attribute-filters">
            <div
              v-for="attr in attributes"
              :key="attr.code"
              class="attribute-filter"
            >
              <label>{{ attr.name }} ({{ attr.code }})</label>
              <div class="range-wrapper">
                <input
                  type="number"
                  v-model.number="filters.attributes[attr.code]"
                  min="0"
                  max="20"
                  class="filter-input"
                >
              </div>
            </div>
          </div>
        </div>

        <div class="filter-section">
          <h3>Creature Type</h3>
          <select v-model="filters.creatureType" class="filter-select">
            <option value="">-- Alle --</option>
            <option value="Humanoid">Humanoid</option>
            <option value="Beast">Beast</option>
            <option value="Undead">Undead</option>
            <option value="Elemental">Elemental</option>
            <option value="Dragon">Dragon</option>
          </select>
        </div>

        <div class="filter-section">
          <h3>Challenge Rating</h3>
          <select v-model="filters.challengeRating" class="filter-select">
            <option value="">-- Alle --</option>
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
          </select>
        </div>

        <div class="filter-actions">
          <button @click="resetFilters" class="reset-btn">Zurücksetzen</button>
        </div>
      </div>
    </transition>

    <div class="content">
      <!-- Gegner werden hier angezeigt -->
    </div>

    <button class="add-btn">+</button>
  </div>
</template>

<script>
export default {
  name: 'GegnerView',
  data() {
    return {
      showFilter: false,
      attributes: [
        { code: 'MU', name: 'Mut' },
        { code: 'KL', name: 'Klugheit' },
        { code: 'IN', name: 'Intuition' },
        { code: 'CH', name: 'Charisma' },
        { code: 'FF', name: 'Fingerfertigkeit' },
        { code: 'GE', name: 'Gewandtheit' },
        { code: 'KO', name: 'Konstitution' },
        { code: 'KK', name: 'Körperkraft' }
      ],
      filters: {
        attributes: {
          MU: null,
          KL: null,
          IN: null,
          CH: null,
          FF: null,
          GE: null,
          KO: null,
          KK: null
        },
        creatureType: '',
        challengeRating: ''
      }
    };
  },
  methods: {
    toggleFilter() {
      this.showFilter = !this.showFilter;
    },
    resetFilters() {
      this.filters.attributes = {
        MU: null,
        KL: null,
        IN: null,
        CH: null,
        FF: null,
        GE: null,
        KO: null,
        KK: null
      };
      this.filters.creatureType = '';
      this.filters.challengeRating = '';
    }
  }
};
</script>

<style scoped>
.gegner-view {
  padding: 40px;
  color: #e8dcc4;
  background-color: #1a1a1a;
  min-height: 100vh;
  position: relative;
}

.header {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #c9a961;
  gap: 20px;
}

h1 {
  color: #c9a961;
  font-size: 2.5rem;
  margin: 0;
  white-space: nowrap;
}

.search-wrapper {
  position: relative;
  width: 250px;
}

.search-input {
  width: 100%;
  padding: 12px 40px 12px 15px;
  background-color: #2d2d2d;
  border: 2px solid #8b7355;
  border-radius: 5px;
  color: #e8dcc4;
  font-size: 1rem;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.search-input::placeholder {
  color: #8b7355;
}

.search-input:focus {
  outline: none;
  border-color: #c9a961;
  background-color: rgba(45, 45, 45, 0.8);
  box-shadow: 0 0 10px rgba(201, 169, 97, 0.2);
}

.search-icon {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
  color: #8b7355;
  pointer-events: none;
}

.filter-btn {
  padding: 10px 16px;
  background-color: #2d2d2d;
  color: #c9a961;
  border: 2px solid #8b7355;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  white-space: nowrap;
}

.filter-btn:hover {
  border-color: #c9a961;
  background-color: rgba(201, 169, 97, 0.1);
}

.close-btn {
  font-size: 2rem;
  color: #c9a961;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.3s ease;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #c9a961;
  border-radius: 50%;
  white-space: nowrap;
  margin-left: auto;
}

.close-btn:hover {
  background-color: rgba(201, 169, 97, 0.1);
  transform: scale(1.1);
}

/* Filter Panel */
.filter-panel {
  background-color: #2d2d2d;
  border: 2px solid #c9a961;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 4px 15px rgba(201, 169, 97, 0.2);
}

.filter-section {
  margin-bottom: 25px;
  padding-bottom: 20px;
  border-bottom: 1px solid #8b7355;
}

.filter-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.filter-section h3 {
  color: #c9a961;
  font-size: 1.1rem;
  margin: 0 0 15px 0;
}

.attribute-filters {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.attribute-filter {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.attribute-filter label {
  font-size: 0.9rem;
  color: #e8dcc4;
  font-weight: 500;
}

.range-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-input {
  width: 70px;
  padding: 8px 10px;
  background-color: #1a1a1a;
  border: 2px solid #8b7355;
  border-radius: 4px;
  color: #c9a961;
  font-weight: bold;
  transition: all 0.3s ease;
}

.filter-input:focus {
  outline: none;
  border-color: #c9a961;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.filter-select {
  padding: 10px;
  background-color: #1a1a1a;
  border: 2px solid #8b7355;
  border-radius: 4px;
  color: #e8dcc4;
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.filter-select:hover {
  border-color: #c9a961;
}

.filter-select:focus {
  outline: none;
  border-color: #c9a961;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.filter-select option {
  background-color: #2d2d2d;
  color: #e8dcc4;
}

.filter-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

.reset-btn {
  padding: 10px 20px;
  background-color: #8b7355;
  color: #e8dcc4;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.reset-btn:hover {
  background-color: #c9a961;
  color: #1a1a1a;
}

/* Transition für Filter Panel */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.content {
  margin-bottom: 100px;
}

.add-btn {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background-color: #c9a961;
  color: #1a1a1a;
  border: none;
  font-size: 2.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(201, 169, 97, 0.3);
}

.add-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 25px rgba(201, 169, 97, 0.5);
}

.add-btn:active {
  transform: scale(0.95);
}

@media (max-width: 768px) {
  .header {
    flex-wrap: wrap;
  }

  h1 {
    font-size: 2rem;
    flex: 1 0 auto;
  }

  .search-wrapper {
    flex: 1 0 100%;
    min-width: 200px;
    order: 3;
  }

  .filter-btn {
    font-size: 0.9rem;
  }

  .close-btn {
    width: 40px;
    height: 40px;
    font-size: 1.5rem;
  }

  .attribute-filters {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
