From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/4] knfsd: remove special handling for SIGHUP
Date: Wed,  4 Jun 2008 11:03:14 -0400
Message-ID: <1212591796-22144-3-git-send-email-jlayton@redhat.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: gnb@melbourne.sgi.com
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1212591796-22144-2-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
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
index 040b3c2..582acb1 100644
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
@@ -167,7 +162,6 @@ int nfsd_nrthreads(void)
 		return nfsd_serv->sv_nrthreads;
 }
 
-static int killsig;	/* signal that was used to kill last nfsd */
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
@@ -178,11 +172,9 @@ static void nfsd_last_thread(struct svc_serv *serv)
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
@@ -234,10 +226,9 @@ int nfsd_create_serv(void)
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
 
@@ -482,17 +473,9 @@ nfsd(struct svc_rqst *rqstp)
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
