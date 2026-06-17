<template>
  <div class="simulation-view">
    <header class="header">
      <h1>Simulation</h1>
      <div class="turn-info">
        <div class="turn-chip">Runde {{ turnCounter }}</div>
      </div>
      <router-link to="/" class="close-btn">✕</router-link>
    </header>

    <section class="current-banner">
      <span class="muted">Aktueller Zug</span>
      <strong>{{ currentActorLabel }}</strong>
    </section>

    <section class="action-bar">
      <button class="btn" @click="openPlayerModal">+ Spieler</button>
      <button class="btn" @click="openEnemyModal">+ Gegner</button>
      <button class="btn primary" @click="startEncounter" :disabled="!canStart">
        Kampf starten
      </button>
      <button class="btn" @click="openAttackModal" :disabled="!canAttack">
        Angriff
      </button>
      <button class="btn" @click="nextTurn" :disabled="!encounterStarted || !turnOrder.length">
        Naechster Zug
      </button>
    </section>

    <section class="boards">
      <div class="board">
        <header class="board__head">
          <h2>Spieler</h2>
          <span class="muted">{{ players.length }} Teilnehmer</span>
        </header>
        <div v-if="!players.length" class="empty-state">Noch keine Spieler.</div>
        <div v-else class="card-grid">
          <article v-for="player in players" :key="player.id" class="card">
            <div>
              <strong>{{ player.name }}</strong>
              <div class="muted small">INI {{ player.ini }}</div>
              <div v-if="player.effects && player.effects.length" class="tag-list">
                <span v-for="effect in player.effects" :key="effect.id" class="tag">
                  {{ effect.name }} ({{ effect.rounds }})
                </span>
              </div>
            </div>
            <button class="btn small" @click="openEffectModal(player)">Effekt</button>
          </article>
        </div>
      </div>

      <div class="board">
        <header class="board__head">
          <h2>DM</h2>
          <span class="muted">{{ enemies.length }} Gegner</span>
        </header>
        <div v-if="!enemies.length" class="empty-state">Noch keine Gegner.</div>
        <div v-else class="card-grid">
          <article v-for="enemy in enemies" :key="enemy.id" class="card">
            <div>
              <strong>{{ enemy.name }}</strong>
              <div class="muted small">INI {{ enemy.ini }}</div>
              <div class="muted small">LE {{ enemy.hp }} | RS {{ enemy.rs }}</div>
              <div v-if="enemy.effects && enemy.effects.length" class="tag-list">
                <span v-for="effect in enemy.effects" :key="effect.id" class="tag">
                  {{ effect.name }} ({{ effect.rounds }})
                </span>
              </div>
            </div>
            <button class="btn small" @click="openEffectModal(enemy)">Effekt</button>
          </article>
        </div>
      </div>
    </section>

    <div v-if="showPlayerModal" class="modal-backdrop" @click="closePlayerModal">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Spieler hinzufuegen</h3>
          <button type="button" class="btn small" @click="closePlayerModal">Schliessen</button>
        </header>
        <div class="modal__body">
          <label>Spielername
          <input v-model="playerForm.name" />
          </label>
          <label>Initiative (INI)
          <input v-model.number="playerForm.ini" type="number" min="0" />
          </label>
          <label>Lebensenergie (LE)
          <input v-model.number="playerForm.hp" type="number" min="0" />
          </label>
          <button class="btn primary" @click="addPlayer">Hinzufuegen</button>
        </div>
      </div>
    </div>

    <div v-if="showEnemyModal" class="modal-backdrop" @click="closeEnemyModal">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Gegner suchen</h3>
          <button type="button" class="btn small" @click="closeEnemyModal">Schliessen</button>
        </header>
        <div class="modal__body">
          <input
            v-model="enemyQuery"
            class="search-input"
            placeholder="Name des Gegners..."
            @input="queueEnemySearch"
          />
          <div v-if="enemyLoading" class="muted">Suche...</div>
          <div v-else-if="enemyError" class="muted">{{ enemyError }}</div>
          <div v-else-if="!enemyResults.length" class="muted">Keine Treffer.</div>
          <div v-else class="result-list">
            <div
              v-for="enemy in enemyResults"
              :key="enemy.id"
              class="result-item"
            >
              <div>
                <strong>{{ enemy.name }}</strong>
                <div class="muted small">
                  INI {{ getAttributeValue(enemy, 'INI') }}
                  +
                  <input
                    class="inline-input"
                    type="number"
                    min="0"
                    v-model.number="enemyIniBonus[enemy.id]"
                  />
                  | LE {{ getAttributeValue(enemy, 'LE') }}
                </div>
              </div>
              <button type="button" class="tag" @click="selectEnemy(enemy)">Auswaehlen</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showDamageModal" class="modal-backdrop" @click="closeDamageModal">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Schaden</h3>
          <button type="button" class="btn small" @click="closeDamageModal">Schliessen</button>
        </header>
        <div class="modal__body">
          <div class="damage-row">
            <label>TP beruecksichtigen (RS abziehen)</label>
            <input type="checkbox" v-model="damageIsTp" />
          </div>
          <input v-model.number="damageValue" type="number" min="0" placeholder="Schaden" />
          <button class="btn primary" @click="applyDamage">Anwenden</button>
        </div>
      </div>
    </div>

    <div v-if="showEffectModal" class="modal-backdrop" @click="closeEffectModal">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Effekt hinzufuegen</h3>
          <button type="button" class="btn small" @click="closeEffectModal">Schliessen</button>
        </header>
        <div class="modal__body">
          <label>Effektname
          <input v-model="effectForm.name" />
          </label>
          <label>Dauer in Runden
          <input v-model.number="effectForm.rounds" type="number" min="1" />
          </label>
          <button class="btn primary" @click="addEffect">Hinzufuegen</button>
        </div>
      </div>
    </div>

    <div v-if="showAttackModal" class="modal-backdrop" @click="closeAttackModal">
      <div class="modal" @click.stop>
        <header class="modal__head">
          <h3>Angriff</h3>
          <button type="button" class="btn small" @click="closeAttackModal">Schliessen</button>
        </header>
        <div class="modal__body">
          <div class="muted">Angreifer: {{ currentActorLabel }}</div>
          <div class="muted">Ziel auswaehlen</div>
          <div class="result-list">
            <button
              v-for="target in attackTargets"
              :key="target.id"
              class="result-item"
              type="button"
              @click="selectAttackTarget(target)"
            >
              <div>
                <strong>{{ target.name }}</strong>
                <div class="muted small">INI {{ target.ini }}</div>
              </div>
              <span class="tag">Waehlen</span>
            </button>
          </div>

          <div v-if="attackTarget" class="attack-panel">
            <div class="attack-stats">
              <div><strong>AW</strong> {{ attackStats.aw }}</div>
              <div><strong>PA</strong> {{ attackStats.pa }}</div>
              <div><strong>RS</strong> {{ attackStats.rs }}</div>
              <div><strong>LE</strong> {{ attackStats.hp }}</div>
            </div>
            <div class="damage-row">
              <label>TP beruecksichtigen (RS abziehen)</label>
              <input type="checkbox" v-model="attackIsTp" />
            </div>
            <div class="attack-actions">
              <button class="btn" @click="markDodged(true)">Ausgewichen</button>
              <button class="btn primary" @click="markDodged(false)">Getroffen</button>
            </div>
            <label>Verursachter Schaden
            <input v-model.number="attackDamage" type="number" min="0" />
            </label>
            <button class="btn primary" @click="applyAttack" :disabled="attackDodged === null">
              Anwenden
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SimulationView',
  data() {
    return {
      supabaseUrl: 'https://dhomjjfeyoeynhunrnbs.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRob21qamZleW9leW5odW5ybmJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MjYwOTIsImV4cCI6MjA5NDIwMjA5Mn0.PaWu0BDYsWL2D4H4U6NoHHwwx2o9tAGt-1L4w2GdK64',
      players: [],
      enemies: [],
      turnOrder: [],
      currentIndex: 0,
      turnCounter: 1,
      encounterStarted: false,
      showPlayerModal: false,
      showEnemyModal: false,
      showDamageModal: false,
      playerForm: { name: '', ini: 10, hp: 25 },
      enemyQuery: '',
      enemyResults: [],
      enemyLoading: false,
      enemyError: '',
      enemySearchTimer: null,
      enemyIniBonus: {},
      damageTarget: null,
      damageValue: 0,
      damageIsTp: true,
      showEffectModal: false,
      effectTarget: null,
      effectForm: { name: '', rounds: 1 },
      showAttackModal: false,
      attackTarget: null,
      attackDamage: 0,
      attackIsTp: true,
      attackDodged: null,
    };
  },
  computed: {
    canStart() {
      return this.players.length + this.enemies.length > 0;
    },
    canAttack() {
      return this.encounterStarted && this.turnOrder.length > 1;
    },
    currentActorLabel() {
      if (!this.encounterStarted || !this.turnOrder.length) {
        return '-';
      }
      return this.turnOrder[this.currentIndex]?.name || '-';
    },
    currentActor() {
      if (!this.encounterStarted || !this.turnOrder.length) {
        return null;
      }
      return this.turnOrder[this.currentIndex] || null;
    },
    attackTargets() {
      if (!this.currentActor) {
        return [];
      }
      return this.currentActor.isPlayer ? this.enemies : this.players;
    },
    attackStats() {
      if (!this.attackTarget) {
        return { aw: '-', pa: '-', rs: '-', hp: '-' };
      }
      const target = this.attackTarget;
      return {
        aw: this.getCombatStat(target, 'AW'),
        pa: this.getCombatStat(target, 'PA'),
        rs: this.getCombatStat(target, 'RS'),
        hp: this.getCombatStat(target, 'LE'),
      };
    },
  },
  methods: {
    openPlayerModal() {
      this.showPlayerModal = true;
    },
    closePlayerModal() {
      this.showPlayerModal = false;
    },
    addPlayer() {
      if (!this.playerForm.name || this.playerForm.ini === null) {
        return;
      }
      const player = {
        id: `p-${Date.now()}`,
        name: this.playerForm.name.trim(),
        ini: Number(this.playerForm.ini) || 0,
        hp: Number(this.playerForm.hp) || 0,
        isPlayer: true,
        effects: [],
      };
      this.players.push(player);
      this.insertCombatant(player);
      this.playerForm = { name: '', ini: 10, hp: 25 };
      this.closePlayerModal();
    },
    openEnemyModal() {
      this.showEnemyModal = true;
      this.enemyError = '';
      if (!this.enemyResults.length) {
        this.fetchEnemies();
      }
    },
    closeEnemyModal() {
      this.showEnemyModal = false;
    },
    queueEnemySearch() {
      if (this.enemySearchTimer) {
        clearTimeout(this.enemySearchTimer);
      }
      this.enemySearchTimer = setTimeout(() => {
        this.fetchEnemies();
      }, 250);
    },
    async fetchEnemies() {
      this.enemyLoading = true;
      this.enemyError = '';

      try {
        const headers = {
          apikey: this.supabaseAnonKey,
          Authorization: `Bearer ${this.supabaseAnonKey}`,
        };
        const query = this.enemyQuery.trim();
        const filter = query ? `&name=ilike.*${encodeURIComponent(query)}*` : '';
        const url = `${this.supabaseUrl}/rest/v1/enemies?select=id,name,enemy_attributes(value,attributes(code))&order=name.asc${filter}`;
        const response = await fetch(url, { headers });
        if (!response.ok) {
          const message = await response.text();
          throw new Error(message || `Request failed with ${response.status}`);
        }
        const data = await response.json();
        this.enemyResults = Array.isArray(data) ? data : [];
      } catch (error) {
        this.enemyError = error?.message || 'Konnte Gegner nicht laden.';
      } finally {
        this.enemyLoading = false;
      }
    },
    selectEnemy(enemy) {
      const ini = Number(this.getAttributeValue(enemy, 'INI')) || 0;
      const bonus = Number(this.enemyIniBonus[enemy.id]) || 0;
      const le = Number(this.getAttributeValue(enemy, 'LE')) || 0;
      const rs = Number(this.getAttributeValue(enemy, 'RS')) || 0;
      const combatant = {
        id: `e-${enemy.id}-${Date.now()}`,
        name: enemy.name,
        ini: ini + bonus,
        hp: le,
        rs,
        isPlayer: false,
        effects: [],
      };
      this.enemies.push(combatant);
      this.insertCombatant(combatant);
      this.closeEnemyModal();
    },
    startEncounter() {
      const combined = [...this.players, ...this.enemies];
      const sorted = combined.sort((a, b) => b.ini - a.ini);
      this.turnOrder = sorted;
      this.currentIndex = 0;
      this.turnCounter = 1;
      this.encounterStarted = true;
    },
    nextTurn() {
      if (!this.turnOrder.length) {
        return;
      }
      if (this.currentIndex >= this.turnOrder.length - 1) {
        this.currentIndex = 0;
        this.turnCounter += 1;
      } else {
        this.currentIndex += 1;
      }
      this.tickEffectsFor(this.turnOrder[this.currentIndex]);
    },
    openDamageModal(target) {
      if (!this.encounterStarted) {
        return;
      }
      this.damageTarget = target;
      this.damageValue = 0;
      this.damageIsTp = true;
      this.showDamageModal = true;
    },
    closeDamageModal() {
      this.showDamageModal = false;
    },
    openEffectModal(target) {
      this.effectTarget = target;
      this.effectForm = { name: '', rounds: 1 };
      this.showEffectModal = true;
    },
    closeEffectModal() {
      this.showEffectModal = false;
    },
    addEffect() {
      if (!this.effectTarget || !this.effectForm.name) {
        return;
      }
      const rounds = Number(this.effectForm.rounds) || 1;
      if (!this.effectTarget.effects) {
        this.effectTarget.effects = [];
      }
      this.effectTarget.effects.push({
        id: `fx-${Date.now()}`,
        name: this.effectForm.name.trim(),
        rounds,
      });
      this.closeEffectModal();
    },
    tickEffectsFor(target) {
      if (!target || !target.effects || !target.effects.length) {
        return;
      }
      target.effects = target.effects
        .map((effect) => ({
          ...effect,
          rounds: effect.rounds - 1,
        }))
        .filter((effect) => effect.rounds > 0);
    },
    applyDamage() {
      if (!this.damageTarget) {
        return;
      }
      if (!this.encounterStarted) {
        return;
      }
      let damage = Number(this.damageValue) || 0;
      if (this.damageIsTp) {
        damage = Math.max(damage - (this.damageTarget.rs || 0), 0);
      }
      if (typeof this.damageTarget.hp === 'number') {
        this.damageTarget.hp -= damage;
        if (this.damageTarget.hp < 0) {
          this.removeCombatant(this.damageTarget);
        }
      }
      this.closeDamageModal();
    },
    openAttackModal() {
      if (!this.canAttack) {
        return;
      }
      this.attackTarget = null;
      this.attackDamage = 0;
      this.attackIsTp = true;
      this.attackDodged = null;
      this.showAttackModal = true;
    },
    closeAttackModal() {
      this.showAttackModal = false;
    },
    selectAttackTarget(target) {
      this.attackTarget = target;
      this.attackDodged = null;
      this.attackDamage = 0;
    },
    markDodged(value) {
      this.attackDodged = value;
      if (value) {
        this.attackDamage = 0;
      }
    },
    applyAttack() {
      if (!this.attackTarget || this.attackDodged === null) {
        return;
      }
      if (this.attackDodged) {
        this.closeAttackModal();
        return;
      }
      const target = this.attackTarget;
      let damage = Number(this.attackDamage) || 0;
      if (this.attackIsTp) {
        damage = Math.max(damage - (target.rs || 0), 0);
      }
      if (typeof target.hp === 'number') {
        target.hp -= damage;
        if (target.hp < 0) {
          this.removeCombatant(target);
        }
      }
      this.closeAttackModal();
    },
    removeCombatant(target) {
      this.enemies = this.enemies.filter((item) => item.id !== target.id);
      this.players = this.players.filter((item) => item.id !== target.id);
      this.turnOrder = this.turnOrder.filter((item) => item.id !== target.id);
      if (!this.turnOrder.length) {
        this.currentIndex = 0;
        this.encounterStarted = false;
        return;
      }
      if (this.currentIndex >= this.turnOrder.length) {
        this.currentIndex = 0;
      }
    },
    getAttributeValue(enemy, code) {
      const rows = enemy?.enemy_attributes || [];
      const match = rows.find((row) => row?.attributes?.code === code);
      if (!match) {
        return '-';
      }
      return match.value ?? '-';
    },
    getCombatStat(target, code) {
      if (target.isPlayer) {
        if (code === 'LE') {
          return typeof target.hp === 'number' ? target.hp : '-';
        }
        return '-';
      }
      if (code === 'LE') {
        return typeof target.hp === 'number' ? target.hp : '-';
      }
      if (code === 'RS') {
        return typeof target.rs === 'number' ? target.rs : '-';
      }
      return this.getAttributeValue(target, code);
    },
    insertCombatant(combatant) {
      if (!this.encounterStarted) {
        return;
      }
      const currentId = this.turnOrder[this.currentIndex]?.id;
      const nextOrder = [...this.turnOrder, combatant].sort((a, b) => b.ini - a.ini);
      this.turnOrder = nextOrder;
      const newIndex = nextOrder.findIndex((item) => item.id === currentId);
      this.currentIndex = newIndex >= 0 ? newIndex : 0;
    },
  },
};
</script>

<style scoped>
.simulation-view {
  padding: 40px;
  color: #e8dcc4;
  background-color: #1a1a1a;
  min-height: 100vh;
}

.header {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: 20px;
  border-bottom: 2px solid #c9a961;
  padding-bottom: 16px;
}

h1 {
  color: #c9a961;
  margin: 0;
  font-size: 2.4rem;
}

.turn-info {
  display: flex;
  align-items: center;
  gap: 16px;
  justify-self: center;
}

.current-banner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  margin: 16px 0 0;
  font-size: 1.1rem;
}

.turn-chip {
  padding: 6px 12px;
  border-radius: 999px;
  border: 1px solid #8b7355;
  color: #c9a961;
  background: #2d2d2d;
}

.turn-current {
  display: flex;
  flex-direction: column;
  font-size: 0.9rem;
}

.action-bar {
  display: flex;
  gap: 12px;
  margin: 20px 0 28px;
  flex-wrap: wrap;
}

.boards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.board {
  background: #141414;
  border: 1px solid #2d2d2d;
  border-radius: 16px;
  padding: 16px;
}

.board__head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.card-grid {
  display: grid;
  gap: 12px;
}

.card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid #2d2d2d;
  background: #1a1a1a;
  gap: 12px;
}

.empty-state {
  color: #8b7355;
  font-size: 0.95rem;
}

.btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  background: #2d2d2d;
  color: #e8dcc4;
  cursor: pointer;
}

.btn.primary {
  background: #c9a961;
  color: #1a1a1a;
}

.btn.small {
  padding: 4px 8px;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(14, 12, 10, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  z-index: 20;
}

.modal {
  background: #141414;
  color: #e8dcc4;
  border: 1px solid #c9a961;
  border-radius: 8px;
  width: min(560px, 100%);
  padding: 16px;
  box-shadow: 0 18px 40px rgba(0, 0, 0, 0.45), 0 0 20px rgba(201, 169, 97, 0.15);
}

.modal__head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #8b7355;
}

.modal__head h3 {
  color: #c9a961;
  margin: 0;
}

.modal__body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.result-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 320px;
  overflow: auto;
}

.result-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid #2d2d2d;
  border-radius: 8px;
  background: #1a1a1a;
  color: #e8dcc4;
}

.result-item:hover {
  border-color: #c9a961;
  background: rgba(201, 169, 97, 0.08);
}

.tag {
  background: #c9a961;
  color: #1a1a1a;
  padding: 2px 8px;
  border: 0;
  border-radius: 999px;
  font-size: 0.75rem;
}

.damage-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.attack-panel {
  border-top: 1px solid #8b7355;
  padding-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.attack-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 8px;
  font-size: 0.9rem;
}

.attack-actions {
  display: flex;
  gap: 10px;
}

.inline-input {
  width: 70px;
  padding: 2px 6px;
  margin: 0 6px;
  border-radius: 6px;
  border: 1px solid #8b7355;
  background: #2d2d2d;
  color: #e8dcc4;
}

.search-input,
input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #8b7355;
  border-radius: 6px;
  background: #2d2d2d;
  color: #e8dcc4;
}

.search-input::placeholder,
input::placeholder {
  color: #8b7355;
}

.search-input:focus,
input:focus {
  outline: none;
  border-color: #c9a961;
  box-shadow: 0 0 8px rgba(201, 169, 97, 0.2);
}

.close-btn {
  font-size: 2rem;
  color: #c9a961;
  text-decoration: none;
  cursor: pointer;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #c9a961;
  border-radius: 50%;
  justify-self: end;
}

.close-btn:hover {
  background-color: rgba(201, 169, 97, 0.1);
}

label {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.9rem;
  font-weight: 600;
}

.muted {
  color: #8b7355;
}

.small {
  font-size: 0.85rem;
}

@media (max-width: 720px) {
  .header {
    grid-template-columns: 1fr;
    justify-items: center;
  }

  .turn-info {
    width: 100%;
    justify-content: center;
  }
}
</style>
