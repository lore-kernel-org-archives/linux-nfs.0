Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:58518 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbbFEQKh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 12:10:37 -0400
Date: Fri, 5 Jun 2015 18:10:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 09/18] kthread: Make it easier to correctly sleep in
 iterant kthreads
Message-ID: <20150605161021.GJ19282@twins.programming.kicks-ass.net>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-10-git-send-email-pmladek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1433516477-5153-10-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2015 at 05:01:08PM +0200, Petr Mladek wrote:
> Many kthreads go into an interruptible sleep when there is nothing
> to do. They should check if anyone did not requested the kthread
> to terminate, freeze, or park in the meantime. It is easy to do
> it a wrong way.

INTERRUPTIBLE is the wrong state to idle in for kthreads, use
TASK_IDLE.

---

commit 80ed87c8a9ca0cad7ca66cf3bbdfb17559a66dcf
Author: Peter Zijlstra <peterz@infradead.org>
Date:   Fri May 8 14:23:45 2015 +0200

    sched/wait: Introduce TASK_NOLOAD and TASK_IDLE
    
    Currently people use TASK_INTERRUPTIBLE to idle kthreads and wait for
    'work' because TASK_UNINTERRUPTIBLE contributes to the loadavg. Having
    all idle kthreads contribute to the loadavg is somewhat silly.
    
    Now mostly this works OK, because kthreads have all their signals
    masked. However there's a few sites where this is causing problems and
    TASK_UNINTERRUPTIBLE should be used, except for that loadavg issue.
    
    This patch adds TASK_NOLOAD which, when combined with
    TASK_UNINTERRUPTIBLE avoids the loadavg accounting.
    
    As most of imagined usage sites are loops where a thread wants to
    idle, waiting for work, a helper TASK_IDLE is introduced.
    
    Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
    Cc: Julian Anastasov <ja@ssi.bg>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: NeilBrown <neilb@suse.de>
    Cc: Oleg Nesterov <oleg@redhat.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

diff --git a/include/linux/sched.h b/include/linux/sched.h
index dd07ac03f82a..7de815c6fa78 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -218,9 +218,10 @@ print_cfs_rq(struct seq_file *m, int cpu, struct cfs_rq *cfs_rq);
 #define TASK_WAKEKILL		128
 #define TASK_WAKING		256
 #define TASK_PARKED		512
-#define TASK_STATE_MAX		1024
+#define TASK_NOLOAD		1024
+#define TASK_STATE_MAX		2048
 
-#define TASK_STATE_TO_CHAR_STR "RSDTtXZxKWP"
+#define TASK_STATE_TO_CHAR_STR "RSDTtXZxKWPN"
 
 extern char ___assert_task_state[1 - 2*!!(
 		sizeof(TASK_STATE_TO_CHAR_STR)-1 != ilog2(TASK_STATE_MAX)+1)];
@@ -230,6 +231,8 @@ extern char ___assert_task_state[1 - 2*!!(
 #define TASK_STOPPED		(TASK_WAKEKILL | __TASK_STOPPED)
 #define TASK_TRACED		(TASK_WAKEKILL | __TASK_TRACED)
 
+#define TASK_IDLE		(TASK_UNINTERRUPTIBLE | TASK_NOLOAD)
+
 /* Convenience macros for the sake of wake_up */
 #define TASK_NORMAL		(TASK_INTERRUPTIBLE | TASK_UNINTERRUPTIBLE)
 #define TASK_ALL		(TASK_NORMAL | __TASK_STOPPED | __TASK_TRACED)
@@ -245,7 +248,8 @@ extern char ___assert_task_state[1 - 2*!!(
 			((task->state & (__TASK_STOPPED | __TASK_TRACED)) != 0)
 #define task_contributes_to_load(task)	\
 				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
-				 (task->flags & PF_FROZEN) == 0)
+				 (task->flags & PF_FROZEN) == 0 && \
+				 (task->state & TASK_NOLOAD) == 0)
 
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 
diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
index 30fedaf3e56a..d57a575fe31f 100644
--- a/include/trace/events/sched.h
+++ b/include/trace/events/sched.h
@@ -147,7 +147,8 @@ TRACE_EVENT(sched_switch,
 		  __print_flags(__entry->prev_state & (TASK_STATE_MAX-1), "|",
 				{ 1, "S"} , { 2, "D" }, { 4, "T" }, { 8, "t" },
 				{ 16, "Z" }, { 32, "X" }, { 64, "x" },
-				{ 128, "K" }, { 256, "W" }, { 512, "P" }) : "R",
+				{ 128, "K" }, { 256, "W" }, { 512, "P" },
+				{ 1024, "N" }) : "R",
 		__entry->prev_state & TASK_STATE_MAX ? "+" : "",
 		__entry->next_comm, __entry->next_pid, __entry->next_prio)
 );
