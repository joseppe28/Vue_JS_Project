<template>
  <div class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>Neue Waffe hinzufügen</h2>
        <button class="close-modal-btn" @click="closeModal">✕</button>
      </div>

      <form @submit.prevent="saveWeapon" class="weapon-form">
        <div class="form-group">
          <label>Waffenname:</label>
          <input
            v-model="weapon.name"
            type="text"
            placeholder="z.B. Langschwert"
            required
          >
        </div>

        <div class="form-group">
          <label>Waffentyp:</label>
          <select v-model="weapon.weapon_type" required>
            <option value="">-- Auswählen --</option>
            <option value="Armbrüste">Armbrüste</option>
            <option value="Blasrohre">Blasrohre</option>
            <option value="Bögen">Bögen</option>
            <option value="Diskusse">Diskusse</option>
            <option value="Dolche">Dolche</option>
            <option value="Fechtwaffen">Fechtwaffen</option>
            <option value="Feuerspeien">Feuerspeien</option>
            <option value="Fächer">Fächer</option>
            <option value="Hiebwaffen">Hiebwaffen</option>
            <option value="Holzwaffen">Holzwaffen</option>
            <option value="Kettenwaffen">Kettenwaffen</option>
            <option value="Lanzen">Lanzen</option>
            <option value="Peitschen">Peitschen</option>
            <option value="Raufen">Raufen</option>
            <option value="Schilde">Schilde</option>
            <option value="Schleudern">Schleudern</option>
            <option value="Schwerter">Schwerter</option>
            <option value="Spießwaffen">Spießwaffen</option>
            <option value="Stangenwaffen">Stangenwaffen</option>
            <option value="Wurfwaffen">Wurfwaffen</option>
            <option value="Zweihandhiebwaffen">Zweihandhiebwaffen</option>
            <option value="Zweihandschwerter">Zweihandschwerter</option>
          </select>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Kampftechnik:</label>
            <input
              v-model="weapon.combat_technique"
              type="text"
              placeholder="z.B. Schwerter"
            >
          </div>

          <div class="form-group">
            <label>Fernwaffe:</label>
            <input v-model="weapon.is_ranged" type="checkbox">
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Schadenswürfel (Anzahl):</label>
            <input
              v-model.number="weapon.damage_dice_count"
              type="number"
              placeholder="z.B. 1"
            >
          </div>

          <div class="form-group">
            <label>Schadenswürfel (Seiten):</label>
            <input
              v-model.number="weapon.damage_dice_sides"
              type="number"
              placeholder="z.B. 8"
            >
          </div>

          <div class="form-group">
            <label>Schadensbonus:</label>
            <input
              v-model.number="weapon.damage_bonus"
              type="number"
              placeholder="z.B. 2"
            >
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Angriff Mod.:</label>
            <input
              v-model.number="weapon.attack_mod"
              type="number"
              placeholder="z.B. +1"
            >
          </div>

          <div class="form-group">
            <label>Parade Mod.:</label>
            <input
              v-model.number="weapon.parry_mod"
              type="number"
              placeholder="z.B. +1"
            >
          </div>
        </div>

        <div class="form-group">
          <label>Beschreibung:</label>
          <textarea
            v-model="weapon.special_rules"
            placeholder="Spezialregeln oder Beschreibung..."
            rows="4"
          ></textarea>
        </div>

        <div class="form-actions">
          <button type="button" @click="closeModal" class="cancel-btn">
            Abbrechen
          </button>
          <button type="submit" class="save-btn">
            Speichern
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AddWeaponView',
  data() {
    return {
      weapon: {
        name: '',
        weapon_type: '',
        combat_technique: '',
        damage_dice_count: null,
        damage_dice_sides: null,
        damage_bonus: null,
        attack_mod: null,
        parry_mod: null,
        is_ranged: false,
        hands_required: true,
        special_rules: ''
      }
    };
  },
  methods: {
    saveWeapon() {
      this.$emit('save-weapon', this.weapon);
      this.resetForm();
    },
    closeModal() {
      this.$emit('close');
    },
    resetForm() {
      this.weapon = {
        name: '',
        weapon_type: '',
        combat_technique: '',
        damage_dice_count: null,
        damage_dice_sides: null,
        damage_bonus: null,
        attack_mod: null,
        parry_mod: null,
        is_ranged: false,
        hands_required: true,
        special_rules: ''
      };
    }
  }
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
  max-width: 600px;
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

.weapon-form {
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
.form-group select,
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
.form-group select:focus,
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

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
}

.form-row .form-group {
  gap: 6px;
}

.form-actions {
  display: flex;
  gap: 15px;
  margin-top: 10px;
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
