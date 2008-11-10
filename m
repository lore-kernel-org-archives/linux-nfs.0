From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 23/85] nfs41: minorversion support for xdr
Date: Mon, 10 Nov 2008 22:21:53 +0200
Message-ID: <1226348513-7951-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48753 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbYKJUWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:22:02 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add the minorversion to struct rpc_version and struct rpc_clnt, and struct
compound_hdr. Switch on the minorversion to perfom NFSv4.0 vrs NFSv4.1
encoding,

Add the nfsv41 encode and decode sizes. Add encode_sequence to all
nfs4_enc_* routines and decode_sequence to all nfs4_dec_* routines as required
by v41.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c            |  641 +++++++++++++++++++++++++++++++------------
 include/linux/sunrpc/clnt.h |    2 +
 net/sunrpc/clnt.c           |    2 +
 3 files changed, 471 insertions(+), 174 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 30addf4..d3da7a5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -240,43 +240,63 @@ static int nfs4_stat_to_errno(int);
 				(encode_getattr_maxsz)
 #define decode_fs_locations_maxsz \
 				(0)
+
+#if defined(CONFIG_NFS_V4_1)
+#define encode_sequence_maxsz	0 /* stub */
+#define decode_sequence_maxsz	0 /* stub */
+#else /* CONFIG_NFS_V4_1 */
+#define encode_sequence_maxsz	0
+#define decode_sequence_maxsz	0
+#endif /* CONFIG_NFS_V4_1 */
+
 #define NFS4_enc_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_read_maxsz)
 #define NFS4_dec_read_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_read_maxsz)
 #define NFS4_enc_readlink_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_readlink_maxsz)
 #define NFS4_dec_readlink_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_readlink_maxsz)
 #define NFS4_enc_readdir_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_readdir_maxsz)
 #define NFS4_dec_readdir_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_readdir_maxsz)
 #define NFS4_enc_write_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_write_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_write_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_write_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_commit_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_commit_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_commit_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_commit_maxsz + \
 				decode_getattr_maxsz)
-#define NFS4_enc_open_sz        (compound_encode_hdr_maxsz + \
+#define NFS4_enc_open_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_open_maxsz + \
@@ -284,7 +304,8 @@ static int nfs4_stat_to_errno(int);
 				encode_getattr_maxsz + \
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
-#define NFS4_dec_open_sz        (compound_decode_hdr_maxsz + \
+#define NFS4_dec_open_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_open_maxsz + \
@@ -301,43 +322,53 @@ static int nfs4_stat_to_errno(int);
 				 decode_putfh_maxsz + \
 				 decode_open_confirm_maxsz)
 #define NFS4_enc_open_noattr_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 					encode_putfh_maxsz + \
 					encode_open_maxsz + \
 					encode_getattr_maxsz)
 #define NFS4_dec_open_noattr_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 					decode_putfh_maxsz + \
 					decode_open_maxsz + \
 					decode_getattr_maxsz)
 #define NFS4_enc_open_downgrade_sz \
 				(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_open_downgrade_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_open_downgrade_sz \
 				(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_open_downgrade_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_close_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_close_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_setattr_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_setattr_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_setattr_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_fsinfo_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_fsinfo_maxsz)
 #define NFS4_dec_fsinfo_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_fsinfo_maxsz)
 #define NFS4_enc_renew_sz	(compound_encode_hdr_maxsz + \
@@ -359,64 +390,81 @@ static int nfs4_stat_to_errno(int);
 				decode_putrootfh_maxsz + \
 				decode_fsinfo_maxsz)
 #define NFS4_enc_lock_sz        (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_lock_maxsz)
 #define NFS4_dec_lock_sz        (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_lock_maxsz)
 #define NFS4_enc_lockt_sz       (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_lockt_maxsz)
 #define NFS4_dec_lockt_sz       (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_lockt_maxsz)
 #define NFS4_enc_locku_sz       (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_locku_maxsz)
 #define NFS4_dec_locku_sz       (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_locku_maxsz)
 #define NFS4_enc_access_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_access_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_access_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_access_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_getattr_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_getattr_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_lookup_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_lookup_maxsz + \
 				encode_getattr_maxsz + \
 				encode_getfh_maxsz)
 #define NFS4_dec_lookup_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_lookup_maxsz + \
 				decode_getattr_maxsz + \
 				decode_getfh_maxsz)
 #define NFS4_enc_lookup_root_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putrootfh_maxsz + \
 				encode_getattr_maxsz + \
 				encode_getfh_maxsz)
 #define NFS4_dec_lookup_root_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putrootfh_maxsz + \
 				decode_getattr_maxsz + \
 				decode_getfh_maxsz)
 #define NFS4_enc_remove_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_remove_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_remove_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				op_decode_hdr_maxsz + 5 + \
 				decode_getattr_maxsz)
 #define NFS4_enc_rename_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
@@ -425,6 +473,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_rename_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
@@ -433,6 +482,7 @@ static int nfs4_stat_to_errno(int);
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_link_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
@@ -441,6 +491,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_dec_link_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
@@ -449,16 +500,19 @@ static int nfs4_stat_to_errno(int);
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_symlink_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_symlink_maxsz + \
 				encode_getattr_maxsz + \
 				encode_getfh_maxsz)
 #define NFS4_dec_symlink_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_symlink_maxsz + \
 				decode_getattr_maxsz + \
 				decode_getfh_maxsz)
 #define NFS4_enc_create_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_create_maxsz + \
@@ -467,6 +521,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_create_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_create_maxsz + \
@@ -475,49 +530,63 @@ static int nfs4_stat_to_errno(int);
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_pathconf_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_pathconf_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_statfs_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_statfs_maxsz)
 #define NFS4_dec_statfs_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_statfs_maxsz)
 #define NFS4_enc_server_caps_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_server_caps_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_delegreturn_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_delegreturn_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_delegreturn_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_delegreturn_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_getacl_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getacl_maxsz)
 #define NFS4_dec_getacl_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_getacl_maxsz)
 #define NFS4_enc_setacl_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_setacl_maxsz)
 #define NFS4_dec_setacl_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_setacl_maxsz)
 #define NFS4_enc_fs_locations_sz \
 				(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_lookup_maxsz + \
 				 encode_fs_locations_maxsz)
 #define NFS4_dec_fs_locations_sz \
 				(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
@@ -543,6 +612,7 @@ struct compound_hdr {
 	uint32_t	nops;
 	uint32_t	taglen;
 	char *		tag;
+	u32		minorversion;
 };
 
 /*
@@ -578,7 +648,7 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 	xdr_encode_opaque(p, str, len);
 }
 
-static __u32 *
+static __be32*
 encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p, *nops;
@@ -588,7 +658,7 @@ encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	RESERVE_SPACE(12+(XDR_QUADLEN(hdr->taglen)<<2));
 	WRITE32(hdr->taglen);
 	WRITEMEM(hdr->tag, hdr->taglen);
-	WRITE32(NFS4_MINOR_VERSION);
+	WRITE32(hdr->minorversion);
 	nops = p;
 	WRITE32(hdr->nops);
 	return nops;
@@ -1377,7 +1447,8 @@ encode_savefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 
 static int
 encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs *arg,
-	       const struct nfs_server *server, struct compound_hdr *hdr)
+	       const struct nfs_server *server,
+	       struct compound_hdr *hdr)
 {
 	int status;
 	__be32 *p;
@@ -1468,6 +1539,30 @@ encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid,
 	return 0;
 
 }
+
+#if defined(CONFIG_NFS_V4_1)
+/* NFSv4.1 operations */
+static int encode_sequence(struct xdr_stream *xdr,
+			   const struct nfs41_sequence_args *args,
+			   struct compound_hdr *hdr)
+{
+	if (hdr->minorversion == 0)
+		return 0;
+
+	/* stub */
+	hdr->nops++;
+
+	return 0;
+}
+#else /* CONFIG_NFS_V4_1 */
+static inline int encode_sequence(struct xdr_stream *xdr,
+				  const struct nfs41_sequence_args *args,
+				  struct compound_hdr *hdr)
+{
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -1475,17 +1570,19 @@ encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *stateid,
 /*
  * Encode an ACCESS request
  */
-static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs4_accessargs *args)
+static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p,
+				const struct nfs4_accessargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status != 0)
 		goto out;
@@ -1501,17 +1598,19 @@ out:
 /*
  * Encode LOOKUP request
  */
-static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_arg *args)
+static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p,
+				const struct nfs4_lookup_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
 	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
@@ -1527,17 +1626,19 @@ out:
 /*
  * Encode LOOKUP_ROOT request
  */
-static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_root_arg *args)
+static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs4_lookup_root_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putrootfh(&xdr, &hdr)) != 0)
 		goto out;
 	if ((status = encode_getfh(&xdr, &hdr)) == 0)
@@ -1550,17 +1651,19 @@ out:
 /*
  * Encode REMOVE request
  */
-static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p,
+				const struct nfs_removeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
 		goto out;
 	if ((status = encode_remove(&xdr, &args->name, &hdr)) != 0)
@@ -1574,17 +1677,19 @@ out:
 /*
  * Encode RENAME request
  */
-static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs4_rename_arg *args)
+static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p,
+				const struct nfs4_rename_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->old_dir, &hdr)) != 0)
 		goto out;
 	if ((status = encode_savefh(&xdr, &hdr)) != 0)
@@ -1607,17 +1712,19 @@ out:
 /*
  * Encode LINK request
  */
-static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_link_arg *args)
+static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p,
+			      const struct nfs4_link_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->fh, &hdr)) != 0)
 		goto out;
 	if ((status = encode_savefh(&xdr, &hdr)) != 0)
@@ -1639,17 +1746,19 @@ out:
 /*
  * Encode CREATE request
  */
-static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs4_create_arg *args)
+static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p,
+				const struct nfs4_create_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
 	if ((status = encode_savefh(&xdr, &hdr)) != 0)
@@ -1679,17 +1788,19 @@ static int nfs4_xdr_enc_symlink(struct rpc_rqst *req, __be32 *p, const struct nf
 /*
  * Encode GETATTR request
  */
-static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nfs4_getattr_arg *args)
+static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p,
+				 const struct nfs4_getattr_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->fh, &hdr)) == 0)
 		status = encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(nops, &hdr);
@@ -1699,17 +1810,19 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 /*
  * Encode a CLOSE request
  */
-static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
+static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p,
+			       struct nfs_closeargs *args)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr = {
-		.nops   = 0,
-        };
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = req->rq_task->tk_client->cl_mvers,
+	};
         int status;
 	__be32 *nops;
 
-        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
         if(status)
                 goto out;
@@ -1725,17 +1838,19 @@ out:
 /*
  * Encode an OPEN request
  */
-static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
+static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p,
+			      struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -1767,7 +1882,7 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
@@ -1786,17 +1901,19 @@ out:
 /*
  * Encode an OPEN request with no attributes.
  */
-static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
+static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p,
+				     struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -1812,17 +1929,19 @@ out:
 /*
  * Encode an OPEN_DOWNGRADE request
  */
-static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
+static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p,
+					struct nfs_closeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -1838,17 +1957,19 @@ out:
 /*
  * Encode a LOCK request
  */
-static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_args *args)
+static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p,
+			      struct nfs_lock_args *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
@@ -1861,17 +1982,19 @@ out:
 /*
  * Encode a LOCKT request
  */
-static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_args *args)
+static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p,
+			       struct nfs_lockt_args *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
@@ -1884,17 +2007,19 @@ out:
 /*
  * Encode a LOCKU request
  */
-static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_args *args)
+static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p,
+			       struct nfs_locku_args *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
@@ -1907,11 +2032,12 @@ out:
 /*
  * Encode a READLINK request
  */
-static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct nfs4_readlink *args)
+static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs4_readlink *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	unsigned int replen;
@@ -1920,6 +2046,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
@@ -1941,11 +2068,12 @@ out:
 /*
  * Encode a READDIR request
  */
-static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nfs4_readdir_arg *args)
+static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p,
+				 const struct nfs4_readdir_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -1954,6 +2082,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if(status)
 		goto out;
@@ -1978,18 +2107,20 @@ out:
 /*
  * Encode a READ request
  */
-static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
+static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p,
+			      struct nfs_readargs *args)
 {
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int replen, status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -2013,18 +2144,20 @@ out:
 /*
  * Encode an SETATTR request
  */
-static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_setattrargs *args)
+static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p,
+				struct nfs_setattrargs *args)
 
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -2042,18 +2175,19 @@ out:
  */
 static int
 nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
-		struct nfs_getaclargs *args)
+		     struct nfs_getaclargs *args)
 {
 	struct xdr_stream xdr;
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int replen, status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -2070,24 +2204,25 @@ out:
 /*
  * Encode a WRITE request
  */
-static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
+static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p,
+			       struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
 	status = encode_write(&xdr, args, &hdr);
 	if (status)
 		goto out;
-	req->rq_snd_buf.flags |= XDRBUF_WRITE;
 	status = encode_getfattr(&xdr, args->bitmask, &hdr);
 out:
 	encode_nops(nops, &hdr);
@@ -2097,17 +2232,19 @@ out:
 /*
  *  a COMMIT request
  */
-static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
+static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p,
+				struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
@@ -2123,17 +2260,19 @@ out:
 /*
  * FSINFO request
  */
-static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsinfo_arg *args)
+static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p,
+				struct nfs4_fsinfo_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
 		status = encode_fsinfo(&xdr, args->bitmask, &hdr);
@@ -2144,17 +2283,19 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 /*
  * a PATHCONF request
  */
-static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct nfs4_pathconf_arg *args)
+static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p,
+				  const struct nfs4_pathconf_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (!status)
 		status = encode_getattr_one(&xdr,
@@ -2167,22 +2308,25 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 /*
  * a STATFS request
  */
-static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs4_statfs_arg *args)
+static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p,
+				const struct nfs4_statfs_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status == 0)
 		status = encode_getattr_two(&xdr,
 				args->bitmask[0] & nfs4_statfs_bitmap[0],
-				args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
+				args->bitmask[1] & nfs4_statfs_bitmap[1],
+				&hdr);
 	encode_nops(nops, &hdr);
 	return status;
 }
@@ -2190,18 +2334,20 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 /*
  * GETATTR_BITMAP request
  */
-static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p, const struct nfs_fh *fhandle)
+static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
+				     struct nfs4_server_caps_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
-	status = encode_putfh(&xdr, fhandle, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
+	status = encode_putfh(&xdr, args->fhandle, &hdr);
 	if (status == 0)
 		status = encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 				FATTR4_WORD0_LINK_SUPPORT|
@@ -2218,7 +2364,7 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
@@ -2226,6 +2372,7 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
 	status = encode_renew(&xdr, clp, &hdr);
+
 	encode_nops(nops, &hdr);
 	return status;
 }
@@ -2237,7 +2384,7 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
@@ -2245,6 +2392,7 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
 	status = encode_setclientid(&xdr, sc, &hdr);
+
 	encode_nops(nops, &hdr);
 	return status;
 }
@@ -2256,7 +2404,7 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops	= 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 	int status;
@@ -2276,17 +2424,19 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 /*
  * DELEGRETURN request
  */
-static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struct nfs4_delegreturnargs *args)
+static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p,
+				     const struct nfs4_delegreturnargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fhandle, &hdr);
 	if (status != 0)
 		goto out;
@@ -2302,11 +2452,12 @@ out:
 /*
  * Encode FS_LOCATIONS request
  */
-static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations_arg *args)
+static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p,
+				      struct nfs4_fs_locations_arg *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	int replen;
@@ -2315,6 +2466,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	if ((status = encode_putfh(&xdr, args->dir_fh, &hdr)) != 0)
 		goto out;
 	if ((status = encode_lookup(&xdr, args->name, &hdr)) != 0)
@@ -2325,7 +2477,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	 *   toplevel_status + OP_PUTFH + status
 	 *   + OP_LOOKUP + status + OP_GETATTR + status = 7
 	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7) << 2;
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_enc_fsinfo_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
 			0, PAGE_SIZE);
 out:
@@ -3963,19 +4115,48 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static int decode_sequence(struct xdr_stream *xdr,
+			   struct nfs41_sequence_res *res,
+			   struct rpc_rqst *rqstp)
+{
+	if (rqstp->rq_task->tk_client->cl_mvers == 0)
+		return 0;
+
+	/* stub */
+
+	return 0;
+}
+#else /* CONFIG_NFS_V4_1 */
+static inline int decode_sequence(struct xdr_stream *xdr,
+			   struct nfs41_sequence_res *res,
+			   struct rpc_rqst *rqstp)
+{
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+/*
+ * END OF "GENERIC" DECODE ROUTINES.
+ */
+
 /*
  * Decode OPEN_DOWNGRADE response
  */
-static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
+static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p,
+					struct nfs_closeres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
 
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
         status = decode_putfh(&xdr);
         if (status)
                 goto out;
@@ -3988,20 +4169,21 @@ out:
 }
 
 /*
- * END OF "GENERIC" DECODE ROUTINES.
- */
-
-/*
  * Decode ACCESS response
  */
-static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_accessres *res)
+static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs4_accessres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 	
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	status = decode_putfh(&xdr);
 	if (status != 0)
@@ -4017,14 +4199,19 @@ out:
 /*
  * Decode LOOKUP response
  */
-static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lookup_res *res)
+static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs4_lookup_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 	
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4040,14 +4227,19 @@ out:
 /*
  * Decode LOOKUP_ROOT response
  */
-static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lookup_res *res)
+static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p,
+				     struct nfs4_lookup_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 	
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putrootfh(&xdr)) != 0)
 		goto out;
@@ -4060,14 +4252,19 @@ out:
 /*
  * Decode REMOVE response
  */
-static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_removeres *res)
+static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs_removeres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 	
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4081,14 +4278,19 @@ out:
 /*
  * Decode RENAME response
  */
-static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_rename_res *res)
+static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs4_rename_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4111,14 +4313,19 @@ out:
 /*
  * Decode LINK response
  */
-static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link_res *res)
+static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p,
+			      struct nfs4_link_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 	
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4144,14 +4351,19 @@ out:
 /*
  * Decode CREATE response
  */
-static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_create_res *res)
+static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs4_create_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
-	
+
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4181,7 +4393,8 @@ static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_c
 /*
  * Decode GETATTR response
  */
-static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_getattr_res *res)
+static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p,
+				 struct nfs4_getattr_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4191,56 +4404,65 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
 	status = decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
-
 }
 
 /*
  * Encode an SETACL request
  */
 static int
-nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
+nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p,
+		     struct nfs_setaclargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
-		.nops   = 0,
+		.minorversion = req->rq_task->tk_client->cl_mvers,
 	};
 	int status;
 	__be32 *nops;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	nops = encode_compound_hdr(&xdr, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	status = encode_putfh(&xdr, args->fh, &hdr);
 	if (status)
 		goto out;
 	status = encode_setacl(&xdr, args, &hdr);
 out:
-	encode_nops(nops, &hdr);
 	return status;
 }
+
 /*
  * Decode SETACL response
  */
 static int
-nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
+nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
+		     struct nfs_setaclres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
+	struct nfs_setattrres *sattrp = NULL;
 	int status;
 
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_setattr(&xdr, res);
+	status = decode_setattr(&xdr, sattrp);
 out:
 	return status;
 }
@@ -4249,7 +4471,8 @@ out:
  * Decode GETACL response
  */
 static int
-nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
+nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
+		     struct nfs_getaclres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4259,10 +4482,13 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p, size_t *acl_len)
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
-	status = decode_getacl(&xdr, rqstp, acl_len);
+	status = decode_getacl(&xdr, rqstp, res->acl_len);
 
 out:
 	return status;
@@ -4271,16 +4497,20 @@ out:
 /*
  * Decode CLOSE response
  */
-static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_closeres *res)
+static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p,
+			       struct nfs_closeres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
 
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
         status = decode_putfh(&xdr);
         if (status)
                 goto out;
@@ -4301,16 +4531,20 @@ out:
 /*
  * Decode OPEN response
  */
-static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
+static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p,
+			      struct nfs_openres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
 
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
         status = decode_putfh(&xdr);
         if (status)
                 goto out;
@@ -4355,16 +4589,20 @@ out:
 /*
  * Decode OPEN response
  */
-static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openres *res)
+static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p,
+				     struct nfs_openres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
 
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
         status = decode_putfh(&xdr);
         if (status)
                 goto out;
@@ -4379,16 +4617,20 @@ out:
 /*
  * Decode SETATTR response
  */
-static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_setattrres *res)
+static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p,
+				 struct nfs_setattrres *res)
 {
-        struct xdr_stream xdr;
-        struct compound_hdr hdr;
-        int status;
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
 
-        xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-        status = decode_compound_hdr(&xdr, &hdr);
-        if (status)
-                goto out;
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
         status = decode_putfh(&xdr);
         if (status)
                 goto out;
@@ -4405,7 +4647,8 @@ out:
 /*
  * Decode LOCK response
  */
-static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_res *res)
+static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p,
+			      struct nfs_lock_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4415,6 +4658,9 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4426,7 +4672,8 @@ out:
 /*
  * Decode LOCKT response
  */
-static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lockt_res *res)
+static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p,
+			       struct nfs_lockt_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4436,6 +4683,9 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4447,7 +4697,8 @@ out:
 /*
  * Decode LOCKU response
  */
-static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_locku_res *res)
+static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p,
+			       struct nfs_locku_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4457,6 +4708,9 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4468,7 +4722,8 @@ out:
 /*
  * Decode READLINK response
  */
-static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
+static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
+				  struct nfs4_readlink_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4478,6 +4733,9 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p, void *res)
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4489,7 +4747,8 @@ out:
 /*
  * Decode READDIR response
  */
-static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_readdir_res *res)
+static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p,
+				 struct nfs4_readdir_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4499,6 +4758,9 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4510,7 +4772,8 @@ out:
 /*
  * Decode Read response
  */
-static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readres *res)
+static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p,
+			      struct nfs_readres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4520,6 +4783,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4533,7 +4799,8 @@ out:
 /*
  * Decode WRITE response
  */
-static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writeres *res)
+static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p,
+			       struct nfs_writeres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4543,6 +4810,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4559,7 +4829,8 @@ out:
 /*
  * Decode COMMIT response
  */
-static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writeres *res)
+static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p,
+				struct nfs_writeres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4569,6 +4840,9 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4583,7 +4857,8 @@ out:
 /*
  * FSINFO request
  */
-static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
+static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
+				struct nfs4_fsinfo_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4592,16 +4867,19 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_fsinfo(&xdr, fsinfo);
+		status = decode_fsinfo(&xdr, res->fsinfo);
 	return status;
 }
 
 /*
  * PATHCONF request
  */
-static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pathconf *pathconf)
+static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
+				  struct nfs4_pathconf_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4610,16 +4888,19 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p, struct nfs_pat
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_pathconf(&xdr, pathconf);
+		status = decode_pathconf(&xdr, res->pathconf);
 	return status;
 }
 
 /*
  * STATFS request
  */
-static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fsstat *fsstat)
+static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
+				struct nfs4_statfs_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4628,23 +4909,30 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p, struct nfs_fssta
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
-		status = decode_statfs(&xdr, fsstat);
+		status = decode_statfs(&xdr, res->fsstat);
 	return status;
 }
 
 /*
  * GETATTR_BITMAP request
  */
-static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4_server_caps_res *res)
+static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p,
+				     struct nfs4_server_caps_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
 	int status;
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
-	if ((status = decode_compound_hdr(&xdr, &hdr)) != 0)
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, req);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
@@ -4709,7 +4997,8 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 /*
  * DELEGRETURN request
  */
-static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_delegreturnres *res)
+static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p,
+				     struct nfs4_delegreturnres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4717,7 +5006,10 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
-	if (status != 0)
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
 		goto out;
 	status = decode_putfh(&xdr);
 	if (status != 0)
@@ -4731,7 +5023,8 @@ out:
 /*
  * FS_LOCATIONS request
  */
-static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations *res)
+static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
+				      struct nfs4_fs_locations_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -4739,14 +5032,18 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
-	if (status != 0)
+	if (status)
+		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, req);
+	if (status)
 		goto out;
 	if ((status = decode_putfh(&xdr)) != 0)
 		goto out;
 	if ((status = decode_lookup(&xdr)) != 0)
 		goto out;
 	xdr_enter_page(&xdr, PAGE_SIZE);
-	status = decode_getfattr(&xdr, &res->fattr, res->server);
+	status = decode_getfattr(&xdr, &res->fs_locations->fattr,
+				 res->fs_locations->server);
 out:
 	return status;
 }
@@ -4877,10 +5174,10 @@ nfs4_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
-	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
-	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
-	.p_arglen = NFS4_##argtype##_sz,			\
-	.p_replen = NFS4_##restype##_sz,			\
+	.p_encode = (kxdrproc_t) nfs4##_xdr_##argtype,	\
+	.p_decode = (kxdrproc_t) nfs4##_xdr_##restype,	\
+	.p_arglen = NFS4##_##argtype##_sz,		\
+	.p_replen = NFS4##_##restype##_sz,		\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
 	.p_name   = #proc,					\
     }
@@ -4922,11 +5219,6 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
 };
 
-#if defined(CONFIG_NFS_V4_1)
-struct rpc_procinfo	nfs41_procedures[] = {
-};
-#endif /* CONFIG_NFS_V4_1 */
-
 struct rpc_version      nfs_version4 = {
 	.number                 = 4,
 	.nrprocs                = ARRAY_SIZE(nfs4_procedures),
@@ -4936,8 +5228,9 @@ struct rpc_version      nfs_version4 = {
 #ifdef CONFIG_NFS_V4_1
 struct rpc_version      nfs_version41 = {
 	.number                 = 4,
-	.nrprocs                = ARRAY_SIZE(nfs41_procedures),
-	.procs                  = nfs41_procedures
+	.minorversion		= 1,
+	.nrprocs                = ARRAY_SIZE(nfs4_procedures),
+	.procs                  = nfs4_procedures
 };
 
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 99d4f9e..77c03a4 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -32,6 +32,7 @@ struct rpc_clnt {
 	struct rpc_procinfo *	cl_procinfo;	/* procedure info */
 	u32			cl_prog,	/* RPC program number */
 				cl_vers,	/* RPC version number */
+				cl_mvers,	/* RPC minorversion number */
 				cl_maxproc;	/* max procedure number */
 
 	char *			cl_server;	/* server machine name */
@@ -82,6 +83,7 @@ get_rpc_version(struct rpc_program *prog, u32 vers, int minorvers)
 
 struct rpc_version {
 	u32			number;		/* version number */
+	u32			minorversion;	/* minorversion number */
 	unsigned int		nrprocs;	/* number of procs */
 	struct rpc_procinfo *	procs;		/* procedure array */
 };
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 44f251d..0c8e5f1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -177,6 +177,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	clnt->cl_protname = program->name;
 	clnt->cl_prog     = args->prognumber ? : program->number;
 	clnt->cl_vers     = version->number;
+	clnt->cl_mvers    = version->minorversion;
 	clnt->cl_stats    = program->stats;
 	clnt->cl_metrics  = rpc_alloc_iostats(clnt);
 	err = -ENOMEM;
@@ -491,6 +492,7 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 	clnt->cl_protname = program->name;
 	clnt->cl_prog     = program->number;
 	clnt->cl_vers     = version->number;
+	clnt->cl_mvers    = version->minorversion;
 	clnt->cl_stats    = program->stats;
 	err = rpc_ping(clnt, RPC_TASK_SOFT);
 	if (err != 0) {
-- 
1.6.0.2

