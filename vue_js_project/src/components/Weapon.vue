<template>
  <div class="weapon-card">
    <div class="weapon-header">
      <h3 class="weapon-name">{{ weaponName }}</h3>
      <span class="weapon-type-badge">{{ weaponTypeLabel }}</span>
    </div>

    <div class="weapon-content">
      <div class="weapon-info">
        <div v-if="damageLabel" class="info-row">
          <span class="info-label">Schaden:</span>
          <span class="info-value">{{ damageLabel }}</span>
        </div>
        
        <div v-if="combatTechniqueLabel" class="info-row">
          <span class="info-label">Kampftechnik:</span>
          <span class="info-value">{{ combatTechniqueLabel }}</span>
        </div>

        <div class="info-row">
          <span class="info-label">Fernwaffe:</span>
          <span class="info-value">{{ isRangedLabel }}</span>
        </div>

        <div v-if="attackModLabel !== null" class="info-row">
          <span class="info-label">Angriff:</span>
          <span class="info-value">{{ attackModLabel }}</span>
        </div>

        <div v-if="parryModLabel !== null" class="info-row">
          <span class="info-label">Parade:</span>
          <span class="info-value">{{ parryModLabel }}</span>
        </div>
      </div>

      <p v-if="specialRulesLabel" class="weapon-description">
        {{ specialRulesLabel }}
      </p>
    </div>

    <div class="weapon-actions">
      <button @click="editWeapon" class="btn-edit">✏️ Bearbeiten</button>
      <button @click="deleteWeapon" class="btn-delete">🗑️ Löschen</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Weapon',
  props: {
    weapon: {
      type: Object,
      required: true
    }
  },
  computed: {
    weaponName() {
      return this.weapon.name || 'Unbekannte Waffe';
    },
    weaponTypeLabel() {
      return this.weapon.weapon_type || this.weapon.weaponType || 'Unbekannt';
    },
    damageLabel() {
      const w = this.weapon;
      const count = w.damage_dice_count || w.damageDiceCount;
      const sides = w.damage_dice_sides || w.damageDiceSides;
      const bonus = w.damage_bonus || w.damageBonus;

      if (!count || !sides) return '';

      let label = `${count}W${sides}`;
      if (bonus) {
        label += bonus > 0 ? `+${bonus}` : `${bonus}`;
      }
      return label;
    },
    combatTechniqueLabel() {
      return this.weapon.combat_technique || this.weapon.combatTechnique || '';
    },
    isRangedLabel() {
      const isRanged = this.weapon.is_ranged !== undefined 
        ? this.weapon.is_ranged 
        : this.weapon.isRanged;
      return isRanged ? 'Ja' : 'Nein';
    },
    attackModLabel() {
      const mod = this.weapon.attack_mod !== undefined 
        ? this.weapon.attack_mod 
        : this.weapon.attackMod;
      return mod !== null && mod !== undefined ? (mod > 0 ? `+${mod}` : mod) : null;
    },
    parryModLabel() {
      const mod = this.weapon.parry_mod !== undefined 
        ? this.weapon.parry_mod 
        : this.weapon.parryMod;
      return mod !== null && mod !== undefined ? (mod > 0 ? `+${mod}` : mod) : null;
    },
    specialRulesLabel() {
      return this.weapon.special_rules || this.weapon.specialRules || '';
    }
  },
  methods: {
    editWeapon() {
      this.$emit('edit', this.weapon);
    },
    deleteWeapon() {
      this.$emit('delete', this.weapon);
    }
  }
};
</script>

<style scoped>
.weapon-card {
  background-color: #2d2d2d;
  border: 2px solid #8b7355;
  border-radius: 8px;
  padding: 20px;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.weapon-card:hover {
  border-color: #c9a961;
  box-shadow: 0 4px 15px rgba(201, 169, 97, 0.2);
  transform: translateY(-2px);
}

.weapon-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 15px;
  padding-bottom: 15px;
  border-bottom: 2px solid #8b7355;
}

.weapon-name {
  color: #c9a961;
  font-size: 1.3rem;
  margin: 0;
  flex: 1;
}

.weapon-type-badge {
  background-color: #8b7355;
  color: #e8dcc4;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  white-space: nowrap;
}

.weapon-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.weapon-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-row {
  display: flex;
  gap: 10px;
  align-items: center;
}

.info-label {
  color: #c9a961;
  font-weight: 600;
  min-width: 140px;
  font-size: 0.9rem;
}

.info-value {
  color: #e8dcc4;
  font-size: 0.9rem;
}

.weapon-description {
  color: #e8dcc4;
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0;
  padding: 10px;
  background-color: rgba(139, 115, 85, 0.2);
  border-left: 3px solid #c9a961;
  border-radius: 4px;
}

.weapon-actions {
  display: flex;
  gap: 10px;
  padding-top: 10px;
  border-top: 1px solid #8b7355;
}

.btn-edit,
.btn-delete {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  font-size: 0.9rem;
}

.btn-edit {
  background-color: #8b7355;
  color: #e8dcc4;
}

.btn-edit:hover {
  background-color: #c9a961;
  color: #1a1a1a;
}

.btn-delete {
  background-color: #5a4a3a;
  color: #e8dcc4;
}

.btn-delete:hover {
  background-color: #d84a4a;
  color: #e8dcc4;
}
</style>
