import {ethers} from "hardhat";
import { FacetCutAction, getSelectors } from "./libs/diamond";
import * as dotenv from "dotenv";

dotenv.config();

export async function addFacets(diamondAddress: string) {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    // deploy new facets
    const FacetNames: string[] = ['ProposalFacet', 'ContributionFacet', 'VotingFacet', 'NFTFacet', 'RewardFacet', 'EcoFacet'];
    const cut = [];

    for(const FacetName of FacetNames) {
        const Facet = await ethers.getContractFactory(FacetName);
        const facet = await Facet.deploy();
        await facet.waitForDeployment();
        console.log(`${FacetName} deployed: ${await facet.getAddress()}`);
        cut.push({
            facetAddress: await facet.getAddress(),
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(Facet)
        });
    }

    // upgrade diamond with facets
    console.log('');
    console.log('Applying cut to diamond:', diamondAddress);
    console.log('Diamond Cut:', cut);
    const diamondCut = await ethers.getContractAt('IDiamondCut', diamondAddress);
    const tx = await diamondCut.diamondCut(cut, ethers.ZeroAddress, '0x');
    console.log('Diamond cut tx:', tx.hash);
    const receipt = await tx.wait();
    if (receipt !== null && receipt.status) {
      console.log("Completed diamond cut");
    } else {
      throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
}

// usage 
addFacets(process.env.DIAMOND_ADDRESS_GOERLI as string).catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
