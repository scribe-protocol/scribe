import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  },
  solidity: "0.8.20"
};

export default config;
