From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 11/67] nfs41: use nfs4_readlink_res
Date: Thu,  2 Apr 2009 16:51:57 +0300
Message-ID: <1238680317-13744-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31270 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752233AbZDBNwE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:04 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs4_readlink_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    3 ++-
 fs/nfs/nfs4xdr.c        |    3 ++-
 include/linux/nfs_xdr.h |    4 ++++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dcdd35b..414c03d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1960,10 +1960,11 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.pglen    = pglen,
 		.pages    = &page,
 	};
+	struct nfs4_readlink_res res;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READLINK],
 		.rpc_argp = &args,
-		.rpc_resp = NULL,
+		.rpc_resp = &res,
 	};
 
 	return rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9130586..1e41420 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4235,7 +4235,8 @@ out:
 /*
  * Decode READLINK response
  */
-static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
+static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
+				 struct nfs4_readlink_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2d95f98..ac01781 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -754,6 +754,10 @@ struct nfs4_readlink {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_readlink_res {
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs4_rename_arg {
 	const struct nfs_fh *		old_dir;
 	const struct nfs_fh *		new_dir;
-- 
1.6.2.1

