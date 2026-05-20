<template>
  <div class="add-enemy-root">
    <header class="page-head">
      <h1>Neuen Gegner anlegen</h1>
      <p class="lead">Fülle das Formular aus und klicke auf „Gegner speichern“ — die Komponente emittiert `save-enemy`.</p>
    </header>

    <form class="enemy-form" @submit.prevent="handleSubmit">
      <section class="card">
        <label class="label">Name</label>
        <input v-model="form.name" required placeholder="Name des Gegners" />

        <label class="label">Typ</label>
        <input v-model="form.type" placeholder="z. B. Goblin, Drache" />

        <label class="label">Beschreibung</label>
        <textarea v-model="form.description" rows="4" placeholder="Kurze Beschreibung"></textarea>
      </section>

      <section class="card">
        <h2>Eigenschaften</h2>
        <div class="attr-grid">
          <div v-for="(label, code) in attributeLabels" :key="code" class="attr-item">
            <label class="small">{{ code }}</label>
            <input v-model.number="form.attributes[code]" type="number" min="0" max="30" />
            <small class="hint">{{ label }}</small>
          </div>
        </div>
      </section>

      <section class="card">
        <h2>Waffen</h2>
        <div v-for="(w, idx) in form.weapons" :key="idx" class="weapon-row">
          <input v-model="w.name" placeholder="Name" />
          <input v-model="w.type" placeholder="Typ" />
          <input v-model="w.details" placeholder="Kurz (z.B. 1W6+2 / AT+1)" />
          <button type="button" class="btn small" @click="removeWeapon(idx)">Entfernen</button>
        </div>
        <div class="weapon-actions">
          <button type="button" class="btn" @click="addWeapon">Waffe manuell</button>
          <button type="button" class="btn" @click="openWeaponSearch">Waffe aus DB</button>
        </div>
      </section>

      <section class="card">
        <h2>Vorteile / Nachteile / Sonderfertigkeiten</h2>

        <div class="list-block">
          <label class="small">Vorteil</label>
          <div class="inline-input">
            <input v-model="tempAdv" placeholder="z. B. Gute Augen" />
            <button type="button" class="btn" @click="pushList('advantages', tempAdv); tempAdv=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(a,i) in form.advantages" :key="i" class="chip">{{ a }} <button type="button" @click="removeFromList('advantages', i)">×</button></span>
          </div>
        </div>

        <div class="list-block">
          <label class="small">Nachteil</label>
          <div class="inline-input">
            <input v-model="tempDis" placeholder="z. B. Leicht reizbar" />
            <button type="button" class="btn" @click="pushList('disadvantages', tempDis); tempDis=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(d,i) in form.disadvantages" :key="i" class="chip chip--neg">{{ d }} <button type="button" @click="removeFromList('disadvantages', i)">×</button></span>
          </div>
        </div>

        <div class="list-block">
          <label class="small">Sonderfertigkeit</label>
          <div class="inline-input">
            <input v-model="tempSF" placeholder="z. B. Ausweichen" />
            <button type="button" class="btn" @click="pushList('specialAbilities', tempSF); tempSF=''">+</button>
          </div>
          <div class="chip-list">
            <span v-for="(s,i) in form.specialAbilities" :key="i" class="chip">{{ s }} <button type="button" @click="removeFromList('specialAbilities', i)">×</button></span>
          </div>
        </div>
      </section>

      <div class="actions">
        <button type="submit" class="btn primary">Gegner speichern</button>
        <button type="button" class="btn" @click="resetForm">Zurücksetzen</button>
      </div>
    </form>

    <div v-if="showWeaponSearch" class="modal-backdrop" @click="closeWeaponSearch">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Waffe suchen</h3>
          <button type="button" class="btn small" @click="closeWeaponSearch">Schließen</button>
        </header>
        <div class="modal__body">
          <input
            v-model="weaponQuery"
            class="search-input"
            placeholder="Name der Waffe..."
            @input="queueWeaponSearch"
          />
          <div v-if="weaponLoading" class="muted">Suche...</div>
          <div v-else-if="weaponError" class="muted">{{ weaponError }}</div>
          <div v-else-if="!weaponResults.length" class="muted">Keine Treffer.</div>
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
                <div class="muted small">{{ weapon.weapon_type || 'Unbekannt' }}</div>
              </div>
              <span class="tag">Auswählen</span>
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
  props: {
    supabaseUrl: {
      type: String,
      required: true,
    },
    supabaseAnonKey: {
      type: String,
      required: true,
    },
  },
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
      // emit a copy so parent can safely mutate
      this.$emit('save-enemy', JSON.parse(JSON.stringify(this.form)));
      this.resetForm();
    },
  },
};
</script>

<style scoped>
.add-enemy-root { max-width: 980px; margin: 32px auto; padding: 0 16px; }
.page-head h1 { margin: 0 0 6px; font-size: 1.8rem; }
.page-head .lead { margin: 0 0 18px; color: #6b5b43; }
.enemy-form .card { background: #fff; padding: 14px; border-radius: 8px; margin-bottom: 14px; border: 1px solid #e6dcc6; }
.label { display:block; margin:6px 0 4px; font-weight:600 }
input, textarea { width:100%; padding:8px 10px; border:1px solid #d8cbb3; border-radius:6px; }
.attr-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:8px; }
.attr-item { display:flex; flex-direction:column; }
.attr-item input { text-align:center }
.weapon-row { display:flex; gap:8px; margin-bottom:8px }
.weapon-row input { flex:1 }
.weapon-actions { display:flex; gap:8px; margin-top:8px }
.btn { padding:6px 10px; border:none; background:#eee; border-radius:6px; cursor:pointer }
.btn.small { padding:4px 8px }
.btn.primary { background:#c9a961; color:#fff }
.modal-backdrop { position:fixed; inset:0; background:rgba(14,12,10,0.7); display:flex; align-items:center; justify-content:center; padding:16px; z-index:20 }
.modal { background:#fff; border-radius:12px; width:min(640px, 100%); padding:16px; box-shadow:0 18px 40px rgba(0,0,0,0.35) }
.modal__head { display:flex; justify-content:space-between; align-items:center; margin-bottom:12px }
.modal__body { display:flex; flex-direction:column; gap:10px }
.weapon-results { display:flex; flex-direction:column; gap:8px; max-height:320px; overflow:auto }
.weapon-result { display:flex; justify-content:space-between; align-items:center; gap:12px; padding:10px 12px; border:1px solid #e6dcc6; border-radius:8px; background:#faf7f0; cursor:pointer }
.weapon-result:hover { background:#f1e8d6 }
.tag { background:#c9a961; color:#fff; padding:2px 8px; border-radius:999px; font-size:0.75rem }
.muted { color:#6b5b43 }
.small { font-size:0.85rem }
.inline-input { display:flex; gap:8px }
.chip-list { display:flex; gap:8px; flex-wrap:wrap; margin-top:8px }
.chip { background:#f3efe6; padding:6px 8px; border-radius:999px }
.chip--neg { background:#f8e6e4 }
.actions { display:flex; gap:12px; justify-content:flex-start; margin-top:12px }
@media (max-width:720px){ .attr-grid{grid-template-columns:repeat(2,1fr)} .weapon-row{flex-direction:column} }
</style>