'reach 0.1';
'use strict';

/* eslint-disable */
const myFromMaybe = (m) => fromMaybe(m, (() => false), ((x) => x));

export const main = Reach.App(() => {

  setOptions({ connectors: [ ALGO ], untrustworthyMaps: true });
  
  const Deployer = Participant('Deployer', {
    setParams: Fun([], Tuple(Token, UInt, UInt)), // Token, Max Addresses, Number of tokens to distribute per address
    fundContract: Fun([], Null),
    seeAddToWhitelist: Fun([Address], Null),
    seeClaim: Fun([Address], Null),
  });
  
  const UserAPI = API('UserAPI', {
    addToWhitelist: Fun([], Bool),  // add address to whitelist, return true if successful
    claimTokens: Fun([], Bool), // claim tokens from contract, return true if successful
  });

  const AdminAPI = API('AdminAPI', {
    endContract: Fun([], Bool), // exit parallelReduce and end contract
  });

  const V = View({
    canClaimTokens: Fun([Address], Bool), // view whether an address is in the whitelist, True = Available to claim, False = Not available
    getTokenInfo: Token, // view to see what token we're claiming
  });

  init();

  Deployer.only(() => {
    const [ ClaimToken, MaxAddresses, TokensPerAddress ] = declassify(interact.setParams());
    const TotalTokens = (MaxAddresses * TokensPerAddress);
  });
  Deployer.publish(ClaimToken, MaxAddresses, TokensPerAddress, TotalTokens);
  commit();

  Deployer.publish().pay([0, [TotalTokens, ClaimToken]]);
  commit();

  Deployer.interact.fundContract();
  Deployer.publish();

  // Map to track whitelisted addresses
  const whitelist = new Map(Bool); // True = Available to claim, False = No longer available to claim

  V.canClaimTokens.set((m) => myFromMaybe(whitelist[m]));
  V.getTokenInfo.set(ClaimToken);

  const [ done, distrubtedTokens, whitelistSize ] = parallelReduce([ false, 0, 0 ])
      .invariant(whitelistSize <= MaxAddresses)
      .while(!done)
      .api(
        UserAPI.addToWhitelist,
        () => {},
        () => 0,
        (returnFunc) => {
          const canAdd = (whitelistSize < MaxAddresses) ? true : false;
          returnFunc(canAdd);
          if (canAdd) {
            whitelist[this] = true;
            Deployer.interact.seeAddToWhitelist(this);
          }
          const whitelistIncrement = (canAdd) ? 1 : 0;

          return [ done, distrubtedTokens, whitelistSize + whitelistIncrement ];
        }
      )
      .api(
        UserAPI.claimTokens,
        () => {
            assume(balance(ClaimToken) >= TokensPerAddress);
        },
        () => 0,
        (returnFunc) => {
          const canWithdraw = (myFromMaybe(whitelist[this]) == true && balance(ClaimToken) >= TokensPerAddress) ? true : false;
          returnFunc(canWithdraw);

          if (canWithdraw) {
              transfer([0, [TokensPerAddress, ClaimToken]]).to(this);
              whitelist[this] = false;
              Deployer.interact.seeClaim(this);
          }
          const claimedTokens = (canWithdraw) ? TokensPerAddress : 0;

          return [ done, distrubtedTokens + claimedTokens, whitelistSize ];
        }
      )
      .api(
        AdminAPI.endContract,
        () => {
          assume(this == Deployer);
        },
        () => 0,
        (returnFunc) => {
          require(this == Deployer);
          returnFunc(true);

          return [ true, distrubtedTokens, whitelistSize ];
        }
      );

      transfer(balance()).to(Deployer);
      transfer([ 0, [ balance(ClaimToken), ClaimToken ] ]).to(Deployer);
      commit();

  exit();
});
