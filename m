From: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] nfsd: move more into nfsd_startup()
Date: Wed, 21 Jul 2010 19:26:50 -0400
Message-ID: <1279754811-8328-6-git-send-email-bfields@redhat.com>
References: <20100721232432.GA6689@fieldses.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46652 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab0GUX1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:27:55 -0400
In-Reply-To: <20100721232432.GA6689@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is just cleanup--it's harmless to call nfsd_rachache_init,
nfsd_init_socks, and nfsd_reset_versions more than once.  But there's no
point to it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |   69 +++++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 8a556ff..62a6c44 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -180,22 +180,54 @@ int nfsd_nrthreads(void)
 	return rv;
 }
 
+static int nfsd_init_socks(int port)
+{
+	int error;
+	if (!list_empty(&nfsd_serv->sv_permsocks))
+		return 0;
+
+	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
+					SVC_SOCK_DEFAULTS);
+	if (error < 0)
+		return error;
+
+	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
+					SVC_SOCK_DEFAULTS);
+	if (error < 0)
+		return error;
+
+	return 0;
+}
+
 static bool nfsd_up = false;
 
 static int nfsd_startup(unsigned short port, int nrservs)
 {
 	int ret;
-
+	/*
+	 * Readahead param cache - will no-op if it already exists.
+	 * (Note therefore results will be suboptimal if number of
+	 * threads is modified after nfsd start.)
+	 */
+	ret = nfsd_racache_init(2*nrservs);
+	if (ret)
+		return ret;
+	ret = nfsd_init_socks(port);
+	if (ret)
+		goto out_racache;
 	ret = lockd_up();
 	if (ret)
 		return ret;
 	ret = nfs4_state_start();
 	if (ret)
 		goto out_lockd;
+	nfsd_reset_versions();
 	nfsd_up = true;
 	return 0;
 out_lockd:
 	lockd_down();
+out_racache:
+	nfsd_racache_shutdown();
 	return ret;
 }
 
@@ -209,8 +241,9 @@ static void nfsd_shutdown(void)
 	 */
 	if (!nfsd_up)
 		return;
-	lockd_down();
 	nfs4_state_shutdown();
+	lockd_down();
+	nfsd_racache_shutdown();
 	nfsd_up = false;
 }
 
@@ -218,7 +251,6 @@ static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
 	nfsd_serv = NULL;
-	nfsd_racache_shutdown();
 	nfsd_shutdown();
 
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
@@ -305,25 +337,6 @@ int nfsd_create_serv(void)
 	return err;
 }
 
-static int nfsd_init_socks(int port)
-{
-	int error;
-	if (!list_empty(&nfsd_serv->sv_permsocks))
-		return 0;
-
-	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
-	if (error < 0)
-		return error;
-
-	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
-	if (error < 0)
-		return error;
-
-	return 0;
-}
-
 int nfsd_nrpools(void)
 {
 	if (nfsd_serv == NULL)
@@ -419,11 +432,6 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	/* Readahead param cache - will no-op if it already exists */
-	error =	nfsd_racache_init(2*nrservs);
-	if (error<0)
-		goto out;
-
 	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
 
 	if (first_thread) {
@@ -431,16 +439,9 @@ nfsd_svc(unsigned short port, int nrservs)
 		if (error)
 			goto out;
 	}
-
-	nfsd_reset_versions();
-
 	error = nfsd_create_serv();
 	if (error)
 		goto out_shutdown;
-	error = nfsd_init_socks(port);
-	if (error)
-		goto out_destroy;
-
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
 	if (error == 0)
 		/* We are holding a reference to nfsd_serv which
-- 
1.7.0.4

