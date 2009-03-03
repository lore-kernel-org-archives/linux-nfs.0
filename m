From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 16/46] nfs41: use nfs4_pathconf_res
Date: Wed,  4 Mar 2009 01:54:36 +0200
Message-ID: <1236124476-3405-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17497
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754156AbZCCXyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:54:51 -0500
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
index 7a01a3f..4db965c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2565,10 +2565,13 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_pathconf_res res = {
+		.pathconf = pathconf,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PATHCONF],
 		.rpc_argp = &args,
-		.rpc_resp = pathconf,
+		.rpc_resp = &res,
 	};
 
 	/* None of the pathconf attributes are mandatory to implement */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6647f10..3f84ab7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4287,7 +4287,8 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 /*
  * PATHCONF request
  */
-static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *pathconf)
+static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
+				 struct nfs4_pathconf_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4298,7 +4299,7 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_pathconf(&xdr, pathconf);
+		status = decode_pathconf(&xdr, res->pathconf);
 	return status;
 }
 
-- 
1.6.1.3

