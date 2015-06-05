Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58232 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933468AbbFEPB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:58 -0400
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
Subject: [RFC PATCH 07/18] kthread: Make iterant kthreads freezable by default
Date: Fri,  5 Jun 2015 17:01:06 +0200
Message-Id: <1433516477-5153-8-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Many kthreads already calls set_freezable() before they enter the main
cycle. One of the reasons for creating iterant kthreads is to create
a safe point for freezing and make even more kthreads properly
freezable. Therefore it would make sense to set all iterant
kthreads freezable by default.

However some kthreads might be hard to make properly freezable.
For example, if they do non-interruptible sleeps. They would
need to explicitly clear PF_NOFREEZE flag in the init() call.
But it should be avoided whenever possible.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 kernel/kthread.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 185902d0e293..e34f67cb8ecf 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -412,13 +412,20 @@ struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
  *
  * This function defines the work flow of iterant kthreads. It calls
  * the given callbacks. Also it defines and implements a common
- * check point for freezing and stopping.
+ * check point for freezing, stopping, and signal handling.
+ *
+ * IMPORTANT: Iterant kthreads are freezable by default. The functions
+ * defined in the given struct kthread_iterant still have to explicitly
+ * call try_to_freeze() after each interruptible sleep. They must avoid
+ * non-interruptible sleep if freezing is allowed.
  */
 static int kthread_iterant_fn(void *kti_ptr)
 {
 	struct kthread_iterant *kti = kti_ptr;
 	void *data = kti->data;
 
+	set_freezable();
+
 	if (kti->init)
 		kti->init(data);
 
-- 
1.8.5.6

