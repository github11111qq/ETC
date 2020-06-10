struct User {

    uint256 pID;
    uint256 affId;
    uint256 invites;
    uint256 onlineOrder;
    uint256 gdNum;
    uint256 isSuper;
    uint256 level;
}
struct UserInfo {
    string  inviteCode;
    address addr;
    bool isout;
}




struct EInfo{
    uint256 totalBet;
    uint256 lastBet;
    uint256 lastReleaseTime;
    uint256 reward;    
    uint256 createtime;

}


struct levelReward {    
    uint16 genRate;    
    uint16 leverage;
  
}

struct gdUser {
    uint256 pId;
    uint256 level;
      
        
}


uint256 orderId_ = 1;
uint256 public nextId_ = 1;  
uint256 public esHistoryId_ = 1;
uint256 public gBetcc_;
uint256 public tokenBuyId_;
uint256 public pointBuyId_;
uint256 public gamebetId_;
uint256 public bestMan_;
uint256 public lastBestMan_;
uint256 public champRound_;
uint256  public gdNum_ = 1;



mapping (uint256 => User)    public plyr_;  
mapping (uint256 => UserInfo) public uf_;
mapping (uint256 => Earnings) public es_;
mapping (uint256 => EInfo) public ef_;

mapping (string   => uint256) public pIDInviteCode_;
mapping (address => uint256)   public pIDxAddr_;



uint256[] public superNode_; 
uint8[28] affRate = [200,100,50,40,30,20,10,5,5,5,5,5,10,10,10,10,10,10,10,10,20,20,20,20,20,20,20,20];
uint8[10] shareRate = [5,4,3,2,1,1,1,1,1,1];
uint8[6] gameShareRate = [10,5,4,3,2,1];



function buyCore(uint256 _pID,uint256 _eth)
    isCanBet(_pID,_eth)
    isWithinLimits(msg.value)
    private
{
    
  
    ef_[_pID].lastBet = _eth;
    ef_[_pID].totalBet += _eth;

  
    plyr_[_pID].onlineOrder = setOrder(_pID,_eth);
    uf_[_pID].isout = false;
    
 
    ef_[_pID].reward = _eth.mul(levelReward_[getLevel(_eth)].leverage);

  
    affUpdate(_pID,_gen,0,1,0);
    
    dSuperNodePot(_eth.mul(4)/100);
    
    champPrize(_pID,_eth,true);
    amPot(_eth);
  
    plyr_[_pID].level = getLevel(_eth);
    ef_[_pID].lastReleaseTime = now;

    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 
    
    if(ef_[_pID].createtime == 0){
        
        ef_[_pID].createtime = now;
    }
 
   
}



function getLevel (uint256 _betEth) 
public
view
returns(uint8 level) 
{
    uint8 _level = 0;
    if(_betEth>=50 * ethWei){
        _level = 4;

    }else if(_betEth>=30 * ethWei){
        _level = 3;

    }else if(_betEth>=10 * ethWei){
        _level = 2;

    }else if(_betEth>=1 * ethWei){
        _level = 1;

    }
    return _level;
}


function getDeepForUser(uint256 _pID)
view
public
returns(uint256 deep){
    
    deep = 0;
    
    if(plyr_[_pID].invites >=10){
        
         deep = 28;
    }else if(plyr_[_pID].invites >=9){
        
         deep = 18;  

    }else {
        deep = plyr_[_pID].invites * 2;
    }
    
    
}


function getExcellenceUser (uint256 _rid,uint256 _weizhi) 
public
view
returns(uint256 _pID,uint256 _totalBet,uint256 _baseAff) 
{
     _pID = drBestQue_[_rid][_weizhi];
    return
    (
        _pID,
        ef_[_pID].totalBet,
        drUserBet_[_rid][_pID]

    );
}


function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _bxTotalCoin,uint256 _bxTime,uint256 _excellencepot,
uint256 _excellenceStartTime,uint256  _excellenceRound,address _lastChampionInviteCode,
uint256 _lastChampion,uint256 _orderId,uint256 _totalSupply,uint256 _totalDestroy,uint256 _totalSellNum)
{
  ( _totalSupply, _totalDestroy, _totalSellNum) = etcc_.totalOfContact();
    return
    (
        gBet_,
        gBetcc_,
        bxTotalCoin, 
        bxStartTime_ + bxTime_,
        chamPrize_,
        chamStartTime + chamTime,
        champRound_,
        uf_[lastBestMan_].addr,
        lastBestPot_,
        orderId_,
        _totalSupply,
        _totalDestroy,
        _totalSellNum
        
        
        
    );
}

function getUserInfo(uint256 _pid) view public returns(uint256 _reward,uint256 _genE,uint256 _affE,uint256 _pointE, uint256 _level,uint256 isSuper,bool isFull){
    
    (uint256 _gen,uint256 _aff,,uint256 _point,) = getUserRewardByBase( _pid);

    uint256 _g = _gen + _aff + _point;

    _reward = ef_[_pid].reward > _g ? ef_[_pid].reward.sub(_g):0;
    
    _genE = es_[_pid].genE + _gen;
    _affE = es_[_pid].affE + _aff;
    _pointE = es_[_pid].point + _point;

    _level =  gd_[plyr_[_pid].gdNum].level;
    isSuper = plyr_[_pid].isSuper;
    isFull = superNode_.length <12?false:true;
    
        
   
   
}


function getAddreToken (address _addr) view public returns(uint256 _token) {
    _token = etcc_.balanceOfAddr(_addr);
}

