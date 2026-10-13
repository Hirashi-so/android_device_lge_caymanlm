package com.hirashi.gcam.provisioner;

import android.app.PendingIntent;
import android.app.job.JobParameters;
import android.app.job.JobService;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageInstaller;
import android.content.pm.PackageManager;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.atomic.AtomicBoolean;

public final class InstallJobService extends JobService {
    private static final String TAG = BootReceiver.TAG;
    private static final String PACKAGE = "com.google.android.GoogleCameraEng";
    private static final String PAYLOAD = "/product/etc/gcam/GCam.apk";
    private final AtomicBoolean stopped = new AtomicBoolean(false);

    @Override
    public boolean onStartJob(JobParameters params) {
        stopped.set(false);
        new Thread(() -> {
            try {
                provision();
            } catch (Exception e) {
                Log.e(TAG, "Provisioning failed", e);
            } finally {
                if (!stopped.get()) {
                    jobFinished(params, false);
                }
            }
        }, "GCamProvisioner-Installer").start();
        return true;
    }

    @Override
    public boolean onStopJob(JobParameters params) {
        stopped.set(true);
        // A later execution may retry; the worker checks stopped during copy.
        return true;
    }

    private void provision() throws Exception {
        File apk = new File(PAYLOAD);
        if (!apk.isFile() || apk.length() <= 0) {
            throw new IllegalStateException("Missing payload: " + PAYLOAD);
        }
        PackageManager pm = getPackageManager();
        PackageInfo payloadInfo = pm.getPackageArchiveInfo(PAYLOAD, 0);
        if (payloadInfo == null || !PACKAGE.equals(payloadInfo.packageName)) {
            throw new IllegalStateException("Invalid GCam package in payload");
        }

        try {
            PackageInfo installed = pm.getPackageInfo(PACKAGE, 0);
            ApplicationInfo ai = pm.getApplicationInfo(PACKAGE, 0);
            String path = ai.sourceDir;
            if (installed.getLongVersionCode() > payloadInfo.getLongVersionCode()) {
                Log.i(TAG, "Skipping newer installed version: " + path);
                return;
            }
            if (installed.getLongVersionCode() == payloadInfo.getLongVersionCode()
                    && path != null && path.startsWith("/data/app/")) {
                Log.i(TAG, "GCam already installed in /data/app: " + path);
                return;
            }
        } catch (PackageManager.NameNotFoundException ignored) {
            Log.i(TAG, "GCam is not installed yet");
        }

        if (checkSelfPermission("android.permission.INSTALL_PACKAGES")
                != PackageManager.PERMISSION_GRANTED) {
            throw new SecurityException("INSTALL_PACKAGES was not granted");
        }

        PackageInstaller installer = pm.getPackageInstaller();
        PackageInstaller.SessionParams sp = new PackageInstaller.SessionParams(
                PackageInstaller.SessionParams.MODE_FULL_INSTALL);
        sp.setAppPackageName(PACKAGE);
        sp.setSize(apk.length());
        sp.setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED);

        int sessionId = installer.createSession(sp);
        boolean committed = false;
        try (PackageInstaller.Session session = installer.openSession(sessionId)) {
            try (InputStream in = new FileInputStream(apk);
                 OutputStream out = session.openWrite("base.apk", 0, apk.length())) {
                byte[] buffer = new byte[64 * 1024];
                int n;
                while ((n = in.read(buffer)) != -1) {
                    if (stopped.get()) {
                        throw new IllegalStateException("Provisioning job stopped");
                    }
                    out.write(buffer, 0, n);
                }
                session.fsync(out);
            }

            Intent callback = new Intent(this, InstallResultReceiver.class)
                    .setAction(InstallResultReceiver.ACTION_RESULT)
                    .putExtra("session_id", sessionId);
            PendingIntent pending = PendingIntent.getBroadcast(this, sessionId, callback,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
            session.commit(pending.getIntentSender());
            committed = true;
            Log.i(TAG, "GCam install session committed: " + sessionId
                    + ", version=" + payloadInfo.getLongVersionCode());
        } finally {
            if (!committed) {
                try {
                    installer.abandonSession(sessionId);
                } catch (Exception e) {
                    Log.w(TAG, "Could not abandon session " + sessionId, e);
                }
            }
        }
    }
}
