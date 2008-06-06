From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/5] knfsd: remove special handling for SIGHUP
Date: Fri,  6 Jun 2008 11:12:49 -0400
Message-ID: <1212765171-26042-4-git-send-email-jlayton@redhat.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
 <1212765171-26042-2-git-send-email-jlayton@redhat.com>
 <1212765171-26042-3-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423AbYFFPM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Jun 2008 11:12:56 -0400
In-Reply-To: <1212765171-26042-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The special handling for SIGHUP in knfsd is a holdover from much
earlier versions of Linux where reloading the export table was
more expensive. That facility is not really needed anymore and
to my knowledge, is seldom-used.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   33 ++++++++-------------------------
 1 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 929af23..6339cb7 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -44,11 +44,6 @@
  * when not handling a request. i.e. when waiting
  */
 #define SHUTDOWN_SIGS	(sigmask(SIGKILL) | sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT))
-/* if the last thread dies with SIGHUP, then the exports table is
- * left unchanged ( like 2.4-{0-9} ).  Any other signal will clear
- * the exports table (like 2.2).
- */
-#define	SIG_NOCLEAN	SIGHUP
 
 extern struct svc_program	nfsd_program;
 static void			nfsd(struct svc_rqst *rqstp);
@@ -175,7 +170,6 @@ int nfsd_nrthreads(void)
 		return nfsd_serv->sv_nrthreads;
 }
 
-static int killsig;	/* signal that was used to kill last nfsd */
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
@@ -186,11 +180,9 @@ static void nfsd_last_thread(struct svc_serv *serv)
 	nfsd_racache_shutdown();
 	nfs4_state_shutdown();
 
-	printk(KERN_WARNING "nfsd: last server has exited\n");
-	if (killsig != SIG_NOCLEAN) {
-		printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
-		nfsd_export_flush();
-	}
+	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
+			    "cache\n");
+	nfsd_export_flush();
 }
 
 void nfsd_reset_versions(void)
@@ -242,10 +234,9 @@ int nfsd_create_serv(void)
 	}
 
 	atomic_set(&nfsd_busy, 0);
-	nfsd_serv = svc_create_pooled(&nfsd_program,
-				      nfsd_max_blksize,
-				      nfsd_last_thread,
-				      nfsd, SIG_NOCLEAN, THIS_MODULE);
+	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
+				      nfsd_last_thread, nfsd, SIGINT,
+				      THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
 
@@ -490,17 +481,9 @@ nfsd(struct svc_rqst *rqstp)
 		atomic_dec(&nfsd_busy);
 	}
 
-	if (err != -EINTR) {
+	if (err != -EINTR)
 		printk(KERN_WARNING "nfsd: terminating on error %d\n", -err);
-	} else {
-		unsigned int	signo;
-
-		for (signo = 1; signo <= _NSIG; signo++)
-			if (sigismember(&current->pending.signal, signo) &&
-			    !sigismember(&current->blocked, signo))
-				break;
-		killsig = signo;
-	}
+
 	/* Clear signals before calling svc_exit_thread() */
 	flush_signals(current);
 
-- 
1.5.3.6

