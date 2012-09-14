Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19830 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758200Ab2INIZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 04:25:54 -0400
Subject: [PATCH 1/2] NFSd: introduce nfsd_destroy() helper
To: stable@vger.kernel.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, viro@zeniv.linux.org.uk,
        jbottomley@parallels.com
Date: Fri, 14 Sep 2012 12:25:45 +0400
Message-ID: <20120914082522.14353.59479.stgit@localhost6.localdomain6>
In-Reply-To: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
References: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

upstream commit 19f7e2ca44dfc3c1b3f499fc46801f98d403500f

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |    8 ++------
 fs/nfsd/nfsd.h   |    9 +++++++++
 fs/nfsd/nfssvc.c |   14 +++-----------
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c55298e..fa49cff 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -673,9 +673,7 @@ static ssize_t __write_ports_addfd(char *buf)
 
 	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err < 0) {
-		if (nfsd_serv->sv_nrthreads == 1)
-			svc_shutdown_net(nfsd_serv, net);
-		svc_destroy(nfsd_serv);
+		nfsd_destroy(net);
 		return err;
 	}
 
@@ -744,9 +742,7 @@ out_close:
 		svc_xprt_put(xprt);
 	}
 out_err:
-	if (nfsd_serv->sv_nrthreads == 1)
-		svc_shutdown_net(nfsd_serv, net);
-	svc_destroy(nfsd_serv);
+	nfsd_destroy(net);
 	return err;
 }
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 1671429..e3339ca 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -73,6 +73,15 @@ int		nfsd_nrpools(void);
 int		nfsd_get_nrthreads(int n, int *);
 int		nfsd_set_nrthreads(int n, int *);
 
+static inline void nfsd_destroy(struct net *net)
+{
+	int destroy = (nfsd_serv->sv_nrthreads == 1);
+
+	if (destroy)
+		svc_shutdown_net(nfsd_serv, net);
+	svc_destroy(nfsd_serv);
+}
+
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
 extern struct svc_version nfsd_acl_version2;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d63c097..e866af4 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -429,11 +429,7 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 		if (err)
 			break;
 	}
-
-	if (nfsd_serv->sv_nrthreads == 1)
-		svc_shutdown_net(nfsd_serv, net);
-	svc_destroy(nfsd_serv);
-
+	nfsd_destroy(net);
 	return err;
 }
 
@@ -480,9 +476,7 @@ out_shutdown:
 	if (error < 0 && !nfsd_up_before)
 		nfsd_shutdown();
 out_destroy:
-	if (nfsd_serv->sv_nrthreads == 1)
-		svc_shutdown_net(nfsd_serv, net);
-	svc_destroy(nfsd_serv);		/* Release server */
+	nfsd_destroy(net);		/* Release server */
 out:
 	mutex_unlock(&nfsd_mutex);
 	return error;
@@ -684,9 +678,7 @@ int nfsd_pool_stats_release(struct inode *inode, struct file *file)
 
 	mutex_lock(&nfsd_mutex);
 	/* this function really, really should have been called svc_put() */
-	if (nfsd_serv->sv_nrthreads == 1)
-		svc_shutdown_net(nfsd_serv, net);
-	svc_destroy(nfsd_serv);
+	nfsd_destroy(net);
 	mutex_unlock(&nfsd_mutex);
 	return ret;
 }

