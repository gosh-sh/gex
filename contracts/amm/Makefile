tvcs = MarketMaker ProxyNotify StockNotify
tvcc = MMClient
clean:
	rm -f *.tvc *.abi.json
	rm -rf .solc_imports

build-contracts:
	for i in $(tvcs); do \
		everdev sol compile $$i.sol || exit $$@; \
	done

build: clean build-contracts

compile:
	everdev sol compile ${ARG}.sol
