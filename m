From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 27/67] nfs41: xdr {encode,decode}_sequence
Date: Thu,  2 Apr 2009 16:54:02 +0300
Message-ID: <1238680442-14245-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14712 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758786AbZDBNyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:54:20 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
[nfs41: pass *session in seq_args and seq_res]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  242 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 232 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 19ca0b5..5b944cd 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -244,43 +244,63 @@ static int nfs4_stat_to_errno(int);
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
@@ -1385,6 +1454,24 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
+
+/* NFSv4.1 operations */
+static void encode_sequence(struct xdr_stream *xdr,
+			    const struct nfs4_sequence_args *args,
+			    struct compound_hdr *hdr)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs4_session *session = args->sa_session;
+
+	if (!session)
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
@@ -1410,6 +1497,7 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_access(&xdr, args->access, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1429,6 +1517,7 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_getfh(&xdr, &hdr);
@@ -1449,6 +1538,7 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_getfh(&xdr, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1468,6 +1558,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_remove(&xdr, &args->name, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1487,6 +1578,7 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->old_dir, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->new_dir, &hdr);
@@ -1510,6 +1602,7 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
@@ -1533,6 +1626,7 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_create(&xdr, args, &hdr);
@@ -1564,6 +1658,7 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1582,6 +1677,7 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1601,6 +1697,7 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_open(&xdr, args, &hdr);
@@ -1642,6 +1739,7 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1661,6 +1759,7 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_downgrade(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1680,6 +1779,7 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1698,6 +1798,7 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1716,6 +1817,7 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1734,6 +1836,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
@@ -1755,6 +1858,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
@@ -1779,6 +1883,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
@@ -1801,6 +1906,7 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_setattr(&xdr, args, args->server, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1823,6 +1929,7 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	replen = hdr.replen + nfs4_fattr_bitmap_maxsz + 1;
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
@@ -1845,6 +1952,7 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
@@ -1865,6 +1973,7 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_commit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1884,6 +1993,7 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1902,6 +2012,7 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
@@ -1921,6 +2032,7 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
@@ -1941,6 +2053,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
@@ -2016,6 +2129,7 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_delegreturn(&xdr, args->stateid, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2036,6 +2150,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	replen = hdr.replen;	/* get the attribute into args->page */
@@ -3762,6 +3877,20 @@ static int decode_delegreturn(struct xdr_stream *xdr)
 	return decode_op_hdr(xdr, OP_DELEGRETURN);
 }
 
+static int decode_sequence(struct xdr_stream *xdr,
+			   struct nfs4_sequence_res *res,
+			   struct rpc_rqst *rqstp)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (!res->sr_session)
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
@@ -3779,6 +3908,9 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -3800,7 +3932,11 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_ac
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
@@ -3823,7 +3959,11 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_lo
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
@@ -3846,7 +3986,11 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp, __be32 *p, struct nf
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
@@ -3866,7 +4010,11 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_rem
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
@@ -3887,7 +4035,11 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
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
@@ -3917,7 +4069,11 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_link
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
@@ -3950,7 +4106,11 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_cr
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
@@ -3990,6 +4150,9 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_g
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4012,6 +4175,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -4033,6 +4197,9 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4056,6 +4223,9 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4078,6 +4248,9 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, __be32 *p, struct nfs_clos
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4108,6 +4281,9 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4162,6 +4338,9 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4186,6 +4365,9 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4210,6 +4392,9 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock_
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4231,6 +4416,9 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4252,6 +4440,9 @@ static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, __be32 *p, struct nfs_lock
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4274,6 +4465,9 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4295,6 +4489,9 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_r
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4316,6 +4513,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, __be32 *p, struct nfs_readr
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4339,6 +4539,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, __be32 *p, struct nfs_writ
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4365,6 +4568,9 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, __be32 *p, struct nfs_wri
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	status = decode_sequence(&xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
 	status = decode_putfh(&xdr);
 	if (status)
 		goto out;
@@ -4389,6 +4595,8 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, res->fsinfo);
@@ -4408,6 +4616,8 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_pathconf(&xdr, res->pathconf);
@@ -4427,6 +4637,8 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, __be32 *p,
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
+		status = decode_sequence(&xdr, &res->seq_res, req);
+	if (!status)
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_statfs(&xdr, res->fsstat);
@@ -4443,7 +4655,11 @@ static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req, __be32 *p, struct nfs4
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
@@ -4516,7 +4732,10 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 
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
@@ -4539,7 +4758,10 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req, __be32 *p,
 
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
1.6.2.1

