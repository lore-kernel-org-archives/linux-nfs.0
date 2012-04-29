Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab2D2Uu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:27 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 03/15] NFSv4: Retrieve attributes _before_ calling delegreturn
Date: Sun, 29 Apr 2012 16:50:08 -0400
Message-Id: <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to retrieve cache consistency attributes before
anyone else has a chance to change the inode, we need to
put the GETATTR op _before_ the DELEGRETURN op.

We can then use that as part of a 'nfs_post_op_update_inode_force_wcc()'
call, to ensure that we update the attributes without clearing our
cached data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    7 ++++---
 fs/nfs/nfs4xdr.c  |    6 +++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 111a3cc..2e0fbff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4138,9 +4138,10 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	if (status != 0)
 		goto out;
 	status = data->rpc_status;
-	if (status != 0)
-		goto out;
-	nfs_refresh_inode(inode, &data->fattr);
+	if (status == 0)
+		nfs_post_op_update_inode_force_wcc(inode, &data->fattr);
+	else
+		nfs_refresh_inode(inode, &data->fattr);
 out:
 	rpc_put_task(task);
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fe61424..ac7a3b0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2602,8 +2602,8 @@ static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fhandle, &hdr);
-	encode_delegreturn(xdr, args->stateid, &hdr);
 	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_delegreturn(xdr, args->stateid, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6527,10 +6527,10 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 	status = decode_putfh(xdr);
 	if (status != 0)
 		goto out;
-	status = decode_delegreturn(xdr);
+	status = decode_getfattr(xdr, res->fattr, res->server);
 	if (status != 0)
 		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
+	status = decode_delegreturn(xdr);
 out:
 	return status;
 }
-- 
1.7.7.6

