From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 18/67] nfs41: use nfs4_fs_locations_res
Date: Thu,  2 Apr 2009 16:52:45 +0300
Message-ID: <1238680365-13962-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31081 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751327AbZDBNwz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:55 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[find nfs4_fs_locations_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 ++++-
 fs/nfs/nfs4xdr.c        |    6 ++++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50ce9ed..2fa9442 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3725,10 +3725,13 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
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
index aa350d5..e448e33 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4504,7 +4504,8 @@ out:
 /*
  * FS_LOCATIONS request
  */
-static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations *res)
+static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
+				     struct nfs4_fs_locations_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4519,7 +4520,8 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	if ((status = decode_lookup(&xdr)) != 0)
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
-	status = decode_getfattr(&xdr, &res->fattr, res->server);
+	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
+				 res->fs_locations->server);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d6cb194..d32a112 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -867,6 +867,11 @@ struct nfs4_fs_locations_arg {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_fs_locations_res {
+	struct nfs4_fs_locations       *fs_locations;
+	struct nfs4_sequence_res	seq_res;
+};
+
 #endif /* CONFIG_NFS_V4 */
 
 struct nfs_page;
-- 
1.6.2.1

