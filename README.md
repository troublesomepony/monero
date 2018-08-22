# MONERO-X v0.0.1-alpha.0 `WIP (work-in-progress)`

## `Abandon all hope, ye who enter here`

### `Pull Requests 👮 Are Welcome`
 
**MONERO-X** is vanilla Monero hard fork with **clear Genesis** aimed to enable **Smart Contracts** to port them back to Monero and all other forks after all dev cycles finished (all job done).

![mr. X](./mrx.png)

Total Supply is limited to 180M and **size limits are doubled**.

This is **highly experimental currency** supposed to use to test and debug independent Smart Contracts implementation based on **Python3** interpreter as Contracts Language and `pyledger` with `monero-python` libraries as contracts runtime.

## Denial of Responsibility (LICENSE.md)

**The currency Monero-X** itself as well as it's source code are *HIGHLY EXPERIMENTAL* and exists only to satisfy the author's fantasies.

We do not provide any *SUPPORT* doing *HOT FIXES* closing *GITHUB ISSUES* or even *COMMENT ON ANY REQUEST OF THE END USERS* sorry.

Have to much to do with the code.

That's it.

## Building Requirements

In Monero-X outdated scheme of dependencies handling (putting code to `external` folder) is changed to using system
libraries search. Almost everything git submodules are removed. You will need following libraries to build Monero-X:

### Mac OS X

```bash
brew install rapidjson unbound miniupnp readline
```

### Ubuntu

```bash
sudo apt install clang rapidjson-dev libreadline-dev
```

### Windows x64

*COMING LATER*

## Building process

Project builds with CLang already available in OSX:

```bash
./build.sh
```

Sample output:

```bash
-- The C compiler identification is AppleClang 9.1.0.9020039
-- The CXX compiler identification is AppleClang 9.1.0.9020039
```

## Copyrights

- 2018 &copy; The Monero-X Project.
- 2014-2018 &copy; The Monero Project.   
- 2012-2013 &copy; The Cryptonote developers.
