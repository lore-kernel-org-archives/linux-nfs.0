From: akpm@linux-foundation.org
Subject: [patch 1/1] lockd: convert reclaimer thread to kthread interface
Date: Mon, 01 Dec 2008 14:27:48 -0800
Message-ID: <200812012227.mB1MRmVg016961@imap1.linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	jlayton@redhat.com, bfields@fieldses.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38610 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751268AbYLAW2f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 17:28:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

My understanding is that there is a push to turn the kernel_thread
interface into a non-exported symbol and move all kernel threads to use
the kthread API. This patch changes lockd to use kthread_run to spawn
the reclaimer thread.

I've made the assumption here that the extra module references taken
when we spawn this thread are unnecessary and removed them. I've also
added a KERN_ERR printk that pops if the thread can't be spawned to warn
the admin that the locks won't be reclaimed.

In the future, it would be nice to be able to notify userspace that
locks have been lost (probably by implementing SIGLOST), and adding some
good policies about how long we should reattempt to reclaim the locks.

Finally, I removed a comment about memory leaks that I believe is
obsolete and added a new one to clarify the result of sending a SIGKILL
to the reclaimer thread. As best I can tell, doing so doesn't actually
cause a memory leak.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/lockd/clntlock.c |   21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff -puN fs/lockd/clntlock.c~lockd-convert-reclaimer-thread-to-kthread-interface fs/lockd/clntlock.c
--- a/fs/lockd/clntlock.c~lockd-convert-reclaimer-thread-to-kthread-interface
+++ a/fs/lockd/clntlock.c
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/smp_lock.h>
+#include <linux/kthread.h>
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
@@ -191,11 +192,15 @@ __be32 nlmclnt_grant(const struct sockad
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
@@ -233,7 +237,12 @@ restart:
 	list_for_each_entry_safe(fl, next, &host->h_reclaim, fl_u.nfs_fl.list) {
 		list_del_init(&fl->fl_u.nfs_fl.list);
 
-		/* Why are we leaking memory here? --okir */
+		/*
+		 * sending this thread a SIGKILL will result in any unreclaimed
+		 * locks being removed from the h_granted list. This means that
+		 * the kernel will not attempt to reclaim them again if a new
+		 * reclaimer thread is spawned for this host.
+		 */
 		if (signalled())
 			continue;
 		if (nlmclnt_reclaim(host, fl) != 0)
@@ -261,5 +270,5 @@ restart:
 	nlm_release_host(host);
 	lockd_down();
 	unlock_kernel();
-	module_put_and_exit(0);
+	return 0;
 }
_
