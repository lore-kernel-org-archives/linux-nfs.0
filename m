Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58217 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933022AbbFEPBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:53 -0400
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
Subject: [RFC PATCH 03/18] kthread: Add kthread_stop_current()
Date: Fri,  5 Jun 2015 17:01:02 +0200
Message-Id: <1433516477-5153-4-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For example, jffs2_gcd_mtd kthread can be stopped by SIGKILL.
The signal is handled inside the main function.

We would like to convert such kthreads to the iterant API
and use proper signal handlers.

The new functions will allow to pass the information
between the signal handler and the main kthread functions.

kthread_stop_current() allows to quit the kthread correctly.
It means to leave the main cycle on a safe point and call
clean up actions via post() function.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/kthread.h |  1 +
 kernel/kthread.c        | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 06fe9ad192dd..100c1e006729 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -86,6 +86,7 @@ kthread_iterant_create_on_cpu(struct kthread_iterant *kti,
 })
 
 void kthread_bind(struct task_struct *k, unsigned int cpu);
+void kthread_stop_current(void);
 int kthread_stop(struct task_struct *k);
 bool kthread_should_stop(void);
 bool kthread_should_park(void);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 4b2698bcc622..688bb4cfd807 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -70,6 +70,19 @@ static struct kthread *to_live_kthread(struct task_struct *k)
 }
 
 /**
+ * kthread_stop_current - make the current kthread to terminate a safe way
+ *
+ * This function sets KTHREAD_SHOULD_STOP flags. It makes kthread to break
+ * the main loop and do some clean up actions before the main kthread
+ * function finishes. It is the standard behavior for SIGTERM signal.
+ */
+void kthread_stop_current(void)
+{
+	set_bit(KTHREAD_SHOULD_STOP, &to_kthread(current)->flags);
+}
+EXPORT_SYMBOL(kthread_stop_current);
+
+/**
  * kthread_should_stop - should this kthread return now?
  *
  * When someone calls kthread_stop() on your kthread, it will be woken
-- 
1.8.5.6

