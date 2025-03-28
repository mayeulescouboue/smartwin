<template>
    <div>
      <button @click="connectWallet">
        {{ isConnected ? 'Connected: ' + userAddress : 'Connect Wallet' }}
      </button>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      onConnect: Function,
    },
    data() {
      return {
        isConnected: false,
        userAddress: null,
      };
    },
    methods: {
      async connectWallet() {
        if (typeof window.ethereum !== "undefined") {
          try {
            const [address] = await window.ethereum.request({ method: "eth_requestAccounts" });
            this.userAddress = address;
            this.isConnected = true;
            this.onConnect(this.userAddress);
          } catch (error) {
            console.error("Erreur de connexion :", error);
          }
        } else {
          alert("MetaMask non détecté. Veuillez installer l'extension MetaMask.");
        }
      }
    }
  };
  </script>
  
  <style scoped>
  </style>
  