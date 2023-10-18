import { ethers } from "hardhat";

async function main() {

  const auction = await ethers.deployContract("Auction");

  await auction.waitForDeployment();

  console.log(
    `Auction contract deployed to ${auction.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
