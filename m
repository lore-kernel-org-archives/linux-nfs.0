From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/7] SQUASHME: nfs41: embed resp_len in nfs_getaclres
Date: Mon, 30 Mar 2009 17:00:39 +0300
Message-ID: <1238421639-25083-1-git-send-email-bhalevy@panasas.com>
References: <49D0D025.2080608@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, andros@netapp.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14402 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752275AbZC3OAu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:00:50 -0400
In-Reply-To: <49D0D025.2080608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Trond's review comment.

squash into "nfs41: use nfs4_getaclres"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   17 ++++++++---------
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e7e95c..788238a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3192,14 +3192,13 @@ out:
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
 	struct page *pages[NFS4ACL_MAXPAGES];
-	size_t resp_len = buflen;
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
 		.acl_pages = pages,
 		.acl_len = buflen,
 	};
 	struct nfs_getaclres res = {
-		.acl_len = &resp_len,
+		.acl_len = buflen,
 	};
 	void *resp_buf;
 	struct rpc_message msg = {
@@ -3219,7 +3218,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 			return -ENOMEM;
 		args.acl_pages[0] = localpage;
 		args.acl_pgbase = 0;
-		resp_len = args.acl_len = PAGE_SIZE;
+		args.acl_len = PAGE_SIZE;
 	} else {
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
@@ -3227,18 +3226,18 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
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
index ae01d82..66922dc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4599,7 +4599,7 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getacl(&xdr, rqstp, res->acl_len);
+	status = decode_getacl(&xdr, rqstp, &res->acl_len);
 
 out:
 	return status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4feacc6..36972c8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -431,7 +431,7 @@ struct nfs_getaclargs {
 };
 
 struct nfs_getaclres {
-	size_t				*acl_len;
+	size_t				acl_len;
 	struct nfs4_sequence_res	seq_res;
 };
 
-- 
1.6.2.1

