Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754378Ab2D2Uuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 15/15] NFSv4: COMMIT does not need post-op attributes
Date: Sun, 29 Apr 2012 16:50:20 -0400
Message-Id: <1335732620-10445-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-7-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-8-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-9-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-10-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-11-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-12-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-13-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-14-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-15-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No attributes are supposed to change during a COMMIT call, so there
is no need to request post-op attributes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 ------
 fs/nfs/nfs4xdr.c  |   12 ++----------
 2 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 64b67f3..98eb48d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3462,7 +3462,6 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *da
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
-	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
 
@@ -3477,11 +3476,6 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	if (data->lseg) {
-		data->args.bitmask = NULL;
-		data->res.fattr = NULL;
-	} else
-		data->args.bitmask = server->cache_consistency_bitmask;
 	if (data->commit_done_cb == NULL)
 		data->commit_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 49483f1..db040e9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -421,13 +421,11 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_commit_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
-				encode_commit_maxsz + \
-				encode_getattr_maxsz)
+				encode_commit_maxsz)
 #define NFS4_dec_commit_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-				decode_commit_maxsz + \
-				decode_getattr_maxsz)
+				decode_commit_maxsz)
 #define NFS4_enc_open_sz        (compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -2425,8 +2423,6 @@ static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_commit(xdr, args, &hdr);
-	if (args->bitmask)
-		encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6306,10 +6302,6 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	if (status)
 		goto out;
 	status = decode_commit(xdr, res);
-	if (status)
-		goto out;
-	if (res->fattr)
-		decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
-- 
1.7.7.6

