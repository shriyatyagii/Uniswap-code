pragma solidity ^0.8.0;

interface ERC20Interface {
    function decimals() external view returns (uint8);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);
    
    function underlying() external view returns (address);
    
    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
    
    function approve(address _spender, uint256 _value) external returns (bool success);
    
    function transfer(address _to, uint256 _value) external returns (bool success);
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata) external returns (uint256[] memory);

    function getAccountLiquidity(address) external view returns (uint256, uint256, uint256);
}


interface PriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}

contract MyContract {
    
    Comptroller public constant _comptroller = Comptroller(address(0));
    
    function mint(address ctoken, uint _amt) public {
        CErc20 _ctokenContract = CErc20(ctoken);
        ERC20Interface _tokenContract = ERC20Interface(_ctokenContract.underlying());
        require(_tokenContract.transferFrom(msg.sender, address(this), _amt), 'transferFrom-failed.');
        require(_tokenContract.approve(address(_ctokenContract), _amt), 'approve failed.');
        uint _cAmt = _ctokenContract.mint(_amt);
        _ctokenContract.transfer(msg.sender, _cAmt);
    }
    
    function redeem(address ctoken, uint _camt) public {
        CErc20 _ctokenContract = CErc20(ctoken);
        ERC20Interface _tokenContract = ERC20Interface(_ctokenContract.underlying());
        require(_ctokenContract.transferFrom(msg.sender, address(this), _camt), 'transferFrom-failed.');
        require(_ctokenContract.approve(address(_ctokenContract), _camt), 'approve failed.');
        uint amt = _ctokenContract.redeem(_camt);
        _tokenContract.transfer(msg.sender, amt);
    }
    
    function borrow(address ctoken, address[] memory cTokenCollateral, uint _amt) public {
        CErc20 _ctokenContract = CErc20(ctoken);
        ERC20Interface _tokenContract = ERC20Interface(_ctokenContract.underlying());
        _comptroller.enterMarkets(cTokenCollateral);
        _ctokenContract.borrow(_amt);
        require(_tokenContract.transfer(msg.sender,_amt));
    }
    
    function repay(address ctoken, uint _amt) public {
        CErc20 _ctokenContract = CErc20(ctoken);
        ERC20Interface _tokenContract = ERC20Interface(_ctokenContract.underlying());
        require(_tokenContract.transferFrom(msg.sender, address(this), _amt), 'transferFrom-failed.');
        require(_tokenContract.approve(address(_ctokenContract), _amt), 'approve failed.');
        require(_ctokenContract.repayBorrow(_amt) == 0, "transfer approved?");
    }
}
