Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58217 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422690AbbFEPCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:02:05 -0400
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
Subject: [RFC PATCH 12/18] lockd: Convert the central lockd service to kthread_iterant API
Date: Fri,  5 Jun 2015 17:01:11 +0200
Message-Id: <1433516477-5153-13-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new iterant kthread API allows to define a common checkpoint for
freezing, parking, termination, and even signal handling. It will allow
to maintain kthreads more easily and make the operations more reliable.

The kthread function is split into optional init(), func(), destroy() parts
where func() is called in a cycle. The common check point is after
each func() function finishes. See kthread_iterant_fn() for more details.

This patch moves the action associated with the signal into a proper
signal handler.

It removes the obsolete set_freezable() call because iterant kthreads
are freezable by default.

struct kthread_iterant is stored into struct svc_rqst. We have already
stored there the pointer to the related task_struct.

The rest is just shuffling the code from the while cycle into _func().

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 fs/lockd/svc.c             | 80 ++++++++++++++++++++++++----------------------
 include/linux/sunrpc/svc.h |  2 ++
 2 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 55505cbe11af..5b1efe509fcc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -122,58 +122,55 @@ static void restart_grace(void)
 }
 
 /*
- * This is the lockd kernel thread
+ * Lockd kernel thread implementation using the iterant API
+ * We don't terminate until the last NFS mount or NFS daemon
+ * has gone away.
  */
-static int
-lockd(void *vrqstp)
+static void lockd_sigkill(int sig)
 {
-	int		err = 0;
-	struct svc_rqst *rqstp = vrqstp;
-
-	/* try_to_freeze() is called from svc_recv() */
-	set_freezable();
+	restart_grace();
+}
 
+static void lockd_init(void *vrqstp)
+{
 	/* Allow SIGKILL to tell lockd to drop all of its locks */
-	allow_signal(SIGKILL);
+	kthread_sigaction(SIGKILL, lockd_sigkill);
 
 	dprintk("NFS locking service started (ver " LOCKD_VERSION ").\n");
+}
 
-	/*
-	 * The main request loop. We don't terminate until the last
-	 * NFS mount or NFS daemon has gone away.
-	 */
-	while (!kthread_should_stop()) {
-		long timeout = MAX_SCHEDULE_TIMEOUT;
-		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
+static void lockd_func(void *vrqstp)
+{
+	int err = 0;
+	struct svc_rqst *rqstp = vrqstp;
 
-		/* update sv_maxconn if it has changed */
-		rqstp->rq_server->sv_maxconn = nlm_max_connections;
+	long timeout = MAX_SCHEDULE_TIMEOUT;
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
-		if (signalled()) {
-			flush_signals(current);
-			restart_grace();
-			continue;
-		}
+	/* update sv_maxconn if it has changed */
+	rqstp->rq_server->sv_maxconn = nlm_max_connections;
 
-		timeout = nlmsvc_retry_blocked();
+	timeout = nlmsvc_retry_blocked();
 
-		/*
-		 * Find a socket with data available and call its
-		 * recvfrom routine.
-		 */
-		err = svc_recv(rqstp, timeout);
-		if (err == -EAGAIN || err == -EINTR)
-			continue;
-		dprintk("lockd: request from %s\n",
-				svc_print_addr(rqstp, buf, sizeof(buf)));
+	/*
+	 * Find a socket with data available and call its
+	 * recvfrom routine.
+	 */
+	err = svc_recv(rqstp, timeout);
+	if (err == -EAGAIN || err == -EINTR)
+		return;
 
-		svc_process(rqstp);
-	}
-	flush_signals(current);
+	dprintk("lockd: request from %s\n",
+		svc_print_addr(rqstp, buf, sizeof(buf)));
+
+	svc_process(rqstp);
+}
+
+static void lockd_destroy(void *vrqstp)
+{
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-	return 0;
 }
 
 static int create_lockd_listener(struct svc_serv *serv, const char *name,
@@ -301,7 +298,14 @@ static int lockd_start_svc(struct svc_serv *serv)
 	svc_sock_update_bufs(serv);
 	serv->sv_maxconn = nlm_max_connections;
 
-	nlmsvc_task = kthread_create(lockd, nlmsvc_rqst, "%s", serv->sv_name);
+	nlmsvc_rqst->rq_kti.type = 0;
+	nlmsvc_rqst->rq_kti.data = nlmsvc_rqst;
+	nlmsvc_rqst->rq_kti.init = lockd_init;
+	nlmsvc_rqst->rq_kti.func = lockd_func;
+	nlmsvc_rqst->rq_kti.destroy = lockd_destroy;
+
+	nlmsvc_task = kthread_iterant_create(&nlmsvc_rqst->rq_kti,
+					     "%s", serv->sv_name);
 	if (IS_ERR(nlmsvc_task)) {
 		error = PTR_ERR(nlmsvc_task);
 		printk(KERN_WARNING
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index fae6fb947fc8..6275e9b9df9b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/svcauth.h>
+#include <linux/kthread.h>
 #include <linux/wait.h>
 #include <linux/mm.h>
 
@@ -283,6 +284,7 @@ struct svc_rqst {
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
+	struct kthread_iterant  rq_kti;		/* info for iterant kthread */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
 };
-- 
1.8.5.6

