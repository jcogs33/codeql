// Generated automatically from android.app.Activity for testing purposes

package android.app;

import android.app.ActionBar;
import android.app.ActivityManager;
import android.app.Application;
import android.app.Dialog;
import android.app.DirectAction;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.LoaderManager;
import android.app.PendingIntent;
import android.app.PictureInPictureParams;
import android.app.PictureInPictureUiState;
import android.app.SharedElementCallback;
import android.app.TaskStackBuilder;
import android.app.VoiceInteractor;
import android.app.assist.AssistContent;
import android.content.ComponentCallbacks2;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.LocusId;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.media.session.MediaController;
import android.net.Uri;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.PersistableBundle;
import android.transition.Scene;
import android.transition.TransitionManager;
import android.util.AttributeSet;
import android.view.ActionMode;
import android.view.ContextMenu;
import android.view.ContextThemeWrapper;
import android.view.DragAndDropPermissions;
import android.view.DragEvent;
import android.view.KeyEvent;
import android.view.KeyboardShortcutGroup;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.SearchEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.accessibility.AccessibilityEvent;
import android.widget.Toolbar;
import android.window.SplashScreen;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.List;
import java.util.function.Consumer;

public class Activity extends ContextThemeWrapper implements ComponentCallbacks2, KeyEvent.Callback, LayoutInflater.Factory2, View.OnCreateContextMenuListener, Window.Callback
{
    protected Dialog onCreateDialog(int p0){ return null; }
    protected Dialog onCreateDialog(int p0, Bundle p1){ return null; }
    protected static int[] FOCUSED_STATE_SET = null;
    protected void attachBaseContext(Context p0){}
    protected void onActivityResult(int p0, int p1, Intent p2){}
    protected void onApplyThemeResource(Resources.Theme p0, int p1, boolean p2){}
    protected void onChildTitleChanged(Activity p0, CharSequence p1){}
    protected void onCreate(Bundle p0){}
    protected void onDestroy(){}
    protected void onNewIntent(Intent p0){}
    protected void onPause(){}
    protected void onPostCreate(Bundle p0){}
    protected void onPostResume(){}
    protected void onPrepareDialog(int p0, Dialog p1){}
    protected void onPrepareDialog(int p0, Dialog p1, Bundle p2){}
    protected void onRestart(){}
    protected void onRestoreInstanceState(Bundle p0){}
    protected void onResume(){}
    protected void onSaveInstanceState(Bundle p0){}
    protected void onStart(){}
    protected void onStop(){}
    protected void onTitleChanged(CharSequence p0, int p1){}
    protected void onUserLeaveHint(){}
    public <T extends View> T findViewById(int p0){ return null; }
    public ActionBar getActionBar(){ return null; }
    public ActionMode onWindowStartingActionMode(ActionMode.Callback p0){ return null; }
    public ActionMode onWindowStartingActionMode(ActionMode.Callback p0, int p1){ return null; }
    public ActionMode startActionMode(ActionMode.Callback p0){ return null; }
    public ActionMode startActionMode(ActionMode.Callback p0, int p1){ return null; }
    public Activity(){}
    public CharSequence onCreateDescription(){ return null; }
    public ComponentName getCallingActivity(){ return null; }
    public ComponentName getComponentName(){ return null; }
    public DragAndDropPermissions requestDragAndDropPermissions(DragEvent p0){ return null; }
    public FragmentManager getFragmentManager(){ return null; }
    public Intent getIntent(){ return null; }
    public Intent getParentActivityIntent(){ return null; }
    public LayoutInflater getLayoutInflater(){ return null; }
    public LoaderManager getLoaderManager(){ return null; }
    public MenuInflater getMenuInflater(){ return null; }
    public Object getLastNonConfigurationInstance(){ return null; }
    public Object getSystemService(String p0){ return null; }
    public Object onRetainNonConfigurationInstance(){ return null; }
    public PendingIntent createPendingResult(int p0, Intent p1, int p2){ return null; }
    public Scene getContentScene(){ return null; }
    public SharedPreferences getPreferences(int p0){ return null; }
    public String getCallingPackage(){ return null; }
    public String getLocalClassName(){ return null; }
    public TransitionManager getContentTransitionManager(){ return null; }
    public Uri getReferrer(){ return null; }
    public Uri onProvideReferrer(){ return null; }
    public View getCurrentFocus(){ return null; }
    public View onCreatePanelView(int p0){ return null; }
    public View onCreateView(String p0, Context p1, AttributeSet p2){ return null; }
    public View onCreateView(View p0, String p1, Context p2, AttributeSet p3){ return null; }
    public VoiceInteractor getVoiceInteractor(){ return null; }
    public Window getWindow(){ return null; }
    public WindowManager getWindowManager(){ return null; }
    public boolean dispatchGenericMotionEvent(MotionEvent p0){ return false; }
    public boolean dispatchKeyEvent(KeyEvent p0){ return false; }
    public boolean dispatchKeyShortcutEvent(KeyEvent p0){ return false; }
    public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent p0){ return false; }
    public boolean dispatchTouchEvent(MotionEvent p0){ return false; }
    public boolean dispatchTrackballEvent(MotionEvent p0){ return false; }
    public boolean enterPictureInPictureMode(PictureInPictureParams p0){ return false; }
    public boolean hasWindowFocus(){ return false; }
    public boolean isActivityTransitionRunning(){ return false; }
    public boolean isChangingConfigurations(){ return false; }
    public boolean isDestroyed(){ return false; }
    public boolean isFinishing(){ return false; }
    public boolean isImmersive(){ return false; }
    public boolean isInMultiWindowMode(){ return false; }
    public boolean isInPictureInPictureMode(){ return false; }
    public boolean isLaunchedFromBubble(){ return false; }
    public boolean isLocalVoiceInteractionSupported(){ return false; }
    public boolean isTaskRoot(){ return false; }
    public boolean isVoiceInteraction(){ return false; }
    public boolean isVoiceInteractionRoot(){ return false; }
    public boolean moveTaskToBack(boolean p0){ return false; }
    public boolean navigateUpTo(Intent p0){ return false; }
    public boolean navigateUpToFromChild(Activity p0, Intent p1){ return false; }
    public boolean onContextItemSelected(MenuItem p0){ return false; }
    public boolean onCreateOptionsMenu(Menu p0){ return false; }
    public boolean onCreatePanelMenu(int p0, Menu p1){ return false; }
    public boolean onCreateThumbnail(Bitmap p0, Canvas p1){ return false; }
    public boolean onGenericMotionEvent(MotionEvent p0){ return false; }
    public boolean onKeyDown(int p0, KeyEvent p1){ return false; }
    public boolean onKeyLongPress(int p0, KeyEvent p1){ return false; }
    public boolean onKeyMultiple(int p0, int p1, KeyEvent p2){ return false; }
    public boolean onKeyShortcut(int p0, KeyEvent p1){ return false; }
    public boolean onKeyUp(int p0, KeyEvent p1){ return false; }
    public boolean onMenuItemSelected(int p0, MenuItem p1){ return false; }
    public boolean onMenuOpened(int p0, Menu p1){ return false; }
    public boolean onNavigateUp(){ return false; }
    public boolean onNavigateUpFromChild(Activity p0){ return false; }
    public boolean onOptionsItemSelected(MenuItem p0){ return false; }
    public boolean onPictureInPictureRequested(){ return false; }
    public boolean onPrepareOptionsMenu(Menu p0){ return false; }
    public boolean onPreparePanel(int p0, View p1, Menu p2){ return false; }
    public boolean onSearchRequested(){ return false; }
    public boolean onSearchRequested(SearchEvent p0){ return false; }
    public boolean onTouchEvent(MotionEvent p0){ return false; }
    public boolean onTrackballEvent(MotionEvent p0){ return false; }
    public boolean releaseInstance(){ return false; }
    public boolean requestVisibleBehind(boolean p0){ return false; }
    public boolean setTranslucent(boolean p0){ return false; }
    public boolean shouldShowRequestPermissionRationale(String p0){ return false; }
    public boolean shouldUpRecreateTask(Intent p0){ return false; }
    public boolean showAssist(Bundle p0){ return false; }
    public boolean startActivityIfNeeded(Intent p0, int p1){ return false; }
    public boolean startActivityIfNeeded(Intent p0, int p1, Bundle p2){ return false; }
    public boolean startNextMatchingActivity(Intent p0){ return false; }
    public boolean startNextMatchingActivity(Intent p0, Bundle p1){ return false; }
    public final <T extends View> T requireViewById(int p0){ return null; }
    public final Activity getParent(){ return null; }
    public final Application getApplication(){ return null; }
    public final CharSequence getTitle(){ return null; }
    public final Cursor managedQuery(Uri p0, String[] p1, String p2, String[] p3, String p4){ return null; }
    public final MediaController getMediaController(){ return null; }
    public final SearchEvent getSearchEvent(){ return null; }
    public final SplashScreen getSplashScreen(){ return null; }
    public final boolean isChild(){ return false; }
    public final boolean requestWindowFeature(int p0){ return false; }
    public final boolean showDialog(int p0, Bundle p1){ return false; }
    public final int getTitleColor(){ return 0; }
    public final int getVolumeControlStream(){ return 0; }
    public final void dismissDialog(int p0){}
    public final void dismissKeyboardShortcutsHelper(){}
    public final void removeDialog(int p0){}
    public final void requestPermissions(String[] p0, int p1){}
    public final void requestShowKeyboardShortcuts(){}
    public final void runOnUiThread(Runnable p0){}
    public final void setDefaultKeyMode(int p0){}
    public final void setFeatureDrawable(int p0, Drawable p1){}
    public final void setFeatureDrawableAlpha(int p0, int p1){}
    public final void setFeatureDrawableResource(int p0, int p1){}
    public final void setFeatureDrawableUri(int p0, Uri p1){}
    public final void setMediaController(MediaController p0){}
    public final void setProgress(int p0){}
    public final void setProgressBarIndeterminate(boolean p0){}
    public final void setProgressBarIndeterminateVisibility(boolean p0){}
    public final void setProgressBarVisibility(boolean p0){}
    public final void setResult(int p0){}
    public final void setResult(int p0, Intent p1){}
    public final void setSecondaryProgress(int p0){}
    public final void setVolumeControlStream(int p0){}
    public final void showDialog(int p0){}
    public int getChangingConfigurations(){ return 0; }
    public int getMaxNumPictureInPictureActions(){ return 0; }
    public int getRequestedOrientation(){ return 0; }
    public int getTaskId(){ return 0; }
    public static int DEFAULT_KEYS_DIALER = 0;
    public static int DEFAULT_KEYS_DISABLE = 0;
    public static int DEFAULT_KEYS_SEARCH_GLOBAL = 0;
    public static int DEFAULT_KEYS_SEARCH_LOCAL = 0;
    public static int DEFAULT_KEYS_SHORTCUT = 0;
    public static int RESULT_CANCELED = 0;
    public static int RESULT_FIRST_USER = 0;
    public static int RESULT_OK = 0;
    public void addContentView(View p0, ViewGroup.LayoutParams p1){}
    public void closeContextMenu(){}
    public void closeOptionsMenu(){}
    public void dump(String p0, FileDescriptor p1, PrintWriter p2, String[] p3){}
    public void enterPictureInPictureMode(){}
    public void finish(){}
    public void finishActivity(int p0){}
    public void finishActivityFromChild(Activity p0, int p1){}
    public void finishAffinity(){}
    public void finishAfterTransition(){}
    public void finishAndRemoveTask(){}
    public void finishFromChild(Activity p0){}
    public void invalidateOptionsMenu(){}
    public void onActionModeFinished(ActionMode p0){}
    public void onActionModeStarted(ActionMode p0){}
    public void onActivityReenter(int p0, Intent p1){}
    public void onAttachFragment(Fragment p0){}
    public void onAttachedToWindow(){}
    public void onBackPressed(){}
    public void onConfigurationChanged(Configuration p0){}
    public void onContentChanged(){}
    public void onContextMenuClosed(Menu p0){}
    public void onCreate(Bundle p0, PersistableBundle p1){}
    public void onCreateContextMenu(ContextMenu p0, View p1, ContextMenu.ContextMenuInfo p2){}
    public void onCreateNavigateUpTaskStack(TaskStackBuilder p0){}
    public void onDetachedFromWindow(){}
    public void onEnterAnimationComplete(){}
    public void onGetDirectActions(CancellationSignal p0, Consumer<List<DirectAction>> p1){}
    public void onLocalVoiceInteractionStarted(){}
    public void onLocalVoiceInteractionStopped(){}
    public void onLowMemory(){}
    public void onMultiWindowModeChanged(boolean p0){}
    public void onMultiWindowModeChanged(boolean p0, Configuration p1){}
    public void onOptionsMenuClosed(Menu p0){}
    public void onPanelClosed(int p0, Menu p1){}
    public void onPerformDirectAction(String p0, Bundle p1, CancellationSignal p2, Consumer<Bundle> p3){}
    public void onPictureInPictureModeChanged(boolean p0){}
    public void onPictureInPictureModeChanged(boolean p0, Configuration p1){}
    public void onPictureInPictureUiStateChanged(PictureInPictureUiState p0){}
    public void onPostCreate(Bundle p0, PersistableBundle p1){}
    public void onPrepareNavigateUpTaskStack(TaskStackBuilder p0){}
    public void onProvideAssistContent(AssistContent p0){}
    public void onProvideAssistData(Bundle p0){}
    public void onProvideKeyboardShortcuts(List<KeyboardShortcutGroup> p0, Menu p1, int p2){}
    public void onRequestPermissionsResult(int p0, String[] p1, int[] p2){}
    public void onRestoreInstanceState(Bundle p0, PersistableBundle p1){}
    public void onSaveInstanceState(Bundle p0, PersistableBundle p1){}
    public void onStateNotSaved(){}
    public void onTopResumedActivityChanged(boolean p0){}
    public void onTrimMemory(int p0){}
    public void onUserInteraction(){}
    public void onVisibleBehindCanceled(){}
    public void onWindowAttributesChanged(WindowManager.LayoutParams p0){}
    public void onWindowFocusChanged(boolean p0){}
    public void openContextMenu(View p0){}
    public void openOptionsMenu(){}
    public void overridePendingTransition(int p0, int p1){}
    public void postponeEnterTransition(){}
    public void recreate(){}
    public void registerActivityLifecycleCallbacks(Application.ActivityLifecycleCallbacks p0){}
    public void registerForContextMenu(View p0){}
    public void reportFullyDrawn(){}
    public void setActionBar(Toolbar p0){}
    public void setContentTransitionManager(TransitionManager p0){}
    public void setContentView(View p0){}
    public void setContentView(View p0, ViewGroup.LayoutParams p1){}
    public void setContentView(int p0){}
    public void setEnterSharedElementCallback(SharedElementCallback p0){}
    public void setExitSharedElementCallback(SharedElementCallback p0){}
    public void setFinishOnTouchOutside(boolean p0){}
    public void setImmersive(boolean p0){}
    public void setInheritShowWhenLocked(boolean p0){}
    public void setIntent(Intent p0){}
    public void setLocusContext(LocusId p0, Bundle p1){}
    public void setPictureInPictureParams(PictureInPictureParams p0){}
    public void setRequestedOrientation(int p0){}
    public void setShowWhenLocked(boolean p0){}
    public void setTaskDescription(ActivityManager.TaskDescription p0){}
    public void setTheme(int p0){}
    public void setTitle(CharSequence p0){}
    public void setTitle(int p0){}
    public void setTitleColor(int p0){}
    public void setTurnScreenOn(boolean p0){}
    public void setVisible(boolean p0){}
    public void setVrModeEnabled(boolean p0, ComponentName p1){}
    public void showLockTaskEscapeMessage(){}
    public void startActivities(Intent[] p0){}
    public void startActivities(Intent[] p0, Bundle p1){}
    public void startActivity(Intent p0){}
    public void startActivity(Intent p0, Bundle p1){}
    public void startActivityForResult(Intent p0, int p1){}
    public void startActivityForResult(Intent p0, int p1, Bundle p2){}
    public void startActivityFromChild(Activity p0, Intent p1, int p2){}
    public void startActivityFromChild(Activity p0, Intent p1, int p2, Bundle p3){}
    public void startActivityFromFragment(Fragment p0, Intent p1, int p2){}
    public void startActivityFromFragment(Fragment p0, Intent p1, int p2, Bundle p3){}
    public void startIntentSender(IntentSender p0, Intent p1, int p2, int p3, int p4){}
    public void startIntentSender(IntentSender p0, Intent p1, int p2, int p3, int p4, Bundle p5){}
    public void startIntentSenderForResult(IntentSender p0, int p1, Intent p2, int p3, int p4, int p5){}
    public void startIntentSenderForResult(IntentSender p0, int p1, Intent p2, int p3, int p4, int p5, Bundle p6){}
    public void startIntentSenderFromChild(Activity p0, IntentSender p1, int p2, Intent p3, int p4, int p5, int p6){}
    public void startIntentSenderFromChild(Activity p0, IntentSender p1, int p2, Intent p3, int p4, int p5, int p6, Bundle p7){}
    public void startLocalVoiceInteraction(Bundle p0){}
    public void startLockTask(){}
    public void startManagingCursor(Cursor p0){}
    public void startPostponedEnterTransition(){}
    public void startSearch(String p0, boolean p1, Bundle p2, boolean p3){}
    public void stopLocalVoiceInteraction(){}
    public void stopLockTask(){}
    public void stopManagingCursor(Cursor p0){}
    public void takeKeyEvents(boolean p0){}
    public void triggerSearch(String p0, Bundle p1){}
    public void unregisterActivityLifecycleCallbacks(Application.ActivityLifecycleCallbacks p0){}
    public void unregisterForContextMenu(View p0){}
}
