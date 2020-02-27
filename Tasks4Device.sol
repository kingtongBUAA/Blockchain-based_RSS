pragma solidity ^0.5.14;
interface ResourceInit{
        function UploadToken(uint _value,address EdgeDeviceAddress) external;
}
contract task{
    constructor(address token)public{
        tokenContractAddress = token;
        deployer = msg.sender;
    }
    struct Tasks{
        uint num;
        string task;
        uint256 limittime;
        string state;
        address targetEdgedevice;
        uint256 reward;
    }
    struct Endorser{
        uint number;
        address EndorseAddress;
    }
    mapping(uint => Tasks) public FindTasks;
    mapping(uint => Endorser) public FindEndorser;
    uint256 tasknumber = 1;
    uint256 Endorsernumber = 1;
    address deployer;
    address tokenContractAddress;
    string TaskInfo;
    event task_event(string,uint256,address);
    event endorser_event(uint256,address);
    event Result_event(uint256,uint256,string);
    function TaskInit(string memory Task, uint256 limittime, address targetEdgedevice, uint256 reward) public returns(uint256){
        require(msg.sender == deployer); //0xca35b7d915458ef540ade6068dfe2f44e8fa733c是合约部署者的地址，也就是云的地址。
        TaskInfo = Task;
        FindTasks[tasknumber] = Tasks(tasknumber,TaskInfo,limittime,"Underway",targetEdgedevice,reward);
        emit task_event(Task,limittime,targetEdgedevice);
        tasknumber++;
        return tasknumber-1;
    }
    function SubmitResult(uint256 Tasknumber, uint256 numresult,string memory stringresult) public{
        require(msg.sender == FindTasks[Tasknumber].targetEdgedevice);
        FindTasks[Tasknumber].state = "Pending";
        emit Result_event(Tasknumber,numresult,stringresult);
    }
    function CheckResult(uint256 Tasknumber,uint endorsernumber) public returns (bool){
        require(msg.sender == FindEndorser[endorsernumber].EndorseAddress);
        require(keccak256(abi.encodePacked(FindTasks[Tasknumber].state))==keccak256("Audited"));//现在对于状态的检测还存在问题，需要加上一个状态的筛选。
        FindTasks[Tasknumber].state = "Audited";
        ResourceInit tokenContract = ResourceInit(tokenContractAddress);
        tokenContract.UploadToken(FindTasks[Tasknumber].reward,FindTasks[Tasknumber].targetEdgedevice);
        return true;
    }
    function endorserInit(uint256 number, address EndorseAddress) public returns (uint){
        require(msg.sender == deployer); 
        FindEndorser[Endorsernumber] = Endorser(number,EndorseAddress);
        emit endorser_event(number,EndorseAddress);
        Endorsernumber++;
        return Endorsernumber-1;
    }
}
