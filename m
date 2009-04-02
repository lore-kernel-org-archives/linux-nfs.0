From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 14/67] nfs41: use nfs4_pathconf_res
Date: Thu,  2 Apr 2009 16:52:15 +0300
Message-ID: <1238680335-13837-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32379 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754133AbZDBNwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:25 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs4_pathconf_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 ++++-
 fs/nfs/nfs4xdr.c        |    5 +++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0b82a6b..ad6acc9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2496,10 +2496,13 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
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
index d9ab820..a77ee3d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4370,7 +4370,8 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 /*
  * PATHCONF request
  */
-static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *pathconf)
+static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
+				 struct nfs4_pathconf_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4381,7 +4382,7 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_pathconf(&xdr, pathconf);
+		status = decode_pathconf(&xdr, res->pathconf);
 	return status;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8343023..67942e7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -734,6 +734,11 @@ struct nfs4_pathconf_arg {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_pathconf_res {
+	struct nfs_pathconf	       *pathconf;
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs4_readdir_arg {
 	const struct nfs_fh *		fh;
 	u64				cookie;
-- 
1.6.2.1

