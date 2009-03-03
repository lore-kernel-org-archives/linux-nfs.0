From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 23/46] nfs41: encode minorversion in compound header
Date: Wed,  4 Mar 2009 01:57:39 +0200
Message-ID: <1236124659-3629-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17661
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754279AbZCCX5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:57:55 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamdon <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  119 ++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 89 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 55b9091..b60dc56 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -544,6 +544,7 @@ struct compound_hdr {
 	__be32 *	nops_p;
 	uint32_t	taglen;
 	char *		tag;
+	u32		minorversion;
 };
 
 /*
@@ -588,7 +589,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
-	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->minorversion);
 	hdr->nops_p = p;
 	WRITE32(hdr->nops);
 }
@@ -1353,8 +1354,10 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs4_accessargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1372,8 +1375,10 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1392,8 +1397,10 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_root_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1411,8 +1418,10 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1430,8 +1439,10 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs4_rename_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1453,8 +1464,10 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_link_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1476,8 +1489,10 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs4_create_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1507,8 +1522,10 @@ static int nfs4_xdr_enc_symlink(struct rpc_rqst *req, __be32 *p, const struct nf
 static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nfs4_getattr_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1525,8 +1542,10 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1544,8 +1563,10 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1585,8 +1606,10 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1604,8 +1627,10 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1623,8 +1648,10 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_args *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1641,8 +1668,10 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_args *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1659,8 +1688,10 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_args *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1677,8 +1708,10 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct nfs4_readlink *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	unsigned int replen;
@@ -1705,8 +1738,10 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nfs4_readdir_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -1737,8 +1772,10 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 {
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	int replen;
 
@@ -1765,8 +1802,10 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_setattrargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1787,8 +1826,10 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 {
 	struct xdr_stream xdr;
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	int replen;
 
@@ -1811,8 +1852,10 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1831,8 +1874,10 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1850,8 +1895,10 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsinfo_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1868,8 +1915,10 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct nfs4_pathconf_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1887,8 +1936,10 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs4_statfs_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1907,8 +1958,10 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 				    struct nfs4_server_caps_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1982,8 +2035,10 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struct nfs4_delegreturnargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2001,8 +2056,10 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations_arg *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -3894,8 +3951,10 @@ static int
 nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
 {
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = clp->cl_minorversion,
 	};
 	int status;
 
-- 
1.6.1.3

