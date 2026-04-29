<template>
  <div class="home-container">
    <div class="hero-section">
      <div class="hero-content">
        <h1>Willkommen</h1>
        <p class="subtitle">Das Schwarze Auge - Kampf Controller</p>
        <p class="description">
          Dein Portal für Kämpfe innerhalb der Welt von DSA.
          Füge ganz einfach Gegner hinzu, verwalte deien Charakter und behalte den Überblick
        </p>
      </div>
    </div>

    <div class="content-section">
      <div class="info-grid">
        <div class="info-card">
          <div class="card-icon">📜</div>
          <h3>Gegner</h3>
          <p>Alle Gegner auf einen Blick.</p>
        </div>
        <div class="info-card">
          <div class="card-icon">✨</div>
          <h3>Kampf</h3>
          <p>Starte den Kampf mit den Gegnern deiner Wahl.</p>
        </div>
        <div class="info-card">
          <div class="card-icon">⚔️</div>
          <h3>Sonderfertigkeiten</h3>
          <p>Entdecke alle verfügbaren Sonderfertigkeiten und Kampfmöglichkeiten.</p>
        </div>
      </div>
    </div>

    <div class="footer-section">
      <p>© 2026 Kampf Controller. Keine Rechte vorbehalten.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HomeView'
}
</script>

<style scoped>
/* DSA Wiki Farbschema */
:root {
  --dsa-dark: #1a1a1a;
  --dsa-bg: #2d2d2d;
  --dsa-gold: #c9a961;
  --dsa-light: #e8dcc4;
  --dsa-accent: #8b7355;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.home-container {
  background-color: var(--dsa-dark);
  color: var(--dsa-light);
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Hero Section */
.hero-section {
  background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
  border-bottom: 3px solid var(--dsa-gold);
  padding: 80px 20px;
  text-align: center;
}

.hero-content h1 {
  font-size: 3.5rem;
  color: var(--dsa-gold);
  margin-bottom: 10px;
  font-weight: 600;
  letter-spacing: 2px;
}

.hero-content .subtitle {
  font-size: 1.5rem;
  color: var(--dsa-accent);
  margin-bottom: 30px;
}

.hero-content .description {
  max-width: 600px;
  margin: 0 auto;
  font-size: 1.1rem;
  color: var(--dsa-light);
  line-height: 1.6;
}

/* Content Section */
.content-section {
  flex: 1;
  padding: 60px 20px;
}

.info-grid {
  max-width: 900px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30px;
}

.info-card {
  background-color: var(--dsa-bg);
  border: 2px solid var(--dsa-accent);
  border-radius: 8px;
  padding: 30px;
  text-align: center;
  transition: all 0.3s ease;
  cursor: pointer;
}

.info-card:hover {
  border-color: var(--dsa-gold);
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(201, 169, 97, 0.2);
}

.card-icon {
  font-size: 3rem;
  margin-bottom: 15px;
}

.info-card h3 {
  color: var(--dsa-gold);
  font-size: 1.3rem;
  margin-bottom: 15px;
}

.info-card p {
  color: var(--dsa-light);
  line-height: 1.6;
  font-size: 0.95rem;
}

/* Footer Section */
.footer-section {
  background-color: var(--dsa-bg);
  border-top: 2px solid var(--dsa-gold);
  padding: 30px;
  text-align: center;
  color: var(--dsa-accent);
  font-size: 0.95rem;
}

/* Responsive */
@media (max-width: 768px) {
  .hero-content h1 {
    font-size: 2.5rem;
  }

  .hero-content .subtitle {
    font-size: 1.2rem;
  }

  .hero-content .description {
    font-size: 1rem;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .hero-section {
    padding: 50px 20px;
  }

  .content-section {
    padding: 40px 20px;
  }
}
</style>
