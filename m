From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 20/46] nfs41: use nfs4_fs_locations_res
Date: Wed,  4 Mar 2009 01:55:30 +0200
Message-ID: <1236124530-3529-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17556
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753644AbZCCXzn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:55:43 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    5 ++++-
 fs/nfs/nfs4xdr.c  |    6 ++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 98b2e89..7b69f00 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3782,10 +3782,13 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		.page = page,
 		.bitmask = bitmask,
 	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations = fs_locations,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
 		.rpc_argp = &args,
-		.rpc_resp = fs_locations,
+		.rpc_resp = &res,
 	};
 	int status;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5fb452c..55b9091 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4421,7 +4421,8 @@ out:
 /*
  * FS_LOCATIONS request
  */
-static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations *res)
+static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
+				     struct nfs4_fs_locations_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4436,7 +4437,8 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	if ((status = decode_lookup(&xdr)) != 0)
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
-	status = decode_getfattr(&xdr, &res->fattr, res->server);
+	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
+				 res->fs_locations->server);
 out:
 	return status;
 }
-- 
1.6.1.3

