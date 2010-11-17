Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758137Ab0KQVQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Nov 2010 16:16:15 -0500
From: andros@netapp.com
To: benny@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFS return an rpc auth error on back channel
Date: Tue, 16 Nov 2010 22:36:30 -0500
Message-Id: <1289964990-4480-4-git-send-email-andros@netapp.com>
In-Reply-To: <1289964990-4480-3-git-send-email-andros@netapp.com>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
 <1289964990-4480-2-git-send-email-andros@netapp.com>
 <1289964990-4480-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

If a matching nfs_client struct is not found in the back channel NFS processing
return an rpc auth error.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.h               |    3 +++
 fs/nfs/callback_proc.c          |    7 ++++---
 fs/nfs/callback_xdr.c           |    4 ++++
 include/linux/sunrpc/msg_prot.h |    1 +
 include/linux/sunrpc/xdr.h      |    1 +
 net/sunrpc/svc.c                |    5 +++++
 6 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index b69bec5..3a54628 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -14,6 +14,9 @@
 #define NFS4_CALLBACK_XDRSIZE 2048
 #define NFS4_CALLBACK_BUFSIZE (1024 + NFS4_CALLBACK_XDRSIZE)
 
+/* Internal error for back channel server */
+#define nfserr_deny_reply          cpu_to_be32(30003)
+
 enum nfs4_callback_procnum {
 	CB_NULL = 0,
 	CB_COMPOUND = 1,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 69d085a..ec3c84b 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -31,7 +31,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 	struct inode *inode;
 
 	res->bitmap[0] = res->bitmap[1] = 0;
-	res->status = htonl(NFS4ERR_BADHANDLE);
+	res->status = nfserr_deny_reply;
 	clp = find_client_from_cps(cps, args->addr);
 	if (clp == NULL)
 		goto out;
@@ -39,6 +39,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 	dprintk("NFS: GETATTR callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	res->status = htonl(NFS4ERR_BADHANDLE);
 	inode = nfs_delegation_find_inode(clp, &args->fh);
 	if (inode == NULL)
 		goto out_putclient;
@@ -76,7 +77,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 	struct inode *inode;
 	__be32 res;
 	
-	res = htonl(NFS4ERR_BADHANDLE);
+	res = nfserr_deny_reply;
 	clp = find_client_from_cps(cps, args->addr);
 	if (clp == NULL)
 		goto out;
@@ -598,7 +599,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 
 	cps->session = NULL;
 
-	status = htonl(NFS4ERR_BADSESSION);
+	status = nfserr_deny_reply;
 	clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 92719f1..8e17464 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -789,6 +789,10 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		nops--;
 	}
 
+	/* An nfs_client struct was not found, return an rpc auth error */
+	if (unlikely(status == nfserr_deny_reply))
+		status = rpc_deny_reply;
+
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
 	if (cps.session)
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 77e6248..9ba9422 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -59,6 +59,7 @@ enum rpc_accept_stat {
 	RPC_SYSTEM_ERR = 5,
 	/* internal use only */
 	RPC_DROP_REPLY = 60000,
+	RPC_DENY_REPLY = 60001,
 };
 
 enum rpc_reject_stat {
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 498ab93..9b4645c 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -82,6 +82,7 @@ struct xdr_buf {
 #define	rpc_garbage_args	cpu_to_be32(RPC_GARBAGE_ARGS)
 #define	rpc_system_err		cpu_to_be32(RPC_SYSTEM_ERR)
 #define	rpc_drop_reply		cpu_to_be32(RPC_DROP_REPLY)
+#define	rpc_deny_reply		cpu_to_be32(RPC_DENY_REPLY)
 
 #define	rpc_auth_ok		cpu_to_be32(RPC_AUTH_OK)
 #define	rpc_autherr_badcred	cpu_to_be32(RPC_AUTH_BADCRED)
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..2c3e428 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1111,6 +1111,11 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
 		}
+		if (*statp == rpc_deny_reply) {
+			if (procp->pc_release)
+				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+			goto err_bad_auth;
+		}
 		if (*statp == rpc_success &&
 		    (xdr = procp->pc_encode) &&
 		    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
-- 
1.6.6

