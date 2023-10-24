import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { keccak256, toUtf8Bytes } from "ethers";
import { ProposalFacet } from "../typechain-types";
import { Web3Storage } from "web3.storage";
import * as dotenv from "dotenv";

dotenv.config();

describe("Local Chain ProposalFacet Test", function () {
  let diamondAddress: string;
  let proposalFacet: ProposalFacet;
  let proposalId: string;
  let cid1: string;

  // Runs before all tests in this block
  before(async function () {
    diamondAddress = await deployDiamond();
    console.log({ diamondAddress });

    // deploy ProposalFacet
    await addFacets(diamondAddress);
    proposalFacet = await ethers.getContractAt("ProposalFacet", diamondAddress);
  });

  it("should create a proposal", async () => {
    const title = "Test Book Title";
    const description = "Test Book Description";
    const content = "";
    const userAddress = "0xTestEthereumAddress";
    const creationTimestamp = Date.now().toString();
    const lastUpdatedTimestamp = creationTimestamp; // Initially, it's the same as creationTimestamp.

    // Generate a proposalId using keccak256
    proposalId = keccak256(
      toUtf8Bytes(title + userAddress + creationTimestamp)
    );

    // Upload to web3.storage and get the CID
    const client = new Web3Storage({
      token: process.env.WEB3_STORAGE_API as string,
    });
    const files = [
      new File(
        [
          JSON.stringify({
            proposalId,
            title,
            description,
            content,
            userAddress,
            creationTimestamp,
            lastUpdatedTimestamp,
          }),
        ],
        `proposal_${proposalId}.json`,
        { type: "application/json" }
      ),
    ];
    cid1 = await client.put(files);

    await proposalFacet.createProposal(proposalId, cid1);

    const proposal = await proposalFacet.getProposal(proposalId);

    assert.exists(proposal);
  });

  it("should emit a proposal creation event", async () => {
    const eventFilter = proposalFacet.filters.NewProposal();

    // Query past events
    const events = await proposalFacet.queryFilter(eventFilter, "latest");

    // Check if the event was emitted
    assert.isNotEmpty(events, "NewProposal event not found");

    // Optionally, if you want to further verify the event data:
    const event = events[0];
    const hashedProposalId = keccak256(toUtf8Bytes(proposalId));
    assert.equal(
      event.args.proposalId.hash,
      hashedProposalId,
      "Event proposalId does not match expected value"
    );
  });

  it("should ensure a proposal with the same proposalId cannot be created", async () => {
    await expect(
      proposalFacet.createProposal(proposalId, cid1)
    ).to.be.revertedWith("ProposalFacet: Proposal already exists");
  });

  it("should retrieve the correct data when calling getProposal", async () => {
    const proposal = await proposalFacet.getProposal(proposalId);

    assert.equal(proposal.proposalId, proposalId);
    assert.equal(proposal.cid, cid1);
  });

  it("should update the cid of a proposal correctly", async () => {
    const cid2 = "newCID";

    await proposalFacet.updateCid(proposalId, cid2);

    const proposal = await proposalFacet.getProposal(proposalId);

    assert.equal(proposal.cid, cid2);
  });

  it("should not allow empty fields when creating a proposal", async () => {
    const proposalId = "";
    const cid = "";

    await expect(
      proposalFacet.createProposal(proposalId, cid)
    ).to.be.revertedWith("ProposalFacet: Invalid proposalId or cid");
  });

  it("should only allow the contract owner to update the cid", async () => {
    const cid = "newCID";

    const signer = await ethers.provider.getSigner(1);

    await expect(
      proposalFacet.connect(signer).updateCid(proposalId, cid)
    ).to.be.revertedWith("LibDiamond: Must be contract owner");
  });
});
