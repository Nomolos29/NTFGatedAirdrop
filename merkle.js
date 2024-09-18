import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";
import csv from "csv-parser";

const csvFilePath = "airdrop.csv"; // CSV file of addresses and amount qualified.
const searchAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"; //One of the address in the csv file This is the address that wants to claim the reward. This is the msg.sender 

async function readCSV(filePath) {
  return new Promise((resolve, reject) => {
    const values = [];
    fs.createReadStream(filePath)
      .pipe(csv())
      .on("data", (row) => {
        values.push([row.address, row.amount]);
      })
      .on("end", () => {
        resolve(values);
      })
      .on("error", reject);
  });
}

async function generateMerkleTree() {
  try {
    const values = await readCSV(csvFilePath);
    const tree = StandardMerkleTree.of(values, ["address", "uint256"]);
    console.log("Merkle Root:", tree.root);
    fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
  } catch (error) {
    console.error("Error generating Merkle tree:", error);
  }
}

async function generateProof() {
  const tree = StandardMerkleTree.load(
    JSON.parse(fs.readFileSync("tree.json", "utf8"))
  );
  for (const [i, v] of tree.entries()) {
    if (v[0] === searchAddress) {
      const proof = tree.getProof(i);
      console.log(i);
      console.log("Value:", v);
      console.log("Proof:", proof);
    }
  }
}

// Run this to generate the Merkle tree Hash
generateMerkleTree();
generateProof();

//Run this to generate Proof for based on the selected address.
// generateProof();