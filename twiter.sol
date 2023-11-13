//SPDX-License-Identifier: MIT
pragma solidity >0.5.0<0.9.0;

contract TweeterContract{
     
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }

    struct Message{
        uint id;
        string content;
        address from;
        address to;
        uint createdAt;
    }
// map trom id of tweet to=> tweet
    mapping(uint=>Tweet) public tweets;

//mapping the address of a particular tweeter to=> tweetID no of that particular tweet. 
//Because, all the tweeets get a unique id after is is posted
    mapping(address=>uint[]) public tweetsOf;

//mapping from the address who is sending the message to=> the message
//this will be an array of structure named conversation. he index or key of the array is the senders address.
    mapping(address=>Message[]) private conversation;

//mapping the address of real owner who is goig to keep an assistant/operator to=>the address of the operator to=> true/false(give/take) permission/access
    mapping(address=>mapping(address=>bool)) public operators;

//mapping from who is trying to follow to=> which address he is trying to follow
    mapping(address=>address[]) public following;

//each tweet will have a unique ID
    uint nextId;
//each message will have a unique ID
    uint nextMessageId;

//these two are the model of the tweet and messaging operations.
//the latter functions will caall/use these model and create instances of tweet and messages
    function _tweet(address _from, string memory _content) internal{
        tweets[nextId]= Tweet(nextId,_from, _content, block.timestamp);
        //need it for the functionality to fetch the tweets of a particular ID
        tweetsOf[_from].push(nextId);
        nextId++;
    }
    function _sendMessage(address _from, address _to, string memory _content) internal{
        conversation[_from].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId;
    }


//two functions: 
//1st if the ID owner tweets the post directly by himself
    function tweet(string memory _content) public{
        _tweet(msg.sender, _content);
    }
//2nd if his account is maintained by someone else and he is posting
    function tweet(address _from, string memory _content) public{
        _tweet(_from,_content);
    }


////two functions: 
//1st if the ID owner sending the message directly by himself
    function sendMessage(address _to, string memory _content) public{
        _sendMessage(msg.sender, _to, _content);
    }
//2nd if his account is maintained by someone else and he is sending message
    function sendMessage(address _from, address _to, string memory _content) public{
        _sendMessage(_from, _to, _content);
    }

//function for the person who wants to follow someone
    function follow(address _followed) public{
        following[msg.sender].push(_followed);
    }

//function to allow or assign an address, who will operate/maintain the account
    function allow(address _operator) public{
        operators[msg.sender][_operator]= true;
    }

//function to disallow or cancel an address, who is currently operate/maintain the account
    function disallow(address _operator) public{
        operators[msg.sender][_operator]= false;
    }

//function that will fetch the latest tweets op posts. by count we are telling how many latest tweets we want to see/fetch
    function getLaatestTweets(uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Improper count");
    //an array of type "Tweet". in that there will be "count" number of elements/tweets
        Tweet[] memory _tweets  = new Tweet[](count); //an array of length "count"

        uint j;

        for(uint i = nextId-count; i<nextId; i++){
             Tweet storage _structure = tweets[i];
             _tweets[j] = Tweet(_structure.id,_structure.author,_structure.content,_structure.createdAt);
             j++;
        }
        return _tweets;
    }

//function to fetch the tweets of any particular tweeter/user
    function getLatestOfUser(address _user, uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Improper count");
    //an array of type "Tweet". in that there will be "count" number of elements/tweets
        Tweet[] memory _tweetsOf  = new Tweet[](count); //an array of length "count"

        uint[] memory tweetIdxArray = tweetsOf[_user];

        uint j;

        for(uint i = tweetIdxArray.length-count+1; i<tweetIdxArray.length; i++){
            Tweet storage _structure = tweets[tweetIdxArray[i]];
            _tweetsOf[j] = Tweet(_structure.id,_structure.author,_structure.content,_structure.createdAt);
            j++;
        }
        return _tweetsOf;
    }
}