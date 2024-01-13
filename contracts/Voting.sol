// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

// Custom error messages for various fail conditions
error OnlyOwner();
error OnlyRegisteredVoters();
error VotingHasEnded();
error VoterAlreadyVoted();
error InvalidCandidateID();
error VoterAlreadyRegistered();
error VotingStillOngoing();

/**
 * @title Decentralized Voting
 * @dev Implements a decentralized voting system using smart contracts.
 */
contract DecentralizedVoting {
    // Struct for storing candidate details
    struct Candidate {
        uint id;           
        string name;       
        uint voteCount;    
    }

    // Struct for storing voter details
    struct Voter {
        bool isRegistered; 
        bool hasVoted;    
    }

    // State variables
    address public immutable contractOwner; 
    mapping(address => Voter) public voters; 
    mapping(uint => Candidate) public candidates; 
    uint public candidatesCount; 
    uint public immutable votingEndTime; 
    uint private leadingCandidateId; 
    uint private highestVoteCount; 

    // Events for logging contract activities
    event VoterRegistered(address voter);
    event CandidateAdded(uint candidateId, string candidateName);
    event VoteCast(address voter, uint candidateId);
    event WinnerDeclared(uint winnerCandidateId, string winnerName, uint voteCount);

    /**
     * @dev Constructor sets the contract owner and voting end time.
     * @param _votingDurationInMinutes Duration in minutes from contract deployment to voting end.
     */
    constructor(uint _votingDurationInMinutes) {
        contractOwner = msg.sender;
        votingEndTime = block.timestamp + (_votingDurationInMinutes * 1 minutes); 
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != contractOwner) revert OnlyOwner();
        _;
    }

    modifier onlyRegisteredVoters() {
        if (!voters[msg.sender].isRegistered) revert OnlyRegisteredVoters();
        _;
    }

    modifier afterVotingPeriod() {
        if (block.timestamp <= votingEndTime) revert VotingStillOngoing();
        _;
    }

    /**
     * @dev Registers a new voter.
     * Reverts if the caller is already registered.
     */
    function registerVoter() public {
        if (voters[msg.sender].isRegistered) revert VoterAlreadyRegistered();
        voters[msg.sender].isRegistered = true;
        emit VoterRegistered(msg.sender);
    }

    /**
     * @dev Registers a new candidate.
     * Can only be called by the contract owner.
     * @param _name Name of the candidate to be registered.
     */
    function registerCandidate(string memory _name) public onlyOwner {
        candidates[candidatesCount++] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }
  /**
 * @dev Allows a registered voter to cast their vote for a specific candidate.
 *      Ensures that voting is only allowed during the voting period and that each voter votes only once.
 *      Updates the vote count for the chosen candidate and potentially the leading candidate details.
 * @param _candidateId The unique identifier of the candidate being voted for.
 */
function vote(uint _candidateId) public onlyRegisteredVoters {
    // Ensures voting is within the designated time period
    if (block.timestamp > votingEndTime) {
        revert VotingHasEnded();
    }

    // Ensures that a voter can only vote once
    if (voters[msg.sender].hasVoted) {
        revert VoterAlreadyVoted();
    }

    // Checks for a valid candidate ID
    if (_candidateId == 0 || _candidateId > candidatesCount) {
        revert InvalidCandidateID();
    }

    // Marks the voter as having voted
    voters[msg.sender].hasVoted = true;

    // Retrieves the candidate from storage and increments their vote count
    Candidate storage candidate = candidates[_candidateId];
    candidate.voteCount++;

    // Updates leading candidate information if this candidate now has the highest vote count
    if (candidate.voteCount > highestVoteCount) {
        leadingCandidateId = _candidateId;
        highestVoteCount = candidate.voteCount;
    }

    // Logs the voting action
    emit VoteCast(msg.sender, _candidateId);
}

/**
 * @dev Retrieves information about a specific candidate.
 *      Validates the candidate ID before returning their details.
 * @param _candidateId The unique identifier of the candidate.
 * @return Candidate The struct containing the candidate's details.
 */
function getCandidate(uint _candidateId) public view returns (Candidate memory) {
    if (_candidateId == 0 || _candidateId > candidatesCount) {
        revert InvalidCandidateID();
    }

    return candidates[_candidateId];
}

/**
 * @dev Declares the winner of the election.
 *      Can only be called by the owner and after the voting period has ended.
 *      Returns the ID of the winning candidate.
 * @return winnerCandidateId The ID of the candidate who has won the election.
 */
function declareWinner() public onlyOwner afterVotingPeriod returns (uint winnerCandidateId) {
    winnerCandidateId = leadingCandidateId;

    emit WinnerDeclared(winnerCandidateId, candidates[winnerCandidateId].name, highestVoteCount);

    return winnerCandidateId;
}


}