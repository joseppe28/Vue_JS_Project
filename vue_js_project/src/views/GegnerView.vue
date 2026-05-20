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
                  max="100"
                  class="filter-input"
                >
              </div>
            </div>
          </div>
        </div>

        <div class="filter-selects">
          <div class="filter-section">
            <h3>Creature Type</h3>
            <div class="filter-with-chips">
              <div class="dropdown-container">
                <button @click="toggleDropdown('creatureType')" class="dropdown-btn">
                  Auswählen ▼
                </button>
                <div v-if="openDropdown === 'creatureType'" class="dropdown-menu">
                  <div
                    @click="toggleSelectAll('creatureType')"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.creatureType.length === creatureTypes.length && creatureTypes.length > 0 }"
                  >
                    -- Alle --
                  </div>
                  <div
                    v-for="type in creatureTypes"
                    :key="type"
                    @click="toggleSelection('creatureType', type)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.creatureType.includes(type) }"
                  >
                    {{ type }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="type in filters.creatureType"
                  :key="type"
                  class="filter-chip"
                >
                  {{ type }}
                  <button
                    @click="toggleSelection('creatureType', type)"
                    class="chip-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="filter-section">
            <h3>Challenge Rating</h3>
            <div class="filter-with-chips">
              <div class="dropdown-container">
                <button @click="toggleDropdown('challengeRating')" class="dropdown-btn">
                  Auswählen ▼
                </button>
                <div v-if="openDropdown === 'challengeRating'" class="dropdown-menu">
                  <div
                    @click="toggleSelectAll('challengeRating')"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.challengeRating.length === challengeRatings.length && challengeRatings.length > 0 }"
                  >
                    -- Alle --
                  </div>
                  <div
                    v-for="rating in challengeRatings"
                    :key="rating"
                    @click="toggleSelection('challengeRating', rating)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.challengeRating.includes(rating) }"
                  >
                    {{ rating }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="rating in filters.challengeRating"
                  :key="rating"
                  class="filter-chip"
                >
                  {{ rating }}
                  <button
                    @click="toggleSelection('challengeRating', rating)"
                    class="chip-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="filter-section">
            <h3>Waffentyp</h3>
            <div class="filter-with-chips">
              <div class="dropdown-container">
                <button @click="toggleDropdown('weaponType')" class="dropdown-btn">
                  Auswählen ▼
                </button>
                <div v-if="openDropdown === 'weaponType'" class="dropdown-menu">
                  <div
                    @click="toggleSelectAll('weaponType')"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.weaponType.length === weaponTypes.length && weaponTypes.length > 0 }"
                  >
                    -- Alle --
                  </div>
                  <div
                    v-for="weapon in weaponTypes"
                    :key="weapon"
                    @click="toggleSelection('weaponType', weapon)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.weaponType.includes(weapon) }"
                  >
                    {{ weapon }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="weapon in filters.weaponType"
                  :key="weapon"
                  class="filter-chip"
                >
                  {{ weapon }}
                  <button
                    @click="toggleSelection('weaponType', weapon)"
                    class="chip-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="filter-actions">
          <button @click="resetFilters" class="reset-btn">Zurücksetzen</button>
        </div>
      </div>
    </transition>

    <div class="content">
      <div v-if="isLoading" class="muted">Lade Gegner...</div>
      <div v-else-if="loadError" class="muted">{{ loadError }}</div>
      <div v-else-if="!enemies.length" class="muted">Keine Gegner gefunden.</div>

      <div v-else class="enemy-grid">
        <article v-for="enemy in enemies" :key="enemy.id" class="enemy-card">
          <header class="enemy-card__head">
            <div>
              <strong class="enemy-card__name">{{ enemy.name }}</strong>
              <div class="muted small">{{ enemy.creature_type || 'Unbekannter Typ' }}</div>
            </div>
            <div class="enemy-card__chip">CR {{ enemy.challenge_rating || 'n/a' }}</div>
          </header>

          <div class="enemy-card__stats">
            <div class="stat">
              <span class="stat__label">LE</span>
              <strong>{{ getAttributeValue(enemy, 'LE') }}</strong>
            </div>
            <div class="stat">
              <span class="stat__label">INI</span>
              <strong>{{ getAttributeValue(enemy, 'INI') }}</strong>
            </div>
            <div class="stat">
              <span class="stat__label">AW</span>
              <strong>{{ getAttributeValue(enemy, 'AW') }}</strong>
            </div>
            <div class="stat">
              <span class="stat__label">MU</span>
              <strong>{{ getAttributeValue(enemy, 'MU') }}</strong>
            </div>
            <div class="stat">
              <span class="stat__label">KL</span>
              <strong>{{ getAttributeValue(enemy, 'KL') }}</strong>
            </div>
          </div>
        </article>
      </div>
    </div>

    <button class="add-btn" @click="openAddEnemy">+</button>

    <transition name="fade">
      <AddEnemyView v-if="showAddEnemy" @save-enemy="handleSaveEnemy" />
    </transition>
  </div>
</template>

<script>
import AddEnemyView from './AddEnemyView.vue'

export default {
  name: 'GegnerView',
  components: { AddEnemyView },
  data() {
    return {
      showFilter: false,
      showAddEnemy: false,
      supabaseUrl: 'https://dhomjjfeyoeynhunrnbs.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRob21qamZleW9leW5odW5ybmJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MjYwOTIsImV4cCI6MjA5NDIwMjA5Mn0.PaWu0BDYsWL2D4H4U6NoHHwwx2o9tAGt-1L4w2GdK64',
      enemies: [],
      isLoading: false,
      loadError: '',
      openDropdown: null,
      creatureTypes: [
        'Automaten', 'Chimären', 'Daimonide', 'Drachen', 'Dämonen',
        'Elementare', 'Feen und Feenartige', 'Geister', 'Golemiden',
        'Golems', 'Homunculi', 'Kulturschaffende', 'Pflanzen', 'Tiere',
        'Untote', 'Übernatürliche Wesen'
      ],
      challengeRatings: ['1', '2', '3', '4', '5'],
      weaponTypes: [
        'Armbrüste', 'Blasrohre', 'Bögen', 'Diskusse', 'Dolche',
        'Fechtwaffen', 'Feuerspeien', 'Fächer', 'Hiebwaffen', 'Holzwaffen',
        'Kettenwaffen', 'Lanzen', 'Peitschen', 'Raufen', 'Schilde',
        'Schleudern', 'Schwerter', 'Spießwaffen', 'Stangenwaffen',
        'Wurfwaffen', 'Zweihandhiebwaffen', 'Zweihandschwerter'
      ],
      attributes: [
        { code: 'MU', name: 'Mut' },
        { code: 'KL', name: 'Klugheit' },
        { code: 'IN', name: 'Intuition' },
        { code: 'CH', name: 'Charisma' },
        { code: 'FF', name: 'Fingerfertigkeit' },
        { code: 'GE', name: 'Gewandtheit' },
        { code: 'KO', name: 'Konstitution' },
        { code: 'KK', name: 'Körperkraft' },
        { code: 'LE', name: 'Lebensenergie' },
        { code: 'ASP', name: 'Astralenergie' },
        { code: 'KAP', name: 'Karmaenergie' },
        { code: 'GS', name: 'Geschwindigkeit' },
        { code: 'INI', name: 'Initiative' },
        { code: 'AW', name: 'Ausweichen' }
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
          KK: null,
          LE: null,
          ASP: null,
          KAP: null,
          GS: null,
          INI: null,
          AW: null
        },
        creatureType: [],
        challengeRating: [],
        weaponType: []
      }
    };
  },
  methods: {
    toggleDropdown(dropdownName) {
      if (this.openDropdown === dropdownName) {
        this.openDropdown = null;
      } else {
        this.openDropdown = dropdownName;
      }
    },
    toggleSelection(filterType, item) {
      const filterArray = this.filters[filterType];
      const index = filterArray.indexOf(item);
      if (index > -1) {
        filterArray.splice(index, 1);
      } else {
        filterArray.push(item);
      }
    },
    toggleSelectAll(filterType) {
      const dataKey = filterType === 'creatureType' ? 'creatureTypes' :
                      filterType === 'challengeRating' ? 'challengeRatings' :
                      'weaponTypes';
      const allItems = this[dataKey];
      const filterArray = this.filters[filterType];
      
      if (filterArray.length === allItems.length) {
        // Alle sind ausgewählt, also alles deselektieren
        filterArray.length = 0;
      } else {
        // Alles auswählen
        filterArray.length = 0;
        filterArray.push(...allItems);
      }
    },
    toggleFilter() {
      this.showFilter = !this.showFilter;
    },
    openAddEnemy() {
      this.showAddEnemy = true;
    },
    async handleSaveEnemy(enemy) {
      this.showAddEnemy = false;

      try {
        await this.saveEnemyToSupabase(enemy);
        await this.fetchEnemies();
        this.$emit('enemy-added', enemy);
      } catch (error) {
        console.error('Supabase save failed:', error);
        const message = error?.message || 'Unbekannter Fehler';
        alert(`Speichern fehlgeschlagen: ${message}`);
      }
    },
    async saveEnemyToSupabase(enemy) {
      const headers = {
        apikey: this.supabaseAnonKey,
        Authorization: `Bearer ${this.supabaseAnonKey}`,
        'Content-Type': 'application/json',
      };

      const created = await this.fetchJson(
        `${this.supabaseUrl}/rest/v1/enemies`,
        {
          method: 'POST',
          headers: { ...headers, Prefer: 'return=representation' },
          body: JSON.stringify({
            name: enemy.name,
            description: enemy.description,
            creature_type: enemy.type,
            challenge_rating: '1',
            source: 'Manual',
          }),
        }
      );

      const createdEnemy = Array.isArray(created) ? created[0] : created;
      if (!createdEnemy?.id) {
        throw new Error('No enemy id returned from Supabase.');
      }

      const attributeCodes = Object.keys(enemy.attributes || {});
      if (!attributeCodes.length) {
        return;
      }

      const codeList = attributeCodes.map((code) => `"${code}"`).join(',');
      const attributes = await this.fetchJson(
        `${this.supabaseUrl}/rest/v1/attributes?select=id,code&code=in.(${codeList})`,
        { headers }
      );

      const idByCode = new Map(
        (Array.isArray(attributes) ? attributes : []).map((attr) => [attr.code, attr.id])
      );

      const attributeRows = attributeCodes
        .map((code) => ({
          enemy_id: createdEnemy.id,
          attribute_id: idByCode.get(code),
          value: enemy.attributes[code],
        }))
        .filter((row) => row.attribute_id !== undefined && row.value !== null && row.value !== '');

      if (!attributeRows.length) {
        return;
      }

      await this.fetchJson(`${this.supabaseUrl}/rest/v1/enemy_attributes`, {
        method: 'POST',
        headers,
        body: JSON.stringify(attributeRows),
      });
    },
    async fetchEnemies() {
      this.isLoading = true;
      this.loadError = '';

      try {
        const headers = {
          apikey: this.supabaseAnonKey,
          Authorization: `Bearer ${this.supabaseAnonKey}`,
        };
        const data = await this.fetchJson(
          `${this.supabaseUrl}/rest/v1/enemies?select=id,name,creature_type,challenge_rating,enemy_attributes(value,attributes(code))&order=id.desc`,
          { headers }
        );
        this.enemies = Array.isArray(data) ? data : [];
      } catch (error) {
        console.error('Supabase load failed:', error);
        this.loadError = error?.message || 'Konnte Gegner nicht laden.';
      } finally {
        this.isLoading = false;
      }
    },
    async fetchJson(url, options = {}) {
      const response = await fetch(url, options);
      if (!response.ok) {
        const message = await response.text();
        throw new Error(message || `Request failed with ${response.status}`);
      }

      if (response.status === 204) {
        return null;
      }

      return response.json();
    },
    getAttributeValue(enemy, code) {
      const rows = enemy?.enemy_attributes || [];
      const match = rows.find((row) => row?.attributes?.code === code);
      if (!match) {
        return '-';
      }

      return match.value ?? '-';
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
        KK: null,
        LE: null,
        ASP: null,
        KAP: null,
        GS: null,
        INI: null,
        AW: null
      };
      this.filters.creatureType = [];
      this.filters.challengeRating = [];
      this.filters.weaponType = [];
    }
  }
  ,
  mounted() {
    this.fetchEnemies();
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

.filter-row {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.filter-selects {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.filter-with-chips {
  display: flex;
  gap: 15px;
  align-items: flex-start;
}

.dropdown-container {
  position: relative;
  min-width: 180px;
}

.dropdown-btn {
  width: 100%;
  padding: 10px 15px;
  background-color: #1a1a1a;
  border: 2px solid #8b7355;
  border-radius: 4px;
  color: #e8dcc4;
  cursor: pointer;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  font-size: 0.9rem;
}

.dropdown-btn:hover {
  border-color: #c9a961;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background-color: #2d2d2d;
  border: 2px solid #c9a961;
  border-radius: 4px;
  max-height: 250px;
  overflow-y: auto;
  z-index: 10;
  margin-top: 5px;
  box-shadow: 0 4px 12px rgba(201, 169, 97, 0.3);
}

.dropdown-item {
  padding: 10px 15px;
  color: #e8dcc4;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.9rem;
  border-bottom: 1px solid #1a1a1a;
}

.dropdown-item:last-child {
  border-bottom: none;
}

.dropdown-item:hover {
  background-color: #8b7355;
  color: #1a1a1a;
  padding-left: 20px;
}

.dropdown-item-selected {
  background-color: #c9a961;
  color: #1a1a1a;
  font-weight: bold;
}

.dropdown-item-selected:hover {
  background-color: #d4b97a;
  color: #1a1a1a;
}

.chips-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-content: flex-start;
  min-height: 40px;
}

.filter-section {
  margin-bottom: 25px;
  padding-bottom: 20px;
  border-bottom: 1px solid #8b7355;
}

.filter-row .filter-section {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
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

.selected-filters {
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #8b7355;
}

.selected-filters h3 {
  color: #c9a961;
  font-size: 1.1rem;
  margin: 0 0 15px 0;
}

.filter-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.filter-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background-color: #8b7355;
  border: 1px solid #c9a961;
  border-radius: 20px;
  color: #e8dcc4;
  font-size: 0.9rem;
  animation: slideIn 0.3s ease;
}

.chip-remove {
  background: none;
  border: none;
  color: #e8dcc4;
  cursor: pointer;
  font-size: 1rem;
  padding: 0;
  display: flex;
  align-items: center;
  transition: all 0.2s ease;
}

.chip-remove:hover {
  color: #c9a961;
  transform: scale(1.2);
}

.no-selection {
  color: #8b7355;
  font-style: italic;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
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

.enemy-grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
}

.enemy-card {
  border: 1px solid #2d2d2d;
  border-radius: 14px;
  background: #141414;
  padding: 14px 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
}

.enemy-card__head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.enemy-card__name {
  display: block;
  font-size: 1.05rem;
}

.enemy-card__chip {
  background: #2d2d2d;
  border: 1px solid #8b7355;
  color: #c9a961;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 0.8rem;
}

.enemy-card__stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.stat {
  background: #1a1a1a;
  border: 1px solid #2d2d2d;
  border-radius: 10px;
  padding: 8px 10px;
  text-align: center;
}

.stat__label {
  display: block;
  color: #8b7355;
  font-size: 0.75rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  margin-bottom: 2px;
}

.muted {
  color: #8b7355;
}

.small {
  font-size: 0.85rem;
}

.enemy-list {
  display: grid;
  gap: 12px;
}

.enemy-list__item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border: 1px solid #2d2d2d;
  border-radius: 10px;
  background: #141414;
}

.muted {
  color: #8b7355;
}

.small {
  font-size: 0.85rem;
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
