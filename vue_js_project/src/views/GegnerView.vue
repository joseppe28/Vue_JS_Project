<template>
  <div class="gegner-view">
    <div class="header">
      <h1>Gegner</h1>
      <div class="search-wrapper">
        <input 
          type="text" 
          class="search-input" 
          placeholder="Gegner suchen..."
        >
        <span class="search-icon">🔍</span>
      </div>
      <router-link to="/" class="close-btn">✕</router-link>
    </div>

    <div class="content">
      <!-- Gegner werden hier angezeigt -->
    </div>

    <button class="add-btn">+</button>
  </div>
</template>

<script>
export default {
  name: 'GegnerView'
}
</script>

<style scoped>
.gegner-view {
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
  width: 300px;
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
  font-size: 2.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(201, 169, 97, 0.3);
}

.add-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 25px rgba(201, 169, 97, 0.5);
}

.add-btn:active {
  transform: scale(0.95);
}

@media (max-width: 768px) {
  .header {
    flex-wrap: wrap;
  }

  h1 {
    font-size: 2rem;
    flex: 1 0 auto;
  }

  .search-wrapper {
    flex: 1 0 100%;
    min-width: 200px;
    order: 3;
  }

  .close-btn {
    width: 40px;
    height: 40px;
    font-size: 1.5rem;
  }
}
</style>
