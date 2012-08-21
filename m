Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758423Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/14] nfsd: remove redundant "port" argument
Date: Tue, 21 Aug 2012 16:57:23 -0400
Message-Id: <1345582652-18476-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

"port" in all these functions is always NFS_PORT.

nfsd can already be run on a nonstandard port using the "nfsd/portlist"
interface.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |    2 +-
 fs/nfsd/nfsd.h   |    2 +-
 fs/nfsd/nfssvc.c |   14 +++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 009632a..89be13c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -406,7 +406,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 			return rv;
 		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(NFS_PORT, newthreads);
+		rv = nfsd_svc(newthreads);
 		if (rv < 0)
 			return rv;
 	} else
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 36243a3..80d5ce4 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -65,7 +65,7 @@ extern const struct seq_operations nfs_exports_op;
 /*
  * Function prototypes.
  */
-int		nfsd_svc(unsigned short port, int nrservs);
+int		nfsd_svc(int nrservs);
 int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 
 int		nfsd_nrthreads(void);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 240473c..dd2b734 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -183,18 +183,18 @@ int nfsd_nrthreads(void)
 	return rv;
 }
 
-static int nfsd_init_socks(int port)
+static int nfsd_init_socks(void)
 {
 	int error;
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", &init_net, PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "udp", &init_net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", &init_net, PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "tcp", &init_net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
@@ -204,7 +204,7 @@ static int nfsd_init_socks(int port)
 
 static bool nfsd_up = false;
 
-static int nfsd_startup(unsigned short port, int nrservs)
+static int nfsd_startup(int nrservs)
 {
 	int ret;
 
@@ -218,7 +218,7 @@ static int nfsd_startup(unsigned short port, int nrservs)
 	ret = nfsd_racache_init(2*nrservs);
 	if (ret)
 		return ret;
-	ret = nfsd_init_socks(port);
+	ret = nfsd_init_socks();
 	if (ret)
 		goto out_racache;
 	ret = lockd_up(&init_net);
@@ -436,7 +436,7 @@ int nfsd_set_nrthreads(int n, int *nthreads)
  * this is the first time nrservs is nonzero.
  */
 int
-nfsd_svc(unsigned short port, int nrservs)
+nfsd_svc(int nrservs)
 {
 	int	error;
 	bool	nfsd_up_before;
@@ -458,7 +458,7 @@ nfsd_svc(unsigned short port, int nrservs)
 
 	nfsd_up_before = nfsd_up;
 
-	error = nfsd_startup(port, nrservs);
+	error = nfsd_startup(nrservs);
 	if (error)
 		goto out_destroy;
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
-- 
1.7.9.5

