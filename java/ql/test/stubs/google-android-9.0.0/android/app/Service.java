// Generated automatically from android.app.Service for testing purposes

package android.app;

import android.app.Application;
import android.app.Notification;
import android.content.ComponentCallbacks2;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.IBinder;
import java.io.FileDescriptor;
import java.io.PrintWriter;

abstract public class Service extends ContextWrapper implements ComponentCallbacks2
{
    protected void attachBaseContext(Context p0){}
    protected void dump(FileDescriptor p0, PrintWriter p1, String[] p2){}
    public Service(){}
    public abstract IBinder onBind(Intent p0);
    public boolean onUnbind(Intent p0){ return false; }
    public final Application getApplication(){ return null; }
    public final boolean stopSelfResult(int p0){ return false; }
    public final int getForegroundServiceType(){ return 0; }
    public final void startForeground(int p0, Notification p1){}
    public final void startForeground(int p0, Notification p1, int p2){}
    public final void stopForeground(boolean p0){}
    public final void stopForeground(int p0){}
    public final void stopSelf(){}
    public final void stopSelf(int p0){}
    public int onStartCommand(Intent p0, int p1, int p2){ return 0; }
    public static int START_CONTINUATION_MASK = 0;
    public static int START_FLAG_REDELIVERY = 0;
    public static int START_FLAG_RETRY = 0;
    public static int START_NOT_STICKY = 0;
    public static int START_REDELIVER_INTENT = 0;
    public static int START_STICKY = 0;
    public static int START_STICKY_COMPATIBILITY = 0;
    public static int STOP_FOREGROUND_DETACH = 0;
    public static int STOP_FOREGROUND_REMOVE = 0;
    public void onConfigurationChanged(Configuration p0){}
    public void onCreate(){}
    public void onDestroy(){}
    public void onLowMemory(){}
    public void onRebind(Intent p0){}
    public void onStart(Intent p0, int p1){}
    public void onTaskRemoved(Intent p0){}
    public void onTrimMemory(int p0){}
}
