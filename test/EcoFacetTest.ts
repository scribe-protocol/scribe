import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { EcoFacet } from "../typechain-types";
import * as dotenv from "dotenv";

dotenv.config();

describe("Local Chain EcoFacet Test", function () {
  let diamondAddress: string;
  let ecoFacet: EcoFacet;
  before(async function () {
    diamondAddress = await deployDiamond();
    console.log({ diamondAddress });

    // deploy ProposalFacet
    await addFacets(diamondAddress);
    ecoFacet = await ethers.getContractAt("EcoFacet", diamondAddress);
  });

  it("should initialize with the correct address", async function () {
    expect(await ecoFacet.getEcoAddress()).to.equal(
      process.env.ECO_TOKEN_ADDRESS
    );
  });

  it("should allow the contract owner to change the eco address", async function () {
    await ecoFacet.changeEcoAddress(
      "0x0000000000000000000000000000000000000001"
    );

    expect(await ecoFacet.getEcoAddress()).to.equal(
      "0x0000000000000000000000000000000000000001"
    );
  });

  it("should not allow a non-owner to change the eco address", async function () {
    const signer = await ethers.provider.getSigner(1);

    await expect(
      ecoFacet
        .connect(signer)
        .changeEcoAddress("0x0000000000000000000000000000000000000002")
    ).to.be.revertedWith("LibDiamond: Must be contract owner");
  });
});
