# Monero-X v0.0.1-alpha.0 `work in progress`

`P u l l R e q u e s t s a r e W e l c o m e` 👮‍
 
**Monero-X** is Vanilla Monero Hardfork with clear Genesis aimed to enable **Smart Contracts** to port them back to Monero and all other forks after all dev cycles finished (all job done).

![mr. X](./mrx.png)

Total Supply is limited to 180M and **size limits are doubled**.

This is **highly experimental currency** supposed to use to test and debug independent Smart Contracts implementation based on **Python3** interpreter as Contracts Language and `pyledger` with `monero-python` libraries as contracts runtime.

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
