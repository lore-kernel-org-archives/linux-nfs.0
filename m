From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 15/67] nfs41: use nfs4_getaclres
Date: Thu,  2 Apr 2009 16:52:23 +0300
Message-ID: <1238680343-13869-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32428 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754133AbZDBNwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:31 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: embed resp_len in nfs_getaclres]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   20 +++++++++++---------
 fs/nfs/nfs4xdr.c        |    5 +++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad6acc9..4270cb4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2758,12 +2758,14 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		.acl_pages = pages,
 		.acl_len = buflen,
 	};
-	size_t resp_len = buflen;
+	struct nfs_getaclres res = {
+		.acl_len = buflen,
+	};
 	void *resp_buf;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETACL],
 		.rpc_argp = &args,
-		.rpc_resp = &resp_len,
+		.rpc_resp = &res,
 	};
 	struct page *localpage = NULL;
 	int ret;
@@ -2777,7 +2779,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 			return -ENOMEM;
 		args.acl_pages[0] = localpage;
 		args.acl_pgbase = 0;
-		resp_len = args.acl_len = PAGE_SIZE;
+		args.acl_len = PAGE_SIZE;
 	} else {
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
@@ -2785,18 +2787,18 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	if (ret)
 		goto out_free;
-	if (resp_len > args.acl_len)
-		nfs4_write_cached_acl(inode, NULL, resp_len);
+	if (res.acl_len > args.acl_len)
+		nfs4_write_cached_acl(inode, NULL, res.acl_len);
 	else
-		nfs4_write_cached_acl(inode, resp_buf, resp_len);
+		nfs4_write_cached_acl(inode, resp_buf, res.acl_len);
 	if (buf) {
 		ret = -ERANGE;
-		if (resp_len > buflen)
+		if (res.acl_len > buflen)
 			goto out_free;
 		if (localpage)
-			memcpy(buf, resp_buf, resp_len);
+			memcpy(buf, resp_buf, res.acl_len);
 	}
-	ret = resp_len;
+	ret = res.acl_len;
 out_free:
 	if (localpage)
 		__free_page(localpage);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a77ee3d..3e77789 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4018,7 +4018,8 @@ out:
  * Decode GETACL response
  */
 static int
-nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
+nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
+		    struct nfs_getaclres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4031,7 +4032,7 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getacl(&xdr, rqstp, acl_len);
+	status = decode_getacl(&xdr, rqstp, &res->acl_len);
 
 out:
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 67942e7..b34a66e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -444,6 +444,11 @@ struct nfs_getaclargs {
 	struct nfs4_sequence_args 	seq_args;
 };
 
+struct nfs_getaclres {
+	size_t				acl_len;
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
 	const struct nfs_server *	server;
-- 
1.6.2.1

