import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert } from "chai";
import { ethers } from "hardhat";
import { keccak256, toUtf8Bytes } from "ethers";
import {
  ContributionFacet,
  MockECOToken,
  MockECOToken__factory,
  ProposalFacet,
  VotingFacet,
  EcoFacet,
} from "../typechain-types";
import { Web3Storage } from "web3.storage";

describe("Local Chain VotingFacet Test", function () {
  let diamondAddress: string;
  let contributionFacet: ContributionFacet;
  let mockEcoToken: MockECOToken;
  let proposalFacet: ProposalFacet;
  let votingFacet: VotingFacet;
  let proposalId: string;
  let updatedProposalCid: string;
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
    proposalFacet = await ethers.getContractAt("ProposalFacet", diamondAddress);
    votingFacet = await ethers.getContractAt("VotingFacet", diamondAddress);
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

    // transfer balance to deployer
    await mockEcoToken.transfer(await deployer.getAddress(), 100000);

    await mockEcoToken.approve(diamondAddress, 10000);

    await ecoFacet.changeEcoAddress(await mockEcoToken.getAddress());
  });

  it("should start a voting session", async () => {
    proposalId = keccak256(toUtf8Bytes("test"));
    await proposalFacet.createProposal(proposalId, "testCid");
    await contributionFacet.createContribution(proposalId, "testCid", 1);
    await votingFacet.startVotingSession(proposalId, 0, 0);
  });

  it("should allow a contributor to submit a vote", async () => {
    await votingFacet.submitVote(proposalId, 0, 0);
  });

  it("should end a voting session", async () => {
    await votingFacet.endVotingSession(proposalId, 0);
  });

  it("should update the proposal in the contract with the new CID", async () => {
    updatedProposalCid = "updatedCid";

    await proposalFacet.updateCid(proposalId, updatedProposalCid);

    let updatedProposal = await proposalFacet.getProposal(proposalId);

    assert.equal(updatedProposal.cid, updatedProposalCid);
  });

  it("should properly finalize a proposal", async () => {
    await contributionFacet.createContribution(proposalId, "testCid", 1);

    const contribution2 = await contributionFacet.getContribution(
      proposalId,
      1
    );

    await votingFacet.startVotingSession(
      proposalId,
      contribution2.contributionId,
      1
    );
    await votingFacet.submitVote(proposalId, contribution2.contributionId, 0);
    await votingFacet.endVotingSession(
      proposalId,
      contribution2.contributionId
    );

    assert.equal(await votingFacet.isProposalFinalized(proposalId), true);
  });

  it("should not start a voting session for a non-existing contribution", async () => {
    try {
      await votingFacet.startVotingSession(proposalId, 1000, 0);
    } catch (error) {
      assert.include(error.message, "VotingFacet: contribution does not exist");
    }
  });

  it("should not submit a vote for non-existing contribution", async () => {
    try {
      await votingFacet.submitVote(proposalId, 1000, 0);
    } catch (error) {
      assert.include(error.message, "VotingFacet: contribution does not exist");
    }
  });

  it("should not end a voting session for a non-existing contribution", async () => {
    try {
      await votingFacet.endVotingSession(proposalId, 1000);
    } catch (error) {
      assert.include(error.message, "VotingFacet: contribution does not exist");
    }
  });

  it("should not a end non-active voting session", async () => {
    await contributionFacet.createContribution(proposalId, "testCid", 1);

    const contribution2 = await contributionFacet.getContribution(
      proposalId,
      2
    );

    try {
      await votingFacet.endVotingSession(
        proposalId,
        contribution2.contributionId
      );
    } catch (error) {
      assert.include(
        error.message,
        "VotingFacet.endVotingSession: voting session is not active"
      );
    }
  });

  it("should not end a voting session prematurely", async () => {
    await contributionFacet.createContribution(proposalId, "testCid", 1);

    const contribution3 = await contributionFacet.getContribution(
      proposalId,
      3
    );

    await votingFacet.startVotingSession(
      proposalId,
      contribution3.contributionId,
      0
    );
    try {
      await votingFacet.endVotingSession(
        proposalId,
        contribution3.contributionId
      );
    } catch (error) {
      assert.include(
        error.message,
        "VotingFacet.endVotingSession: Voting session cannot be ended yet because the timer has not expired and not everyone has voted"
      );
    }
  });
});
