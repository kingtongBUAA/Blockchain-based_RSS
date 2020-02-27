pragma solidity ^0.5.14;
contract margin{
    constructor (uint256 _MarginMoney,address _ChallengeAddress)public{
        deployer = msg.sender;
        MarginMoney = _MarginMoney;
        ChallengeAddress = _ChallengeAddress;
    }
    struct Device{
        uint256 EdgeNumber;
        uint256 MarginMoney;
        address EdgeDeviceAddress;
        string CPU;
        string Storage;
        string Memory;
        string MAC_address;
        uint256 state;
    }
    //变量设置
    address deployer;
    address ChallengeAddress;
    uint256 number = 1;
    uint256 MarginMoney;
    uint256 MarginLeft = 0;
    mapping (uint256 => Device) public AddEdgeDevice;
    mapping (address => bool) public CheckDevice; //用來保證設備尚未被添加，防止重複添加。
    event Info(address,string,string,string,string);
    function Request2Join(address EdgeDeviceAddress,string memory CPU,string memory Storage,string memory Memory,string memory MAC_address)public payable returns (uint256){
        require(CheckDevice[EdgeDeviceAddress] == false);
        AddEdgeDevice[number]=Device(number,MarginMoney,EdgeDeviceAddress,CPU,Storage,Memory,MAC_address,0);
        CheckDevice[EdgeDeviceAddress] = true; 
        require(msg.value >=MarginMoney);
        MarginLeft += msg.value;
        emit Info(EdgeDeviceAddress,CPU,Storage,Memory,MAC_address);
        number++;
        return number-1;
    }
    function ReturnBack(address payable _EdgeDeviceAddress) public payable returns (bool){
        require(msg.sender == ChallengeAddress || msg.sender == deployer);
        require(MarginLeft >= MarginMoney);
        _EdgeDeviceAddress.transfer(MarginMoney);
    }
}
