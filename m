From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 13/67] nfs41: use nfs4_fsinfo_res
Date: Thu,  2 Apr 2009 16:52:10 +0300
Message-ID: <1238680330-13806-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:18745 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756404AbZDBNwQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:52:16 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs4_fsinfo_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 ++++-
 fs/nfs/nfs4xdr.c        |    5 +++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 85e6bc6..0b82a6b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2458,10 +2458,13 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
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
index b7871ad..d9ab820 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4351,7 +4351,8 @@ out:
 /*
  * FSINFO request
  */
-static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
+static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
+			       struct nfs4_fsinfo_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4362,7 +4363,7 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, fsinfo);
+		status = decode_fsinfo(&xdr, res->fsinfo);
 	return status;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3f1ff24..8343023 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -675,6 +675,11 @@ struct nfs4_fsinfo_arg {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_fsinfo_res {
+	struct nfs_fsinfo	       *fsinfo;
+	struct nfs4_sequence_res	seq_res;
+};
+
 struct nfs4_getattr_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
-- 
1.6.2.1

