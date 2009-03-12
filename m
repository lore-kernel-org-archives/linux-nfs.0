From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/40] SUNRPC: Change svc_create_xprt() to take a @family
	argument
Date: Thu, 12 Mar 2009 12:07:44 -0400
Message-ID: <20090312160743.16019.83412.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:21182 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbZCLQIf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:08:35 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sv_family field is going away.  Pass a protocol family argument to
svc_create_xprt() instead of extracting the family from the passed-in
svc_serv struct.

Again, as this is a listener socket and not an address, we make this
new argument an "int" protocol family, instead of an "sa_family_t."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c                  |    3 ++-
 fs/nfs/callback.c               |    4 ++--
 fs/nfsd/nfsctl.c                |    2 +-
 fs/nfsd/nfssvc.c                |    4 ++--
 include/linux/sunrpc/svc_xprt.h |    3 ++-
 net/sunrpc/svc_xprt.c           |   15 +++++++++------
 6 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 64f1c31..390c559 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -211,7 +211,8 @@ static int create_lockd_listener(struct svc_serv *serv, char *name,
 
 	xprt = svc_find_xprt(serv, name, 0, 0);
 	if (xprt == NULL)
-		return svc_create_xprt(serv, name, port, SVC_SOCK_DEFAULTS);
+		return svc_create_xprt(serv, name, nlmsvc_family,
+					port, SVC_SOCK_DEFAULTS);
 
 	svc_xprt_put(xprt);
 	return 0;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 3e634f2..fb35cab 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -122,8 +122,8 @@ int nfs_callback_up(void)
 	if (!serv)
 		goto out_err;
 
-	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
-			      SVC_SOCK_ANONYMOUS);
+	ret = svc_create_xprt(serv, "tcp", nfs_callback_family,
+				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_err;
 	nfs_callback_tcpport = ret;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 3d93b20..817999e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -941,7 +941,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 			err = nfsd_create_serv();
 			if (!err) {
 				err = svc_create_xprt(nfsd_serv,
-						      transport, port,
+						      transport, PF_INET, port,
 						      SVC_SOCK_ANONYMOUS);
 				if (err == -ENOENT)
 					/* Give a reasonable perror msg for
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 07e4f5d..ab7f249 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -244,7 +244,7 @@ static int nfsd_init_socks(int port)
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", port,
+	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
@@ -253,7 +253,7 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", port,
+	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 167e4b5..72c5e9c 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -71,7 +71,8 @@ int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
-int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
+int	svc_create_xprt(struct svc_serv *, const char *, const int,
+			const unsigned short, int);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c947c93..2819ee0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -161,7 +161,9 @@ EXPORT_SYMBOL_GPL(svc_xprt_init);
 
 static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 					 struct svc_serv *serv,
-					 unsigned short port, int flags)
+					 const int family,
+					 const unsigned short port,
+					 int flags)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
@@ -176,12 +178,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 	struct sockaddr *sap;
 	size_t len;
 
-	switch (serv->sv_family) {
-	case AF_INET:
+	switch (family) {
+	case PF_INET:
 		sap = (struct sockaddr *)&sin;
 		len = sizeof(sin);
 		break;
-	case AF_INET6:
+	case PF_INET6:
 		sap = (struct sockaddr *)&sin6;
 		len = sizeof(sin6);
 		break;
@@ -192,7 +194,8 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 	return xcl->xcl_ops->xpo_create(serv, sap, len, flags);
 }
 
-int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
+int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
+		    const int family, const unsigned short port,
 		    int flags)
 {
 	struct svc_xprt_class *xcl;
@@ -209,7 +212,7 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 			goto err;
 
 		spin_unlock(&svc_xprt_class_lock);
-		newxprt = __svc_xpo_create(xcl, serv, port, flags);
+		newxprt = __svc_xpo_create(xcl, serv, family, port, flags);
 		if (IS_ERR(newxprt)) {
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);

