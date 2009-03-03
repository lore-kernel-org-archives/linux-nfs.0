From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 29/46] nfs41: xdr {encode,decode}_sequence
Date: Wed,  4 Mar 2009 01:58:53 +0200
Message-ID: <1236124733-3787-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17736
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753641AbZCCX7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:59:11 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement stubs for encode and decode sequence, defined as no-ops when
CONFIG_NFS_V4_1 is not defined.
Add the nfsv41 encode and decode sizes. Add encode_sequence to all
nfs4_enc_* routines and decode_sequence to all nfs4_dec_* routines as required
by v41.

[was nfs41: minorversion support for xdr]
[added nfs_client argument to encode_sequence so not to use sequence_args to pass sa_session]
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  244 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 234 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9cec237..14af88a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -244,43 +244,63 @@ static int nfs4_stat_to_errno(int);
 				(encode_getattr_maxsz)
 #define decode_fs_locations_maxsz \
 				(decode_getattr_maxsz)
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
 #define NFS4_enc_open_sz        (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_open_maxsz + \
@@ -289,6 +309,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_open_sz        (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_open_maxsz + \
@@ -305,43 +326,53 @@ static int nfs4_stat_to_errno(int);
 				 decode_putfh_maxsz + \
 				 decode_open_confirm_maxsz)
 #define NFS4_enc_open_noattr_sz	(compound_encode_hdr_maxsz + \
+					encode_sequence_maxsz + \
 					encode_putfh_maxsz + \
 					encode_open_maxsz + \
 					encode_getattr_maxsz)
 #define NFS4_dec_open_noattr_sz	(compound_decode_hdr_maxsz + \
+					decode_sequence_maxsz + \
 					decode_putfh_maxsz + \
 					decode_open_maxsz + \
 					decode_getattr_maxsz)
 #define NFS4_enc_open_downgrade_sz \
 				(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_open_downgrade_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_open_downgrade_sz \
 				(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_open_downgrade_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_close_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_close_maxsz + \
 				 decode_getattr_maxsz)
 #define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_setattr_maxsz + \
 				 encode_getattr_maxsz)
 #define NFS4_dec_setattr_sz	(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
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
@@ -363,64 +394,81 @@ static int nfs4_stat_to_errno(int);
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
+				 decode_sequence_maxsz + \
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
 				decode_remove_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_rename_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
@@ -429,6 +477,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_rename_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
@@ -437,6 +486,7 @@ static int nfs4_stat_to_errno(int);
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_link_sz	(compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
 				encode_savefh_maxsz + \
 				encode_putfh_maxsz + \
@@ -445,6 +495,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_dec_link_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_putfh_maxsz + \
@@ -453,16 +504,19 @@ static int nfs4_stat_to_errno(int);
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
@@ -471,6 +525,7 @@ static int nfs4_stat_to_errno(int);
 				encode_restorefh_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_create_sz	(compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_savefh_maxsz + \
 				decode_create_maxsz + \
@@ -479,49 +534,63 @@ static int nfs4_stat_to_errno(int);
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
+				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_lookup_maxsz + \
 				 encode_fs_locations_maxsz)
 #define NFS4_dec_fs_locations_sz \
 				(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
@@ -1388,6 +1457,23 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
+
+/* NFSv4.1 operations */
+static void encode_sequence(struct xdr_stream *xdr,
+			    const struct nfs_client *clp,
+			    const struct nfs4_sequence_args *args,
+			    struct compound_hdr *hdr)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (!clp->cl_minorversion)
+		return;
+
+	/* stub */
+	hdr->nops++;
+	hdr->replen += decode_sequence_maxsz;
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */
@@ -1406,6 +1492,7 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_access(&xdr, args->access, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1427,6 +1514,7 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_getfh(&xdr, &hdr);
@@ -1449,6 +1537,7 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_getfh(&xdr, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1470,6 +1559,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_remove(&xdr, &args->name, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1491,6 +1581,7 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->old_dir, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->new_dir, &hdr);
@@ -1516,6 +1607,7 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
@@ -1541,6 +1633,7 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_create(&xdr, args, &hdr);
@@ -1574,6 +1667,7 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1594,6 +1688,7 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1615,6 +1710,7 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_open(&xdr, args, &hdr);
@@ -1658,6 +1754,7 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1679,6 +1776,7 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_downgrade(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1700,6 +1798,7 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1720,6 +1819,7 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1740,6 +1840,7 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1760,6 +1861,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
@@ -1783,6 +1885,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
@@ -1809,6 +1912,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
@@ -1833,6 +1937,7 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_setattr(&xdr, args, args->server, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1856,6 +1961,7 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
@@ -1879,6 +1985,7 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
@@ -1901,6 +2008,7 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_commit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1922,6 +2030,7 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1942,6 +2051,7 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
@@ -1963,6 +2073,7 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
@@ -1985,6 +2096,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
@@ -2062,6 +2174,7 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_delegreturn(&xdr, args->stateid, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2083,6 +2196,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
@@ -3720,6 +3834,23 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+static int decode_sequence(struct xdr_stream *xdr,
+			   struct nfs4_sequence_res *res,
+			   struct rpc_rqst *rqstp)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs_client *clp =
+		(struct nfs_client *)rqstp->rq_task->tk_client->cl_private;
+
+	if (clp->cl_minorversion == 0)
+		return 0;
+
+	/* stub */
+#endif /* CONFIG_NFS_V4_1 */
+
+	return 0;
+}
+
 /*
  * END OF "GENERIC" DECODE ROUTINES.
  */
@@ -3737,6 +3868,9 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -3758,7 +3892,11 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
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
@@ -3781,7 +3919,11 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
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
@@ -3804,7 +3946,11 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
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
@@ -3824,7 +3970,11 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
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
@@ -3845,7 +3995,11 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
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
@@ -3875,7 +4029,11 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
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
@@ -3908,7 +4066,11 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
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
@@ -3948,6 +4110,9 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -3972,6 +4137,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -3993,6 +4159,9 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4016,6 +4185,9 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4038,6 +4210,9 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4068,6 +4243,9 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4122,6 +4300,9 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4146,6 +4327,9 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4172,6 +4356,9 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4193,6 +4380,9 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4214,6 +4404,9 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4236,6 +4429,9 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4257,6 +4453,9 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4278,6 +4477,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4301,6 +4503,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4327,6 +4532,9 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4351,6 +4559,8 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, res->fsinfo);
@@ -4370,6 +4580,8 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_pathconf(&xdr, res->pathconf);
@@ -4389,6 +4601,8 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_statfs(&xdr, res->fsstat);
@@ -4405,7 +4619,11 @@ static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4
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
@@ -4478,7 +4696,10 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 
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
@@ -4501,7 +4722,10 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 
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
-- 
1.6.1.3

