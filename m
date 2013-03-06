Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:48310 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab3CFAa0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 19:30:26 -0500
From: Mandeep Singh Baines <msb@chromium.org>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Mandeep Singh Baines <msb@chromium.org>, Tejun Heo <tj@kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>, Ming Lei <ming.lei@canonical.com>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: [PATCH] lockdep: make lock held while freezing check optional
Date: Tue,  5 Mar 2013 16:30:19 -0800
Message-Id: <1362529819-19076-1-git-send-email-msb@chromium.org>
In-Reply-To: <20130305231110.GK15816@fieldses.org>
References: <20130305231110.GK15816@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This check is turning up a lot of code paths which need to be
fixed so while those paths are fixed, let's make this check
optional so that folks can still use lockdep.

CC: Tejun Heo <tj@kernel.org>
CC: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Ming Lei <ming.lei@canonical.com>
CC: "Rafael J. Wysocki" <rjw@sisk.pl>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Ingo Molnar <mingo@redhat.com>
---
 include/linux/freezer.h |  2 ++
 lib/Kconfig.debug       | 12 ++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 043a5cf..03bdc54 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -49,8 +49,10 @@ extern void thaw_kernel_threads(void);
 
 static inline bool try_to_freeze(void)
 {
+#ifdef CONFIG_DEBUG_LOCK_HELD_FREEZING
 	if (!(current->flags & PF_NOFREEZE))
 		debug_check_no_locks_held();
+#endif
 	might_sleep();
 	if (likely(!freezing(current)))
 		return false;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 28be08c..bddda5f 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -547,6 +547,18 @@ config DEBUG_MUTEXES
 	 This feature allows mutex semantics violations to be detected and
 	 reported.
 
+config DEBUG_LOCK_HELD_FREEZING
+	bool "Lock debugging: detect when locks are held during freeze"
+	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
+	select DEBUG_SPINLOCK
+	select DEBUG_MUTEXES
+	select LOCKDEP
+	help
+	 This feature will check whether any lock is incorrectly held
+	 while freezing. If a task freezes with a lock held it will
+	 block any other task that is waiting on that lock from freezing.
+	 In the case of cgroup_freezer, this can cause a deadlock.
+
 config DEBUG_LOCK_ALLOC
 	bool "Lock debugging: detect incorrect freeing of live locks"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
-- 
1.7.12.4

