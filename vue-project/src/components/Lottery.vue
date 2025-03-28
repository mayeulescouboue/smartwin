<template>
  <div>
    <div>
      <p id="test">Balance de la lotterie : {{ balance }} ETH (= {{ balanceInEuros }} €)</p>
      <p v-if="ticketsBought !== null">Vous avez : {{ ticketsBought }} Billet(s)</p>
    </div>

    <div>
      <div>
        <button @click="buyTicket">Acheter un billet</button>

        <button @click="toggleAdminPanel">Admin Panel</button>

        <AdminPanel
          v-if="showAdminPanel"
          :userAddress="userAddress"
          :contractAddress="contractAddress"
          @winnerSelected="updateWinner"
        />

        <div v-if="winner">
          <p>Le dernier gagnant est : {{ winner }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from "ethers";
import lotteryABI from "../LotteryABI.json";
import AdminPanel from "./AdminPanel.vue";

export default {
  props: {
    userAddress: String,
  },
  data() {
    return {
      contractAddress: "0x750cE6ea2e3626C023C72CA16Ebe260bd577a1c8",
      showAdminPanel: false,
      winner: "",
      balance: "",
      balanceInEuros: "",
      ticketsBought: null,
    };
  },
  methods: {
    async buyTicket() {
      if (!this.userAddress) {
        alert("Veuillez connecter votre wallet d'abord.");
        return;
      }

      if (typeof window.ethereum !== "undefined") {
        try {
          const provider = new ethers.BrowserProvider(window.ethereum);
          const signer = await provider.getSigner();

          const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);

          const tx = await lotteryContract.enter({
            value: ethers.parseEther("0.0002"),
          });

          await tx.wait();
          alert("Billet acheté avec succès !");
          await this.fetchBalance();
          await this.fetchUserTickets();
        } catch (error) {
          console.error("Erreur lors de l'achat du billet :", error);
          alert("Achat du billet échoué.");
        }
      } else {
        alert("MetaMask non détecté. Veuillez installer l'extension MetaMask.");
      }
    },
    toggleAdminPanel() {
      this.showAdminPanel = !this.showAdminPanel;
    },
    updateWinner(newWinner) {
      this.winner = newWinner;
    },
    async fetchBalance() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, provider);

        const contractBalance = await lotteryContract.getBalance();
        this.balance = ethers.formatEther(contractBalance);


        await this.fetchETHtoEUR();
      } catch (error) {
        console.error("Erreur lors de la récupération de la balance du contrat :", error);
      }
    },
    async fetchETHtoEUR() {
      try {
        const response = await fetch("https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur");
        const data = await response.json();
        
        const ethToEurRate = data.ethereum.eur;

        const balanceInEuros = (parseFloat(this.balance) * ethToEurRate).toFixed(2);
        this.balanceInEuros = balanceInEuros;
      } catch (error) {
        console.error("Erreur lors de la récupération du taux ETH/EUR :", error);
        this.balanceInEuros = "N/A";
      }
    },
    async fetchUserTickets() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, provider);

        const players = await lotteryContract.getPlayers();

        this.ticketsBought = players.filter(player => player.toLowerCase() === this.userAddress.toLowerCase()).length;
      } catch (error) {
        console.error("Erreur lors de la récupération des tickets de l'utilisateur :", error);
        this.ticketsBought = 0;
      }
    },
  },
  created() {
    this.fetchBalance();
    if (this.userAddress) {
      this.fetchUserTickets();
    }
  },
  watch: {
    userAddress(newAddress) {
      if (newAddress) {
        this.fetchUserTickets();
      }
    },
  },
  components: {
    AdminPanel,
  },
};
</script>

<style scoped>
</style>
