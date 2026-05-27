<template>
  <div class="waffen-view">
    <div class="header">
      <h1>Waffen</h1>
      <div class="search-wrapper">
        <input
          type="text"
          class="search-input"
          placeholder="Waffen suchen..."
          v-model="searchQuery"
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
        <div class="filter-selects">
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
                    v-for="type in weaponTypes"
                    :key="type"
                    @click="toggleSelection('weaponType', type)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.weaponType.includes(type) }"
                  >
                    {{ type }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="type in filters.weaponType"
                  :key="type"
                  class="filter-chip"
                >
                  {{ type }}
                  <button
                    @click="toggleSelection('weaponType', type)"
                    class="chip-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="filter-section">
            <h3>Schadensklasse</h3>
            <div class="filter-with-chips">
              <div class="dropdown-container">
                <button @click="toggleDropdown('damageClass')" class="dropdown-btn">
                  Auswählen ▼
                </button>
                <div v-if="openDropdown === 'damageClass'" class="dropdown-menu">
                  <div
                    @click="toggleSelectAll('damageClass')"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.damageClass.length === damageClasses.length && damageClasses.length > 0 }"
                  >
                    -- Alle --
                  </div>
                  <div
                    v-for="damage in damageClasses"
                    :key="damage"
                    @click="toggleSelection('damageClass', damage)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.damageClass.includes(damage) }"
                  >
                    {{ damage }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="damage in filters.damageClass"
                  :key="damage"
                  class="filter-chip"
                >
                  {{ damage }}
                  <button
                    @click="toggleSelection('damageClass', damage)"
                    class="chip-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="filter-section">
            <h3>Kampftechnik</h3>
            <div class="filter-with-chips">
              <div class="dropdown-container">
                <button @click="toggleDropdown('combatTechnique')" class="dropdown-btn">
                  Auswählen ▼
                </button>
                <div v-if="openDropdown === 'combatTechnique'" class="dropdown-menu">
                  <div
                    @click="toggleSelectAll('combatTechnique')"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.combatTechnique.length === combatTechniques.length && combatTechniques.length > 0 }"
                  >
                    -- Alle --
                  </div>
                  <div
                    v-for="technique in combatTechniques"
                    :key="technique"
                    @click="toggleSelection('combatTechnique', technique)"
                    class="dropdown-item"
                    :class="{ 'dropdown-item-selected': filters.combatTechnique.includes(technique) }"
                  >
                    {{ technique }}
                  </div>
                </div>
              </div>
              <div class="chips-container">
                <div
                  v-for="technique in filters.combatTechnique"
                  :key="technique"
                  class="filter-chip"
                >
                  {{ technique }}
                  <button
                    @click="toggleSelection('combatTechnique', technique)"
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
      <div v-if="isLoading" class="muted">Lade Waffen...</div>
      <div v-else-if="loadError" class="muted">{{ loadError }}</div>
      <div v-else-if="!weapons.length" class="empty-state">
        <p>Keine Waffen vorhanden. Füge eine neue Waffe mit dem "+" Button hinzu!</p>
      </div>
      <div v-else-if="!shownWeapons.length" class="empty-state">
        <p>Keine Waffen passen zu den Filtern.</p>
      </div>

      <div v-else class="weapons-grid">
        <Weapon
          v-for="weapon in shownWeapons"
          :key="weapon.id"
          :weapon="weapon"
          @edit="editWeapon"
          @delete="deleteWeapon"
        />
      </div>
    </div>

    <button class="add-btn" @click="openAddWeapon">+</button>

    <transition name="fade">
      <AddWeaponView 
        v-if="showAddWeapon" 
        @save-weapon="handleSaveWeapon"
        @close="showAddWeapon = false"
      />
    </transition>
  </div>
</template>

<script>
import AddWeaponView from './AddWeaponView.vue'
import Weapon from '../components/Weapon.vue'

export default {
  name: 'WaffenView',
  components: { AddWeaponView, Weapon },
  data() {
    return {
      showFilter: false,
      showAddWeapon: false,
      supabaseUrl: 'https://dhomjjfeyoeynhunrnbs.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRob21qamZleW9leW5odW5ybmJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MjYwOTIsImV4cCI6MjA5NDIwMjA5Mn0.PaWu0BDYsWL2D4H4U6NoHHwwx2o9tAGt-1L4w2GdK64',
      weapons: [],
      shownWeapons: [],
      searchQuery: '',
      isLoading: false,
      loadError: '',
      openDropdown: null,
      weaponTypes: [
        'Armbrüste', 'Blasrohre', 'Bögen', 'Diskusse', 'Dolche',
        'Fechtwaffen', 'Feuerspeien', 'Fächer', 'Hiebwaffen', 'Holzwaffen',
        'Kettenwaffen', 'Lanzen', 'Peitschen', 'Raufen', 'Schilde',
        'Schleudern', 'Schwerter', 'Spießwaffen', 'Stangenwaffen',
        'Wurfwaffen', 'Zweihandhiebwaffen', 'Zweihandschwerter'
      ],
      damageClasses: [
        '1W4', '1W6', '1W8', '1W10', '1W12', '2W6', '2W8', '2W10', 'W20'
      ],
      combatTechniques: [
        'Armbrüste', 'Blasrohre', 'Bögen', 'Dolche', 'Fechtwaffen',
        'Fächer', 'Hiebwaffen', 'Kettenwaffen', 'Lanzen', 'Peitschen',
        'Raufen', 'Schleudern', 'Schwerter', 'Spießwaffen', 'Stangenwaffen',
        'Wurfwaffen'
      ],
      filters: {
        weaponType: [],
        damageClass: [],
        combatTechnique: []
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
      const dataKey = filterType === 'weaponType' ? 'weaponTypes' :
                      filterType === 'damageClass' ? 'damageClasses' :
                      'combatTechniques';
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
    openAddWeapon() {
      this.showAddWeapon = true;
    },
    handleSaveWeapon(weapon) {
      this.showAddWeapon = false;

      (async () => {
        try {
          await this.saveWeaponToSupabase(weapon);
          await this.fetchWeapons();
          this.$emit('weapon-added', weapon);
        } catch (error) {
          console.error('Supabase save failed:', error);
          const message = error?.message || 'Unbekannter Fehler';
          alert(`Speichern fehlgeschlagen: ${message}`);
        }
      })();
    },
    async saveWeaponToSupabase(weapon) {
      const headers = {
        apikey: this.supabaseAnonKey,
        Authorization: `Bearer ${this.supabaseAnonKey}`,
        'Content-Type': 'application/json',
      };

      const body = {
        name: weapon.name,
        weapon_type: weapon.weapon_type,
        combat_technique: weapon.combat_technique || null,
        damage_dice_count: weapon.damage_dice_count || null,
        damage_dice_sides: weapon.damage_dice_sides || null,
        damage_bonus: weapon.damage_bonus || null,
        attack_mod: weapon.attack_mod || null,
        parry_mod: weapon.parry_mod || null,
        is_ranged: weapon.is_ranged || false,
        hands_required: weapon.hands_required !== false,
        special_rules: weapon.special_rules || null
      };

      await this.fetchJson(
        `${this.supabaseUrl}/rest/v1/weapons`,
        {
          method: 'POST',
          headers: { ...headers, Prefer: 'return=representation' },
          body: JSON.stringify(body),
        }
      );
    },
    async fetchWeapons() {
      this.isLoading = true;
      this.loadError = '';

      try {
        const headers = {
          apikey: this.supabaseAnonKey,
          Authorization: `Bearer ${this.supabaseAnonKey}`,
        };
        const data = await this.fetchJson(
          `${this.supabaseUrl}/rest/v1/weapons?order=id.desc`,
          { headers }
        );
        this.weapons = Array.isArray(data) ? data : [];
        this.filterWeapons();
      } catch (error) {
        console.error('Supabase load failed:', error);
        this.loadError = error?.message || 'Konnte Waffen nicht laden.';
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
    filterWeapons() {
      const query = this.searchQuery.trim().toLowerCase();
      const filtered = this.weapons.filter((weapon) => {
        if (query) {
          const name = (weapon.name || '').toLowerCase();
          if (!name.includes(query)) {
            return false;
          }
        }

        if (this.filters.weaponType.length > 0 && !this.filters.weaponType.includes(weapon.weapon_type)) {
          return false;
        }

        if (this.filters.combatTechnique.length > 0 && !this.filters.combatTechnique.includes(weapon.combat_technique)) {
          return false;
        }

        if (this.filters.damageClass.length > 0) {
          const damageClass = this.getDamageClass(weapon);
          if (!damageClass || !this.filters.damageClass.includes(damageClass)) {
            return false;
          }
        }

        return true;
      });

      this.shownWeapons = filtered;
    },
    getDamageClass(weapon) {
      const count = weapon.damage_dice_count;
      const sides = weapon.damage_dice_sides;
      if (!count || !sides) {
        return '';
      }

      if (count === 1 && sides === 20) {
        return 'W20';
      }

      return `${count}W${sides}`;
    },
    resetFilters() {
      this.filters.weaponType = [];
      this.filters.damageClass = [];
      this.filters.combatTechnique = [];
      this.filterWeapons();
    },
    editWeapon(weapon) {
      // Öffne Edit-Modal wenn implementiert
      console.log('Waffe bearbeiten:', weapon);
    },
    async deleteWeapon(weapon) {
      if (!confirm('Waffe wirklich löschen?')) return;

      try {
        const headers = {
          apikey: this.supabaseAnonKey,
          Authorization: `Bearer ${this.supabaseAnonKey}`,
        };
        await this.fetchJson(
          `${this.supabaseUrl}/rest/v1/weapons?id=eq.${weapon.id}`,
          { method: 'DELETE', headers }
        );
        await this.fetchWeapons();
      } catch (error) {
        console.error('Delete failed:', error);
        alert('Löschen fehlgeschlagen');
      }
    }
  },
  mounted() {
    this.fetchWeapons();
  },
  watch: {
    searchQuery() {
      this.filterWeapons();
    },
    filters: {
      deep: true,
      handler() {
        this.filterWeapons();
      }
    }
  }
};
</script>

<style scoped>
.waffen-view {
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
  padding: 12px 20px;
  background-color: #2d2d2d;
  color: #c9a961;
  border: 2px solid #c9a961;
  border-radius: 5px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
  font-size: 2rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(201, 169, 97, 0.4);
}

.add-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(201, 169, 97, 0.6);
}

/* Transitions */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.weapons-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 50px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #8b7355;
  font-size: 1.1rem;
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
</style>
