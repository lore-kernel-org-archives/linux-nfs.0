Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24153 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426Ab1AYPhl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 10:37:41 -0500
From: andros@netapp.com
To: trond.myklebuse@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/3] NFS do not find client in NFSv4 pg_authenticate
Date: Tue, 25 Jan 2011 10:38:01 -0500
Message-Id: <1295969883-2100-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The information required to find the nfs_client cooresponding to the incoming
back channel request is contained in the NFS layer. Perform minimal checking
in the RPC layer pg_authenticate method, and push more detailed checking into
the NFS layer where the nfs_client can be found.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c               |  109 ++++++++++----------------------------
 fs/nfs/callback.h               |    4 +-
 fs/nfs/callback_proc.c          |   10 +---
 fs/nfs/callback_xdr.c           |    5 +-
 fs/nfs/client.c                 |   15 ++----
 fs/nfs/internal.h               |    3 +-
 fs/nfs/nfs4state.c              |    6 --
 include/linux/sunrpc/bc_xprt.h  |   13 -----
 include/linux/sunrpc/svc_xprt.h |    1 -
 net/sunrpc/svcsock.c            |    4 +-
 10 files changed, 42 insertions(+), 128 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 1990165..e3d2942 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -135,33 +135,6 @@ out_err:
 
 #if defined(CONFIG_NFS_V4_1)
 /*
- *  * CB_SEQUENCE operations will fail until the callback sessionid is set.
- *   */
-int nfs4_set_callback_sessionid(struct nfs_client *clp)
-{
-	struct svc_serv *serv = clp->cl_rpcclient->cl_xprt->bc_serv;
-	struct nfs4_sessionid *bc_sid;
-
-	if (!serv->sv_bc_xprt)
-		return -EINVAL;
-
-	/* on success freed in xprt_free */
-	bc_sid = kmalloc(sizeof(struct nfs4_sessionid), GFP_KERNEL);
-	if (!bc_sid)
-		return -ENOMEM;
-	memcpy(bc_sid->data, &clp->cl_session->sess_id.data,
-		NFS4_MAX_SESSIONID_LEN);
-	spin_lock_bh(&serv->sv_cb_lock);
-	serv->sv_bc_xprt->xpt_bc_sid = bc_sid;
-	spin_unlock_bh(&serv->sv_cb_lock);
-	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for sv_bc_xprt %p\n", __func__,
-		((u32 *)bc_sid->data)[0], ((u32 *)bc_sid->data)[1],
-		((u32 *)bc_sid->data)[2], ((u32 *)bc_sid->data)[3],
-		serv->sv_bc_xprt);
-	return 0;
-}
-
-/*
  * The callback service for NFSv4.1 callbacks
  */
 static int
@@ -266,10 +239,6 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct nfs_callback_data *cb_info)
 {
 }
-int nfs4_set_callback_sessionid(struct nfs_client *clp)
-{
-	return 0;
-}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -359,78 +328,58 @@ void nfs_callback_down(int minorversion)
 	mutex_unlock(&nfs_callback_mutex);
 }
 
-static int check_gss_callback_principal(struct nfs_client *clp,
-					struct svc_rqst *rqstp)
+/* Boolean check of RPC_AUTH_GSS principal */
+int
+check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 {
 	struct rpc_clnt *r = clp->cl_rpcclient;
 	char *p = svc_gss_principal(rqstp);
 
+	if (rqstp->rq_authop->flavour != RPC_AUTH_GSS)
+		return 1;
+
 	/* No RPC_AUTH_GSS on NFSv4.1 back channel yet */
 	if (clp->cl_minorversion != 0)
-		return SVC_DROP;
+		return 0;
 	/*
 	 * It might just be a normal user principal, in which case
 	 * userspace won't bother to tell us the name at all.
 	 */
 	if (p == NULL)
-		return SVC_DENIED;
+		return 0;
 
 	/* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
 
 	if (memcmp(p, "nfs@", 4) != 0)
-		return SVC_DENIED;
+		return 0;
 	p += 4;
 	if (strcmp(p, r->cl_server) != 0)
-		return SVC_DENIED;
-	return SVC_OK;
+		return 0;
+	return 1;
 }
 
-/* pg_authenticate method helper */
-static struct nfs_client *nfs_cb_find_client(struct svc_rqst *rqstp)
-{
-	struct nfs4_sessionid *sessionid = bc_xprt_sid(rqstp);
-	int is_cb_compound = rqstp->rq_proc == CB_COMPOUND ? 1 : 0;
-
-	dprintk("--> %s rq_proc %d\n", __func__, rqstp->rq_proc);
-	if (svc_is_backchannel(rqstp))
-		/* Sessionid (usually) set after CB_NULL ping */
-		return nfs4_find_client_sessionid(svc_addr(rqstp), sessionid,
-						  is_cb_compound);
-	else
-		/* No callback identifier in pg_authenticate */
-		return nfs4_find_client_no_ident(svc_addr(rqstp));
-}
-
-/* pg_authenticate method for nfsv4 callback threads. */
+/*
+ * pg_authenticate method for nfsv4 callback threads.
+ *
+ * The authflavor has been negotiated, so an incorrect flavor is a server
+ * bug. Drop packets with incorrect authflavor.
+ *
+ * All other checking done after NFS decoding where the nfs_client can be
+ * found in nfs4_callback_compound
+ */
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct nfs_client *clp;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
-	int ret = SVC_OK;
-
-	/* Don't talk to strangers */
-	clp = nfs_cb_find_client(rqstp);
-	if (clp == NULL)
-		return SVC_DROP;
-
-	dprintk("%s: %s NFSv4 callback!\n", __func__,
-			svc_print_addr(rqstp, buf, sizeof(buf)));
-
 	switch (rqstp->rq_authop->flavour) {
-		case RPC_AUTH_NULL:
-			if (rqstp->rq_proc != CB_NULL)
-				ret = SVC_DENIED;
-			break;
-		case RPC_AUTH_UNIX:
-			break;
-		case RPC_AUTH_GSS:
-			ret = check_gss_callback_principal(clp, rqstp);
-			break;
-		default:
-			ret = SVC_DENIED;
+	case RPC_AUTH_NULL:
+		if (rqstp->rq_proc != CB_NULL)
+			return SVC_DROP;
+		break;
+	case RPC_AUTH_GSS:
+		/* No RPC_AUTH_GSS support yet in NFSv4.1 */
+		 if (svc_is_backchannel(rqstp))
+			return SVC_DROP;
 	}
-	nfs_put_client(clp);
-	return ret;
+	return SVC_OK;
 }
 
 /*
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index d3b44f9..46d93ce 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -7,6 +7,7 @@
  */
 #ifndef __LINUX_FS_NFS_CALLBACK_H
 #define __LINUX_FS_NFS_CALLBACK_H
+#include <linux/sunrpc/svc.h>
 
 #define NFS4_CALLBACK 0x40000000
 #define NFS4_CALLBACK_XDRSIZE 2048
@@ -37,7 +38,6 @@ enum nfs4_callback_opnum {
 struct cb_process_state {
 	__be32			drc_status;
 	struct nfs_client	*clp;
-	struct nfs4_sessionid	*svc_sid; /* v4.1 callback service sessionid */
 };
 
 struct cb_compound_hdr_arg {
@@ -168,7 +168,7 @@ extern unsigned nfs4_callback_layoutrecall(
 extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 extern void nfs4_cb_take_slot(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
-
+extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_getattrres *res,
 				    struct cb_process_state *cps);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 4bb91cb..829f406 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -373,17 +373,11 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 {
 	struct nfs_client *clp;
 	int i;
-	__be32 status;
+	__be32 status = htonl(NFS4ERR_BADSESSION);
 
 	cps->clp = NULL;
 
-	status = htonl(NFS4ERR_BADSESSION);
-	/* Incoming session must match the callback session */
-	if (memcmp(&args->csa_sessionid, cps->svc_sid, NFS4_MAX_SESSIONID_LEN))
-		goto out;
-
-	clp = nfs4_find_client_sessionid(args->csa_addr,
-					 &args->csa_sessionid, 1);
+	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 23112c2..14e0f93 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -794,10 +794,9 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 
 	if (hdr_arg.minorversion == 0) {
 		cps.clp = nfs4_find_client_ident(hdr_arg.cb_ident);
-		if (!cps.clp)
+		if (!cps.clp || !check_gss_callback_principal(cps.clp, rqstp))
 			return rpc_drop_reply;
-	} else
-		cps.svc_sid = bc_xprt_sid(rqstp);
+	}
 
 	hdr_res.taglen = hdr_arg.taglen;
 	hdr_res.tag = hdr_arg.tag;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 192f2f8..bd3ca32 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1206,16 +1206,11 @@ nfs4_find_client_ident(int cb_ident)
  * For CB_COMPOUND calls, find a client by IP address, protocol version,
  * minorversion, and sessionID
  *
- * CREATE_SESSION triggers a CB_NULL ping from servers. The callback service
- * sessionid can only be set after the CREATE_SESSION return, so a CB_NULL
- * can arrive before the callback sessionid is set. For CB_NULL calls,
- * find a client by IP address protocol version, and minorversion.
- *
  * Returns NULL if no such client
  */
 struct nfs_client *
 nfs4_find_client_sessionid(const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid, int is_cb_compound)
+			   struct nfs4_sessionid *sid)
 {
 	struct nfs_client *clp;
 
@@ -1227,9 +1222,9 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
 		if (!nfs4_has_session(clp))
 			continue;
 
-		/* Match sessionid unless cb_null call*/
-		if (is_cb_compound && (memcmp(clp->cl_session->sess_id.data,
-		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0))
+		/* Match sessionid*/
+		if (memcmp(clp->cl_session->sess_id.data,
+		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
 			continue;
 
 		atomic_inc(&clp->cl_count);
@@ -1244,7 +1239,7 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
 
 struct nfs_client *
 nfs4_find_client_sessionid(const struct sockaddr *addr,
-			   struct nfs4_sessionid *sid, int is_cb_compound)
+			   struct nfs4_sessionid *sid)
 {
 	return NULL;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index bfa3a34..25b734c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -133,8 +133,7 @@ extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_no_ident(const struct sockaddr *);
 extern struct nfs_client *nfs4_find_client_ident(int);
 extern struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *,
-			   int);
+nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2336d53..e6742b5 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -232,12 +232,6 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
-	status = nfs4_set_callback_sessionid(clp);
-	if (status != 0) {
-		printk(KERN_WARNING "Sessionid not set. No callback service\n");
-		nfs_callback_down(1);
-		status = 0;
-	}
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index c50b458..0828842 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -47,14 +47,6 @@ static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
 		return 1;
 	return 0;
 }
-static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
-{
-	if (svc_is_backchannel(rqstp))
-		return (struct nfs4_sessionid *)
-			rqstp->rq_server->sv_bc_xprt->xpt_bc_sid;
-	return NULL;
-}
-
 #else /* CONFIG_NFS_V4_1 */
 static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
 					 unsigned int min_reqs)
@@ -67,11 +59,6 @@ static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
 	return 0;
 }
 
-static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
-{
-	return NULL;
-}
-
 static inline void xprt_free_bc_request(struct rpc_rqst *req)
 {
 }
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 357da5e..aea0d43 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -78,7 +78,6 @@ struct svc_xprt {
 	size_t			xpt_remotelen;	/* length of address */
 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
 	struct list_head	xpt_users;	/* callbacks on free */
-	void			*xpt_bc_sid;	/* back channel session ID */
 
 	struct net		*xpt_net;
 };
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d265aa7..460655f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1605,9 +1605,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
  */
 static void svc_bc_sock_free(struct svc_xprt *xprt)
 {
-	if (xprt) {
-		kfree(xprt->xpt_bc_sid);
+	if (xprt)
 		kfree(container_of(xprt, struct svc_sock, sk_xprt));
-	}
 }
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.6

