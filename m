From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 26/67] nfs41: encode minorversion in compound header
Date: Thu,  2 Apr 2009 16:53:48 +0300
Message-ID: <1238680428-14214-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1121 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756803AbZDBNyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:54:04 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamdon <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: pass *session in seq_args and seq_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   70 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6888946..19ca0b5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -546,6 +546,7 @@ struct compound_hdr {
 	uint32_t	taglen;
 	char *		tag;
 	uint32_t	replen;		/* expected reply words */
+	u32		minorversion;
 };
 
 /*
@@ -598,7 +599,7 @@ static void encode_compound_hdr(struct xdr_stream *xdr,
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
-	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->minorversion);
 	hdr->nops_p = p;
 	WRITE32(hdr->nops);
 }
@@ -1388,6 +1389,15 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
  * END OF "GENERIC" ENCODE ROUTINES.
  */
 
+static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (args->sa_session)
+		return args->sa_session->clp->cl_minorversion;
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
 /*
  * Encode an ACCESS request
  */
@@ -1395,7 +1405,7 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1414,7 +1424,7 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1434,7 +1444,7 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1453,7 +1463,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1472,7 +1482,7 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1495,7 +1505,7 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1518,7 +1528,7 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1549,7 +1559,7 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1567,7 +1577,7 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1586,7 +1596,7 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1627,7 +1637,7 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1646,7 +1656,7 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1665,7 +1675,7 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1683,7 +1693,7 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1701,7 +1711,7 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1719,7 +1729,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1740,7 +1750,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1764,7 +1774,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1786,7 +1796,7 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1807,7 +1817,7 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	uint32_t replen;
 
@@ -1830,7 +1840,7 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1850,7 +1860,7 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1869,7 +1879,7 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1887,7 +1897,7 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1906,7 +1916,7 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1926,7 +1936,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2001,7 +2011,7 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2020,7 +2030,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	uint32_t replen;
 
@@ -3996,7 +4006,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	int status;
 
-- 
1.6.2.1

