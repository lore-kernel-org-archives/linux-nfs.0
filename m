From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 17/67] nfs41: use nfs4_setaclres
Date: Thu,  2 Apr 2009 16:52:40 +0300
Message-ID: <1238680360-13931-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29057 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754382AbZDBNwr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:47 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs_setaclres]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    3 ++-
 fs/nfs/nfs4xdr.c        |    3 ++-
 include/linux/nfs_xdr.h |    4 ++++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4270cb4..50ce9ed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2845,10 +2845,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		.acl_pages	= pages,
 		.acl_len	= buflen,
 	};
+	struct nfs_setaclres res;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETACL],
 		.rpc_argp	= &arg,
-		.rpc_resp	= NULL,
+		.rpc_resp	= &res,
 	};
 	int ret;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 27dd25d..aa350d5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3996,7 +3996,8 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
  * Decode SETACL response
  */
 static int
-nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
+nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
+		    struct nfs_setaclres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b34a66e..d6cb194 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -436,6 +436,10 @@ struct nfs_setaclargs {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs_setaclres {
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs_getaclargs {
 	struct nfs_fh *			fh;
 	size_t				acl_len;
-- 
1.6.2.1

