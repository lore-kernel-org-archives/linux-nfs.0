Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58304 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933475AbbFEPCC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:02 -0400
From: Petr Mladek <pmladek@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>
Cc: Richard Weinberger <richard@nod.at>, Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
        Petr Mladek <pmladek@suse.cz>
Subject: [RFC PATCH 10/18] jffs2: Remove forward definition of jffs2_garbage_collect_thread()
Date: Fri,  5 Jun 2015 17:01:09 +0200
Message-Id: <1433516477-5153-11-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit just moves the function definition and fixes few coding
style problems reported by checkpatch.pl. There are no changes in
the functionality.

The change will be useful when switching to the new iterant kthread API.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 fs/jffs2/background.c | 101 +++++++++++++++++++++++++-------------------------
 1 file changed, 50 insertions(+), 51 deletions(-)

diff --git a/fs/jffs2/background.c b/fs/jffs2/background.c
index bb9cebc9ca8a..6af076b8f60f 100644
--- a/fs/jffs2/background.c
+++ b/fs/jffs2/background.c
@@ -21,57 +21,6 @@
 #include <linux/kthread.h>
 #include "nodelist.h"
 
-
-static int jffs2_garbage_collect_thread(void *);
-
-void jffs2_garbage_collect_trigger(struct jffs2_sb_info *c)
-{
-	assert_spin_locked(&c->erase_completion_lock);
-	if (c->gc_task && jffs2_thread_should_wake(c))
-		send_sig(SIGHUP, c->gc_task, 1);
-}
-
-/* This must only ever be called when no GC thread is currently running */
-int jffs2_start_garbage_collect_thread(struct jffs2_sb_info *c)
-{
-	struct task_struct *tsk;
-	int ret = 0;
-
-	BUG_ON(c->gc_task);
-
-	init_completion(&c->gc_thread_start);
-	init_completion(&c->gc_thread_exit);
-
-	tsk = kthread_run(jffs2_garbage_collect_thread, c, "jffs2_gcd_mtd%d", c->mtd->index);
-	if (IS_ERR(tsk)) {
-		pr_warn("fork failed for JFFS2 garbage collect thread: %ld\n",
-			-PTR_ERR(tsk));
-		complete(&c->gc_thread_exit);
-		ret = PTR_ERR(tsk);
-	} else {
-		/* Wait for it... */
-		jffs2_dbg(1, "Garbage collect thread is pid %d\n", tsk->pid);
-		wait_for_completion(&c->gc_thread_start);
-		ret = tsk->pid;
-	}
-
-	return ret;
-}
-
-void jffs2_stop_garbage_collect_thread(struct jffs2_sb_info *c)
-{
-	int wait = 0;
-	spin_lock(&c->erase_completion_lock);
-	if (c->gc_task) {
-		jffs2_dbg(1, "Killing GC task %d\n", c->gc_task->pid);
-		send_sig(SIGKILL, c->gc_task, 1);
-		wait = 1;
-	}
-	spin_unlock(&c->erase_completion_lock);
-	if (wait)
-		wait_for_completion(&c->gc_thread_exit);
-}
-
 static int jffs2_garbage_collect_thread(void *_c)
 {
 	struct jffs2_sb_info *c = _c;
@@ -166,3 +115,53 @@ static int jffs2_garbage_collect_thread(void *_c)
 	spin_unlock(&c->erase_completion_lock);
 	complete_and_exit(&c->gc_thread_exit, 0);
 }
+
+void jffs2_garbage_collect_trigger(struct jffs2_sb_info *c)
+{
+	assert_spin_locked(&c->erase_completion_lock);
+	if (c->gc_task && jffs2_thread_should_wake(c))
+		send_sig(SIGHUP, c->gc_task, 1);
+}
+
+/* This must only ever be called when no GC thread is currently running */
+int jffs2_start_garbage_collect_thread(struct jffs2_sb_info *c)
+{
+	struct task_struct *tsk;
+	int ret = 0;
+
+	BUG_ON(c->gc_task);
+
+	init_completion(&c->gc_thread_start);
+	init_completion(&c->gc_thread_exit);
+
+	tsk = kthread_run(jffs2_garbage_collect_thread, c,
+			  "jffs2_gcd_mtd%d", c->mtd->index);
+	if (IS_ERR(tsk)) {
+		pr_warn("fork failed for JFFS2 garbage collect thread: %ld\n",
+			-PTR_ERR(tsk));
+		complete(&c->gc_thread_exit);
+		ret = PTR_ERR(tsk);
+	} else {
+		/* Wait for it... */
+		jffs2_dbg(1, "Garbage collect thread is pid %d\n", tsk->pid);
+		wait_for_completion(&c->gc_thread_start);
+		ret = tsk->pid;
+	}
+
+	return ret;
+}
+
+void jffs2_stop_garbage_collect_thread(struct jffs2_sb_info *c)
+{
+	int wait = 0;
+
+	spin_lock(&c->erase_completion_lock);
+	if (c->gc_task) {
+		jffs2_dbg(1, "Killing GC task %d\n", c->gc_task->pid);
+		send_sig(SIGKILL, c->gc_task, 1);
+		wait = 1;
+	}
+	spin_unlock(&c->erase_completion_lock);
+	if (wait)
+		wait_for_completion(&c->gc_thread_exit);
+}
-- 
1.8.5.6

