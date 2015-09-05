Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35525 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbbIEXHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Sep 2015 19:07:01 -0400
Received: by qgt47 with SMTP id 47so40923337qgt.2
        for <linux-nfs@vger.kernel.org>; Sat, 05 Sep 2015 16:07:00 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Express delegation limit in units of pages
Date: Sat,  5 Sep 2015 19:06:57 -0400
Message-Id: <1441494418-53583-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we're tracking modifications to the page cache on a per-page
basis, it makes sense to express the limit to how much we may cache
in units of pages.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c     |  5 +++--
 fs/nfs/delegation.h     |  2 +-
 fs/nfs/nfs4xdr.c        | 16 ++++++++++------
 include/linux/nfs_xdr.h |  2 +-
 4 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 029d688a969f..4817f66c8d47 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -175,7 +175,8 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 		if (delegation->inode != NULL) {
 			nfs4_stateid_copy(&delegation->stateid, &res->delegation);
 			delegation->type = res->delegation_type;
-			delegation->maxsize = res->maxsize;
+			delegation->pagemod_limit = res->pagemod_limit;
+				;
 			oldcred = delegation->cred;
 			delegation->cred = get_rpccred(cred);
 			clear_bit(NFS_DELEGATION_NEED_RECLAIM,
@@ -337,7 +338,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		return -ENOMEM;
 	nfs4_stateid_copy(&delegation->stateid, &res->delegation);
 	delegation->type = res->delegation_type;
-	delegation->maxsize = res->maxsize;
+	delegation->pagemod_limit = res->pagemod_limit;
 	delegation->change_attr = inode->i_version;
 	delegation->cred = get_rpccred(cred);
 	delegation->inode = inode;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index e3c20a3ccc93..554178a17376 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -18,7 +18,7 @@ struct nfs_delegation {
 	struct inode *inode;
 	nfs4_stateid stateid;
 	fmode_t type;
-	loff_t maxsize;
+	unsigned long pagemod_limit;
 	__u64 change_attr;
 	unsigned long flags;
 	spinlock_t lock;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ff4784c54e04..788adf3897c7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4932,24 +4932,28 @@ static int decode_lookup(struct xdr_stream *xdr)
 }
 
 /* This is too sick! */
-static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
+static int decode_space_limit(struct xdr_stream *xdr,
+		unsigned long *pagemod_limit)
 {
 	__be32 *p;
 	uint32_t limit_type, nblocks, blocksize;
+	u64 maxsize = 0;
 
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
 		goto out_overflow;
 	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
-	case 1:
-		xdr_decode_hyper(p, maxsize);
+	case NFS4_LIMIT_SIZE:
+		xdr_decode_hyper(p, &maxsize);
 		break;
-	case 2:
+	case NFS4_LIMIT_BLOCKS:
 		nblocks = be32_to_cpup(p++);
 		blocksize = be32_to_cpup(p);
-		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
+		maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
+	maxsize >>= PAGE_CACHE_SHIFT;
+	*pagemod_limit = min_t(u64, maxsize, ULONG_MAX);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -4977,7 +4981,7 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
 		break;
 	case NFS4_OPEN_DELEGATE_WRITE:
 		res->delegation_type = FMODE_WRITE|FMODE_READ;
-		if (decode_space_limit(xdr, &res->maxsize) < 0)
+		if (decode_space_limit(xdr, &res->pagemod_limit) < 0)
 				return -EIO;
 	}
 	return decode_ace(xdr, NULL, res->server->nfs_client);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b4392d86d157..52faf7e96c65 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -406,8 +406,8 @@ struct nfs_openres {
 	const struct nfs_server *server;
 	fmode_t			delegation_type;
 	nfs4_stateid		delegation;
+	unsigned long		pagemod_limit;
 	__u32			do_recall;
-	__u64			maxsize;
 	__u32			attrset[NFS4_BITMAP_SIZE];
 	struct nfs4_string	*owner;
 	struct nfs4_string	*group_owner;
-- 
2.4.3

