Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f74.google.com ([209.85.128.74]:50756 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3ECVMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 17:12:02 -0400
Received: by mail-qe0-f74.google.com with SMTP id 1so217211qec.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 May 2013 14:12:00 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Colin Cross <ccross@android.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Fri,  3 May 2013 14:04:10 -0700
Message-Id: <1367615050-3894-2-git-send-email-ccross@android.com>
In-Reply-To: <1367615050-3894-1-git-send-email-ccross@android.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mandeep Singh Baines <msb@chromium.org>

We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
deadlock if the lock is later acquired in the suspend or hibernate path
(e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
cgroup_freezer if a lock is held inside a frozen cgroup that is later
acquired by a process outside that group.

History:
This patch was originally applied as 6aa9707099c and reverted in
dbf520a9d7d4 because NFS was freezing with locks held.  It was
deemed better to keep the bad freeze point in NFS to allow laptops
to suspend consistently.  The previous patch in this series converts
NFS to call _unsafe versions of the freezable helpers so that
lockdep doesn't complain about them until a more correct fix
can be applied.

[akpm@linux-foundation.org: export debug_check_no_locks_held]
Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
Cc: Ben Chan <benchan@chromium.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
[ccross@android.com: don't warn if try_to_freeze_unsafe is called]
Signed-off-by: Colin Cross <ccross@android.com>
---
 include/linux/debug_locks.h |  4 ++--
 include/linux/freezer.h     |  3 +++
 kernel/exit.c               |  2 +-
 kernel/lockdep.c            | 17 ++++++++---------
 4 files changed, 14 insertions(+), 12 deletions(-)

As requested by Tejun, this is to prevent incorrect use when
I add new freezable helpers in a subsequent patch series.

I'm not sure what the protocol is for Signed-off-by when
reapplying a reverted patch, but I got the patch from Linus'
tree so I left all of them and added mine at the bottom.

diff --git a/include/linux/debug_locks.h b/include/linux/debug_locks.h
index 3bd46f7..a975de1 100644
--- a/include/linux/debug_locks.h
+++ b/include/linux/debug_locks.h
@@ -51,7 +51,7 @@ struct task_struct;
 extern void debug_show_all_locks(void);
 extern void debug_show_held_locks(struct task_struct *task);
 extern void debug_check_no_locks_freed(const void *from, unsigned long len);
-extern void debug_check_no_locks_held(struct task_struct *task);
+extern void debug_check_no_locks_held(void);
 #else
 static inline void debug_show_all_locks(void)
 {
@@ -67,7 +67,7 @@ debug_check_no_locks_freed(const void *from, unsigned long len)
 }
 
 static inline void
-debug_check_no_locks_held(struct task_struct *task)
+debug_check_no_locks_held(void)
 {
 }
 #endif
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 5b31e21c..efb80dd 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -3,6 +3,7 @@
 #ifndef FREEZER_H_INCLUDED
 #define FREEZER_H_INCLUDED
 
+#include <linux/debug_locks.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/atomic.h>
@@ -60,6 +61,8 @@ static inline bool try_to_freeze_unsafe(void)
 
 static inline bool try_to_freeze(void)
 {
+	if (!(current->flags & PF_NOFREEZE))
+		debug_check_no_locks_held();
 	return try_to_freeze_unsafe();
 }
 
diff --git a/kernel/exit.c b/kernel/exit.c
index 60bc027..51e485c 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -835,7 +835,7 @@ void do_exit(long code)
 	/*
 	 * Make sure we are holding no locks:
 	 */
-	debug_check_no_locks_held(tsk);
+	debug_check_no_locks_held();
 	/*
 	 * We can do this unlocked here. The futex code uses this flag
 	 * just to verify whether the pi state cleanup has been done
diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 8a0efac..259db20 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -4088,7 +4088,7 @@ void debug_check_no_locks_freed(const void *mem_from, unsigned long mem_len)
 }
 EXPORT_SYMBOL_GPL(debug_check_no_locks_freed);
 
-static void print_held_locks_bug(struct task_struct *curr)
+static void print_held_locks_bug(void)
 {
 	if (!debug_locks_off())
 		return;
@@ -4097,22 +4097,21 @@ static void print_held_locks_bug(struct task_struct *curr)
 
 	printk("\n");
 	printk("=====================================\n");
-	printk("[ BUG: lock held at task exit time! ]\n");
+	printk("[ BUG: %s/%d still has locks held! ]\n",
+	       current->comm, task_pid_nr(current));
 	print_kernel_ident();
 	printk("-------------------------------------\n");
-	printk("%s/%d is exiting with locks still held!\n",
-		curr->comm, task_pid_nr(curr));
-	lockdep_print_held_locks(curr);
-
+	lockdep_print_held_locks(current);
 	printk("\nstack backtrace:\n");
 	dump_stack();
 }
 
-void debug_check_no_locks_held(struct task_struct *task)
+void debug_check_no_locks_held(void)
 {
-	if (unlikely(task->lockdep_depth > 0))
-		print_held_locks_bug(task);
+	if (unlikely(current->lockdep_depth > 0))
+		print_held_locks_bug();
 }
+EXPORT_SYMBOL_GPL(debug_check_no_locks_held);
 
 void debug_show_all_locks(void)
 {
-- 
1.8.2.1

