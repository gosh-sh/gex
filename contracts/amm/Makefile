tvcs = marketmaker stocknotify Helper
tvcc = MMClient
clean:
	rm -f *.tvc *.abi.json *.code
	rm -rf .solc_imports

build-contracts:
# everdev sol compile $$i.sol || exit $$@;
	for i in $(tvcs); do \
		../compiler/solc $$i.sol || exit $$@; \
		../compiler/tvm_linker compile $$i.code -o $$i.tvc --lib ../compiler/stdlib_sol.tvm || exit $$@; \
		if [ "${target-dir}" != "" ] ; then cp $$i.* ${target-dir}/ ; fi; \
	done

build: clean build-contracts

compile:
	everdev sol compile ${ARG}.sol
