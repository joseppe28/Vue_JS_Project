<template>
	<section class="enemy-shell">
		<article class="enemy-card" :class="{ 'is-empty': !hasEnemy }">
			<header class="enemy-hero">
				<div>
					<p class="eyebrow">Gegnerprofil</p>
					<h1 class="enemy-title">
						{{ enemyName }}
					</h1>
					<p class="enemy-subtitle">
						{{ enemyTypeLabel }}
					</p>
				</div>

				<div class="enemy-meta" v-if="hasEnemy">
					<div class="meta-chip">
						<span class="meta-label">Bedrohung</span>
						<strong>{{ challengeRating }}</strong>
					</div>
					<div class="meta-chip">
						<span class="meta-label">Quelle</span>
						<strong>{{ sourceLabel }}</strong>
					</div>
				</div>
			</header>

			<div v-if="hasEnemy" class="enemy-content">
				<section class="panel panel--wide">
					<div class="panel-head">
						<h2>Beschreibung</h2>
					</div>
					<p class="description">
						{{ description }}
					</p>
				</section>

				<section class="panel">
					<div class="panel-head">
						<h2>Eigenschaften</h2>
					</div>

					<div class="attribute-grid">
						<div
							v-for="attribute in attributes"
							:key="attribute.code"
							class="attribute-card"
						>
							<span class="attribute-code">{{ attribute.code }}</span>
							<strong class="attribute-value">{{ attribute.value }}</strong>
							<span class="attribute-name">{{ attribute.name }}</span>
						</div>
					</div>
				</section>

				<section class="panel">
					<div class="panel-head">
						<h2>Waffen</h2>
					</div>

					<div v-if="weapons.length" class="list-stack">
						<article v-for="weapon in weapons" :key="weapon.key" class="list-item">
							<div class="list-item__head">
								<strong>{{ weapon.name }}</strong>
								<span class="tag">{{ weapon.type }}</span>
							</div>
							<p>{{ weapon.details }}</p>
						</article>
					</div>
					<p v-else class="muted">Keine Waffen hinterlegt.</p>
				</section>

				<section class="panel">
					<div class="panel-head">
						<h2>Vorteile</h2>
					</div>

					<div class="chip-list" v-if="advantages.length">
						<span v-for="advantage in advantages" :key="advantage" class="chip chip--positive">
							{{ advantage }}
						</span>
					</div>
					<p v-else class="muted">Keine Vorteile hinterlegt.</p>
				</section>

				<section class="panel">
					<div class="panel-head">
						<h2>Nachteile</h2>
					</div>

					<div class="chip-list" v-if="disadvantages.length">
						<span v-for="disadvantage in disadvantages" :key="disadvantage" class="chip chip--negative">
							{{ disadvantage }}
						</span>
					</div>
					<p v-else class="muted">Keine Nachteile hinterlegt.</p>
				</section>

				<section class="panel panel--wide">
					<div class="panel-head">
						<h2>Sonderfertigkeiten</h2>
					</div>

					<div v-if="specialAbilities.length" class="special-grid">
						<article v-for="ability in specialAbilities" :key="ability" class="special-card">
							<strong>{{ ability }}</strong>
						</article>
					</div>
					<p v-else class="muted">Keine Sonderfertigkeiten hinterlegt.</p>
				</section>
			</div>

			<div v-else class="empty-state">
				<h2>Kein Gegner geladen</h2>
				<p>Übergib der Komponente ein Gegnerobjekt, damit die Daten angezeigt werden.</p>
			</div>
		</article>
	</section>
</template>

<script>
export default {
	name: 'Enemy',
	props: {
		enemy: {
			type: Object,
			default: null,
		},
	},
	computed: {
		hasEnemy() {
			return Boolean(this.enemy);
		},
		normalizedEnemy() {
			return this.enemy || {};
		},
		enemyName() {
			return this.getValue(['name', 'bezeichnung'], 'Unbekannter Gegner');
		},
		enemyTypeLabel() {
			return this.getValue(['creatureType', 'creature_type', 'type'], 'Unbekannter Typ');
		},
		description() {
			return this.getValue(['description', 'beschreibung'], 'Keine Beschreibung vorhanden.');
		},
		challengeRating() {
			return this.getValue(['challengeRating', 'challenge_rating', 'challenge', 'rating'], 'n/a');
		},
		sourceLabel() {
			return this.getValue(['source', 'quelle'], 'Unbekannt');
		},
		attributes() {
			const attributeKeys = [
				['MU', 'Mut'],
				['KL', 'Klugheit'],
				['IN', 'Intuition'],
				['CH', 'Charisma'],
				['FF', 'Fingerfertigkeit'],
				['GE', 'Gewandtheit'],
				['KO', 'Konstitution'],
				['KK', 'Körperkraft'],
			];

			const source = this.normalizedEnemy.attributes || this.normalizedEnemy.eigenschaften || {};

			if (Array.isArray(source)) {
				return source.map((entry) => ({
					code: entry.code || entry.kurz || entry.short || entry.name || '??',
					name: entry.name || entry.label || entry.bezeichnung || entry.code || 'Eigenschaft',
					value: entry.value ?? entry.wert ?? entry.points ?? '-',
				}));
			}

			if (source && typeof source === 'object') {
				return attributeKeys.map(([code, name]) => ({
					code,
					name,
					value: source[code] ?? source[code.toLowerCase()] ?? source[name] ?? '-',
				}));
			}

			return attributeKeys.map(([code, name]) => ({
				code,
				name,
				value: '-',
			}));
		},
		weapons() {
			const source = this.normalizedEnemy.weapons || this.normalizedEnemy.waffen || [];

			if (!Array.isArray(source)) {
				return [];
			}

			return source.map((weapon, index) => {
				const name = weapon.name || weapon.bezeichnung || `Waffe ${index + 1}`;
				const type = weapon.weaponType || weapon.weapon_type || weapon.type || 'Waffe';
				const details = this.buildWeaponDetails(weapon);

				return {
					key: `${name}-${index}`,
					name,
					type,
					details,
				};
			});
		},
		advantages() {
			return this.normalizeNameList(['advantages', 'vorteile']);
		},
		disadvantages() {
			return this.normalizeNameList(['disadvantages', 'nachteile']);
		},
		specialAbilities() {
			return this.normalizeNameList(['specialAbilities', 'special_abilities', 'sonderfertigkeiten']);
		},
	},
	methods: {
		getValue(keys, fallback) {
			for (const key of keys) {
				const value = this.normalizedEnemy[key];
				if (value !== undefined && value !== null && value !== '') {
					return value;
				}
			}

			return fallback;
		},
		normalizeNameList(keys) {
			for (const key of keys) {
				const source = this.normalizedEnemy[key];
				if (!source) {
					continue;
				}

				if (Array.isArray(source)) {
					return source
						.map((item) => {
							if (typeof item === 'string') {
								return item;
							}

							if (item && typeof item === 'object') {
								return item.name || item.bezeichnung || item.label || item.title || '';
							}

							return '';
						})
						.filter(Boolean);
				}

				if (typeof source === 'string') {
					return source
						.split(',')
						.map((item) => item.trim())
						.filter(Boolean);
				}
			}

			return [];
		},
		buildWeaponDetails(weapon) {
			const parts = [];

			if (weapon.combatTechnique || weapon.combat_technique) {
				parts.push(weapon.combatTechnique || weapon.combat_technique);
			}

			const damageDiceCount = weapon.damageDiceCount ?? weapon.damage_dice_count;
			const damageDiceSides = weapon.damageDiceSides ?? weapon.damage_dice_sides;
			const damageBonus = weapon.damageBonus ?? weapon.damage_bonus;

			if (damageDiceCount || damageDiceSides || damageBonus !== undefined) {
				const damageText = `${damageDiceCount || 0}W${damageDiceSides || 0}${damageBonus ? `+${damageBonus}` : ''}`;
				parts.push(`Schaden ${damageText}`);
			}

			const attackMod = weapon.attackMod ?? weapon.attack_mod;
			const parryMod = weapon.parryMod ?? weapon.parry_mod;

			if (attackMod !== undefined || parryMod !== undefined) {
				parts.push(`AT ${attackMod ?? '-'} / PA ${parryMod ?? '-'}`);
			}

			if (weapon.rangeDistance || weapon.range_distance) {
				parts.push(`Reichweite ${weapon.rangeDistance || weapon.range_distance}`);
			}

			if (weapon.specialRules || weapon.special_rules) {
				parts.push(weapon.specialRules || weapon.special_rules);
			}

			return parts.length ? parts.join(' · ') : 'Keine weiteren Angaben.';
		},
	},
};
</script>

<style scoped>
.enemy-shell {
	padding: 1.5rem;
	background:
		radial-gradient(circle at top left, rgba(219, 140, 64, 0.18), transparent 28%),
		radial-gradient(circle at bottom right, rgba(35, 60, 91, 0.22), transparent 30%),
		linear-gradient(180deg, #f6efe4 0%, #eee2d2 100%);
	min-height: 100%;
}

.enemy-card {
	max-width: 1180px;
	margin: 0 auto;
	border-radius: 28px;
	padding: 1.5rem;
	background: rgba(255, 252, 247, 0.92);
	border: 1px solid rgba(93, 69, 38, 0.14);
	box-shadow: 0 24px 80px rgba(74, 53, 29, 0.16);
	backdrop-filter: blur(10px);
}

.enemy-hero {
	display: flex;
	justify-content: space-between;
	gap: 1rem;
	padding: 1.25rem;
	border-radius: 22px;
	background:
		linear-gradient(135deg, rgba(40, 43, 50, 0.98), rgba(77, 60, 36, 0.98));
	color: #fff6e8;
}

.eyebrow {
	margin: 0 0 0.35rem;
	text-transform: uppercase;
	letter-spacing: 0.18em;
	font-size: 0.72rem;
	color: rgba(255, 244, 226, 0.72);
}

.enemy-title {
	margin: 0;
	font-size: clamp(2rem, 4vw, 3.4rem);
	line-height: 1.05;
}

.enemy-subtitle {
	margin: 0.45rem 0 0;
	font-size: 1rem;
	color: rgba(255, 244, 226, 0.82);
}

.enemy-meta {
	display: grid;
	gap: 0.75rem;
	align-content: start;
	min-width: 240px;
}

.meta-chip {
	padding: 0.85rem 1rem;
	border-radius: 18px;
	background: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.12);
}

.meta-label {
	display: block;
	margin-bottom: 0.2rem;
	font-size: 0.76rem;
	text-transform: uppercase;
	letter-spacing: 0.12em;
	color: rgba(255, 244, 226, 0.72);
}

.enemy-content {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 1rem;
	margin-top: 1rem;
}

.panel {
	padding: 1rem;
	border-radius: 22px;
	background: linear-gradient(180deg, rgba(255, 255, 255, 0.95), rgba(251, 245, 236, 0.95));
	border: 1px solid rgba(93, 69, 38, 0.08);
}

.panel--wide {
	grid-column: 1 / -1;
}

.panel-head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 0.85rem;
}

.panel-head h2 {
	margin: 0;
	font-size: 1rem;
	letter-spacing: 0.06em;
	text-transform: uppercase;
	color: #4a3622;
}

.description {
	margin: 0;
	color: #3f352a;
	line-height: 1.65;
	white-space: pre-line;
}

.attribute-grid {
	display: grid;
	grid-template-columns: repeat(4, minmax(0, 1fr));
	gap: 0.75rem;
}

.attribute-card {
	display: grid;
	gap: 0.2rem;
	padding: 0.9rem;
	border-radius: 18px;
	background: linear-gradient(180deg, #fff, #f6eee1);
	border: 1px solid rgba(93, 69, 38, 0.09);
	text-align: center;
}

.attribute-code {
	font-size: 0.78rem;
	letter-spacing: 0.12em;
	text-transform: uppercase;
	color: #9b6a2f;
}

.attribute-value {
	font-size: 1.7rem;
	color: #2e241b;
}

.attribute-name {
	font-size: 0.82rem;
	color: #655142;
}

.list-stack {
	display: grid;
	gap: 0.75rem;
}

.list-item {
	padding: 0.9rem 1rem;
	border-radius: 18px;
	background: #fff;
	border: 1px solid rgba(93, 69, 38, 0.09);
}

.list-item__head {
	display: flex;
	justify-content: space-between;
	gap: 0.5rem;
	align-items: center;
	margin-bottom: 0.35rem;
}

.list-item p {
	margin: 0;
	color: #564739;
	line-height: 1.55;
}

.tag {
	display: inline-flex;
	align-items: center;
	padding: 0.28rem 0.65rem;
	border-radius: 999px;
	background: #efe2cf;
	color: #5b4228;
	font-size: 0.76rem;
	white-space: nowrap;
}

.chip-list {
	display: flex;
	flex-wrap: wrap;
	gap: 0.6rem;
}

.chip {
	display: inline-flex;
	align-items: center;
	padding: 0.4rem 0.75rem;
	border-radius: 999px;
	font-size: 0.9rem;
	border: 1px solid transparent;
}

.chip--positive {
	background: rgba(110, 154, 97, 0.14);
	border-color: rgba(110, 154, 97, 0.18);
	color: #40613a;
}

.chip--negative {
	background: rgba(184, 87, 65, 0.12);
	border-color: rgba(184, 87, 65, 0.18);
	color: #8a3a2b;
}

.special-grid {
	display: grid;
	grid-template-columns: repeat(2, minmax(0, 1fr));
	gap: 0.75rem;
}

.special-card {
	padding: 0.9rem 1rem;
	border-radius: 18px;
	background: linear-gradient(180deg, #fff, #f8f1e5);
	border: 1px solid rgba(93, 69, 38, 0.09);
	color: #3f352a;
}

.muted {
	margin: 0;
	color: #7f6a58;
}

.empty-state {
	padding: 3rem 1.25rem 1.5rem;
	text-align: center;
	color: #564739;
}

.empty-state h2 {
	margin: 0 0 0.5rem;
	color: #3b2b1d;
}

.is-empty {
	min-height: 320px;
}

@media (max-width: 1024px) {
	.enemy-content {
		grid-template-columns: 1fr;
	}

	.attribute-grid {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

@media (max-width: 720px) {
	.enemy-shell {
		padding: 0.75rem;
	}

	.enemy-card {
		padding: 0.85rem;
		border-radius: 22px;
	}

	.enemy-hero {
		flex-direction: column;
	}

	.enemy-meta {
		min-width: 0;
	}

	.attribute-grid,
	.special-grid {
		grid-template-columns: 1fr;
	}

	.list-item__head {
		flex-direction: column;
		align-items: flex-start;
	}
}
</style>
