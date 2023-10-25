import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert, expect } from "chai";
import { ethers } from "hardhat";
import {
  ContributionFacet,
  Diamond,
  EcoFacet,
  MockECOToken,
  MockECOToken__factory,
} from "../typechain-types";

describe("Local Chain ContributionFacet Test", function () {
  let diamondAddress: string;
  let contributionFacet: ContributionFacet;
  let mockEcoToken: MockECOToken;
  let ecoFacet: EcoFacet;

  // Runs before all tests in this block
  before(async function () {
    diamondAddress = await deployDiamond();
    console.log({ diamondAddress });

    // deploy Contribution Facet
    await addFacets(diamondAddress);
    contributionFacet = await ethers.getContractAt(
      "ContributionFacet",
      diamondAddress
    );
    ecoFacet = await ethers.getContractAt("EcoFacet", diamondAddress);

    const [deployer] = await ethers.getSigners();

    console.log(
      "Deploying MockEcoToken with the account:",
      await deployer.getAddress()
    );

    const MockEcoToken: MockECOToken__factory = new MockECOToken__factory(
      deployer
    );
    mockEcoToken = await MockEcoToken.deploy(1000000000000);
    await mockEcoToken.waitForDeployment();

    console.log({ mockEcoToken });

    console.log("MockEcoToken deployed to:", await mockEcoToken.getAddress());

    // transfer balance to deployer
    await mockEcoToken.transfer(await deployer.getAddress(), 100000);

    console.log(
      "MockEcoToken balance of deployer:",
      await mockEcoToken.balanceOf(await deployer.getAddress())
    );

    console.log({ deployer });

    let approval = await mockEcoToken.approve(diamondAddress, 10000);

    console.log({ approval });
  });

  it("should be able to change the erc20 token address", async () => {
    await ecoFacet.changeEcoAddress(await mockEcoToken.getAddress());

    const ecoTokenInStorage = await ecoFacet.getEcoAddress();

    console.log({ ecoTokenInStorage });

    assert.equal(ecoTokenInStorage, await mockEcoToken.getAddress());
  });

  it("should create a contribution", async () => {
    await contributionFacet.createContribution("test", "test cid", 1);

    let contribution = await contributionFacet.getContribution("test", 0);

    assert.exists(contribution);

    console.log({ contribution });
  });

  it("should successfully create multiple contributions", async () => {
    await contributionFacet.createContribution("test", "test cid 2", 1);

    let contribution2 = await contributionFacet.getContribution("test", 1);

    assert.exists(contribution2);

    console.log({ contribution2 });

    await contributionFacet.createContribution("test", "test cid 3", 1);

    let contribution3 = await contributionFacet.getContribution("test", 2);

    assert.exists(contribution3);

    console.log({ contribution3 });
  });

  it("should allow contract owner to set character count", async () => {
    await contributionFacet.updateCharacterCount("test", 0, 10);

    let characterCount = (await contributionFacet.getContribution("test", 0))
      .characterCount;

    assert.equal(characterCount, 10);
  });

  it("should not allow non contract owner to set character count", async () => {
    const signer = await ethers.provider.getSigner(1);

    await expect(
      contributionFacet.connect(signer).updateCharacterCount("test", 0, 15)
    ).to.be.revertedWith("LibDiamond: Must be contract owner");
  });

  it("should not allow person to contribute if they haven't been approved for enough tokens", async () => {
    try {
      await contributionFacet.createContribution(
        "test",
        "testCid",
        1000000000000
      );
      assert.fail("Expected an error but did not get one");
    } catch (err) {
      assert.include(err.message, "ERC20InsufficientAllowance");
    }
  });
});
