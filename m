From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 10/67] nfs41: use nfs4_server_caps_arg
Date: Thu,  2 Apr 2009 16:51:50 +0300
Message-ID: <1238680310-13713-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30873 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756193AbZDBNv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:57 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for nfs41 sequence processing.

Signed-off-by: Andy Admason <andros@netapp.com>
[define nfs4_server_caps_arg]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |    5 ++++-
 fs/nfs/nfs4xdr.c        |    5 +++--
 include/linux/nfs_xdr.h |    5 +++++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 884bbe0..dcdd35b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1584,10 +1584,13 @@ void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
+	struct nfs4_server_caps_arg args = {
+		.fhandle = fhandle,
+	};
 	struct nfs4_server_caps_res res = {};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SERVER_CAPS],
-		.rpc_argp = fhandle,
+		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
 	int status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1690f0e..9130586 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1900,7 +1900,8 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 /*
  * GETATTR_BITMAP request
  */
-static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struct nfs_fh *fhandle)
+static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
+				    struct nfs4_server_caps_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -1909,7 +1910,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	encode_putfh(&xdr, fhandle, &hdr);
+	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
 			   FATTR4_WORD0_SYMLINK_SUPPORT|
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9480a32..2d95f98 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -791,6 +791,11 @@ struct nfs4_statfs_arg {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs4_server_caps_arg {
+	struct nfs_fh		       *fhandle;
+	struct nfs4_sequence_args	seq_args;
+};
+
 struct nfs4_server_caps_res {
 	u32				attr_bitmask[2];
 	u32				acl_bitmask;
-- 
1.6.2.1

