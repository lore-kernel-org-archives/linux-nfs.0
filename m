From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 14/46] nfs41: use nfs4_statfs_res
Date: Wed,  4 Mar 2009 01:54:12 +0200
Message-ID: <1236124452-3353-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17507
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753780AbZCCXy0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:54:26 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    5 ++++-
 fs/nfs/nfs4xdr.c  |    5 +++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 13a22c6..20c5e0d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2495,10 +2495,13 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_statfs_res res = {
+		.fsstat = fsstat,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_STATFS],
 		.rpc_argp = &args,
-		.rpc_resp = fsstat,
+		.rpc_resp = &res,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 17de1d4..1b37faa 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4304,7 +4304,8 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 /*
  * STATFS request
  */
-static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *fsstat)
+static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
+			       struct nfs4_statfs_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4315,7 +4316,7 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_statfs(&xdr, fsstat);
+		status = decode_statfs(&xdr, res->fsstat);
 	return status;
 }
 
-- 
1.6.1.3

