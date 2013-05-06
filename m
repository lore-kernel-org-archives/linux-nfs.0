Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f74.google.com ([209.85.213.74]:37443 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3EFXu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:29 -0400
Received: by mail-yh0-f74.google.com with SMTP id t59so449568yho.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:50:28 -0700 (PDT)
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
Subject: [PATCH v3 08/16] freezer: convert freezable helpers to static inline where possible
Date: Mon,  6 May 2013 16:50:13 -0700
Message-Id: <1367884221-20462-9-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the freezable helpers have to be macros because their
condition argument needs to get evaluated every time through
the wait loop.  Convert the others to static inline to make
future changes easier.

Signed-off-by: Colin Cross <ccross@android.com>
---
 include/linux/freezer.h | 58 ++++++++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index c71337af..8430d4c5 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -159,46 +159,46 @@ static inline bool freezer_should_skip(struct task_struct *p)
 }
 
 /*
- * These macros are intended to be used whenever you want allow a sleeping
+ * These functions are intended to be used whenever you want allow a sleeping
  * task to be frozen. Note that neither return any clear indication of
  * whether a freeze event happened while in this function.
  */
 
 /* Like schedule(), but should not block the freezer. */
-#define freezable_schedule()						\
-({									\
-	freezer_do_not_count();						\
-	schedule();							\
-	freezer_count();						\
-})
+static inline void freezable_schedule(void)
+{
+	freezer_do_not_count();
+	schedule();
+	freezer_count();
+}
 
 /* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
-#define freezable_schedule_unsafe()					\
-({									\
-	freezer_do_not_count();						\
-	schedule();							\
-	freezer_count_unsafe();						\
-})
+static inline void freezable_schedule_unsafe(void)
+{
+	freezer_do_not_count();
+	schedule();
+	freezer_count_unsafe();
+}
 
 /* Like schedule_timeout_killable(), but should not block the freezer. */
-#define freezable_schedule_timeout_killable(timeout)			\
-({									\
-	long __retval;							\
-	freezer_do_not_count();						\
-	__retval = schedule_timeout_killable(timeout);			\
-	freezer_count();						\
-	__retval;							\
-})
+static inline long freezable_schedule_timeout_killable(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout_killable(timeout);
+	freezer_count();
+	return __retval;
+}
 
 /* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
-#define freezable_schedule_timeout_killable_unsafe(timeout)		\
-({									\
-	long __retval;							\
-	freezer_do_not_count();						\
-	__retval = schedule_timeout_killable(timeout);			\
-	freezer_count_unsafe();						\
-	__retval;							\
-})
+static inline long freezable_schedule_timeout_killable_unsafe(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout_killable(timeout);
+	freezer_count_unsafe();
+	return __retval;
+}
 
 /*
  * Freezer-friendly wrappers around wait_event_interruptible(),
-- 
1.8.2.1

