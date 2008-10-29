From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] lockd: convert reclaimer thread to kthread interface
Date: Wed, 29 Oct 2008 07:15:45 -0400
Message-ID: <1225278945-15407-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	hch@infradead.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58331 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbYJ2LPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 07:15:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My understanding is that there is a push to turn the kernel_thread
interface into a non-exported symbol and move all kernel threads to use
the kthread API. This patch changes lockd to use kthread_run to spawn
the reclaimer thread.

I've made the assumption here that the extra module references taken
when we spawn this thread are unnecessary and removed them. I've also
added a KERN_ERR printk that pops if the thread can't be spawned to warn
the admin that the locks won't be reclaimed.

I consider this patch 2.6.29 material.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/clntlock.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 8307dd6..fcc2378 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/smp_lock.h>
+#include <linux/kthread.h>
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
@@ -191,11 +192,15 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 void
 nlmclnt_recovery(struct nlm_host *host)
 {
+	struct task_struct *task;
+
 	if (!host->h_reclaiming++) {
 		nlm_get_host(host);
-		__module_get(THIS_MODULE);
-		if (kernel_thread(reclaimer, host, CLONE_FS | CLONE_FILES) < 0)
-			module_put(THIS_MODULE);
+		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
+		if (IS_ERR(task))
+			printk(KERN_ERR "lockd: unable to spawn reclaimer "
+				"thread. Locks for %s won't be reclaimed! "
+				"(%ld)\n", host->h_name, PTR_ERR(task));
 	}
 }
 
@@ -207,7 +212,6 @@ reclaimer(void *ptr)
 	struct file_lock *fl, *next;
 	u32 nsmstate;
 
-	daemonize("%s-reclaim", host->h_name);
 	allow_signal(SIGKILL);
 
 	down_write(&host->h_rwsem);
@@ -261,5 +265,5 @@ restart:
 	nlm_release_host(host);
 	lockd_down();
 	unlock_kernel();
-	module_put_and_exit(0);
+	return 0;
 }
-- 
1.5.5.1

