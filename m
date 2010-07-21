From: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] nfsd: just keep single lockd reference for nfsd
Date: Wed, 21 Jul 2010 19:26:49 -0400
Message-ID: <1279754811-8328-5-git-send-email-bfields@redhat.com>
References: <20100721232432.GA6689@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916Ab0GUX1x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:27:53 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Right now, nfsd keeps a lockd reference for each socket that it has
open. This is unnecessary and complicates the error handling on
startup and shutdown. Change it to just do a lockd_up when starting
the first nfsd thread just do a single lockd_down when taking down the
last nfsd thread. Because of the strange way the sv_count is handled
this requires an extra flag to tell whether the nfsd_serv holds a
reference for lockd or not.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |   10 ----------
 fs/nfsd/nfssvc.c |   25 ++++++++++++++-----------
 2 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9e8645a..b1c5be8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -949,15 +949,8 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0)
 		return err;
 
-	err = lockd_up();
-	if (err != 0) {
-		svc_destroy(nfsd_serv);
-		return err;
-	}
-
 	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err < 0) {
-		lockd_down();
 		svc_destroy(nfsd_serv);
 		return err;
 	}
@@ -982,9 +975,6 @@ static ssize_t __write_ports_delfd(char *buf)
 	if (nfsd_serv != NULL)
 		len = svc_sock_names(nfsd_serv, buf,
 					SIMPLE_TRANSACTION_LIMIT, toclose);
-	if (len >= 0)
-		lockd_down();
-
 	kfree(toclose);
 	return len;
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a631ea6..8a556ff 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -186,8 +186,16 @@ static int nfsd_startup(unsigned short port, int nrservs)
 {
 	int ret;
 
+	ret = lockd_up();
+	if (ret)
+		return ret;
 	ret = nfs4_state_start();
+	if (ret)
+		goto out_lockd;
 	nfsd_up = true;
+	return 0;
+out_lockd:
+	lockd_down();
 	return ret;
 }
 
@@ -201,6 +209,7 @@ static void nfsd_shutdown(void)
 	 */
 	if (!nfsd_up)
 		return;
+	lockd_down();
 	nfs4_state_shutdown();
 	nfsd_up = false;
 }
@@ -208,9 +217,6 @@ static void nfsd_shutdown(void)
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
-	struct svc_xprt *xprt;
-	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
-		lockd_down();
 	nfsd_serv = NULL;
 	nfsd_racache_shutdown();
 	nfsd_shutdown();
@@ -310,19 +316,11 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
-	error = lockd_up();
-	if (error < 0)
-		return error;
-
 	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = lockd_up();
-	if (error < 0)
-		return error;
-
 	return 0;
 }
 
@@ -400,6 +398,11 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 	return err;
 }
 
+/*
+ * Adjust the number of threads and return the new number of threads.
+ * This is also the function that starts the server if necessary, if
+ * this is the first time nrservs is nonzero.
+ */
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
-- 
1.7.0.4

