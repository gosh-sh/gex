./tonos-cli run 0:836444681da138f13179d2bf16485520c9b460a4b3b7302c21b58386772dfe96 getPayloadForDeployInternalWallet '{"owner_pubkey":"0xedab2e180ca6566edf8c2120dc90af7daa48d89f2983f26c934c9504e6dcef2e","owner_addr":"0:d63dfca928e51ec6f1d2c4b5a1a74932120fb210c5e998ddbd8587099011a72b","evers":10000000000, "keep_evers":8000000000}' --abi ../../../work/flex/flex/ui/FlexClient.abi 
./tonos-cli run 0:fe02785bd6dbe3146172f49ddba7201036047f220591616b48412d98f84cb300 getDeposit '{"m_amount":1000000000, "wrapperWallet":"0:503fdce7b7cc63a90ce20b49a16357f78de8dcb55dac97a05b69938988ad318e", "m_userMsig":"0:90a09f7e6c9f63f6d3af4609de595fe37733df12752d1d500c5cd232ed4ef07f", "value0": "te6ccgEBAQEAZAAAw+2rLhgMplZu34whINyQr32qSNifKYPybJNMlQTm3O8uwA1j38qSjlHsbx0sS1oadJMhIPshDF6ZjdvYWHCZARpysAAAAAAAAAAAAAAAJUC+QAAAAAAAAAAAAAAAAB3NZQAI"}' --abi ../../../work/gex/contracts/amm/Helper.abi.json
./tonos-cli run 0:fe02785bd6dbe3146172f49ddba7201036047f220591616b48412d98f84cb300 getDeposit '{"m_amount":1000000000, "wrapperWallet":"0:c304ee549051d5500877f2fc796bb81e3f9cfde2b1b62de0eb360804ab7fe661", "m_userMsig":"0:90a09f7e6c9f63f6d3af4609de595fe37733df12752d1d500c5cd232ed4ef07f", "value0": "te6ccgEBAQEAZAAAw+2rLhgMplZu34whINyQr32qSNifKYPybJNMlQTm3O8uwA1j38qSjlHsbx0sS1oadJMhIPshDF6ZjdvYWHCZARpysAAAAAAAAAAAAAAAJUC+QAAAAAAAAAAAAAAAAB3NZQAI"}' --abi ../../../work/gex/contracts/amm/Helper.abi.json
./tonos-cli call 0:90a09f7e6c9f63f6d3af4609de595fe37733df12752d1d500c5cd232ed4ef07f submitTransaction '{"dest":"0:58a401adf8dfc910f0180e6def1a8287719049ae5696b976318cb1c569fa010f", "value" : 15000000000, "bounce":  true, "allBalance": false, "payload":"te6ccgEBAwEAwgABa0ap1+wAAAAAAAAAAAAAAAA7msoAgAoH+5z2+Yx1IZxBaTQsav7xvRuWq7WS9AttMnExFaYx0AEBQ4ASFBPvzZPsftp16ME7yyv8buZ74k6lo6oBi5pGXaneD/gCAMPtqy4YDKZWbt+MISDckK99qkjYnymD8myTTJUE5tzvLsANY9/Kko5R7G8dLEtaGnSTISD7IQxemY3b2FhwmQEacrAAAAAAAAAAAAAAACVAvkAAAAAAAAAAAAAAAAAdzWUACA=="}' --abi ../../../ton-contracts/solidity/multisig/MultisigWallet.abi.json --sign surf2.json 
./tonos-cli call 0:90a09f7e6c9f63f6d3af4609de595fe37733df12752d1d500c5cd232ed4ef07f submitTransaction '{"dest":"0:79e34daf85dcff3c80063042db184d5fb45bab2f905a5b91b2927545eb22a138", "value" : 15000000000, "bounce":  true, "allBalance": false, "payload":"te6ccgEBAwEAwgABa0ap1+wAAAAAAAAAAAAAAAA7msoAgBhgncqSCjqqAQ7+X48tdwPH85+8VjbFvB1mwQCVb/zMMAEBQ4ASFBPvzZPsftp16ME7yyv8buZ74k6lo6oBi5pGXaneD/gCAMPtqy4YDKZWbt+MISDckK99qkjYnymD8myTTJUE5tzvLsANY9/Kko5R7G8dLEtaGnSTISD7IQxemY3b2FhwmQEacrAAAAAAAAAAAAAAACVAvkAAAAAAAAAAAAAAAAAdzWUACA=="}' --abi ../../../ton-contracts/solidity/multisig/MultisigWallet.abi.json --sign surf2.json 