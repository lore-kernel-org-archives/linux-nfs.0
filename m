From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] [RFC] knfsd: remove signal defines and extraneous variables
Date: Sat, 17 May 2008 22:35:14 -0400
Message-ID: <1211078114-18384-4-git-send-email-jlayton@redhat.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
 <1211078114-18384-2-git-send-email-jlayton@redhat.com>
 <1211078114-18384-3-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbYERCfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 May 2008 22:35:17 -0400
In-Reply-To: <1211078114-18384-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are some defines for signals delivered to knfsd which are no
longer used with the new kthread-based server.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   21 ++-------------------
 1 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d4d4be9..fb70660 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -37,20 +37,6 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
-/* these signals will be delivered to an nfsd thread 
- * when handling a request
- */
-#define ALLOWED_SIGS	(sigmask(SIGKILL))
-/* these signals will be delivered to an nfsd thread
- * when not handling a request. i.e. when waiting
- */
-#define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
-/* if the last thread dies with SIGHUP, then the exports table is
- * left unchanged ( like 2.4-{0-9} ).  Any other signal will clear
- * the exports table (like 2.2).
- */
-#define	SIG_NOCLEAN	SIGHUP
-
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 struct timeval			nfssvc_boot;
@@ -152,7 +138,6 @@ int nfsd_nrthreads(void)
 		return nfsd_serv->sv_nrthreads;
 }
 
-static int killsig;	/* signal that was used to kill last nfsd */
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
@@ -164,10 +149,8 @@ static void nfsd_last_thread(struct svc_serv *serv)
 	nfs4_state_shutdown();
 
 	printk(KERN_WARNING "nfsd: last server has exited\n");
-	if (killsig != SIG_NOCLEAN) {
-		printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
-		nfsd_export_flush();
-	}
+	printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
+	nfsd_export_flush();
 }
 
 void nfsd_reset_versions(void)
-- 
1.5.3.6

