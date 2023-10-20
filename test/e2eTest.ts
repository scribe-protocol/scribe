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
  NFTFacet,
} from "../typechain-types";
import { Web3Storage } from "web3.storage";

describe("Local Chain NFTFacet Test", function () {
  let diamondAddress: string;
  let contributionFacet: ContributionFacet;
  let mockEcoToken: MockECOToken;
  let proposalFacet: ProposalFacet;
  let votingFacet: VotingFacet;
  let nftFacet: NFTFacet;
  let title: string;
  let description: string;
  let content: string;
  let proposer: string;
  let creationTimestamp: string;
  let lastUpdatedTimestamp: string;
  let proposalId: string;
  let client: Web3Storage;
  let proposalCid: string;
  let contributor: string;
  let contributionContent: string;
  let contributionEcoAmount: number;
  let proposalVersion: number = 0;
  let updatedProposalCid: string;

  // Runs before all tests in this block
  before(async function () {
    diamondAddress = await deployDiamond();
    console.log({ diamondAddress });

    
    await addFacets(diamondAddress);
    contributionFacet = await ethers.getContractAt(
      "ContributionFacet",
      diamondAddress
    );
    proposalFacet = await ethers.getContractAt("ProposalFacet", diamondAddress);
    votingFacet = await ethers.getContractAt("VotingFacet", diamondAddress);
    nftFacet = await ethers.getContractAt("NFTFacet", diamondAddress);

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

    let approval = await mockEcoToken.approve(diamondAddress, 10000);

    await contributionFacet.changeEcoAddress(await mockEcoToken.getAddress());

    const ecoTokenInStorage = await contributionFacet.getEcoAddress();

    title = "Test Book Title";
    description = "Test Book Description.";
    content = "";
    proposer = "0xTestEthereumAddress"; 
    creationTimestamp = Date.now().toString();
    lastUpdatedTimestamp = creationTimestamp; // Initially, it's the same as creationTimestamp.

    // Generate a proposalId using keccak256
    proposalId = keccak256(toUtf8Bytes(title + proposer + creationTimestamp));

    // Upload to web3.storage and get the CID
    client = new Web3Storage({
      token: process.env.WEB3_STORAGE_API as string,
    });
    const proposalFile = [
      new File(
        [
          JSON.stringify({
            proposalId,
            title,
            description,
            content,
            proposer,
            creationTimestamp,
            lastUpdatedTimestamp,
          }),
        ],
        `proposal_${proposalId}_v${proposalVersion}.json`,
        { type: "application/json" }
      ),
    ];
    proposalCid = await client.put(proposalFile, {
      name: `proposal_${proposalId}_v${proposalVersion}`,
    });

    await proposalFacet.createProposal(proposalId, proposalCid);

    contributor = "0xTestEthereumAddress";
    contributionContent = "Test Contribution Content";
    contributionEcoAmount = 1;

    const contributionFiles = [
      new File(
        [
          JSON.stringify({
            proposalId,
            contributor,
            contributionContent,
            contributionEcoAmount,
            creationTimestamp,
          }),
        ],
        `contributions_${proposalId}.json`,
        { type: "application/json" }
      ),
    ];
    const contributionCid = await client.put(contributionFiles, {
      name: `contributions_${proposalId}`,
    });

    await contributionFacet.createContribution(
      proposalId,
      contributionCid,
      contributionEcoAmount
    );

    await votingFacet.startVotingSession(proposalId, 0, 1);

    await votingFacet.submitVote(proposalId, 0, 0);

    await votingFacet.endVotingSession(proposalId, 0);

    const proposalResponse = await client.get(proposalCid);

    // Get the files from the response
    const files = await proposalResponse.files();

    // Assuming there's only one file (which is the case for a single JSON file)
    const file = files[0];

    // Read the content of the file
    const fileContent = await file.text();

    // Parse the content as JSON
    let proposalData;
    try {
      proposalData = JSON.parse(fileContent);
    } catch (error) {
      console.error("Failed to parse JSON:", fileContent);
      throw error;
    }

    // Update the content of the proposal
    proposalData.content += contributionContent;
    proposalData.lastUpdatedTimestamp = Date.now().toString();

    proposalVersion++;

    // Upload the updated proposal to web3.storage
    const updatedProposalFile = [
      new File(
        [JSON.stringify(proposalData)],
        `proposal_${proposalId}_v${proposalVersion}.json`,
        { type: "application/json" }
      ),
    ];

    updatedProposalCid = await client.put(updatedProposalFile, {
      name: `proposal_${proposalId}_v${proposalVersion}`,
    });

    await proposalFacet.updateCid(proposalId, updatedProposalCid);
  });

  it("should successfully mint NFT to claimer", async function () {
    let finishedProposal = await proposalFacet.getProposal(proposalId);

    if (await proposalFacet.isProposalFinalized(proposalId)) {
      let name = `Proposal NFT - ${finishedProposal.proposalId}`;
      let description = `This NFT represents a finalized proposal with ID: ${proposalId}.`;
      let image = "Test NFT Image"; // Replace with your actual image URI

      let metadata = {
        name: name,
        description: description,
        image: image,
        attributes: [
          { trait_type: "Proposal ID", value: proposalId },
          { trait_type: "Proposer", value: finishedProposal.proposer },
          {
            trait_type: "CID",
            value: finishedProposal.cid,
          },
        ],
        background_color: "#FFFFFF", // Replace with your desired color
      };

      let metadataString = JSON.stringify(metadata);

      let metadataFile = new File([metadataString], `nft_metadata_${finishedProposal.proposalId}.json`, {
        type: "application/json",
      });

      let metadataCid = await client.put([metadataFile]);

      let claimedNft = await nftFacet.claimNFT(proposalId);

      console.log(claimedNft);

      console.log(await nftFacet.ownerOf(0));

      console.log(await nftFacet.ownerOf(1));
    }
  });
});
