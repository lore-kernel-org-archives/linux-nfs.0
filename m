From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NLM: allow lockd requests from an unprivileged port
Date: Fri, 07 Nov 2008 09:15:29 -0500
Message-ID: <20081107141457.18394.89469.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:52631 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbYKGOWR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Nov 2008 09:22:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the admin has specified the "noresvport" option for an NFS mount
point, the kernel's NFS client uses an unprivileged source port for
the main NFS transport.  The kernel's lockd client should use an
unprivileged port in this case as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
This might apply more cleanly than the last version of this patch.

 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |   10 +++++++++-
 fs/nfs/client.c             |    2 ++
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    4 +++-
 5 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 8307dd6..9d0098f 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -60,7 +60,7 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 
 	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
-				   nlm_init->hostname);
+				   nlm_init->hostname, nlm_init->noresvport);
 	if (host == NULL) {
 		lockd_down();
 		return ERR_PTR(-ENOLCK);
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 5d3c7c6..0123964 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -42,6 +42,7 @@ struct nlm_lookup_host_info {
 	const size_t		hostname_len;	/* it's length */
 	const struct sockaddr	*src_sap;	/* our address (optional) */
 	const size_t		src_len;	/* it's length */
+	const int		noresvport;	/* use non-priv port */
 };
 
 /*
@@ -228,6 +229,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	host->h_nsmstate   = 0;			/* real NSM state */
 	host->h_nsmhandle  = nsm;
 	host->h_server	   = ni->server;
+	host->h_noresvport = ni->noresvport;
 	hlist_add_head(&host->h_hash, chain);
 	INIT_LIST_HEAD(&host->h_lockowners);
 	spin_lock_init(&host->h_lock);
@@ -276,6 +278,7 @@ nlm_destroy_host(struct nlm_host *host)
  * @protocol: transport protocol to use
  * @version: NLM protocol version
  * @hostname: '\0'-terminated hostname of server
+ * @noresvport: 1 if non-privileged port should be used
  *
  * Returns an nlm_host structure that matches the passed-in
  * [server address, transport protocol, NLM version, server hostname].
@@ -285,7 +288,9 @@ nlm_destroy_host(struct nlm_host *host)
 struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 				     const size_t salen,
 				     const unsigned short protocol,
-				     const u32 version, const char *hostname)
+				     const u32 version,
+				     const char *hostname,
+				     int noresvport)
 {
 	const struct sockaddr source = {
 		.sa_family	= AF_UNSPEC,
@@ -300,6 +305,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.hostname_len	= strlen(hostname),
 		.src_sap	= &source,
 		.src_len	= sizeof(source),
+		.noresvport	= noresvport,
 	};
 
 	dprintk("lockd: %s(host='%s', vers=%u, proto=%s)\n", __func__,
@@ -421,6 +427,8 @@ nlm_bind_host(struct nlm_host *host)
 		 */
 		if (!host->h_server)
 			args.flags |= RPC_CLNT_CREATE_HARDRTRY;
+		if (host->h_noresvport)
+			args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
 		clnt = rpc_create(&args);
 		if (!IS_ERR(clnt))
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index cd4a174..bfc4bc3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -526,6 +526,8 @@ static int nfs_start_lockd(struct nfs_server *server)
 		.protocol	= server->flags & NFS_MOUNT_TCP ?
 						IPPROTO_TCP : IPPROTO_UDP,
 		.nfs_version	= clp->rpc_ops->version,
+		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
+					1 : 0,
 	};
 
 	if (nlm_init.nfs_version > 3)
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index e5872dc..fbc48f8 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -41,6 +41,7 @@ struct nlmclnt_initdata {
 	size_t			addrlen;
 	unsigned short		protocol;
 	u32			nfs_version;
+	int			noresvport;
 };
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a7d6911..958734a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -54,6 +54,7 @@ struct nlm_host {
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
 				h_server     : 1, /* server side, not client side */
+				h_noresvport : 1,
 				h_inuse      : 1;
 	wait_queue_head_t	h_gracewait;	/* wait while reclaiming */
 	struct rw_semaphore	h_rwsem;	/* Reboot recovery lock */
@@ -218,7 +219,8 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const size_t salen,
 					const unsigned short protocol,
 					const u32 version,
-					const char *hostname);
+					const char *hostname,
+					int noresvport);
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 					const char *hostname,
 					const size_t hostname_len);

