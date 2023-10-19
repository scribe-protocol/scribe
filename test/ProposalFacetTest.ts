import { deployDiamond } from "../scripts/deploy";
import { addFacets } from "../scripts/addFacets";
import { assert } from "chai";
import { ethers } from "hardhat";
import { keccak256, toUtf8Bytes } from "ethers";
import {ProposalFacet} from "../typechain-types";
import { Web3Storage } from "web3.storage";
import * as dotenv from "dotenv";

dotenv.config();

describe("Local Chain ProposalFacet Test", function() {
    let diamondAddress: string;
    let proposalFacet: ProposalFacet;

    // Runs before all tests in this block
    before(async function() {
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
        const proposalId = keccak256(toUtf8Bytes(title + userAddress + creationTimestamp));
    
        // Upload to web3.storage and get the CID
        const client = new Web3Storage({ token: process.env.WEB3_STORAGE_API as string });
        const files = [
            new File([JSON.stringify({
                proposalId,
                title,
                description,
                content,
                userAddress,
                creationTimestamp,
                lastUpdatedTimestamp
            })], `proposal_${proposalId}.json`, { type: "application/json" })
        ];
        const cid = await client.put(files);


        await proposalFacet.createProposal(proposalId, cid);

        const proposal = await proposalFacet.getProposal(proposalId);

        assert.exists(proposal);

        console.log({ proposal });
    });

    // it("should successfully create multiple proposals", async () => {
    //     await proposalFacet.createProposal("", "");
    //     await proposalFacet.createProposal("", "");

    //     const proposal2 = await proposalFacet.getProposal("");
    //     const proposal3 = await proposalFacet.getProposal("");

    //     assert.exists(proposal2);
    //     assert.exists(proposal3);

    //     console.log({ proposal2 });
    //     console.log({ proposal3 });
    // });
});