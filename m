Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754270Ab2EZSkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 14:40:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 9/9] NFSv4.1: Don't clobber the seqid if exchange_id returns a confirmed clientid
Date: Sat, 26 May 2012 14:40:00 -0400
Message-Id: <1338057600-11130-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338057600-11130-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the EXCHGID4_FLAG_CONFIRMED_R flag is set, the client is in theory
supposed to already know the correct value of the seqid, in which case
RFC5661 states that it should ignore the value returned.

Also ensure that if the sanity check in nfs4_check_cl_exchange_flags
fails, then we must not change the nfs_client fields.

Finally, clean up the code: we don't need to retest the value of
'status' unless it can change.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |   17 +++++++++--------
 fs/nfs/nfs4xdr.c        |    7 +++----
 include/linux/nfs_xdr.h |    3 ++-
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 485a6c0..9f0a96f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5171,7 +5171,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER,
 	};
 	struct nfs41_exchange_id_res res = {
-		.client = clp,
+		0
 	};
 	int status;
 	struct rpc_message msg = {
@@ -5214,22 +5214,22 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (status == 0)
-		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
+		status = nfs4_check_cl_exchange_flags(res.flags);
 
 	if (status == 0) {
+		clp->cl_clientid = res.clientid;
+		clp->cl_exchange_flags = (res.flags & ~EXCHGID4_FLAG_CONFIRMED_R);
+		if (!(res.flags & EXCHGID4_FLAG_CONFIRMED_R))
+			clp->cl_seqid = res.seqid;
+
 		kfree(clp->cl_serverowner);
 		clp->cl_serverowner = res.server_owner;
 		res.server_owner = NULL;
-	}
 
-	if (status == 0) {
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
-	} else
-		kfree(res.impl_id);
 
-	if (status == 0) {
 		if (clp->cl_serverscope != NULL &&
 		    !nfs41_same_server_scope(clp->cl_serverscope,
 					     res.server_scope)) {
@@ -5244,7 +5244,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			clp->cl_serverscope = res.server_scope;
 			goto out;
 		}
-	}
+	} else
+		kfree(res.impl_id);
 
 out_server_owner:
 	kfree(res.server_owner);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b9ce3fd..ee4a74d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5319,7 +5319,6 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	uint32_t dummy;
 	char *dummy_str;
 	int status;
-	struct nfs_client *clp = res->client;
 	uint32_t impl_id_count;
 
 	status = decode_op_hdr(xdr, OP_EXCHANGE_ID);
@@ -5329,12 +5328,12 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
-	xdr_decode_hyper(p, &clp->cl_clientid);
+	xdr_decode_hyper(p, &res->clientid);
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
 		goto out_overflow;
-	clp->cl_seqid = be32_to_cpup(p++);
-	clp->cl_exchange_flags = be32_to_cpup(p++);
+	res->seqid = be32_to_cpup(p++);
+	res->flags = be32_to_cpup(p++);
 
 	/* We ask for SP4_NONE */
 	dummy = be32_to_cpup(p);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6387fc0..d1a7bf5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1132,7 +1132,8 @@ struct nfs41_bind_conn_to_session_res {
 };
 
 struct nfs41_exchange_id_res {
-	struct nfs_client		*client;
+	u64				clientid;
+	u32				seqid;
 	u32				flags;
 	struct nfs41_server_owner	*server_owner;
 	struct nfs41_server_scope	*server_scope;
-- 
1.7.7.6

