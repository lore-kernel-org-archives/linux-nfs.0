Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:23727 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423191Ab2LFLWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:51 -0500
Subject: [PATCH 4/8] nfsd: make NFSd service structure allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:24 +0300
Message-ID: <20121206112324.29559.17042.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch makes main step in NFSd containerisation.
There could be different approaches in how to make NFSd able to handle
incomming RPC request from different network namespaces.

But there are two main ideas:
1) Share NFSd kthreads betwween all network namespaces.
2) Create separated pool of threads for each namespace.

While first approach looks more flexible, second one is simplier and non-racy.
This patch implements second one.
To make it possible to allocate separated pool of threads, we have to make it
possible to allocate separated NFSd service structure per net.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    2 +
 fs/nfsd/nfs4state.c |   14 +++++---
 fs/nfsd/nfsctl.c    |   63 +++++++++++++++++++++--------------
 fs/nfsd/nfsd.h      |   18 ++--------
 fs/nfsd/nfssvc.c    |   91 ++++++++++++++++++++++++++++++++-------------------
 5 files changed, 110 insertions(+), 78 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 8acfb17..abfc97c 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -99,6 +99,8 @@ struct nfsd_net {
 	 * Time of server startup
 	 */
 	struct timeval nfssvc_boot;
+
+	struct svc_serv *nfsd_serv;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b1aa577..39605c1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -743,9 +743,12 @@ out_free:
 	return NULL;
 }
 
-static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4_channel_attrs *req, int numslots, int slotsize)
+static void init_forechannel_attrs(struct nfsd4_channel_attrs *new,
+				   struct nfsd4_channel_attrs *req,
+				   int numslots, int slotsize,
+				   struct nfsd_net *nn)
 {
-	u32 maxrpc = nfsd_serv->sv_max_mesg;
+	u32 maxrpc = nn->nfsd_serv->sv_max_mesg;
 
 	new->maxreqs = numslots;
 	new->maxresp_cached = min_t(u32, req->maxresp_cached,
@@ -883,7 +886,8 @@ void nfsd4_put_session(struct nfsd4_session *ses)
 	spin_unlock(&nn->client_lock);
 }
 
-static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
+static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan,
+					   struct nfsd_net *nn)
 {
 	struct nfsd4_session *new;
 	int numslots, slotsize;
@@ -904,7 +908,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
 		return NULL;
 	}
-	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize);
+	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize, nn);
 	return new;
 }
 
@@ -1776,7 +1780,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		return nfserr_inval;
 	if (check_forechannel_attrs(cr_ses->fore_channel))
 		return nfserr_toosmall;
-	new = alloc_session(&cr_ses->fore_channel);
+	new = alloc_session(&cr_ses->fore_channel, nn);
 	if (!new)
 		return nfserr_jukebox;
 	status = nfserr_jukebox;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 8536100..7493428 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -409,7 +409,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		if (rv < 0)
 			return rv;
 	} else
-		rv = nfsd_nrthreads();
+		rv = nfsd_nrthreads(net);
 
 	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n", rv);
 }
@@ -450,7 +450,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
-	npools = nfsd_nrpools();
+	npools = nfsd_nrpools(net);
 	if (npools == 0) {
 		/*
 		 * NFS is shut down.  The admin can start it by
@@ -483,7 +483,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 			goto out_free;
 	}
 
-	rv = nfsd_get_nrthreads(npools, nthreads);
+	rv = nfsd_get_nrthreads(npools, nthreads, net);
 	if (rv)
 		goto out_free;
 
@@ -510,11 +510,13 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
+	struct net *net = &init_net;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (size>0) {
-		if (nfsd_serv)
+		if (nn->nfsd_serv)
 			/* Cannot change versions without updating
-			 * nfsd_serv->sv_xdrsize, and reallocing
+			 * nn->nfsd_serv->sv_xdrsize, and reallocing
 			 * rq_argp and rq_resp
 			 */
 			return -EBUSY;
@@ -645,11 +647,13 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
  * Zero-length write.  Return a list of NFSD's current listener
  * transports.
  */
-static ssize_t __write_ports_names(char *buf)
+static ssize_t __write_ports_names(char *buf, struct net *net)
 {
-	if (nfsd_serv == NULL)
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (nn->nfsd_serv == NULL)
 		return 0;
-	return svc_xprt_names(nfsd_serv, buf, SIMPLE_TRANSACTION_LIMIT);
+	return svc_xprt_names(nn->nfsd_serv, buf, SIMPLE_TRANSACTION_LIMIT);
 }
 
 /*
@@ -661,6 +665,7 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
 {
 	char *mesg = buf;
 	int fd, err;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	err = get_int(&mesg, &fd);
 	if (err != 0 || fd < 0)
@@ -670,14 +675,14 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
 	if (err != 0)
 		return err;
 
-	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
+	err = svc_addsock(nn->nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err < 0) {
 		nfsd_destroy(net);
 		return err;
 	}
 
 	/* Decrease the count, but don't shut down the service */
-	nfsd_serv->sv_nrthreads--;
+	nn->nfsd_serv->sv_nrthreads--;
 	return err;
 }
 
@@ -690,6 +695,7 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net)
 	char transport[16];
 	struct svc_xprt *xprt;
 	int port, err;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (sscanf(buf, "%15s %5u", transport, &port) != 2)
 		return -EINVAL;
@@ -701,21 +707,21 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net)
 	if (err != 0)
 		return err;
 
-	err = svc_create_xprt(nfsd_serv, transport, net,
+	err = svc_create_xprt(nn->nfsd_serv, transport, net,
 				PF_INET, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0)
 		goto out_err;
 
-	err = svc_create_xprt(nfsd_serv, transport, net,
+	err = svc_create_xprt(nn->nfsd_serv, transport, net,
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_close;
 
 	/* Decrease the count, but don't shut down the service */
-	nfsd_serv->sv_nrthreads--;
+	nn->nfsd_serv->sv_nrthreads--;
 	return 0;
 out_close:
-	xprt = svc_find_xprt(nfsd_serv, transport, net, PF_INET, port);
+	xprt = svc_find_xprt(nn->nfsd_serv, transport, net, PF_INET, port);
 	if (xprt != NULL) {
 		svc_close_xprt(xprt);
 		svc_xprt_put(xprt);
@@ -729,7 +735,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
 			     struct net *net)
 {
 	if (size == 0)
-		return __write_ports_names(buf);
+		return __write_ports_names(buf, net);
 
 	if (isdigit(buf[0]))
 		return __write_ports_addfd(buf, net);
@@ -821,6 +827,9 @@ int nfsd_max_blksize;
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
+	struct net *net = &init_net;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
 	if (size > 0) {
 		int bsize;
 		int rv = get_int(&mesg, &bsize);
@@ -835,7 +844,7 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 			bsize = NFSSVC_MAXBLKSIZE;
 		bsize &= ~(1024-1);
 		mutex_lock(&nfsd_mutex);
-		if (nfsd_serv) {
+		if (nn->nfsd_serv) {
 			mutex_unlock(&nfsd_mutex);
 			return -EBUSY;
 		}
@@ -848,13 +857,14 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 }
 
 #ifdef CONFIG_NFSD_V4
-static ssize_t __nfsd4_write_time(struct file *file, char *buf, size_t size, time_t *time)
+static ssize_t __nfsd4_write_time(struct file *file, char *buf, size_t size,
+				  time_t *time, struct nfsd_net *nn)
 {
 	char *mesg = buf;
 	int rv, i;
 
 	if (size > 0) {
-		if (nfsd_serv)
+		if (nn->nfsd_serv)
 			return -EBUSY;
 		rv = get_int(&mesg, &i);
 		if (rv)
@@ -879,12 +889,13 @@ static ssize_t __nfsd4_write_time(struct file *file, char *buf, size_t size, tim
 	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n", *time);
 }
 
-static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size, time_t *time)
+static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size,
+				time_t *time, struct nfsd_net *nn)
 {
 	ssize_t rv;
 
 	mutex_lock(&nfsd_mutex);
-	rv = __nfsd4_write_time(file, buf, size, time);
+	rv = __nfsd4_write_time(file, buf, size, time, nn);
 	mutex_unlock(&nfsd_mutex);
 	return rv;
 }
@@ -913,7 +924,7 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size, time_
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
 	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
-	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease);
+	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease, nn);
 }
 
 /**
@@ -929,17 +940,18 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
 {
 	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
-	return nfsd4_write_time(file, buf, size, &nn->nfsd4_grace);
+	return nfsd4_write_time(file, buf, size, &nn->nfsd4_grace, nn);
 }
 
-static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
+static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size,
+				   struct nfsd_net *nn)
 {
 	char *mesg = buf;
 	char *recdir;
 	int len, status;
 
 	if (size > 0) {
-		if (nfsd_serv)
+		if (nn->nfsd_serv)
 			return -EBUSY;
 		if (size > PATH_MAX || buf[size-1] != '\n')
 			return -EINVAL;
@@ -983,9 +995,10 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	mutex_lock(&nfsd_mutex);
-	rv = __write_recoverydir(file, buf, size);
+	rv = __write_recoverydir(file, buf, size, nn);
 	mutex_unlock(&nfsd_mutex);
 	return rv;
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 71ba60d..de23db2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -55,7 +55,6 @@ extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
 extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
-extern struct svc_serv		*nfsd_serv;
 extern spinlock_t		nfsd_drc_lock;
 extern unsigned int		nfsd_drc_max_mem;
 extern unsigned int		nfsd_drc_mem_used;
@@ -68,23 +67,14 @@ extern const struct seq_operations nfs_exports_op;
 int		nfsd_svc(int nrservs, struct net *net);
 int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 
-int		nfsd_nrthreads(void);
-int		nfsd_nrpools(void);
-int		nfsd_get_nrthreads(int n, int *);
+int		nfsd_nrthreads(struct net *);
+int		nfsd_nrpools(struct net *);
+int		nfsd_get_nrthreads(int n, int *, struct net *);
 int		nfsd_set_nrthreads(int n, int *, struct net *);
 int		nfsd_pool_stats_open(struct inode *, struct file *);
 int		nfsd_pool_stats_release(struct inode *, struct file *);
 
-static inline void nfsd_destroy(struct net *net)
-{
-	int destroy = (nfsd_serv->sv_nrthreads == 1);
-
-	if (destroy)
-		svc_shutdown_net(nfsd_serv, net);
-	svc_destroy(nfsd_serv);
-	if (destroy)
-		nfsd_serv = NULL;
-}
+void		nfsd_destroy(struct net *net);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 40992cd..0e8622a 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -29,11 +29,11 @@ extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 
 /*
- * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
+ * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
  * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
  * extent ->sv_temp_socks and ->sv_permsocks. It also protects nfsdstats.th_cnt
  *
- * If (out side the lock) nfsd_serv is non-NULL, then it must point to a
+ * If (out side the lock) nn->nfsd_serv is non-NULL, then it must point to a
  * properly initialised 'struct svc_serv' with ->sv_nrthreads > 0. That number
  * of nfsd threads must exist and each must listed in ->sp_all_threads in each
  * entry of ->sv_pools[].
@@ -51,7 +51,6 @@ static int			nfsd(void *vrqstp);
  *	nfsd_versions
  */
 DEFINE_MUTEX(nfsd_mutex);
-struct svc_serv 		*nfsd_serv;
 
 /*
  * nfsd_drc_lock protects nfsd_drc_max_pages and nfsd_drc_pages_used.
@@ -172,12 +171,14 @@ int nfsd_minorversion(u32 minorversion, enum vers_op change)
  */
 #define	NFSD_MAXSERVS		8192
 
-int nfsd_nrthreads(void)
+int nfsd_nrthreads(struct net *net)
 {
 	int rv = 0;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
 	mutex_lock(&nfsd_mutex);
-	if (nfsd_serv)
-		rv = nfsd_serv->sv_nrthreads;
+	if (nn->nfsd_serv)
+		rv = nn->nfsd_serv->sv_nrthreads;
 	mutex_unlock(&nfsd_mutex);
 	return rv;
 }
@@ -185,15 +186,17 @@ int nfsd_nrthreads(void)
 static int nfsd_init_socks(struct net *net)
 {
 	int error;
-	if (!list_empty(&nfsd_serv->sv_permsocks))
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (!list_empty(&nn->nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", net, PF_INET, NFS_PORT,
+	error = svc_create_xprt(nn->nfsd_serv, "udp", net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", net, PF_INET, NFS_PORT,
+	error = svc_create_xprt(nn->nfsd_serv, "tcp", net, PF_INET, NFS_PORT,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)
 		return error;
@@ -369,21 +372,21 @@ int nfsd_create_serv(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
-	if (nfsd_serv) {
-		svc_get(nfsd_serv);
+	if (nn->nfsd_serv) {
+		svc_get(nn->nfsd_serv);
 		return 0;
 	}
 	if (nfsd_max_blksize == 0)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
-	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
+	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
-	if (nfsd_serv == NULL)
+	if (nn->nfsd_serv == NULL)
 		return -ENOMEM;
 
-	error = svc_bind(nfsd_serv, net);
+	error = svc_bind(nn->nfsd_serv, net);
 	if (error < 0) {
-		svc_destroy(nfsd_serv);
+		svc_destroy(nn->nfsd_serv);
 		return error;
 	}
 
@@ -392,39 +395,55 @@ int nfsd_create_serv(struct net *net)
 	return 0;
 }
 
-int nfsd_nrpools(void)
+int nfsd_nrpools(struct net *net)
 {
-	if (nfsd_serv == NULL)
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (nn->nfsd_serv == NULL)
 		return 0;
 	else
-		return nfsd_serv->sv_nrpools;
+		return nn->nfsd_serv->sv_nrpools;
 }
 
-int nfsd_get_nrthreads(int n, int *nthreads)
+int nfsd_get_nrthreads(int n, int *nthreads, struct net *net)
 {
 	int i = 0;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	if (nfsd_serv != NULL) {
-		for (i = 0; i < nfsd_serv->sv_nrpools && i < n; i++)
-			nthreads[i] = nfsd_serv->sv_pools[i].sp_nrthreads;
+	if (nn->nfsd_serv != NULL) {
+		for (i = 0; i < nn->nfsd_serv->sv_nrpools && i < n; i++)
+			nthreads[i] = nn->nfsd_serv->sv_pools[i].sp_nrthreads;
 	}
 
 	return 0;
 }
 
+void nfsd_destroy(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	int destroy = (nn->nfsd_serv->sv_nrthreads == 1);
+
+	if (destroy)
+		svc_shutdown_net(nn->nfsd_serv, net);
+	svc_destroy(nn->nfsd_serv);
+	if (destroy)
+		nn->nfsd_serv = NULL;
+}
+
 int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 {
 	int i = 0;
 	int tot = 0;
 	int err = 0;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 
-	if (nfsd_serv == NULL || n <= 0)
+	if (nn->nfsd_serv == NULL || n <= 0)
 		return 0;
 
-	if (n > nfsd_serv->sv_nrpools)
-		n = nfsd_serv->sv_nrpools;
+	if (n > nn->nfsd_serv->sv_nrpools)
+		n = nn->nfsd_serv->sv_nrpools;
 
 	/* enforce a global maximum number of threads */
 	tot = 0;
@@ -454,9 +473,9 @@ int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 		nthreads[0] = 1;
 
 	/* apply the new numbers */
-	svc_get(nfsd_serv);
+	svc_get(nn->nfsd_serv);
 	for (i = 0; i < n; i++) {
-		err = svc_set_num_threads(nfsd_serv, &nfsd_serv->sv_pools[i],
+		err = svc_set_num_threads(nn->nfsd_serv, &nn->nfsd_serv->sv_pools[i],
 				    	  nthreads[i]);
 		if (err)
 			break;
@@ -475,6 +494,7 @@ nfsd_svc(int nrservs, struct net *net)
 {
 	int	error;
 	bool	nfsd_up_before;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
@@ -483,7 +503,7 @@ nfsd_svc(int nrservs, struct net *net)
 	if (nrservs > NFSD_MAXSERVS)
 		nrservs = NFSD_MAXSERVS;
 	error = 0;
-	if (nrservs == 0 && nfsd_serv == NULL)
+	if (nrservs == 0 && nn->nfsd_serv == NULL)
 		goto out;
 
 	error = nfsd_create_serv(net);
@@ -495,14 +515,14 @@ nfsd_svc(int nrservs, struct net *net)
 	error = nfsd_startup(nrservs, net);
 	if (error)
 		goto out_destroy;
-	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
+	error = svc_set_num_threads(nn->nfsd_serv, NULL, nrservs);
 	if (error)
 		goto out_shutdown;
-	/* We are holding a reference to nfsd_serv which
+	/* We are holding a reference to nn->nfsd_serv which
 	 * we don't want to count in the return value,
 	 * so subtract 1
 	 */
-	error = nfsd_serv->sv_nrthreads - 1;
+	error = nn->nfsd_serv->sv_nrthreads - 1;
 out_shutdown:
 	if (error < 0 && !nfsd_up_before)
 		nfsd_shutdown(net);
@@ -681,14 +701,17 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 int nfsd_pool_stats_open(struct inode *inode, struct file *file)
 {
 	int ret;
+	struct net *net = &init_net;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
 	mutex_lock(&nfsd_mutex);
-	if (nfsd_serv == NULL) {
+	if (nn->nfsd_serv == NULL) {
 		mutex_unlock(&nfsd_mutex);
 		return -ENODEV;
 	}
 	/* bump up the psudo refcount while traversing */
-	svc_get(nfsd_serv);
-	ret = svc_pool_stats_open(nfsd_serv, file);
+	svc_get(nn->nfsd_serv);
+	ret = svc_pool_stats_open(nn->nfsd_serv, file);
 	mutex_unlock(&nfsd_mutex);
 	return ret;
 }

