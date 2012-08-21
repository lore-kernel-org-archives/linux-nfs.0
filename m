Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758510Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/14] svcrpc: remove handling of unknown errors from svc_recv
Date: Tue, 21 Aug 2012 16:57:28 -0400
Message-Id: <1345582652-18476-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

svc_recv() returns only -EINTR or -EAGAIN.  If we really want to worry
about the case where it has a bug that causes it to return something
else, we could stick a WARN() in svc_recv.  But it's silly to require
every caller to have all this boilerplate to handle that case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/lockd/svc.c    |   17 ++---------------
 fs/nfs/callback.c |   16 ++--------------
 fs/nfsd/nfssvc.c  |   12 +-----------
 3 files changed, 5 insertions(+), 40 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 31a63f8..e515569 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -126,7 +126,7 @@ static void restart_grace(void)
 static int
 lockd(void *vrqstp)
 {
-	int		err = 0, preverr = 0;
+	int		err = 0;
 	struct svc_rqst *rqstp = vrqstp;
 
 	/* try_to_freeze() is called from svc_recv() */
@@ -165,21 +165,8 @@ lockd(void *vrqstp)
 		 * recvfrom routine.
 		 */
 		err = svc_recv(rqstp, timeout);
-		if (err == -EAGAIN || err == -EINTR) {
-			preverr = err;
+		if (err == -EAGAIN || err == -EINTR)
 			continue;
-		}
-		if (err < 0) {
-			if (err != preverr) {
-				printk(KERN_WARNING "%s: unexpected error "
-					"from svc_recv (%d)\n", __func__, err);
-				preverr = err;
-			}
-			schedule_timeout_interruptible(HZ);
-			continue;
-		}
-		preverr = err;
-
 		dprintk("lockd: request from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
 
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 4c8459e..d9e2a18 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -45,7 +45,7 @@ unsigned short nfs_callback_tcpport6;
 static int
 nfs4_callback_svc(void *vrqstp)
 {
-	int err, preverr = 0;
+	int err;
 	struct svc_rqst *rqstp = vrqstp;
 
 	set_freezable();
@@ -55,20 +55,8 @@ nfs4_callback_svc(void *vrqstp)
 		 * Listen for a request on the socket
 		 */
 		err = svc_recv(rqstp, MAX_SCHEDULE_TIMEOUT);
-		if (err == -EAGAIN || err == -EINTR) {
-			preverr = err;
+		if (err == -EAGAIN || err == -EINTR)
 			continue;
-		}
-		if (err < 0) {
-			if (err != preverr) {
-				printk(KERN_WARNING "NFS: %s: unexpected error "
-					"from svc_recv (%d)\n", __func__, err);
-				preverr = err;
-			}
-			schedule_timeout_uninterruptible(HZ);
-			continue;
-		}
-		preverr = err;
 		svc_process(rqstp);
 	}
 	return 0;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index dd2b734..2013aa00 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -487,7 +487,7 @@ static int
 nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
-	int err, preverr = 0;
+	int err;
 
 	/* Lock module and set up kernel thread */
 	mutex_lock(&nfsd_mutex);
@@ -534,16 +534,6 @@ nfsd(void *vrqstp)
 			;
 		if (err == -EINTR)
 			break;
-		else if (err < 0) {
-			if (err != preverr) {
-				printk(KERN_WARNING "%s: unexpected error "
-					"from svc_recv (%d)\n", __func__, -err);
-				preverr = err;
-			}
-			schedule_timeout_uninterruptible(HZ);
-			continue;
-		}
-
 		validate_process_creds();
 		svc_process(rqstp);
 		validate_process_creds();
-- 
1.7.9.5

