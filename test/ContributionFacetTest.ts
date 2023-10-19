import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert } from "chai";
import { ethers } from "hardhat";
import { ContributionFacet, Diamond, MockECOToken, MockECOToken__factory } from "../typechain-types";

describe("Local Chain ContributionFacet Test", function () {
  let diamondAddress: string;
  let contributionFacet: ContributionFacet;
  let mockEcoToken: MockECOToken;

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

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying MockEcoToken with the account:",
        await deployer.getAddress()
    );

    const MockEcoToken: MockECOToken__factory = new MockECOToken__factory(deployer);
    mockEcoToken = await MockEcoToken.deploy(1000000000000);
    await mockEcoToken.waitForDeployment();

    console.log({ mockEcoToken });

    console.log("MockEcoToken deployed to:", await mockEcoToken.getAddress());

    // transfer balance to deployer
    await mockEcoToken.transfer(await deployer.getAddress(), 100000);

    console.log("MockEcoToken balance of deployer:", await mockEcoToken.balanceOf(await deployer.getAddress()));

    console.log({ deployer });

    let approval = await mockEcoToken.approve(diamondAddress, 10000);

    console.log({ approval });
  });

  it("should be able to change the erc20 token address", async () => {
    await contributionFacet.changeEcoAddress(await mockEcoToken.getAddress());

    const ecoTokenInStorage = await contributionFacet.getEcoAddress();

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
});
