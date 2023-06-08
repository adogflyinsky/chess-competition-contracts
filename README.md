# DATN

### Target:
- Make it easy for third parties to connect to blockchain technology, specifically, applied to game genres such as soduku, chess, puzzle...

### Specific problem solving:
With a third-party available website serving chess players and available data, it is possible to create chess puzzle competitions in a transparent and fair manner, and players who participate and solve correctly will certainly receive their rewards. rewards without depending on other parties.

### How to solve:
With the contest to find the optimal move, there is always only 1 correct answer, and the moves depend on the pieces and the position of the board. We can encode each move based on that. Specifically, with the pawn, rook, horse, net, queen, and king pieces numbered in the order from 0 to 5 and the chessboard from position a1 to position h8, we number in order from 1 to 64. ( See details in [file](./contracts/libraries/Chess.sol)). So the answer will be an array of moves. To ensure transparency, just announcing the winners without proof is not convincing enough, but if the answers are announced early, the game will end. Here, the proposed solution is based on ZKP: The organizer will hold the contests at the same time and create the corresponding contract for the players to participate and enter the results into the contract in the form of ZKP. (do not enter results directly).
- Implementation steps:
1. Create questions in the form of smart contract (unlimited number of questions can be created, see examples in [folder](./contracts/chess_questions/))
2. Each question is created in nft format, with a link to the corresponding contest. The answer is available in the organizer's database.
3. The organizer will base on the contest id and use keccak to hash the answer and create the corresponding contest.
4. Players will participate and each person will randomly receive different questions and answer questions during the competition. (can check the real answer before filling in by comparing with the hash code provided earlier)
5. After the time is up, as long as there is an answer corresponding to the hash code, anyone can trigger the end of the contest and the reward (token) is automatically sent to the correct answer.

- Note: With the need to expand, there will be many players, many questions with different complexity. To avoid being able to choose a given question to answer, use VRF to get a random seed and based on that to assign a question to the player.

- Binding to increase benefits for the organizer:
Create a whitelist to accept only those members who are allowed to participate or organize private competitions through available data (userid and address respectively) and players authorize the organizer to participate when meeting the attached requirements more.