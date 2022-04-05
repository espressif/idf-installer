<template>
  <!-- <img alt="Vue logo" src="./assets/logo.png"> -->
  <HelloWorld msg="Welcome to ESP-IDF Installer 3 (preview)"/>
</template>

<script>
import FrameworkSelector from './components/FrameworkSelector.vue'

export default {
  name: 'App',
  components: {
    FrameworkSelector
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
