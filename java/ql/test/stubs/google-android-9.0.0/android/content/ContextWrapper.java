// Generated automatically from android.content.ContextWrapper for testing purposes

package android.content;

import android.content.AttributionSource;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import android.content.ContextParams;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.DatabaseErrorHandler;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.UserHandle;
import android.view.Display;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.List;
import java.util.concurrent.Executor;

public class ContextWrapper extends Context
{
    protected ContextWrapper() {}
    protected void attachBaseContext(Context p0){}
    public ApplicationInfo getApplicationInfo(){ return null; }
    public AssetManager getAssets(){ return null; }
    public AttributionSource getAttributionSource(){ return null; }
    public ClassLoader getClassLoader(){ return null; }
    public ComponentName startForegroundService(Intent p0){ return null; }
    public ComponentName startService(Intent p0){ return null; }
    public ContentResolver getContentResolver(){ return null; }
    public Context createAttributionContext(String p0){ return null; }
    public Context createConfigurationContext(Configuration p0){ return null; }
    public Context createContext(ContextParams p0){ return null; }
    public Context createContextForSplit(String p0){ return null; }
    public Context createDeviceProtectedStorageContext(){ return null; }
    public Context createDisplayContext(Display p0){ return null; }
    public Context createPackageContext(String p0, int p1){ return null; }
    public Context createWindowContext(Display p0, int p1, Bundle p2){ return null; }
    public Context createWindowContext(int p0, Bundle p1){ return null; }
    public Context getApplicationContext(){ return null; }
    public Context getBaseContext(){ return null; }
    public ContextParams getParams(){ return null; }
    public ContextWrapper(Context p0){}
    public Display getDisplay(){ return null; }
    public Drawable getWallpaper(){ return null; }
    public Drawable peekWallpaper(){ return null; }
    public Executor getMainExecutor(){ return null; }
    public File getCacheDir(){ return null; }
    public File getCodeCacheDir(){ return null; }
    public File getDataDir(){ return null; }
    public File getDatabasePath(String p0){ return null; }
    public File getDir(String p0, int p1){ return null; }
    public File getExternalCacheDir(){ return null; }
    public File getExternalFilesDir(String p0){ return null; }
    public File getFileStreamPath(String p0){ return null; }
    public File getFilesDir(){ return null; }
    public File getNoBackupFilesDir(){ return null; }
    public File getObbDir(){ return null; }
    public FileInputStream openFileInput(String p0){ return null; }
    public FileOutputStream openFileOutput(String p0, int p1){ return null; }
    public File[] getExternalCacheDirs(){ return null; }
    public File[] getExternalFilesDirs(String p0){ return null; }
    public File[] getExternalMediaDirs(){ return null; }
    public File[] getObbDirs(){ return null; }
    public Intent registerReceiver(BroadcastReceiver p0, IntentFilter p1){ return null; }
    public Intent registerReceiver(BroadcastReceiver p0, IntentFilter p1, String p2, Handler p3){ return null; }
    public Intent registerReceiver(BroadcastReceiver p0, IntentFilter p1, String p2, Handler p3, int p4){ return null; }
    public Intent registerReceiver(BroadcastReceiver p0, IntentFilter p1, int p2){ return null; }
    public Looper getMainLooper(){ return null; }
    public Object getSystemService(String p0){ return null; }
    public PackageManager getPackageManager(){ return null; }
    public Resources getResources(){ return null; }
    public Resources.Theme getTheme(){ return null; }
    public SQLiteDatabase openOrCreateDatabase(String p0, int p1, SQLiteDatabase.CursorFactory p2){ return null; }
    public SQLiteDatabase openOrCreateDatabase(String p0, int p1, SQLiteDatabase.CursorFactory p2, DatabaseErrorHandler p3){ return null; }
    public SharedPreferences getSharedPreferences(String p0, int p1){ return null; }
    public String getAttributionTag(){ return null; }
    public String getOpPackageName(){ return null; }
    public String getPackageCodePath(){ return null; }
    public String getPackageName(){ return null; }
    public String getPackageResourcePath(){ return null; }
    public String getSystemServiceName(Class<? extends Object> p0){ return null; }
    public String[] databaseList(){ return null; }
    public String[] fileList(){ return null; }
    public boolean bindIsolatedService(Intent p0, int p1, String p2, Executor p3, ServiceConnection p4){ return false; }
    public boolean bindService(Intent p0, ServiceConnection p1, int p2){ return false; }
    public boolean bindService(Intent p0, int p1, Executor p2, ServiceConnection p3){ return false; }
    public boolean bindServiceAsUser(Intent p0, ServiceConnection p1, int p2, UserHandle p3){ return false; }
    public boolean deleteDatabase(String p0){ return false; }
    public boolean deleteFile(String p0){ return false; }
    public boolean deleteSharedPreferences(String p0){ return false; }
    public boolean isDeviceProtectedStorage(){ return false; }
    public boolean isRestricted(){ return false; }
    public boolean isUiContext(){ return false; }
    public boolean moveDatabaseFrom(Context p0, String p1){ return false; }
    public boolean moveSharedPreferencesFrom(Context p0, String p1){ return false; }
    public boolean startInstrumentation(ComponentName p0, String p1, Bundle p2){ return false; }
    public boolean stopService(Intent p0){ return false; }
    public int checkCallingOrSelfPermission(String p0){ return 0; }
    public int checkCallingOrSelfUriPermission(Uri p0, int p1){ return 0; }
    public int checkCallingPermission(String p0){ return 0; }
    public int checkCallingUriPermission(Uri p0, int p1){ return 0; }
    public int checkPermission(String p0, int p1, int p2){ return 0; }
    public int checkSelfPermission(String p0){ return 0; }
    public int checkUriPermission(Uri p0, String p1, String p2, int p3, int p4, int p5){ return 0; }
    public int checkUriPermission(Uri p0, int p1, int p2, int p3){ return 0; }
    public int getWallpaperDesiredMinimumHeight(){ return 0; }
    public int getWallpaperDesiredMinimumWidth(){ return 0; }
    public int[] checkCallingOrSelfUriPermissions(List<Uri> p0, int p1){ return null; }
    public int[] checkCallingUriPermissions(List<Uri> p0, int p1){ return null; }
    public int[] checkUriPermissions(List<Uri> p0, int p1, int p2, int p3){ return null; }
    public void clearWallpaper(){}
    public void enforceCallingOrSelfPermission(String p0, String p1){}
    public void enforceCallingOrSelfUriPermission(Uri p0, int p1, String p2){}
    public void enforceCallingPermission(String p0, String p1){}
    public void enforceCallingUriPermission(Uri p0, int p1, String p2){}
    public void enforcePermission(String p0, int p1, int p2, String p3){}
    public void enforceUriPermission(Uri p0, String p1, String p2, int p3, int p4, int p5, String p6){}
    public void enforceUriPermission(Uri p0, int p1, int p2, int p3, String p4){}
    public void grantUriPermission(String p0, Uri p1, int p2){}
    public void removeStickyBroadcast(Intent p0){}
    public void removeStickyBroadcastAsUser(Intent p0, UserHandle p1){}
    public void revokeUriPermission(String p0, Uri p1, int p2){}
    public void revokeUriPermission(Uri p0, int p1){}
    public void sendBroadcast(Intent p0){}
    public void sendBroadcast(Intent p0, String p1){}
    public void sendBroadcastAsUser(Intent p0, UserHandle p1){}
    public void sendBroadcastAsUser(Intent p0, UserHandle p1, String p2){}
    public void sendOrderedBroadcast(Intent p0, String p1){}
    public void sendOrderedBroadcast(Intent p0, String p1, BroadcastReceiver p2, Handler p3, int p4, String p5, Bundle p6){}
    public void sendOrderedBroadcast(Intent p0, String p1, String p2, BroadcastReceiver p3, Handler p4, int p5, String p6, Bundle p7){}
    public void sendOrderedBroadcast(Intent p0, int p1, String p2, String p3, BroadcastReceiver p4, Handler p5, String p6, Bundle p7, Bundle p8){}
    public void sendOrderedBroadcastAsUser(Intent p0, UserHandle p1, String p2, BroadcastReceiver p3, Handler p4, int p5, String p6, Bundle p7){}
    public void sendStickyBroadcast(Intent p0){}
    public void sendStickyBroadcast(Intent p0, Bundle p1){}
    public void sendStickyBroadcastAsUser(Intent p0, UserHandle p1){}
    public void sendStickyOrderedBroadcast(Intent p0, BroadcastReceiver p1, Handler p2, int p3, String p4, Bundle p5){}
    public void sendStickyOrderedBroadcastAsUser(Intent p0, UserHandle p1, BroadcastReceiver p2, Handler p3, int p4, String p5, Bundle p6){}
    public void setTheme(int p0){}
    public void setWallpaper(Bitmap p0){}
    public void setWallpaper(InputStream p0){}
    public void startActivities(Intent[] p0){}
    public void startActivities(Intent[] p0, Bundle p1){}
    public void startActivity(Intent p0){}
    public void startActivity(Intent p0, Bundle p1){}
    public void startIntentSender(IntentSender p0, Intent p1, int p2, int p3, int p4){}
    public void startIntentSender(IntentSender p0, Intent p1, int p2, int p3, int p4, Bundle p5){}
    public void unbindService(ServiceConnection p0){}
    public void unregisterReceiver(BroadcastReceiver p0){}
    public void updateServiceGroup(ServiceConnection p0, int p1, int p2){}
}
