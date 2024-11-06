# ETH Tech Tree Challenges
This repository is the home of all the challenges in the [ETH Tech Tree](https://github.com/BuidlGuidl/eth-tech-tree).

## Structure of the repository
The `main` branch is set up to give you everything you need to build new challenges. This includes instructions (below) and scripts for adding the new challenges as branches.

The other branches are the challenges. They are represented by the minimum set of file changes that will need to be made to a fresh clone of [Scaffold-ETH-2](https://github.com/scaffold-eth/scaffold-eth-2). The logic that determines how to add the files (and remove unnecessary files) can be found [here](https://github.com/BuidlGuidl/eth-tech-tree/blob/main/src/utils/setupChallenge.ts) though you shouldn't need to look at it to add a new challenge.

## Creating new challenges
Start by making a copy of the `template` branch that matches the name of the challenge you are creating.
```bash
  git checkout -b new-challenge-name template
```

Separately, clone Scaffold-ETH-2 pointed to a specific branch and commit that can be found here: https://github.com/BuidlGuidl/eth-tech-tree/blob/main/src/config.ts. To clarify, you can do this by swapping out the values below with the values in the linked file and running these commands:
```bash
  git clone --branch BASE_BRANCH BASE_REPO 

  git checkout BASE_COMMIT
```
This will make sure you are setting up your new challenge to work with the latest supported Scaffold-ETH-2 version. By working from this repository you will be able to run your tests and make sure everything works before copying over the necessary changes to your new template branch clone.

It might be helpful to start by writing a contract that satisfies the challenge and then write tests that provide good coverage. You will want the tests to be as generalized as possible and where not possible make sure the challenger has clear guidelines in the README. Make your README changes directly in the template branch clone repo as it will make more sense. 

Iterate on your solution and the tests until they are as generalized as possible, thinking through the multiple possibilities that exist for each method. Don't make your tests reference anything except the bare minimum functions you detail in the README. Then when you think the tests are sufficiently generalized erase all the solution from your challenge contract and copy over every important change from your working tree to the template branch clone repo.

Publish your new branch to your fork of eth-tech-tree-challenges and create an issue in the original repository asking for a branch to be created for your challenge. Once we have created the branch and responded to your issue then you can submit a PR to the new branch that matches your challenge name. We will review your challenge and hopefully be able to add your challenge to the tech tree after a couple rounds of feedback!
