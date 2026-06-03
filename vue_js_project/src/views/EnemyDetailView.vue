<template>
  <div class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <div>
          <p class="header-label">Gegnerprofil</p>
          <h2>{{ enemy.name }}</h2>
        </div>
        <button class="close-modal-btn" @click="closeModal">✕</button>
      </div>

      <div class="detail-body">
        <!-- Zusammenfassung / Summary -->
        <section class="summary-section">
          <div class="summary-grid">
            <div class="summary-item">
              <label>Typ:</label>
              <p class="summary-value">{{ enemy.creature_type || 'Unbekannt' }}</p>
            </div>
            <div class="summary-item">
              <label>Bedrohung:</label>
              <p class="summary-value">{{ enemy.challenge_rating || 'n/a' }}</p>
            </div>
          </div>
          <div class="summary-full" v-if="enemy.description">
            <label>Beschreibung:</label>
            <p class="summary-description">{{ enemy.description }}</p>
          </div>
        </section>

        <!-- Eigenschaften -->
        <section class="detail-section">
          <h3 class="section-title">Eigenschaften</h3>
          <div class="attr-display-grid">
            <div v-for="(label, code) in attributeLabels" :key="code" class="attr-display-item">
              <span class="attr-display-label">{{ code }}</span>
              <strong class="attr-display-value">{{ getAttributeValue(code) }}</strong>
              <small class="attr-display-hint">{{ label }}</small>
            </div>
          </div>
        </section>

        <!-- Waffen -->
        <section class="detail-section" v-if="weapons.length">
          <h3 class="section-title">Waffen</h3>
          <div class="weapons-display-list">
            <div v-for="(w, idx) in weapons" :key="idx" class="weapon-display-item">
              <strong>{{ w.name }}</strong>
              <span class="weapon-display-type">{{ w.weapon_type || w.type || 'Unbekannt' }}</span>
              <p v-if="w.damage_info" class="weapon-display-details">{{ w.damage_info }}</p>
            </div>
          </div>
        </section>

        <!-- Vorteile -->
        <section class="detail-section" v-if="advantages.length">
          <h3 class="section-title">Vorteile</h3>
          <div class="chip-display-list">
            <span v-for="(a, i) in advantages" :key="i" class="chip chip-positive">{{ a }}</span>
          </div>
        </section>

        <!-- Nachteile -->
        <section class="detail-section" v-if="disadvantages.length">
          <h3 class="section-title">Nachteile</h3>
          <div class="chip-display-list">
            <span v-for="(d, i) in disadvantages" :key="i" class="chip chip-negative">{{ d }}</span>
          </div>
        </section>

        <!-- Sonderfertigkeiten -->
        <section class="detail-section" v-if="specialAbilities.length">
          <h3 class="section-title">Sonderfertigkeiten</h3>
          <div class="chip-display-list">
            <span v-for="(s, i) in specialAbilities" :key="i" class="chip chip-special">{{ s }}</span>
          </div>
        </section>

        <div class="form-actions">
          <button type="button" @click="closeModal" class="cancel-btn">
            Schließen
          </button>
          <button type="button" @click="editEnemy" class="save-btn">
            Bearbeiten
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EnemyDetailView',
  props: {
    enemy: {
      type: Object,
      required: true,
    },
  },
  emits: ['close', 'edit'],
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
    };
  },
  computed: {
    weapons() {
      const w = this.enemy.enemy_weapons || this.enemy.weapons || [];
      return Array.isArray(w) ? w : [];
    },
    advantages() {
      const a = this.enemy.advantages || [];
      if (typeof a === 'string') {
        try {
          return JSON.parse(a);
        } catch {
          return a.split(',').map(s => s.trim()).filter(s => s);
        }
      }
      return Array.isArray(a) ? a : [];
    },
    disadvantages() {
      const d = this.enemy.disadvantages || [];
      if (typeof d === 'string') {
        try {
          return JSON.parse(d);
        } catch {
          return d.split(',').map(s => s.trim()).filter(s => s);
        }
      }
      return Array.isArray(d) ? d : [];
    },
    specialAbilities() {
      const s = this.enemy.special_abilities || [];
      if (typeof s === 'string') {
        try {
          return JSON.parse(s);
        } catch {
          return s.split(',').map(str => str.trim()).filter(str => str);
        }
      }
      return Array.isArray(s) ? s : [];
    },
  },
  methods: {
    closeModal() {
      this.$emit('close');
    },
    editEnemy() {
      this.$emit('edit', this.enemy);
    },
    getAttributeValue(code) {
      const attrs = this.enemy.enemy_attributes || [];
      const match = attrs.find(attr => attr?.attributes?.code === code);
      if (match) {
        return match.value;
      }
      return 'n/a';
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
  align-items: flex-start;
  gap: 15px;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #c9a961;
}

.modal-header h2 {
  color: #c9a961;
  font-size: 1.5rem;
  margin: 0;
}

.header-label {
  color: #8b7355;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 0 4px 0;
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

.detail-body {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.summary-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 15px;
  background-color: rgba(139, 115, 85, 0.1);
  border: 1px solid #8b7355;
  border-radius: 6px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.summary-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.summary-item label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.summary-value {
  color: #e8dcc4;
  margin: 0;
  font-size: 0.95rem;
  font-weight: 600;
}

.summary-full {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.summary-full label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.summary-description {
  color: #e8dcc4;
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.5;
}

.detail-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.section-title {
  color: #c9a961;
  font-size: 1.1rem;
  font-weight: 700;
  margin: 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #8b7355;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-item label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.85rem;
}

.info-item p {
  color: #e8dcc4;
  margin: 0;
  font-size: 0.95rem;
}

.info-full {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.info-full label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.85rem;
}

.info-full p {
  color: #e8dcc4;
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.5;
}

.attr-display-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(70px, 1fr));
  gap: 8px;
}

.attr-display-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  text-align: center;
  padding: 8px;
  background-color: rgba(139, 115, 85, 0.1);
  border: 1px solid #8b7355;
  border-radius: 4px;
}

.attr-display-label {
  color: #c9a961;
  font-weight: 600;
  font-size: 0.8rem;
}

.attr-display-value {
  color: #e8dcc4;
  font-size: 1.1rem;
}

.attr-display-hint {
  color: #8b7355;
  font-size: 0.7rem;
}

.weapons-display-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.weapon-display-item {
  padding: 10px;
  background-color: rgba(139, 115, 85, 0.1);
  border: 1px solid #8b7355;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.weapon-display-item strong {
  color: #c9a961;
}

.weapon-display-type {
  color: #8b7355;
  font-size: 0.85rem;
  font-weight: 600;
}

.weapon-display-details {
  color: #e8dcc4;
  margin: 0;
  font-size: 0.9rem;
}

.chip-display-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.chip {
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 0.85rem;
  display: inline-block;
}

.chip-positive {
  background-color: rgba(76, 175, 80, 0.2);
  border: 1px solid #4caf50;
  color: #a8d5a8;
}

.chip-negative {
  background-color: rgba(255, 100, 100, 0.1);
  border: 1px solid #c9705a;
  color: #ffb3a8;
}

.chip-special {
  background-color: rgba(139, 115, 85, 0.2);
  border: 1px solid #8b7355;
  color: #e8dcc4;
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
</style>
