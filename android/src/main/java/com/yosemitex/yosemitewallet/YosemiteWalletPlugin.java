package com.yosemitex.yosemitewallet;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.yosemitex.yosemitewalletlibrary.crypto.ec.YosPublicKey;
import com.yosemitex.yosemitewalletlibrary.data.remote.model.chain.SignedTransaction;
import com.yosemitex.yosemitewalletlibrary.data.remote.model.types.TypeChainId;
import com.yosemitex.yosemitewalletlibrary.data.wallet.WalletManager;
import com.yosemitex.yosemitewalletlibrary.util.Utils;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * YosemiteWalletPlugin
 */
public class YosemiteWalletPlugin implements MethodCallHandler {

    final static String TAG = "YosemiteWalletPlugin";

    final static String ERROR_TYPE_OPERATION_NOT_FAILED = "OperationFailed";
    final static String ERROR_TYPE_OPERATION_NOT_PERMITTED = "OperationNotPermitted";

    final static String DEFAULT_WALLET_DIR = "wallets";
    final static String DEFAULT_WALLET_NAME = "default";

    final private WalletManager walletManager;
    final private Gson gson;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Log.d(TAG, "Initializing YosemiteWalletPlugin");
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.yosemitex.yosemite_wallet");
        channel.setMethodCallHandler(new YosemiteWalletPlugin(registrar.context()));
    }

    public YosemiteWalletPlugin(Context context) {
        gson = Utils.createYosemiteJGsonBuilder().create();
        walletManager = new WalletManager();
        File walletDir = new File(context.getFilesDir(), DEFAULT_WALLET_DIR);

        if (!walletDir.exists()) {
            walletDir.mkdirs();
        }

        walletManager.setDir(walletDir);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("create")) {
            String pw = call.argument("password");
            create(pw, result);
        } else if (call.method.equals("unlock")) {
            String pw = call.argument("password");
            unlock(pw);
        } else if (call.method.equals("lock")) {
            lock();
        } else if (call.method.equals("sign")) {
            String data = call.argument("data");
            signData(data, result);
        } else if (call.method.equals("signTx")) {
            String jsonStr = call.argument("txData");
            String chainId = call.argument("chainId");

            signTransaction(jsonStr, chainId, result);
        } else if (call.method.equals("getPublicKey")) {
            if (this.walletManager.isLocked(DEFAULT_WALLET_NAME)) {
                result.error(ERROR_TYPE_OPERATION_NOT_PERMITTED, "Wallet should be unlocked before calling this API", null);
                return;
            }

            String pubKey = getPubKey();

            if (pubKey != null) {
                result.success(pubKey);
            } else {
                result.error(ERROR_TYPE_OPERATION_NOT_FAILED, "No public key found", null);
            }
        } else if (call.method.equals("isLocked")) {
            isLocked(result);
        } else {
            result.notImplemented();
        }
    }

    private void create(String password, Result result) {
        try {

            if (this.walletManager.openExistingsInDir() > 0) {
                this.walletManager.deleteFile(DEFAULT_WALLET_NAME);
            }

            this.walletManager.createWithPassword(DEFAULT_WALLET_NAME, password);

            String pubKey = getPubKey();

            if (pubKey != null) {
                result.success(pubKey);
            } else {
                result.error("IllegalState", "Wallet is corrupted", null);
            }
        } catch (IOException e) {
            e.printStackTrace();
            result.error("IOException", "Error occurred while creating a wallet", null);
        }
    }

    private void unlock(String password) {
        this.walletManager.unlock(DEFAULT_WALLET_NAME, password);
    }

    private void lock() {
        this.walletManager.lock(DEFAULT_WALLET_NAME);
    }

    private void isLocked(Result result) {

        try {
            if (this.walletManager.isLocked(DEFAULT_WALLET_NAME)) {
                result.success(true);
            } else {
                result.success(false);
            }
        } catch (Exception e) {
            result.success(true);
        }
    }

    private void signData(String data, Result result) {

        if (this.walletManager.isLocked(DEFAULT_WALLET_NAME)) {
            result.error(ERROR_TYPE_OPERATION_NOT_PERMITTED, "Wallet is locked", null);
            return;
        }

        String pubKey = getPubKey();

        String signature = this.walletManager.signData(data.getBytes(StandardCharsets.UTF_8), new YosPublicKey(pubKey));

        result.success(signature);
    }

    private String getPubKey() {
        this.walletManager.listKeysAsPairString();

        ArrayList<String> pubKeys = this.walletManager.listPubKeys();

        if (pubKeys.size() == 1) {
            String pubKey = pubKeys.get(0);
            return pubKey;
        }

        return null;
    }

    private void signTransaction(String stringifiedSignedTransaction, String chainId, Result result) {

        if (this.walletManager.isLocked(DEFAULT_WALLET_NAME)) {
            result.error(ERROR_TYPE_OPERATION_NOT_PERMITTED, "Wallet is locked", null);
            return;
        }

        final SignedTransaction txToSign = gson.fromJson(stringifiedSignedTransaction, SignedTransaction.class);

        final SignedTransaction signedTx = this.walletManager.signTransaction(txToSign, Arrays.asList(new YosPublicKey(getPubKey())), new TypeChainId(chainId));

        final String stringifiedSignedTx = gson.toJson(signedTx);

        result.success(stringifiedSignedTx);
    }
}
