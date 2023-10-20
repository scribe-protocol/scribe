import { ethers } from "hardhat";
import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { ContributionFacet, NFTFacet, ProposalFacet, VotingFacet } from "../typechain-types";
import {assert, expect} from "chai";

describe("Local Chain NFTFacet Test", function () {
  let diamondAddress: string;
  let nftFacet: NFTFacet;
  let proposalFacet: ProposalFacet;
  let contributionFacet: ContributionFacet;
  let votingFacet: VotingFacet;
  
  // Assume necessary mocked data
  let proposalId = "mockedProposalId"; // Mocked proposalId for testing
  let mockProposalCID = "mockedCID"; // Mocked CID for proposal
  let mockMetadataCID = "mockedMetadataCID"; // Mocked CID for NFT

  // Setup NFTFacet for testing
  before(async function () {
    const [deployer] = await ethers.getSigners();
    diamondAddress = await deployDiamond(); // Assuming the diamond is essential for NFTFacet
    await addFacets(diamondAddress);
    proposalFacet = await ethers.getContractAt("ProposalFacet", diamondAddress);
    nftFacet = await ethers.getContractAt("NFTFacet", diamondAddress);
    contributionFacet = await ethers.getContractAt("ContributionFacet", diamondAddress);
    votingFacet = await ethers.getContractAt("VotingFacet", diamondAddress);

    // Create mock proposal
    createMockProposal(proposalId, mockProposalCID);

    //create mock contribution
    createMockContribution(proposalId, mockProposalCID, 0);

    //hold mock vote
    holdMockVote(proposalId, 0, 1, 0);
  });

  it("should successfully mint NFT to claimer", async function () {
    await nftFacet.claimNFT(proposalId, mockMetadataCID);

    let [deployer] = await ethers.getSigners();

    assert.equal(await nftFacet.ownerOf(0), deployer.address);
  });

  it("should not allow a claimer to claim NFT twice", async function () {
    await expect(nftFacet.claimNFT(proposalId, mockMetadataCID)).to.be.revertedWith("You have already claimed your NFT.");
  });

  async function createMockProposal(proposalId: string, mockProposalCID: string) {
    await proposalFacet.createProposal(
      proposalId,
      mockProposalCID
    );
  }

  async function createMockContribution(proposalId: string, mockContributiionCID: string, ecoAmount: number) {
    await contributionFacet.createContribution(proposalId, mockContributiionCID, ecoAmount);
  }

  async function holdMockVote(proposalId: string, contributionId: number, sessionType: number, voteType: number, ) {
    await votingFacet.startVotingSession(proposalId, contributionId, sessionType);
    await votingFacet.submitVote(proposalId, contributionId, voteType);
    await votingFacet.endVotingSession(proposalId, contributionId);
  }

});
