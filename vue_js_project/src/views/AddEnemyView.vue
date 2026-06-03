<template>
  <div class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>Neuen Gegner hinzufügen</h2>
        <button class="close-modal-btn" @click="closeModal">✕</button>
      </div>

      <form @submit.prevent="handleSubmit" class="enemy-form">
        <!-- Grundinformationen -->
        <div class="form-group">
          <label>Gegnername:</label>
          <input
            v-model="form.name"
            type="text"
            placeholder="z.B. Goblin Krieger"
            required
          >
        </div>

        <div class="form-group">
          <label>Gegnertyp:</label>
          <input
            v-model="form.type"
            type="text"
            placeholder="z.B. Goblin, Drache"
          >
        </div>

        <div class="form-group">
          <label>Beschreibung:</label>
          <textarea
            v-model="form.description"
            placeholder="Kurze Beschreibung"
            rows="3"
          ></textarea>
        </div>

        <!-- Eigenschaften -->
        <div class="section-title">Eigenschaften</div>
        <div class="attr-grid">
          <div v-for="(label, code) in attributeLabels" :key="code" class="attr-item">
            <label class="attr-label">{{ code }}</label>
            <input v-model.number="form.attributes[code]" type="number" min="0" max="100000" class="attr-input" />
            <small class="attr-hint">{{ label }}</small>
          </div>
        </div>

        <!-- Waffen -->
        <div class="section-title">Waffen</div>
        <div v-if="form.weapons.length" class="weapons-list">
          <div v-for="(w, idx) in form.weapons" :key="idx" class="weapon-item">
            <input v-model="w.name" placeholder="Name" class="weapon-input" />
            <input v-model="w.type" placeholder="Typ" class="weapon-input" />
            <input v-model="w.details" placeholder="Details (z.B. 1W6+2 / AT+1)" class="weapon-input" />
            <button type="button" class="btn-remove" @click="removeWeapon(idx)">✕</button>
          </div>
        </div>
        <div class="weapon-actions">
          <button type="button" class="btn-action" @click="addWeapon">+ Waffe manuell</button>
          <button type="button" class="btn-action" @click="openWeaponSearch">+ Waffe aus DB</button>
        </div>

        <!-- Vorteile / Nachteile / Sonderfertigkeiten -->
        <div class="section-title">Vorteile & Fähigkeiten</div>
        
        <div class="form-group">
          <label>Vorteil hinzufügen:</label>
          <div class="inline-input">
            <input v-model="tempAdv" placeholder="z.B. Gute Augen" class="flex-input" />
            <button type="button" class="btn-add" @click="pushList('advantages', tempAdv); tempAdv=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(a,i) in form.advantages" :key="i" class="chip">
              {{ a }}
              <button type="button" @click="removeFromList('advantages', i)" class="chip-remove">×</button>
            </span>
          </div>
        </div>

        <div class="form-group">
          <label>Nachteil hinzufügen:</label>
          <div class="inline-input">
            <input v-model="tempDis" placeholder="z.B. Leicht reizbar" class="flex-input" />
            <button type="button" class="btn-add" @click="pushList('disadvantages', tempDis); tempDis=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(d,i) in form.disadvantages" :key="i" class="chip chip--neg">
              {{ d }}
              <button type="button" @click="removeFromList('disadvantages', i)" class="chip-remove">×</button>
            </span>
          </div>
        </div>

        <div class="form-group">
          <label>Sonderfertigkeit hinzufügen:</label>
          <div class="inline-input">
            <input v-model="tempSF" placeholder="z.B. Ausweichen" class="flex-input" />
            <button type="button" class="btn-add" @click="pushList('specialAbilities', tempSF); tempSF=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(s,i) in form.specialAbilities" :key="i" class="chip">
              {{ s }}
              <button type="button" @click="removeFromList('specialAbilities', i)" class="chip-remove">×</button>
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" @click="closeModal" class="cancel-btn">
            Abbrechen
          </button>
          <button type="submit" class="save-btn">
            Gegner speichern
          </button>
        </div>
      </form>

      <!-- Waffen-Such-Modal -->
      <div v-if="showWeaponSearch" class="weapon-search-overlay" @click="closeWeaponSearch">
        <div class="weapon-search-modal" @click.stop>
          <div class="search-header">
            <h3>Waffe suchen</h3>
            <button type="button" class="close-search-btn" @click="closeWeaponSearch">✕</button>
          </div>
          <input
            v-model="weaponQuery"
            class="search-input"
            placeholder="Name der Waffe..."
            @input="queueWeaponSearch"
          />
          <div v-if="weaponLoading" class="search-status">Suche...</div>
          <div v-else-if="weaponError" class="search-status error">{{ weaponError }}</div>
          <div v-else-if="!weaponResults.length" class="search-status">Keine Treffer.</div>
          <div v-else class="weapon-results">
            <button
              v-for="weapon in weaponResults"
              :key="weapon.id"
              type="button"
              class="weapon-result"
              @click="selectWeapon(weapon)"
            >
              <div>
                <strong>{{ weapon.name }}</strong>
                <div class="weapon-type">{{ weapon.weapon_type || 'Unbekannt' }}</div>
              </div>
              <span class="tag">+</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AddEnemyView',
  emits: ['save-enemy'],
  data() {
    return {
      attributeLabels: {
        MU: 'Mut',
        KL: 'Klugheit',
        IN: 'Intuition',
        CH: 'Charisma',
        FF: 'Fingerfertigkeit',
        GE: 'Gewandtheit',
        KO: 'Konstitution',
        KK: 'Körperkraft',
        LE: 'Lebensenergie',
        ASP: 'Astralenergie',
        KAP: 'Karmaenergie',
        GS: 'Geschwindigkeit',
        INI: 'Initiative',
        AW: 'Ausweichen',
        RS: 'Rüstungsschutz',
      },
      form: this.emptyForm(),
      tempAdv: '',
      tempDis: '',
      tempSF: '',
      showWeaponSearch: false,
      weaponQuery: '',
      weaponResults: [],
      weaponLoading: false,
      weaponError: '',
      weaponSearchTimer: null,
      supabaseUrl: 'https://dhomjjfeyoeynhunrnbs.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRob21qamZleW9leW5odW5ybmJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MjYwOTIsImV4cCI6MjA5NDIwMjA5Mn0.PaWu0BDYsWL2D4H4U6NoHHwwx2o9tAGt-1L4w2GdK64',
    };
  },
  methods: {
    emptyForm() {
      return {
        name: '',
        type: '',
        description: '',
        attributes: {
          MU: 10,
          KL: 10,
          IN: 10,
          CH: 10,
          FF: 10,
          GE: 10,
          KO: 10,
          KK: 10,
          LE: 20,
          ASP: 0,
          KAP: 0,
          GS: 8,
          INI: 10,
          AW: 6,
          RS: 0,
        },
        weapons: [],
        advantages: [],
        disadvantages: [],
        specialAbilities: [],
      };
    },
    addWeapon() {
      this.form.weapons.push({ name: '', type: '', details: '' });
    },
    openWeaponSearch() {
      this.showWeaponSearch = true;
      this.weaponError = '';
      if (!this.weaponResults.length) {
        this.fetchWeapons();
      }
    },
    closeWeaponSearch() {
      this.showWeaponSearch = false;
    },
    closeModal() {
      this.$emit('close');
    },
    queueWeaponSearch() {
      if (this.weaponSearchTimer) {
        clearTimeout(this.weaponSearchTimer);
      }
      this.weaponSearchTimer = setTimeout(() => {
        this.fetchWeapons();
      }, 250);
    },
    async fetchWeapons() {
      this.weaponLoading = true;
      this.weaponError = '';

      try {
        const headers = {
          apikey: this.supabaseAnonKey,
          Authorization: `Bearer ${this.supabaseAnonKey}`,
        };
        const query = this.weaponQuery.trim();
        const filter = query ? `&name=ilike.*${encodeURIComponent(query)}*` : '';
        const url = `${this.supabaseUrl}/rest/v1/weapons?select=id,name,weapon_type,combat_technique,damage_dice_count,damage_dice_sides,damage_bonus,attack_mod,parry_mod,range_distance,initiative_mod,special_rules&order=name.asc${filter}`;
        const response = await fetch(url, { headers });
        if (!response.ok) {
          const message = await response.text();
          throw new Error(message || `Request failed with ${response.status}`);
        }
        const data = await response.json();
        this.weaponResults = Array.isArray(data) ? data : [];
      } catch (error) {
        this.weaponError = error?.message || 'Konnte Waffen nicht laden.';
      } finally {
        this.weaponLoading = false;
      }
    },
    selectWeapon(weapon) {
      this.form.weapons.push({
        weapon_id: weapon.id,
        name: weapon.name,
        type: weapon.weapon_type,
        details: this.buildWeaponDetails(weapon),
      });
      this.closeWeaponSearch();
    },
    buildWeaponDetails(weapon) {
      const parts = [];
      if (weapon.combat_technique) {
        parts.push(weapon.combat_technique);
      }
      if (weapon.damage_dice_count || weapon.damage_dice_sides || weapon.damage_bonus !== null) {
        const bonus = weapon.damage_bonus ? `+${weapon.damage_bonus}` : '';
        const dice = `${weapon.damage_dice_count || 0}W${weapon.damage_dice_sides || 0}${bonus}`;
        parts.push(`Schaden ${dice}`);
      }
      if (weapon.attack_mod !== null || weapon.parry_mod !== null) {
        parts.push(`AT ${weapon.attack_mod ?? '-'} / PA ${weapon.parry_mod ?? '-'}`);
      }
      if (weapon.range_distance) {
        parts.push(`Reichweite ${weapon.range_distance}`);
      }
      if (weapon.special_rules) {
        parts.push(weapon.special_rules);
      }
      return parts.length ? parts.join(' · ') : '';
    },
    removeWeapon(i) {
      this.form.weapons.splice(i, 1);
    },
    pushList(listName, value) {
      if (!value || !value.toString().trim()) return;
      this.form[listName].push(value.toString().trim());
    },
    removeFromList(listName, idx) {
      this.form[listName].splice(idx, 1);
    },
    resetForm() {
      this.form = this.emptyForm();
      this.tempAdv = this.tempDis = this.tempSF = '';
      this.weaponQuery = '';
      this.weaponResults = [];
      this.weaponError = '';
    },
    handleSubmit() {
      this.$emit('save-enemy', JSON.parse(JSON.stringify(this.form)));
      this.resetForm();
    },
  },
};
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.modal-content {
  background-color: #2d2d2d;
  border: 2px solid #c9a961;
  border-radius: 8px;
  padding: 30px;
  max-width: 700px;
  width: 90%;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(201, 169, 97, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #c9a961;
}

.modal-header h2 {
  color: #c9a961;
  font-size: 1.5rem;
  margin: 0;
}

.close-modal-btn {
  background: none;
  border: none;
  color: #c9a961;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.close-modal-btn:hover {
  color: #e8dcc4;
  transform: scale(1.2);
}

.enemy-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.95rem;
}

.form-group input,
.form-group textarea {
  padding: 10px;
  background-color: #1a1a1a;
  border: 2px solid #8b7355;
  border-radius: 4px;
  color: #e8dcc4;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  font-size: 0.95rem;
  transition: all 0.3s ease;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #c9a961;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: #8b7355;
}

.form-group textarea {
  resize: vertical;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.section-title {
  color: #c9a961;
  font-size: 1.1rem;
  font-weight: 700;
  margin-top: 15px;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #8b7355;
}

.attr-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(70px, 1fr));
  gap: 8px;
  margin-bottom: 15px;
}

.attr-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.attr-label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.8rem;
  text-align: center;
}

.attr-input {
  text-align: center;
  padding: 6px 4px;
  background-color: #1a1a1a;
  border: 1px solid #8b7355;
  border-radius: 3px;
  color: #e8dcc4;
  font-size: 0.9rem;
}

.attr-input:focus {
  outline: none;
  border-color: #c9a961;
}

.attr-hint {
  color: #8b7355;
  font-size: 0.7rem;
  text-align: center;
}

.weapons-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 10px;
}

.weapon-item {
  display: grid;
  grid-template-columns: 1fr 1fr 2fr auto;
  gap: 8px;
  padding: 8px;
  background-color: rgba(139, 115, 85, 0.1);
  border: 1px solid #8b7355;
  border-radius: 4px;
}

.weapon-input {
  padding: 6px 8px;
  background-color: #1a1a1a;
  border: 1px solid #8b7355;
  border-radius: 3px;
  color: #e8dcc4;
  font-size: 0.85rem;
}

.weapon-input:focus {
  outline: none;
  border-color: #c9a961;
}

.btn-remove {
  background: none;
  border: none;
  color: #c9a961;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-remove:hover {
  color: #e8dcc4;
  transform: scale(1.2);
}

.weapon-actions {
  display: flex;
  gap: 8px;
  margin-bottom: 15px;
}

.btn-action {
  flex: 1;
  padding: 8px 12px;
  background-color: #8b7355;
  border: 1px solid #c9a961;
  border-radius: 4px;
  color: #e8dcc4;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-action:hover {
  background-color: #a0825c;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.inline-input {
  display: flex;
  gap: 8px;
}

.flex-input {
  flex: 1;
  padding: 8px 10px;
  background-color: #1a1a1a;
  border: 1px solid #8b7355;
  border-radius: 4px;
  color: #e8dcc4;
  font-size: 0.9rem;
}

.flex-input:focus {
  outline: none;
  border-color: #c9a961;
}

.btn-add {
  padding: 8px 12px;
  background-color: #8b7355;
  border: 1px solid #c9a961;
  border-radius: 4px;
  color: #e8dcc4;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-add:hover {
  background-color: #a0825c;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.chip-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
}

.chip {
  background-color: rgba(139, 115, 85, 0.2);
  border: 1px solid #8b7355;
  color: #e8dcc4;
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  gap: 6px;
}

.chip--neg {
  background-color: rgba(255, 100, 100, 0.1);
  border-color: #c9705a;
}

.chip-remove {
  background: none;
  border: none;
  color: inherit;
  cursor: pointer;
  font-weight: bold;
  padding: 0;
  font-size: 1rem;
}

.chip-remove:hover {
  color: #c9a961;
}

.form-actions {
  display: flex;
  gap: 15px;
  margin-top: 20px;
}

.cancel-btn,
.save-btn {
  flex: 1;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  font-size: 1rem;
  transition: all 0.3s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.cancel-btn {
  background-color: #8b7355;
  color: #e8dcc4;
}

.cancel-btn:hover {
  background-color: #6b5344;
}

.save-btn {
  background-color: #c9a961;
  color: #1a1a1a;
}

.save-btn:hover {
  background-color: #d4b97a;
}

/* Waffen-Such-Modal Styling */
.weapon-search-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 101;
}

.weapon-search-modal {
  background-color: #2d2d2d;
  border: 2px solid #c9a961;
  border-radius: 8px;
  padding: 20px;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.search-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #8b7355;
}

.search-header h3 {
  color: #c9a961;
  margin: 0;
  font-size: 1.2rem;
}

.close-search-btn {
  background: none;
  border: none;
  color: #c9a961;
  font-size: 1.2rem;
  cursor: pointer;
}

.close-search-btn:hover {
  color: #e8dcc4;
}

.search-input {
  padding: 10px;
  background-color: #1a1a1a;
  border: 1px solid #8b7355;
  border-radius: 4px;
  color: #e8dcc4;
  margin-bottom: 10px;
}

.search-input:focus {
  outline: none;
  border-color: #c9a961;
}

.search-status {
  color: #8b7355;
  padding: 15px;
  text-align: center;
}

.search-status.error {
  color: #c9705a;
}

.weapon-results {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 50vh;
  overflow-y: auto;
}

.weapon-result {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid #8b7355;
  border-radius: 4px;
  background-color: rgba(139, 115, 85, 0.1);
  cursor: pointer;
  transition: all 0.2s ease;
}

.weapon-result:hover {
  background-color: rgba(139, 115, 85, 0.2);
  border-color: #c9a961;
}

.weapon-result strong {
  color: #c9a961;
  display: block;
}

.weapon-type {
  color: #8b7355;
  font-size: 0.85rem;
  margin-top: 2px;
}

.tag {
  background-color: #c9a961;
  color: #1a1a1a;
  padding: 4px 8px;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: bold;
}
</style>
