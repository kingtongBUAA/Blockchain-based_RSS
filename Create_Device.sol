pragma solidity ^0.5.14;
contract ResourceInit {
    constructor()public{
        deployer = msg.sender;
    }
    struct Info{
        string CPU;
        string Storage;
        string Memory;
        string MAC_address;
    }
    struct EdgeDevice {
        uint ResourceCoin_Number;
        uint FogID;
        address EdgeDeviceAddress;
    }
    mapping (uint => EdgeDevice) public Devices;
    mapping (address => uint) public FindNum;
    mapping (uint => Info) public EdgeDeviceInfo;
    uint number =1 ;
    address deployer;
    address TaskContractAddress;
     //创建一个边缘设备
    function CreateEdgeDeviceToken(uint FogID, address EdgeDeviceAddress, string memory cpu, string memory Storage, string memory Memory, string memory MAC_address) public returns (uint){
        require(msg.sender == deployer); //deployer是合约部署者的地址，也就是云的地址。
        require(FindNum[EdgeDeviceAddress]==0);
        Devices[number] = EdgeDevice(0,FogID,EdgeDeviceAddress);
        EdgeDeviceInfo[number] = Info(cpu,Storage,Memory,MAC_address);
        FindNum[EdgeDeviceAddress] = number;
        number++;
        return number-1;
    }
    function TaskContractAddressEnter(address _TaskContractAddress)public{
        require(msg.sender == deployer); //deployer是合约部署者的地址，也就是云的地址。
        TaskContractAddress = _TaskContractAddress;
    }
   //
   //初始化一个设备的token值
    function InitToken(uint _value, address EdgeDeviceAddress) public {
        require(msg.sender == deployer); //deployer是合约部署者的地址，也就是云的地址。
        uint num = FindNum[EdgeDeviceAddress];
        Devices[num].ResourceCoin_Number = _value;
    }
    //
    //更新一个设备的token值
    function UploadToken(uint _value,address EdgeDeviceAddress) public {
    require(msg.sender == deployer||msg.sender == TaskContractAddress);
    Devices[FindNum[EdgeDeviceAddress]].ResourceCoin_Number = Devices[FindNum[EdgeDeviceAddress]].ResourceCoin_Number + _value;
    }
}



