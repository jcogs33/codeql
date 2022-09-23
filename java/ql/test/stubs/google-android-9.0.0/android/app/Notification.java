// Generated automatically from android.app.Notification for testing purposes

package android.app;

import android.app.PendingIntent;
import android.app.RemoteInput;
import android.content.LocusId;
import android.graphics.Bitmap;
import android.graphics.drawable.Icon;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Pair;
import android.widget.RemoteViews;
import java.util.List;

public class Notification implements Parcelable
{
    public AudioAttributes audioAttributes = null;
    public Bitmap largeIcon = null;
    public Bundle extras = null;
    public CharSequence getSettingsText(){ return null; }
    public CharSequence tickerText = null;
    public Icon getLargeIcon(){ return null; }
    public Icon getSmallIcon(){ return null; }
    public List<Notification.Action> getContextualActions(){ return null; }
    public LocusId getLocusId(){ return null; }
    public Notification clone(){ return null; }
    public Notification publicVersion = null;
    public Notification(){}
    public Notification(Parcel p0){}
    public Notification(int p0, CharSequence p1, long p2){}
    public Notification.Action[] actions = null;
    public Notification.BubbleMetadata getBubbleMetadata(){ return null; }
    public Pair<RemoteInput, Notification.Action> findRemoteInputActionPair(boolean p0){ return null; }
    public PendingIntent contentIntent = null;
    public PendingIntent deleteIntent = null;
    public PendingIntent fullScreenIntent = null;
    public RemoteViews bigContentView = null;
    public RemoteViews contentView = null;
    public RemoteViews headsUpContentView = null;
    public RemoteViews tickerView = null;
    public String category = null;
    public String getChannelId(){ return null; }
    public String getGroup(){ return null; }
    public String getShortcutId(){ return null; }
    public String getSortKey(){ return null; }
    public String toString(){ return null; }
    public Uri sound = null;
    public boolean getAllowSystemGeneratedContextualActions(){ return false; }
    public boolean hasImage(){ return false; }
    public int audioStreamType = 0;
    public int color = 0;
    public int defaults = 0;
    public int describeContents(){ return 0; }
    public int flags = 0;
    public int getBadgeIconType(){ return 0; }
    public int getGroupAlertBehavior(){ return 0; }
    public int icon = 0;
    public int iconLevel = 0;
    public int ledARGB = 0;
    public int ledOffMS = 0;
    public int ledOnMS = 0;
    public int number = 0;
    public int priority = 0;
    public int visibility = 0;
    public long getTimeoutAfter(){ return 0; }
    public long when = 0;
    public long[] vibrate = null;
    public static AudioAttributes AUDIO_ATTRIBUTES_DEFAULT = null;
    public static Parcelable.Creator<Notification> CREATOR = null;
    public static String CATEGORY_ALARM = null;
    public static String CATEGORY_CALL = null;
    public static String CATEGORY_EMAIL = null;
    public static String CATEGORY_ERROR = null;
    public static String CATEGORY_EVENT = null;
    public static String CATEGORY_LOCATION_SHARING = null;
    public static String CATEGORY_MESSAGE = null;
    public static String CATEGORY_MISSED_CALL = null;
    public static String CATEGORY_NAVIGATION = null;
    public static String CATEGORY_PROGRESS = null;
    public static String CATEGORY_PROMO = null;
    public static String CATEGORY_RECOMMENDATION = null;
    public static String CATEGORY_REMINDER = null;
    public static String CATEGORY_SERVICE = null;
    public static String CATEGORY_SOCIAL = null;
    public static String CATEGORY_STATUS = null;
    public static String CATEGORY_STOPWATCH = null;
    public static String CATEGORY_SYSTEM = null;
    public static String CATEGORY_TRANSPORT = null;
    public static String CATEGORY_WORKOUT = null;
    public static String EXTRA_ANSWER_COLOR = null;
    public static String EXTRA_ANSWER_INTENT = null;
    public static String EXTRA_AUDIO_CONTENTS_URI = null;
    public static String EXTRA_BACKGROUND_IMAGE_URI = null;
    public static String EXTRA_BIG_TEXT = null;
    public static String EXTRA_CALL_IS_VIDEO = null;
    public static String EXTRA_CALL_PERSON = null;
    public static String EXTRA_CHANNEL_GROUP_ID = null;
    public static String EXTRA_CHANNEL_ID = null;
    public static String EXTRA_CHRONOMETER_COUNT_DOWN = null;
    public static String EXTRA_COLORIZED = null;
    public static String EXTRA_COMPACT_ACTIONS = null;
    public static String EXTRA_CONVERSATION_TITLE = null;
    public static String EXTRA_DECLINE_COLOR = null;
    public static String EXTRA_DECLINE_INTENT = null;
    public static String EXTRA_HANG_UP_INTENT = null;
    public static String EXTRA_HISTORIC_MESSAGES = null;
    public static String EXTRA_INFO_TEXT = null;
    public static String EXTRA_IS_GROUP_CONVERSATION = null;
    public static String EXTRA_LARGE_ICON = null;
    public static String EXTRA_LARGE_ICON_BIG = null;
    public static String EXTRA_MEDIA_SESSION = null;
    public static String EXTRA_MESSAGES = null;
    public static String EXTRA_MESSAGING_PERSON = null;
    public static String EXTRA_NOTIFICATION_ID = null;
    public static String EXTRA_NOTIFICATION_TAG = null;
    public static String EXTRA_PEOPLE = null;
    public static String EXTRA_PEOPLE_LIST = null;
    public static String EXTRA_PICTURE = null;
    public static String EXTRA_PICTURE_CONTENT_DESCRIPTION = null;
    public static String EXTRA_PICTURE_ICON = null;
    public static String EXTRA_PROGRESS = null;
    public static String EXTRA_PROGRESS_INDETERMINATE = null;
    public static String EXTRA_PROGRESS_MAX = null;
    public static String EXTRA_REMOTE_INPUT_DRAFT = null;
    public static String EXTRA_REMOTE_INPUT_HISTORY = null;
    public static String EXTRA_SELF_DISPLAY_NAME = null;
    public static String EXTRA_SHOW_BIG_PICTURE_WHEN_COLLAPSED = null;
    public static String EXTRA_SHOW_CHRONOMETER = null;
    public static String EXTRA_SHOW_WHEN = null;
    public static String EXTRA_SMALL_ICON = null;
    public static String EXTRA_SUB_TEXT = null;
    public static String EXTRA_SUMMARY_TEXT = null;
    public static String EXTRA_TEMPLATE = null;
    public static String EXTRA_TEXT = null;
    public static String EXTRA_TEXT_LINES = null;
    public static String EXTRA_TITLE = null;
    public static String EXTRA_TITLE_BIG = null;
    public static String EXTRA_VERIFICATION_ICON = null;
    public static String EXTRA_VERIFICATION_TEXT = null;
    public static String INTENT_CATEGORY_NOTIFICATION_PREFERENCES = null;
    public static int BADGE_ICON_LARGE = 0;
    public static int BADGE_ICON_NONE = 0;
    public static int BADGE_ICON_SMALL = 0;
    public static int COLOR_DEFAULT = 0;
    public static int DEFAULT_ALL = 0;
    public static int DEFAULT_LIGHTS = 0;
    public static int DEFAULT_SOUND = 0;
    public static int DEFAULT_VIBRATE = 0;
    public static int FLAG_AUTO_CANCEL = 0;
    public static int FLAG_BUBBLE = 0;
    public static int FLAG_FOREGROUND_SERVICE = 0;
    public static int FLAG_GROUP_SUMMARY = 0;
    public static int FLAG_HIGH_PRIORITY = 0;
    public static int FLAG_INSISTENT = 0;
    public static int FLAG_LOCAL_ONLY = 0;
    public static int FLAG_NO_CLEAR = 0;
    public static int FLAG_ONGOING_EVENT = 0;
    public static int FLAG_ONLY_ALERT_ONCE = 0;
    public static int FLAG_SHOW_LIGHTS = 0;
    public static int FOREGROUND_SERVICE_DEFAULT = 0;
    public static int FOREGROUND_SERVICE_DEFERRED = 0;
    public static int FOREGROUND_SERVICE_IMMEDIATE = 0;
    public static int GROUP_ALERT_ALL = 0;
    public static int GROUP_ALERT_CHILDREN = 0;
    public static int GROUP_ALERT_SUMMARY = 0;
    public static int PRIORITY_DEFAULT = 0;
    public static int PRIORITY_HIGH = 0;
    public static int PRIORITY_LOW = 0;
    public static int PRIORITY_MAX = 0;
    public static int PRIORITY_MIN = 0;
    public static int STREAM_DEFAULT = 0;
    public static int VISIBILITY_PRIVATE = 0;
    public static int VISIBILITY_PUBLIC = 0;
    public static int VISIBILITY_SECRET = 0;
    public void writeToParcel(Parcel p0, int p1){}
    static public class Action implements Parcelable
    {
        protected Action() {}
        public Action(int p0, CharSequence p1, PendingIntent p2){}
        public Bundle getExtras(){ return null; }
        public CharSequence title = null;
        public Icon getIcon(){ return null; }
        public Notification.Action clone(){ return null; }
        public PendingIntent actionIntent = null;
        public RemoteInput[] getDataOnlyRemoteInputs(){ return null; }
        public RemoteInput[] getRemoteInputs(){ return null; }
        public boolean getAllowGeneratedReplies(){ return false; }
        public boolean isAuthenticationRequired(){ return false; }
        public boolean isContextual(){ return false; }
        public int describeContents(){ return 0; }
        public int getSemanticAction(){ return 0; }
        public int icon = 0;
        public static Parcelable.Creator<Notification.Action> CREATOR = null;
        public static int SEMANTIC_ACTION_ARCHIVE = 0;
        public static int SEMANTIC_ACTION_CALL = 0;
        public static int SEMANTIC_ACTION_DELETE = 0;
        public static int SEMANTIC_ACTION_MARK_AS_READ = 0;
        public static int SEMANTIC_ACTION_MARK_AS_UNREAD = 0;
        public static int SEMANTIC_ACTION_MUTE = 0;
        public static int SEMANTIC_ACTION_NONE = 0;
        public static int SEMANTIC_ACTION_REPLY = 0;
        public static int SEMANTIC_ACTION_THUMBS_DOWN = 0;
        public static int SEMANTIC_ACTION_THUMBS_UP = 0;
        public static int SEMANTIC_ACTION_UNMUTE = 0;
        public void writeToParcel(Parcel p0, int p1){}
    }
    static public class BubbleMetadata implements Parcelable
    {
        protected BubbleMetadata() {}
        public Icon getIcon(){ return null; }
        public PendingIntent getDeleteIntent(){ return null; }
        public PendingIntent getIntent(){ return null; }
        public String getShortcutId(){ return null; }
        public boolean getAutoExpandBubble(){ return false; }
        public boolean isBubbleSuppressable(){ return false; }
        public boolean isBubbleSuppressed(){ return false; }
        public boolean isNotificationSuppressed(){ return false; }
        public int describeContents(){ return 0; }
        public int getDesiredHeight(){ return 0; }
        public int getDesiredHeightResId(){ return 0; }
        public static Parcelable.Creator<Notification.BubbleMetadata> CREATOR = null;
        public void writeToParcel(Parcel p0, int p1){}
    }
}
