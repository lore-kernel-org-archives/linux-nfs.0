Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f201.google.com ([209.85.213.201]:64777 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759636Ab3EFX5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:57:33 -0400
Received: by mail-ye0-f201.google.com with SMTP id m14so448554yen.0
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:57:33 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Paul Walmsley <paul@pwsan.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH v3 03/16] lockdep: remove task argument from debug_check_no_locks_held
Date: Mon,  6 May 2013 16:50:08 -0700
Message-Id: <1367884221-20462-4-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only existing caller to debug_check_no_locks_held calls it
with 'current' as the task, and the freezer needs to call
debug_check_no_locks_held but doesn't already have a current
task pointer, so remove the argument.  It is already assuming
that the current task is relevant by dumping the current stack
trace as part of the warning.

This was originally part of 6aa9707099c (lockdep: check that
no locks held at freeze time) which was reverted in
dbf520a9d7d4.

Original-author: Mandeep Singh Baines <msb@chromium.org>
Signed-off-by: Colin Cross <ccross@android.com>
---
 include/linux/debug_locks.h |  4 ++--
 kernel/exit.c               |  2 +-
 kernel/lockdep.c            | 17 ++++++++---------
 3 files changed, 11 insertions(+), 12 deletions(-)

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

