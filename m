Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48891 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753441AbZHOQBF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Aug 2009 12:01:05 -0400
Date: Sun, 16 Aug 2009 00:54:41 +0900
From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: linux-nfs@vger.kernel.org, neilb@suse.de
Cc: mandel59@gmail.com, yamahata@valinux.co.jp, yoshfuji@linux-ipv6.org
Subject: [PATCH] knfsd: Replace lock_kernel with a mutex in nfsd pool stats.
Message-Id: <20090816005441.2c923280.yoshfuji@linux-ipv6.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ryusei Yamaguchi <mandel59@gmail.com>
Subject: [PATCH] knfsd: Replace lock_kernel with a mutex in nfsd pool stats.

lock_kernel() in knfsd was replaced with a mutex. The later
commit 03cf6c9f49a8fea953d38648d016e3f46e814991 ("knfsd:
add file to export stats about nfsd pools") did not follow
that change. This patch fixes the issue.

Signed-off-by: Ryusei Yamaguchi <mandel59@gmail.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
 fs/nfsd/nfsctl.c      |    3 ++-
 fs/nfsd/nfssvc.c      |   23 +++++++++++++++++++++--
 net/sunrpc/svc_xprt.c |   11 -----------
 3 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6d08475..6b1b917 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -173,12 +173,13 @@ static const struct file_operations exports_operations = {
 };
 
 extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
+extern int nfsd_pool_stats_release(struct inode *inode, struct file *file);
 
 static struct file_operations pool_stats_operations = {
 	.open		= nfsd_pool_stats_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release,
+	.release	= nfsd_pool_stats_release,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 492c79b..32e64fc 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -34,6 +34,7 @@
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
+#include <linux/seq_file.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
@@ -605,7 +606,25 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 
 int nfsd_pool_stats_open(struct inode *inode, struct file *file)
 {
-	if (nfsd_serv == NULL)
+	int ret;
+	mutex_lock(&nfsd_mutex);
+	if (nfsd_serv == NULL) {
+		mutex_unlock(&nfsd_mutex);
 		return -ENODEV;
-	return svc_pool_stats_open(nfsd_serv, file);
+	}
+	/* bump up the psudo refcount while traversing */
+	svc_get(nfsd_serv);
+	ret = svc_pool_stats_open(nfsd_serv, file);
+	mutex_unlock(&nfsd_mutex);
+	return ret;
+}
+
+int nfsd_pool_stats_release(struct inode *inode, struct file *file)
+{
+	int ret = seq_release(inode, file);
+	mutex_lock(&nfsd_mutex);
+	/* this function really, really should have been called svc_put() */
+	svc_destroy(nfsd_serv);
+	mutex_unlock(&nfsd_mutex);
+	return ret;
 }
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 27d4433..dcd2d1e 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1166,11 +1166,6 @@ static void *svc_pool_stats_start(struct seq_file *m, loff_t *pos)
 
 	dprintk("svc_pool_stats_start, *pidx=%u\n", pidx);
 
-	lock_kernel();
-	/* bump up the pseudo refcount while traversing */
-	svc_get(serv);
-	unlock_kernel();
-
 	if (!pidx)
 		return SEQ_START_TOKEN;
 	return (pidx > serv->sv_nrpools ? NULL : &serv->sv_pools[pidx-1]);
@@ -1198,12 +1193,6 @@ static void *svc_pool_stats_next(struct seq_file *m, void *p, loff_t *pos)
 
 static void svc_pool_stats_stop(struct seq_file *m, void *p)
 {
-	struct svc_serv *serv = m->private;
-
-	lock_kernel();
-	/* this function really, really should have been called svc_put() */
-	svc_destroy(serv);
-	unlock_kernel();
 }
 
 static int svc_pool_stats_show(struct seq_file *m, void *p)
-- 
1.4.4.4


--yoshfuji
