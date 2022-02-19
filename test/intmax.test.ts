import {
    Intmax,
    TestERC20,
    Governance
} from "../typechain";

import {ethers} from 'hardhat';
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import {expect, use} from "chai";
import {solidity} from "ethereum-waffle";

use(solidity);

const {parseEther} = ethers.utils;
const {AddressZero} = ethers.constants;


describe("Intmax", () => {
    let deployer: SignerWithAddress;
    let alice: SignerWithAddress;
    let bob: SignerWithAddress;
    let intmax: Intmax;
    let testERC20: TestERC20;
    let governance: Governance;

    beforeEach(async () => {
        [deployer, alice, bob] = await ethers.getSigners();

        const Governance = await ethers.getContractFactory('Governance');
        governance = (await Governance.deploy()) as Governance;

        const Intmax = await ethers.getContractFactory('Intmax');
        intmax = (await Intmax.deploy(ethers.utils.defaultAbiCoder.encode(['address'], [governance.address]))) as Intmax;

        const TestERC20 = await ethers.getContractFactory('TestERC20');
        testERC20 = (await TestERC20.deploy()) as TestERC20;

        await testERC20.mint(alice.address, parseEther('10000'));
        await testERC20.mint(bob.address, parseEther('10000'));

        // set allowlist
        await governance.addToken(testERC20.address);
    });


    describe("depositETH", async () => {
        it("success", async () => {
            const aliceBalance = await alice.getBalance();
            expect(aliceBalance).to.eq(parseEther('10000'));

            await intmax.connect(alice).depositETH(alice.address, {value: parseEther('10')});
            const aliceBalance2 = await alice.getBalance();
            expect(aliceBalance2).to.lt(parseEther('9990'));

            const expectedContractBalance = await intmax.provider.getBalance(intmax.address);
            expect(expectedContractBalance).to.eq(parseEther('10'));
        });
        it("fail without value", async () => {
            await expect(intmax.connect(alice).depositETH(alice.address)).revertedWith('Value must ve greater than 0');
            const aliceBalance = await alice.getBalance();

            expect(aliceBalance).to.lt(parseEther('10000'));
        });
    });

    describe("depositERC20", async () => {
        it("success", async () => {
            const aliceBalance = await testERC20.balanceOf(alice.address);
            const depositAmount = parseEther('100');
            await testERC20.connect(alice).approve(intmax.address, depositAmount);

            await intmax.connect(alice).depositERC20(testERC20.address, depositAmount, alice.address);

            const expectedAliceBalance = await testERC20.balanceOf(alice.address);
            expect(expectedAliceBalance).to.eq(aliceBalance.sub(depositAmount));
        });
        it("fail without approving", async () => {
            const depositAmount = parseEther('100');
            await expect(intmax.connect(alice).depositERC20(testERC20.address, depositAmount, alice.address)).to.revertedWith('ERC20: insufficient allowance');
        });
    });
    //
    // describe("withdrawPendingBalance(ETH)", async () => {
    //     it("success", async () => {
    //         const withdrawAmount = parseEther('100');
    //
    //         await intmax.depositETH(alice.address);
    //
    //         // withdraw ETH
    //         await intmax.withdrawPendingBalance(alice.address, AddressZero, withdrawAmount);
    //     });
    //     it("fail without pending balance", async () => {
    //         const withdrawAmount = parseEther('100');
    //         await expect(intmax.withdrawPendingBalance(alice.address, AddressZero, withdrawAmount)).to.revertedWith('');
    //     });
    // });
    //
    // describe("withdrawPendingBalance(ERC20)", async () => {
    //     it("success", async () => {
    //         const withdrawAmount = parseEther('100');
    //
    //         await testERC20.connect(alice).approve(intmax.address, withdrawAmount);
    //         await intmax.depositERC20(testERC20.address, withdrawAmount, alice.address);
    //
    //         // withdraw ERC20
    //         await intmax.withdrawPendingBalance(alice.address, testERC20.address, withdrawAmount);
    //     });
    //     it("fail without pending balance", async () => {
    //         const withdrawAmount = parseEther('100');
    //         await expect(intmax.withdrawPendingBalance(alice.address, AddressZero, withdrawAmount)).to.revertedWith('');
    //     });
    // });
    //
    // describe("exit(ETH)", async () => {
    //     it("success", async () => {
    //         const exitAmount = parseEther('100');
    //         await intmax.exit(alice.address, AddressZero, exitAmount);
    //     });
    //     it("fail in normal mode", async () => {
    //         const exitAmount = parseEther('100');
    //         await expect(intmax.exit(alice.address, AddressZero, exitAmount)).to.revertedWith('Exit mode is normal');
    //     });
    //     it("fail without balance", async () => {
    //         const exitAmount = parseEther('100');
    //         await expect(intmax.exit(alice.address, AddressZero, exitAmount)).to.revertedWith('Your balance is zero');
    //     });
    // });
    //
    // describe("exit(ERC20)", async () => {
    //     it("success", async () => {
    //         const exitAmount = parseEther('100');
    //         await intmax.exit(alice.address, testERC20.address, exitAmount);
    //     });
    //     it("fail in normal mode", async () => {
    //         const exitAmount = parseEther('100');
    //         await expect(intmax.exit(alice.address, testERC20.address, exitAmount)).to.revertedWith('Exit mode is normal');
    //     });
    //     it("fail without balance", async () => {
    //         const exitAmount = parseEther('100');
    //         await expect(intmax.exit(alice.address, testERC20.address, exitAmount)).to.revertedWith('Your balance is zero');
    //     });
    // });
    //
    // describe("commitBlocks()", async () => {
    //     it("success", async () => {
    //         await intmax.commitBlocks();
    //
    //     });
    //     it("fail", async () => {
    //         await expect(intmax.commitBlocks()).to.revertedWith('');
    //     });
    // });
    //
    // describe("proveBlocks()", async () => {
    //     it("success", async () => {
    //         await intmax.proveBlocks();
    //     });
    //     it("fail", async () => {
    //         await expect(intmax.proveBlocks()).to.revertedWith('');
    //     });
    // });
    //
    // describe("executeBlocks()", async () => {
    //     it("success", async () => {
    //         await intmax.executeBlocks();
    //     });
    //     it("fail", async () => {
    //         await expect(intmax.executeBlocks()).to.revertedWith('');
    //     });
    // });
});