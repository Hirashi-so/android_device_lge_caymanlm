package com.hirashi.gcam.provisioner;

import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public final class BootReceiver extends BroadcastReceiver {
    static final String TAG = "GCamProvisioner";
    static final int JOB_ID = 17017;

    @Override
    public void onReceive(Context context, Intent intent) {
        JobScheduler scheduler = context.getSystemService(JobScheduler.class);
        if (scheduler == null) {
            Log.e(TAG, "JobScheduler unavailable");
            return;
        }
        JobInfo job = new JobInfo.Builder(JOB_ID,
                new ComponentName(context, InstallJobService.class))
                .setOverrideDeadline(0L)
                .build();
        int result = scheduler.schedule(job);
        Log.i(TAG, "Provisioning job scheduled: " + result + " from "
                + (intent != null ? intent.getAction() : "unknown"));
    }
}
