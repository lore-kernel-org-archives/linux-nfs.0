Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46575 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab0I1PQZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 11:16:25 -0400
Message-ID: <4CA206BE.3030702@parallels.com>
Date: Tue, 28 Sep 2010 19:16:14 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] sunrpc: Add net argument to svc_create_xprt
References: <4CA20651.4070605@parallels.com>
In-Reply-To: <4CA20651.4070605@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/lockd/svc.c                  |    2 +-
 fs/nfs/callback.c               |    4 ++--
 fs/nfsd/nfsctl.c                |    4 ++--
 fs/nfsd/nfssvc.c                |    5 +++--
 include/linux/sunrpc/svc_xprt.h |    4 ++--
 net/sunrpc/svc_xprt.c           |    4 ++--
 6 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f1bacf1..b13aabc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -206,7 +206,7 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
 
 	xprt = svc_find_xprt(serv, name, family, 0);
 	if (xprt == NULL)
-		return svc_create_xprt(serv, name, family, port,
+		return svc_create_xprt(serv, name, &init_net, family, port,
 						SVC_SOCK_DEFAULTS);
 	svc_xprt_put(xprt);
 	return 0;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e17b49e..aeec017 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -109,7 +109,7 @@ nfs4_callback_up(struct svc_serv *serv)
 {
 	int ret;
 
-	ret = svc_create_xprt(serv, "tcp", PF_INET,
+	ret = svc_create_xprt(serv, "tcp", &init_net, PF_INET,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_err;
@@ -117,7 +117,7 @@ nfs4_callback_up(struct svc_serv *serv)
 	dprintk("NFS: Callback listener port = %u (af %u)\n",
 			nfs_callback_tcpport, PF_INET);
 
-	ret = svc_create_xprt(serv, "tcp", PF_INET6,
+	ret = svc_create_xprt(serv, "tcp", &init_net, PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
 		nfs_callback_tcpport6 = ret;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b6e192d..b81da24 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1015,12 +1015,12 @@ static ssize_t __write_ports_addxprt(char *buf)
 	if (err != 0)
 		return err;
 
-	err = svc_create_xprt(nfsd_serv, transport,
+	err = svc_create_xprt(nfsd_serv, transport, &init_net,
 				PF_INET, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0)
 		goto out_err;
 
-	err = svc_create_xprt(nfsd_serv, transport,
+	err = svc_create_xprt(nfsd_serv, transport, &init_net,
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_close;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index e2c4346..2bae1d8 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -16,6 +16,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
+#include <net/net_namespace.h>
 #include "nfsd.h"
 #include "cache.h"
 #include "vfs.h"
@@ -186,12 +187,12 @@ static int nfsd_init_socks(int port)
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "udp", &init_net, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
+	error = svc_create_xprt(nfsd_serv, "tcp", &init_net, PF_INET, port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index e50e3ec..646263c 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -74,8 +74,8 @@ int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
-int	svc_create_xprt(struct svc_serv *, const char *, const int,
-			const unsigned short, int);
+int	svc_create_xprt(struct svc_serv *, const char *, struct net *,
+			const int, const unsigned short, int);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_received(struct svc_xprt *);
 void	svc_xprt_put(struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f7e8915..d80789a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -204,8 +204,8 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 }
 
 int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
-		    const int family, const unsigned short port,
-		    int flags)
+		    struct net *net, const int family,
+		    const unsigned short port, int flags)
 {
 	struct svc_xprt_class *xcl;
 
-- 
1.5.5.6

