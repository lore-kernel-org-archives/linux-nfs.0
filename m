Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f202.google.com ([209.85.213.202]:33947 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758304Ab3EFX6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:58:04 -0400
Received: by mail-ye0-f202.google.com with SMTP id r13so448548yen.5
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:58:04 -0700 (PDT)
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
Subject: [PATCH v3 02/16] freezer: add unsafe versions of freezable helpers for CIFS
Date: Mon,  6 May 2013 16:50:07 -0700
Message-Id: <1367884221-20462-3-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CIFS calls wait_event_freezekillable_unsafe with a VFS lock held,
which is unsafe and will cause lockdep warnings when 6aa9707
"lockdep: check that no locks held at freeze time" is reapplied
(it was reverted in dbf520a).  CIFS shouldn't be doing this, but
it has long-running syscalls that must hold a lock but also
shouldn't block suspend.  Until CIFS freeze handling is rewritten
to use a signal to exit out of the critical section, add a new
wait_event_freezekillable_unsafe helper that will not run the
lockdep test when 6aa9707 is reapplied, and call it from CIFS.

In practice the likley result of holding the lock while freezing
is that a second task blocked on the lock will never freeze,
aborting suspend, but it is possible to manufacture a case using
the cgroup freezer, the lock, and the suspend freezer to create
a deadlock.  Silencing the lockdep warning here will allow
problems to be found in other drivers that may have a more
serious deadlock risk, and prevent new problems from being added.

Signed-off-by: Colin Cross <ccross@android.com>
---
 include/linux/freezer.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 5b31e21c..d3c038e 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -212,6 +212,16 @@ static inline bool freezer_should_skip(struct task_struct *p)
 	__retval;							\
 })
 
+/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
+#define wait_event_freezekillable_unsafe(wq, condition)			\
+({									\
+	int __retval;							\
+	freezer_do_not_count();						\
+	__retval = wait_event_killable(wq, (condition));		\
+	freezer_count_unsafe();						\
+	__retval;							\
+})
+
 #define wait_event_freezable(wq, condition)				\
 ({									\
 	int __retval;							\
@@ -277,6 +287,9 @@ static inline void set_freezable(void) {}
 #define wait_event_freezekillable(wq, condition)		\
 		wait_event_killable(wq, condition)
 
+#define wait_event_freezekillable_unsafe(wq, condition)			\
+		wait_event_killable(wq, condition)
+
 #endif /* !CONFIG_FREEZER */
 
 #endif	/* FREEZER_H_INCLUDED */
-- 
1.8.2.1

