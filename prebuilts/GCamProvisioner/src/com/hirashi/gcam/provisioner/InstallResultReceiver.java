package com.hirashi.gcam.provisioner;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInstaller;
import android.util.Log;

public final class InstallResultReceiver extends BroadcastReceiver {
    static final String ACTION_RESULT = "com.hirashi.gcam.provisioner.INSTALL_RESULT";

    @Override
    public void onReceive(Context context, Intent intent) {
        int status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS,
                PackageInstaller.STATUS_FAILURE);
        String message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE);
        int sessionId = intent.getIntExtra("session_id", -1);
        if (status == PackageInstaller.STATUS_SUCCESS) {
            Log.i(BootReceiver.TAG, "GCam installed successfully, session=" + sessionId);
        } else if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            // A privileged installer should not normally need a confirmation UI.
            Log.e(BootReceiver.TAG, "Unexpected user confirmation required, session="
                    + sessionId + ", detail=" + message);
        } else {
            Log.e(BootReceiver.TAG, "GCam install failed, session=" + sessionId
                    + ", status=" + status + ", detail=" + message);
        }
    }
}
