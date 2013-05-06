Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f74.google.com ([209.85.213.74]:41637 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758835Ab3EFX6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:58:30 -0400
Received: by mail-yh0-f74.google.com with SMTP id t59so450376yho.5
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:58:30 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Len Brown <len.brown@intel.com>
Subject: [PATCH v3 09/16] freezer: add new freezable helpers using freezer_do_not_count()
Date: Mon,  6 May 2013 16:50:14 -0700
Message-Id: <1367884221-20462-10-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Freezing tasks will wake up almost every userspace task from
where it is blocking and force it to run until it hits a
call to try_to_sleep(), generally on the exit path from the syscall
it is blocking in.  On resume each task will run again, usually
restarting the syscall and running until it hits the same
blocking call as it was originally blocked in.

To allow tasks to avoid running on every suspend/resume cycle,
this patch adds additional freezable wrappers around blocking calls
that call freezer_do_not_count().  Combined with the previous patch,
these tasks will not run during suspend or resume unless they wake
up for another reason, in which case they will run until they hit
the try_to_freeze() in freezer_count(), and then continue processing
the wakeup after tasks are thawed.

Additional patches will convert the most common locations that
userspace blocks in to use freezable helpers.

Signed-off-by: Colin Cross <ccross@android.com>
---
v3:
   split out the changes to existing helpers to a separate patch

 include/linux/freezer.h | 61 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 8430d4c5..7fd81b8 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -180,6 +180,32 @@ static inline void freezable_schedule_unsafe(void)
 	freezer_count_unsafe();
 }
 
+/*
+ * Like freezable_schedule_timeout(), but should not block the freezer.  Do not
+ * call this with locks held.
+ */
+static inline long freezable_schedule_timeout(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout(timeout);
+	freezer_count();
+	return __retval;
+}
+
+/*
+ * Like schedule_timeout_interruptible(), but should not block the freezer.  Do not
+ * call this with locks held.
+ */
+static inline long freezable_schedule_timeout_interruptible(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout_interruptible(timeout);
+	freezer_count();
+	return __retval;
+}
+
 /* Like schedule_timeout_killable(), but should not block the freezer. */
 static inline long freezable_schedule_timeout_killable(long timeout)
 {
@@ -201,6 +227,20 @@ static inline long freezable_schedule_timeout_killable_unsafe(long timeout)
 }
 
 /*
+ * Like schedule_hrtimeout_range(), but should not block the freezer.  Do not
+ * call this with locks held.
+ */
+static inline int freezable_schedule_hrtimeout_range(ktime_t *expires,
+		unsigned long delta, const enum hrtimer_mode mode)
+{
+	int __retval;
+	freezer_do_not_count();
+	__retval = schedule_hrtimeout_range(expires, delta, mode);
+	freezer_count();
+	return __retval;
+}
+
+/*
  * Freezer-friendly wrappers around wait_event_interruptible(),
  * wait_event_killable() and wait_event_interruptible_timeout(), originally
  * defined in <linux/wait.h>
@@ -244,6 +284,16 @@ static inline long freezable_schedule_timeout_killable_unsafe(long timeout)
 	__retval;							\
 })
 
+#define wait_event_freezable_exclusive(wq, condition)			\
+({									\
+	int __retval;							\
+	freezer_do_not_count();						\
+	__retval = wait_event_interruptible_exclusive(wq, condition);	\
+	freezer_count();						\
+	__retval;							\
+})
+
+
 #else /* !CONFIG_FREEZER */
 static inline bool frozen(struct task_struct *p) { return false; }
 static inline bool freezing(struct task_struct *p) { return false; }
@@ -267,18 +317,29 @@ static inline void set_freezable(void) {}
 
 #define freezable_schedule_unsafe()  schedule()
 
+#define freezable_schedule_timeout(timeout)  schedule_timeout(timeout)
+
+#define freezable_schedule_timeout_interruptible(timeout)		\
+	schedule_timeout_interruptible(timeout)
+
 #define freezable_schedule_timeout_killable(timeout)			\
 	schedule_timeout_killable(timeout)
 
 #define freezable_schedule_timeout_killable_unsafe(timeout)		\
 	schedule_timeout_killable(timeout)
 
+#define freezable_schedule_hrtimeout_range(expires, delta, mode)	\
+	schedule_hrtimeout_range(expires, delta, mode)
+
 #define wait_event_freezable(wq, condition)				\
 		wait_event_interruptible(wq, condition)
 
 #define wait_event_freezable_timeout(wq, condition, timeout)		\
 		wait_event_interruptible_timeout(wq, condition, timeout)
 
+#define wait_event_freezable_exclusive(wq, condition)			\
+		wait_event_interruptible_exclusive(wq, condition)
+
 #define wait_event_freezekillable(wq, condition)		\
 		wait_event_killable(wq, condition)
 
-- 
1.8.2.1

