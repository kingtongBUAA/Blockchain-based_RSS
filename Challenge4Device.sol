pragma solidity ^0.5.14;
interface margin{
    function ReturnBack(address payable _EdgeDeviceAddress) external payable returns (bool);
}
contract challenge{
    constructor()public{
        deployer = msg.sender;
    }
    //变量设置
    address deployer;
    uint256 tasknumber = 1;
    address MarginContractAddress;
    //
    struct Tasks{
        address payable targetEdgeDevice;
        string desciption;
        uint256 timelimit;
        uint256 deploytime;
        bytes32 target;
        uint256 targetlength;
        uint256 round1;
        uint256 round2;
    }
    mapping(uint256 => Tasks) public FindTask;
    mapping(uint256 => Algorithms) public FindAlgorithm;
    event Show(address,bool);
    struct Algorithms{
        uint256 AlgorithmName;
        uint256 AlgorithmRound;
    }
    function AlgorithmSHA256(bytes32 input) internal pure returns (bytes32){
        return(sha256(abi.encodePacked(input)));
    }
    function AlgorithmSHA3(bytes32 input) internal pure returns(bytes32){
        return(keccak256(abi.encodePacked(input)));
    }
    function submit(uint256 hash,uint256 _tasknumber) public  returns(bool){
        require(CheckTime(_tasknumber));
        require(msg.sender == FindTask[_tasknumber].targetEdgeDevice);
        uint I = FindTask[_tasknumber].round1;
        uint J = FindTask[_tasknumber].round2;
        bool result;
        bytes32 answer = sha256(abi.encodePacked(hash));
        for (uint i=2;i<=I;i++){
            answer =AlgorithmSHA256(answer);
        }
        for(uint j=1;j<=J;j++){
            answer = AlgorithmSHA3(answer);
        }
        if(answer == FindTask[_tasknumber].target){
            result = true;
            margin margincontract = margin(MarginContractAddress);
            margincontract.ReturnBack(FindTask[_tasknumber].targetEdgeDevice);
        }
        else{
        result = false;
        }
        emit Show(FindTask[_tasknumber].targetEdgeDevice,result);
        return result;
    }
    function challengeInit(uint round1, uint round2, uint length,string memory desciption, bytes32 target, uint timelimit, address payable targetEdgedevice) public returns (uint) {
        require(msg.sender == deployer);
        FindTask[tasknumber] = Tasks(targetEdgedevice,desciption,timelimit,now,target,length,round1,round2);
        tasknumber++;
        return tasknumber-1;
    }
    function testcalculation(uint256 input,uint256 round1,uint256 round2) public view returns(bytes32){
        require(msg.sender == deployer);
        uint I = round1;
        uint J = round2;
        bytes32 answer = sha256(abi.encodePacked(input));
        for (uint i=2;i<=I;i++){
            answer =AlgorithmSHA256(answer);
        }
        for(uint j=1;j<=J;j++){
            answer = AlgorithmSHA3(answer);
        }
        return answer;
    }
    function CheckTime(uint256 _tasknumber)internal view returns(bool){
        return(now <= FindTask[_tasknumber].deploytime + FindTask[_tasknumber].timelimit);
    }
    function MarginContractAddressInit(address _MarginContractAddress) public{
        require(msg.sender == deployer);
        MarginContractAddress = _MarginContractAddress;
    }
}
