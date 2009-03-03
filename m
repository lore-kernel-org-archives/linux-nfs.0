From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 15/46] nfs41: use nfs4_fsinfo_res
Date: Wed,  4 Mar 2009 01:54:26 +0200
Message-ID: <1236124466-3380-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17520
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753923AbZCCXyi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:54:38 -0500
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
index 20c5e0d..7a01a3f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2527,10 +2527,13 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.fh = fhandle,
 		.bitmask = server->attr_bitmask,
 	};
+	struct nfs4_fsinfo_res res = {
+		.fsinfo = fsinfo,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FSINFO],
 		.rpc_argp = &args,
-		.rpc_resp = fsinfo,
+		.rpc_resp = &res,
 	};
 
 	return rpc_call_sync(server->client, &msg, 0);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1b37faa..6647f10 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4268,7 +4268,8 @@ out:
 /*
  * FSINFO request
  */
-static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
+static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
+			       struct nfs4_fsinfo_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4279,7 +4280,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, fsinfo);
+		status = decode_fsinfo(&xdr, res->fsinfo);
 	return status;
 }
 
-- 
1.6.1.3

