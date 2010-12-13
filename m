From: Andy Adamson <andros@netapp.com>
Subject: [PATCH_V3 3/7] NFS associate sessionid with callback connection
Date: Mon, 13 Dec 2010 15:19:41 -0500
Message-ID: <1292271585-3038-4-git-send-email-andros@netapp.com>
References: <1292271585-3038-1-git-send-email-andros@netapp.com>
 <1292271585-3038-2-git-send-email-andros@netapp.com>
 <1292271585-3038-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7260 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755093Ab0LMUT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 15:19:58 -0500
In-Reply-To: <1292271585-3038-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sessions based callback service is started prior to the CREATE_SESSION call
so that it can handle CB_NULL requests which can be sent before the
CREATE_SESSION call returns and the session ID is known.

Set the callback sessionid after a sucessful CREATE_SESSION.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c               |   31 +++++++++++++++++++++++++++++++
 fs/nfs/callback.h               |    1 +
 fs/nfs/nfs4state.c              |    6 ++++++
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/xprt.c               |    2 ++
 5 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 023a9eb..558d858 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -137,6 +137,33 @@ out_err:
 
 #if defined(CONFIG_NFS_V4_1)
 /*
+ *  * CB_SEQUENCE operations will fail until the callback sessionid is set.
+ *   */
+int nfs4_set_callback_sessionid(struct nfs_client *clp)
+{
+	struct svc_serv *serv = clp->cl_rpcclient->cl_xprt->bc_serv;
+	struct nfs4_sessionid *bc_sid;
+
+	if (!serv->bc_xprt)
+		return -EINVAL;
+
+	/* on success freed in xprt_free */
+	bc_sid = kmalloc(sizeof(struct nfs4_sessionid), GFP_KERNEL);
+	if (!bc_sid)
+		return -ENOMEM;
+	memcpy(bc_sid->data, &clp->cl_session->sess_id.data,
+		NFS4_MAX_SESSIONID_LEN);
+	spin_lock(&serv->sv_cb_lock);
+	serv->bc_xprt->xpt_bc_sid = bc_sid;
+	spin_unlock(&serv->sv_cb_lock);
+	dprintk("%s set xpt_bc_sid=%u:%u:%u:%u for bc_xprt %p\n", __func__,
+		((u32 *)bc_sid->data)[0], ((u32 *)bc_sid->data)[1],
+		((u32 *)bc_sid->data)[2], ((u32 *)bc_sid->data)[3],
+		serv->bc_xprt);
+	return 0;
+}
+
+/*
  * The callback service for NFSv4.1 callbacks
  */
 static int
@@ -236,6 +263,10 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
 		struct nfs_callback_data *cb_info)
 {
 }
+int nfs4_set_callback_sessionid(struct nfs_client *clp)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 85a7cfd..58d61a8 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -137,6 +137,7 @@ extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
 					    const nfs4_stateid *stateid);
+extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4 */
 /*
  * nfs41: Callbacks are expected to not cause substantial latency,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index fe61422..11290de 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -193,6 +193,12 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
+	status = nfs4_set_callback_sessionid(clp);
+	if (status != 0) {
+		printk(KERN_WARNING "Sessionid not set. No callback service\n");
+		nfs_callback_down(1);
+		status = 0;
+	}
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 600c669..aa15126 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -79,6 +79,7 @@ struct svc_xprt {
 	size_t			xpt_remotelen;	/* length of address */
 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
 	struct list_head	xpt_users;	/* callbacks on free */
+	void			*xpt_bc_sid;	/* back channel session ID */
 
 	struct net		*xpt_net;
 };
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 4c8f18a..18783cb 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -985,6 +985,8 @@ void xprt_free(struct rpc_xprt *xprt)
 {
 	put_net(xprt->xprt_net);
 	kfree(xprt->slot);
+	if (xprt->bc_xprt)
+		kfree(xprt->bc_xprt->xpt_bc_sid);
 	kfree(xprt);
 }
 EXPORT_SYMBOL_GPL(xprt_free);
-- 
1.6.6

