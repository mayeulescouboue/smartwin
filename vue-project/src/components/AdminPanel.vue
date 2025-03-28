<template>
  <div v-if="isOwner">
    <p>Balance du contrat: {{ balance }} ETH</p>
    <p>Liste des joueurs actuels:</p>
    <ul>
      <li v-for="(player, index) in players" :key="index">{{ player }}</li>
    </ul>

    <button @click="pickWinner" :disabled="pickingWinner">Tirer un gagnant</button>
    <button @click="startLottery" :disabled="lotteryStarted">Démarrer la loterie</button>
    <button @click="endLottery" :disabled="!lotteryStarted">Arrêter la loterie</button>

    <div v-if="winner">
      <h4>Le gagnant actuel est : {{ winner }}</h4>
      <p>Montant gagné : {{ winningAmount }} ETH</p>
    </div>

    <div v-if="pickingWinner">
      <p>En cours de tirage...</p>
    </div>

    <div v-if="oldWinners.length > 0">
      <h4>Anciens gagnants :</h4>
      <ul>
        <li v-for="(winner, index) in oldWinners" :key="index">{{ winner }}</li>
      </ul>
    </div>
  </div>
  <div v-else>
    <p>Vous n'êtes pas l'administrateur de cette loterie.</p>
  </div>
</template>

<script>
import { ethers } from "ethers";
import lotteryABI from "../LotteryABI.json";

export default {
  props: {
    userAddress: String,
    contractAddress: String,
  },
  data() {
    return {
      isOwner: false,
      balance: 0,
      players: [],
      winner: "",
      winningAmount: "",
      pickingWinner: false,
      oldWinners: [],
      lotteryStarted: false,
    };
  },
  async created() {
    await this.checkOwner();
    if (this.isOwner) {
      await this.fetchLotteryInfo();
      await this.fetchOldWinners();
      await this.fetchLotteryStatus();
    }
  },
  methods: {
    async checkOwner() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const address = await signer.getAddress();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const owner = await lotteryContract.owner();
        this.isOwner = address.toLowerCase() === owner.toLowerCase();
      } catch (error) {
        console.error("Erreur lors de la vérification du propriétaire :", error);
      }
    },
    async fetchLotteryInfo() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const contractBalance = await lotteryContract.getBalance();
        this.balance = ethers.formatEther(contractBalance);
        const players = await lotteryContract.getPlayers();
        this.players = players.map((player) => player.toLowerCase());
      } catch (error) {
        console.error("Erreur lors de la récupération des informations de la loterie :", error);
      }
    },
    async fetchLotteryStatus() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        this.lotteryStarted = await lotteryContract.lotteryStarted();
      } catch (error) {
        console.error("Erreur lors de la récupération de l'état de la loterie :", error);
      }
    },
    async fetchOldWinners() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const winners = [];
        const totalLotteries = await lotteryContract.lotteryId();
        for (let i = 1; i < totalLotteries; i++) {
          const winner = await lotteryContract.getWinnerByLottery(i);
          winners.push(winner.toLowerCase());
        }
        this.oldWinners = winners;
      } catch (error) {
        console.error("Erreur lors de la récupération des anciens gagnants :", error);
      }
    },
    async pickWinner() {
      this.pickingWinner = true;
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const contractBalance = await lotteryContract.getBalance();
        const winningAmount = ethers.formatEther(contractBalance);
        const tx = await lotteryContract.pickWinner();
        await tx.wait();
        const lotteryId = await lotteryContract.lotteryId();
        const winnerAddress = await lotteryContract.getWinnerByLottery(lotteryId - BigInt(1));
        this.winner = winnerAddress;
        this.winningAmount = winningAmount;
        await this.fetchLotteryInfo();
        await this.fetchOldWinners();
      } catch (error) {
        console.error("Erreur lors du tirage du gagnant :", error);
        alert("Erreur lors du tirage du gagnant.");
      } finally {
        this.pickingWinner = false;
      }
    },
    async startLottery() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const tx = await lotteryContract.startLottery();
        await tx.wait();
        this.lotteryStarted = true;
      } catch (error) {
        console.error("Erreur lors du démarrage de la loterie :", error);
        alert("Erreur lors du démarrage de la loterie.");
      }
    },
    async endLottery() {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const lotteryContract = new ethers.Contract(this.contractAddress, lotteryABI, signer);
        const tx = await lotteryContract.endLottery();
        await tx.wait();
        this.lotteryStarted = false;
      } catch (error) {
        console.error("Erreur lors de l'arrêt de la loterie :", error);
        alert("Erreur lors de l'arrêt de la loterie.");
      }
    },
  },
};
</script>
