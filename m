Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42781 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932610Ab1AMJZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 04:25:44 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFSD: do common error handling in decode_cb_op_status
Date: Thu, 13 Jan 2011 11:25:41 +0200
Message-Id: <1294910741-18407-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D2EC4AC.9090205@panasas.com>
References: <4D2EC4AC.9090205@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Rather than handling the cb operation status in each and every
decode_cb_op_status's caller, just put the common code there.

If need be, and some caller really needs to see the original status
this patch can be reverted but right now there's no real need for the
abstract functionality.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5a6dcf8..6f69645 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -248,11 +248,11 @@ static int nfs_cb_stat_to_errno(int status)
 	return -status;
 }
 
-static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
-			       enum nfsstat4 *status)
+static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 {
 	__be32 *p;
 	u32 op;
+	enum nfsstat4 status;
 
 	p = xdr_inline_decode(xdr, 4 + 4);
 	if (unlikely(p == NULL))
@@ -260,7 +260,9 @@ static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
 	op = be32_to_cpup(p++);
 	if (unlikely(op != expected))
 		goto out_unexpected;
-	*status = be32_to_cpup(p);
+	status = be32_to_cpup(p);
+	if (unlikely(status != NFS4_OK))
+		return nfs_cb_stat_to_errno(status);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -469,22 +471,17 @@ out_overflow:
 static int decode_cb_sequence4res(struct xdr_stream *xdr,
 				  struct nfsd4_callback *cb)
 {
-	enum nfsstat4 nfserr;
 	int status;
 
 	if (cb->cb_minorversion == 0)
 		return 0;
 
-	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &nfserr);
+	status = decode_cb_op_status(xdr, OP_CB_SEQUENCE);
 	if (unlikely(status))
 		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		goto out_default;
 	status = decode_cb_sequence4resok(xdr, cb);
 out:
 	return status;
-out_default:
-	return nfs_cb_stat_to_errno(nfserr);
 }
 
 /*
@@ -547,7 +544,6 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 				  struct nfsd4_callback *cb)
 {
 	struct nfs4_cb_compound_hdr hdr;
-	enum nfsstat4 nfserr;
 	int status;
 
 	status = decode_cb_compound4res(xdr, &hdr);
@@ -560,11 +556,7 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 			goto out;
 	}
 
-	status = decode_cb_op_status(xdr, OP_CB_RECALL, &nfserr);
-	if (unlikely(status))
-		goto out;
-	if (unlikely(nfserr != NFS4_OK))
-		status = nfs_cb_stat_to_errno(nfserr);
+	status = decode_cb_op_status(xdr, OP_CB_RECALL);
 out:
 	return status;
 }
-- 
1.7.3.4

