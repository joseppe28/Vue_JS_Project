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
        <button type="button" class="btn" @click="addWeapon">Waffe hinzufügen</button>
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
      },
      form: this.emptyForm(),
      tempAdv: '',
      tempDis: '',
      tempSF: '',
    };
  },
  methods: {
    emptyForm() {
      return {
        name: '',
        type: '',
        description: '',
        attributes: { MU: 10, KL: 10, IN: 10, CH: 10, FF: 10, GE: 10, KO: 10, KK: 10 },
        weapons: [],
        advantages: [],
        disadvantages: [],
        specialAbilities: [],
      };
    },
    addWeapon() {
      this.form.weapons.push({ name: '', type: '', details: '' });
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
.btn { padding:6px 10px; border:none; background:#eee; border-radius:6px; cursor:pointer }
.btn.small { padding:4px 8px }
.btn.primary { background:#c9a961; color:#fff }
.inline-input { display:flex; gap:8px }
.chip-list { display:flex; gap:8px; flex-wrap:wrap; margin-top:8px }
.chip { background:#f3efe6; padding:6px 8px; border-radius:999px }
.chip--neg { background:#f8e6e4 }
.actions { display:flex; gap:12px; justify-content:flex-start; margin-top:12px }
@media (max-width:720px){ .attr-grid{grid-template-columns:repeat(2,1fr)} .weapon-row{flex-direction:column} }
</style>