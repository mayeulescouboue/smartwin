<template>
  <div id="app">
    <nav class="navbar">
      <h1>EtherBay Lottery</h1>
      <ConnectWallet :onConnect="setUserAddress" />
    </nav>

    <main class="main-content">
      <Lottery :userAddress="userAddress" />
    </main>
  </div>
</template>

<script>
import ConnectWallet from "./components/ConnectWallet.vue";
import Lottery from "./components/Lottery.vue";

export default {
  components: {
    ConnectWallet,
    Lottery,
  },
  data() {
    return {
      userAddress: null,
    };
  },
  methods: {
    setUserAddress(address) {
      this.userAddress = address;
    },
  },
};
</script>