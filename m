From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 12/67] nfs41: use nfs4_statfs_res
Date: Thu,  2 Apr 2009 16:52:02 +0300
Message-ID: <1238680322-13775-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27828 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756245AbZDBNwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:11 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs4_statfs_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 ++++-
 fs/nfs/nfs4xdr.c        |    5 +++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 414c03d..85e6bc6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2426,10 +2426,13 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
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
index 1e41420..b7871ad 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4387,7 +4387,8 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 /*
  * STATFS request
  */
-static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *fsstat)
+static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
+			       struct nfs4_statfs_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4398,7 +4399,7 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_statfs(&xdr, fsstat);
+		status = decode_statfs(&xdr, res->fsstat);
 	return status;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ac01781..3f1ff24 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -795,6 +795,11 @@ struct nfs4_statfs_arg {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_statfs_res {
+	struct nfs_fsstat	       *fsstat;
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs4_server_caps_arg {
 	struct nfs_fh		       *fhandle;
 	struct nfs4_sequence_args	seq_args;
-- 
1.6.2.1

