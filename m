From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 13/46] nfs41: use nfs4_readlink_res
Date: Wed,  4 Mar 2009 01:54:00 +0200
Message-ID: <1236124440-3321-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17473
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754434AbZCCXyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:54:15 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 fs/nfs/nfs4xdr.c  |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0c60965..13a22c6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2029,10 +2029,11 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
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
index 4b356ac..17de1d4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4152,7 +4152,8 @@ out:
 /*
  * Decode READLINK response
  */
-static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
+static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
+				 struct nfs4_readlink_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
-- 
1.6.1.3

