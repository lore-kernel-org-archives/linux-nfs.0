From: Cedric Le Goater <clg@fr.ibm.com>
Subject: kthread: update lockd to use kthread
Date: Fri, 25 Aug 2006 09:25:25 +0200
Message-ID: <44EEA5E5.6000509@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GGW4R-0000ui-3e
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 00:25:39 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GGW4P-0002gt-8j
	for nfs@lists.sourceforge.net; Fri, 25 Aug 2006 00:25:39 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7P7PQdj011464
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 03:25:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k7P7PSFX255792
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 03:25:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k7P7PSAO008341
	for <nfs@lists.sourceforge.net>; Fri, 25 Aug 2006 03:25:28 -0400
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Convert lockd to use kthread rather than kernel_thread, which is deprecated.

Not sure how to test it.

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Cc: Neil Brown <neilb@suse.de>
Cc: nfs@lists.sourceforge.net

---
 fs/lockd/clntlock.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: 2.6.18-rc4-mm2/fs/lockd/clntlock.c
===================================================================
--- 2.6.18-rc4-mm2.orig/fs/lockd/clntlock.c
+++ 2.6.18-rc4-mm2/fs/lockd/clntlock.c
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/smp_lock.h>
+#include <linux/kthread.h>

 #define NLMDBG_FACILITY		NLMDBG_CLIENT

@@ -181,9 +182,12 @@ nlmclnt_recovery(struct nlm_host *host,
 		return;
 	host->h_nsmstate = newstate;
 	if (!host->h_reclaiming++) {
+		struct task_struct* task;
+
 		nlm_get_host(host);
 		__module_get(THIS_MODULE);
-		if (kernel_thread(reclaimer, host, CLONE_KERNEL) < 0)
+		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
+		if (IS_ERR(task))
 			module_put(THIS_MODULE);
 	}
 }
@@ -196,7 +200,6 @@ reclaimer(void *ptr)
 	struct file_lock *fl, *next;
 	u32 nsmstate;

-	daemonize("%s-reclaim", host->h_name);
 	allow_signal(SIGKILL);

 	/* This one ensures that our parent doesn't terminate while the


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
