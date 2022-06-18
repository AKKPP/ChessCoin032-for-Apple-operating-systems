# ChessCoinWallet - A Chesscoin & Lightning Wallet

Built with React Native and Electrum.

## BUILD & RUN IT

Please refer to the engines field in package.json file for the minimum required versions of Node and npm. It is preferred that you use an even-numbered version of Node as these are LTS versions.

To view the version of Node and npm in your environment, run the following in your console:

```
node --version && npm --version
```

* In your console:

```
git clone https://github.com/AKKPP/ChessCoin032-for-Apple-operating-systems.git
cd ChessCoin032-for-Apple-operating-systems
npm install
```

Please make sure that your console is running the most stable versions of npm and node (even-numbered versions).

* To run on iOS:

```
npx pod-install
npm start
```

In another terminal window within the ChessCoin032-Wallet folder:
```
npx react-native run-ios
```

* To run on macOS using Mac Catalyst:

```
npm run maccatalystpatches
```

Once the patches are applied, open Xcode and select "My Mac" as destination. If you are running macOS Catalina, you may need to remove all iOS 14 Widget targets.


## TESTS

```bash
npm run test
```

## LICENSE

MIT
