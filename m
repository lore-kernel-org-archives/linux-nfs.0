From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 12/46] nfs41: use nfs4_server_caps_arg
Date: Wed,  4 Mar 2009 01:53:49 +0200
Message-ID: <1236124429-3296-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17468
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755961AbZCCXyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:54:04 -0500
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
index fed6cfb..0c60965 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1656,10 +1656,13 @@ out_drop:
 
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
index d1e4c8f..4b356ac 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1903,7 +1903,8 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 /*
  * GETATTR_BITMAP request
  */
-static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struct nfs_fh *fhandle)
+static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
+				    struct nfs4_server_caps_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -1912,7 +1913,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, &hdr);
-	encode_putfh(&xdr, fhandle, &hdr);
+	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
 			   FATTR4_WORD0_SYMLINK_SUPPORT|
-- 
1.6.1.3

