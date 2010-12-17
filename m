Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755756Ab0LQSUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 13:20:15 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V4 9/9] NFS rename client back channel transport field
Date: Fri, 17 Dec 2010 13:20:10 -0500
Message-Id: <1292610010-19084-10-git-send-email-andros@netapp.com>
In-Reply-To: <1292610010-19084-9-git-send-email-andros@netapp.com>
References: <1292610010-19084-1-git-send-email-andros@netapp.com>
 <1292610010-19084-2-git-send-email-andros@netapp.com>
 <1292610010-19084-3-git-send-email-andros@netapp.com>
 <1292610010-19084-4-git-send-email-andros@netapp.com>
 <1292610010-19084-5-git-send-email-andros@netapp.com>
 <1292610010-19084-6-git-send-email-andros@netapp.com>
 <1292610010-19084-7-git-send-email-andros@netapp.com>
 <1292610010-19084-8-git-send-email-andros@netapp.com>
 <1292610010-19084-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Differentiate from server backchannel

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c              |   12 ++++++------
 include/linux/sunrpc/bc_xprt.h |    4 ++--
 include/linux/sunrpc/svc.h     |    2 +-
 net/sunrpc/svc.c               |    6 +++---
 net/sunrpc/svcsock.c           |    2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 52e6695..e9a4453 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -142,7 +142,7 @@ int nfs4_set_callback_sessionid(struct nfs_client *clp)
 	struct svc_serv *serv = clp->cl_rpcclient->cl_xprt->bc_serv;
 	struct nfs4_sessionid *bc_sid;
 
-	if (!serv->bc_xprt)
+	if (!serv->sv_bc_xprt)
 		return -EINVAL;
 
 	/* on success freed in xprt_free */
@@ -152,12 +152,12 @@ int nfs4_set_callback_sessionid(struct nfs_client *clp)
 	memcpy(bc_sid->data, &clp->cl_session->sess_id.data,
 		NFS4_MAX_SESSIONID_LEN);
 	spin_lock_bh(&serv->sv_cb_lock);
-	serv->bc_xprt->xpt_bc_sid = bc_sid;
+	serv->sv_bc_xprt->xpt_bc_sid = bc_sid;
 	spin_unlock_bh(&serv->sv_cb_lock);
-	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for bc_xprt %p\n", __func__,
+	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for sv_bc_xprt %p\n", __func__,
 		((u32 *)bc_sid->data)[0], ((u32 *)bc_sid->data)[1],
 		((u32 *)bc_sid->data)[2], ((u32 *)bc_sid->data)[3],
-		serv->bc_xprt);
+		serv->sv_bc_xprt);
 	return 0;
 }
 
@@ -233,8 +233,8 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 	init_waitqueue_head(&serv->sv_cb_waitq);
 	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(rqstp)) {
-		svc_xprt_put(serv->bc_xprt);
-		serv->bc_xprt = NULL;
+		svc_xprt_put(serv->sv_bc_xprt);
+		serv->sv_bc_xprt = NULL;
 	}
 out:
 	dprintk("--> %s return %ld\n", __func__, PTR_ERR(rqstp));
diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 2c60e09..c50b458 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -43,7 +43,7 @@ int bc_send(struct rpc_rqst *req);
  */
 static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
 {
-	if (rqstp->rq_server->bc_xprt)
+	if (rqstp->rq_server->sv_bc_xprt)
 		return 1;
 	return 0;
 }
@@ -51,7 +51,7 @@ static inline struct nfs4_sessionid *bc_xprt_sid(struct svc_rqst *rqstp)
 {
 	if (svc_is_backchannel(rqstp))
 		return (struct nfs4_sessionid *)
-					rqstp->rq_server->bc_xprt->xpt_bc_sid;
+			rqstp->rq_server->sv_bc_xprt->xpt_bc_sid;
 	return NULL;
 }
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..c81d4d8 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -99,7 +99,7 @@ struct svc_serv {
 	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
 	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
 						 * entries in the svc_cb_list */
-	struct svc_xprt		*bc_xprt;
+	struct svc_xprt		*sv_bc_xprt;	/* callback on fore channel */
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3520cb3..5f7397b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1263,7 +1263,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	int		ret;
 
 	/* Build the svc_rqst used by the common processing routine */
-	rqstp->rq_xprt = serv->bc_xprt;
+	rqstp->rq_xprt = serv->sv_bc_xprt;
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
@@ -1289,14 +1289,14 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	svc_getnl(argv);	/* CALLDIR */
 
 	/* Hold a reference to the back channel socket across the call */
-	svc_xprt_get(serv->bc_xprt);
+	svc_xprt_get(serv->sv_bc_xprt);
 	ret = svc_process_common(rqstp, argv, resv);
 	if (ret <= 0)
 		return ret;
 
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
 	ret = bc_send(req);
-	svc_xprt_put(serv->bc_xprt);
+	svc_xprt_put(serv->sv_bc_xprt);
 	return ret;
 }
 EXPORT_SYMBOL(bc_svc_process);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f8b5ca9..e495a45 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1615,7 +1615,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 	xprt = &svsk->sk_xprt;
 	svc_xprt_init(&svc_tcp_bc_class, xprt, serv);
 
-	serv->bc_xprt = xprt;
+	serv->sv_bc_xprt = xprt;
 
 	return xprt;
 }
-- 
1.6.6

