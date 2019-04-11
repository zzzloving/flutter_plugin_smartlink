package com.rotai.xz.flutter_plugin_smartlink;

import android.content.Context;

import com.hiflying.smartlink.ISmartLinker;
import com.hiflying.smartlink.OnSmartLinkListener;
import com.hiflying.smartlink.SmartLinkedModule;
import com.hiflying.smartlink.v7.MulticastSmartLinker;

import java.util.HashMap;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;

/**
 * FlutterPluginSmartlinkPlugin
 */
public class FlutterPluginSmartlinkPlugin implements MethodCallHandler, OnSmartLinkListener {
    private static BasicMessageChannel<Object> dart;
    private ISmartLinker mSmartLinker;
    private Context context;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_plugin_smartlink");
        channel.setMethodCallHandler(new FlutterPluginSmartlinkPlugin(registrar.context()));


        dart = new BasicMessageChannel<>(registrar.messenger(), "flutter_plugin_smartlink_2_dart", new StandardMessageCodec());

    }

    public FlutterPluginSmartlinkPlugin(Context context) {
        this.context = context;
        mSmartLinker = MulticastSmartLinker.getInstance();
        ((MulticastSmartLinker) mSmartLinker).setMixType(MulticastSmartLinker.MIX_TYPE_SMART_LINK_V8);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if ("start".equals(call.method)) {
            //设置要配置的ssid 和pswd
            try {
                mSmartLinker.setOnSmartLinkListener(this);
                Object others = call.argument("others");
                if (others != null)
                    mSmartLinker.setOthers(others.toString().trim());
                //开始 smartLink
                Object pwd = call.argument("pwd");
                String pwdS = null;
                if (pwd != null) {
                    pwdS = pwd.toString().trim();
                }
                mSmartLinker.start(context, pwdS, call.argument("ssid").toString().trim());
                result.success(true);
            } catch (Exception e) {
                e.printStackTrace();
                result.success(false);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onLinked(SmartLinkedModule smartLinkedModule) {
        HashMap data = new HashMap();
        data.put("type",1);
        HashMap hashMap = new HashMap();
        hashMap.put("Mac",smartLinkedModule.getMac());
        hashMap.put("Ip",smartLinkedModule.getIp());
        hashMap.put("Id",smartLinkedModule.getId());
        hashMap.put("Mid",smartLinkedModule.getMid());
        hashMap.put("ModuleIP",smartLinkedModule.getModuleIP());
        data.put("data",hashMap);
        dart.send(data);
    }

    @Override
    public void onCompleted() {
        HashMap data = new HashMap();
        data.put("type",2);
        data.put("data",1);
        dart.send(data);
    }

    @Override
    public void onTimeOut() {
        HashMap data = new HashMap();
        data.put("type",2);
        data.put("data",2);
        dart.send(data);
    }
}
