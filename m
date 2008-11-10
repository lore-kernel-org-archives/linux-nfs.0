From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 47/85] nfs41: get cred in exchange_id when cred arg is NULL
Date: Mon, 10 Nov 2008 22:26:28 +0200
Message-ID: <1226348788-8795-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48859 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbYKJU0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:35 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When creating a session to a pnfs data server, the cred is passed
down as NULL.  Either use the saved cl_ex_cred or get a new one
using nfs4_get_setclientid_cred.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |   18 +++++++++++++++---
 fs/nfs/nfs4state.c |    2 +-
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 904b19e..b9771f2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -229,6 +229,7 @@ extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 #ifdef CONFIG_NFS_V4_1
 struct rpc_cred *nfs41_get_state_renewal_cred(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5b1f6d0..8c28d0c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4276,6 +4276,7 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	};
 	int status;
 	int loop = 0;
+	int got_cred = 0;
 	struct rpc_message msg = {
 		.rpc_proc = nfs4_proc(clp, NFSPROC4_CLNT_EXCHANGE_ID),
 		.rpc_argp = &args,
@@ -4286,6 +4287,16 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 	dprintk("--> %s\n", __func__);
 	BUG_ON(clp == NULL);
+
+	if (!cred) {
+		/* FIXME: do we need to lock clp and take a ref count on cl_ex_cred? */
+		cred = clp->cl_ex_cred;
+		if (!cred) {
+			cred = nfs4_get_setclientid_cred(clp);
+			got_cred = (cred != NULL);
+		}
+	}
+
 	p = (u32 *)verifier.data;
 	*p++ = htonl((u32)clp->cl_boot_time.tv_sec);
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
@@ -4317,17 +4328,18 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		else if (++clp->cl_id_uniquifier == 0)
 			break;
 	}
-	if (status == 0) {
+	if ((status == 0) && (cred != clp->cl_ex_cred) && (cred != NULL)) {
+		/* FIXME: do we need to lock clp here? */
 		if (clp->cl_ex_cred) {
 			dprintk("%s put cl_ex_cred %p\n", __func__,
 				clp->cl_ex_cred);
 			put_rpccred(clp->cl_ex_cred);
 		}
-
-		BUG_ON(cred == NULL);
 		clp->cl_ex_cred = get_rpccred(cred);
 		dprintk("%s set cl_ex_cred %p\n", __func__, clp->cl_ex_cred);
 	}
+	if (got_cred)
+		put_rpccred(cred);
 
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5a91072..693e5a6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -122,7 +122,7 @@ struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
 	return cred;
 }
 
-static struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
-- 
1.6.0.2

