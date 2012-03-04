Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38040 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755953Ab2CDXDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Mar 2012 18:03:13 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] NFSv4: Simplify the struct nfs4_stateid
Date: Sun,  4 Mar 2012 18:03:00 -0500
Message-Id: <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h     |    4 ++--
 fs/nfs/nfs4proc.c    |    8 ++++----
 fs/nfs/nfs4state.c   |    4 ++--
 fs/nfs/nfs4xdr.c     |    6 +++---
 fs/nfs/pnfs.c        |   10 +++++-----
 include/linux/nfs4.h |    7 ++-----
 6 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f4cafab..4b4e48b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -349,12 +349,12 @@ extern struct svc_version nfs4_callback_version4;
 
 static inline void nfs4_stateid_copy(nfs4_stateid *dst, const nfs4_stateid *src)
 {
-	memcpy(dst->data, src->data, sizeof(dst->data));
+	memcpy(dst, src, sizeof(*dst));
 }
 
 static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_stateid *src)
 {
-	return memcmp(dst->data, src->data, sizeof(dst->data)) == 0;
+	return memcmp(dst, src, sizeof(*dst)) == 0;
 }
 
 #else
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e65766..5d90dc8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6257,13 +6257,13 @@ static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
 		const nfs4_stateid *s2)
 {
-	if (memcmp(s1->stateid.other, s2->stateid.other,
-		   sizeof(s1->stateid.other)) != 0)
+	if (memcmp(s1->other, s2->other,
+		   sizeof(s1->other)) != 0)
 		return false;
 
-	if (s1->stateid.seqid == s2->stateid.seqid)
+	if (s1->seqid == s2->seqid)
 		return true;
-	if (s1->stateid.seqid == 0 || s1->stateid.seqid == 0)
+	if (s1->seqid == 0 || s1->seqid == 0)
 		return true;
 
 	return false;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 41e2b44..0b17ccc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1215,8 +1215,8 @@ restart:
 				 * Open state on this file cannot be recovered
 				 * All we can do is revert to using the zero stateid.
 				 */
-				memset(state->stateid.data, 0,
-					sizeof(state->stateid.data));
+				memset(&state->stateid, 0,
+					sizeof(state->stateid));
 				/* Mark the file as being 'closed' */
 				state->state = 0;
 				break;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 38736dc..76ef986 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -930,7 +930,7 @@ static void encode_nops(struct compound_hdr *hdr)
 
 static void encode_nfs4_stateid(struct xdr_stream *xdr, const nfs4_stateid *stateid)
 {
-	encode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+	encode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
 }
 
 static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *verf)
@@ -1548,7 +1548,7 @@ static void encode_open_stateid(struct xdr_stream *xdr, const struct nfs_open_co
 	if (ctx->state != NULL) {
 		nfs4_select_rw_stateid(&stateid, ctx->state, l_ctx->lockowner, l_ctx->pid);
 		if (zero_seqid)
-			stateid.stateid.seqid = 0;
+			stateid.seqid = 0;
 		encode_nfs4_stateid(xdr, &stateid);
 	} else
 		encode_nfs4_stateid(xdr, &zero_stateid);
@@ -4237,7 +4237,7 @@ static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
 
 static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 {
-	return decode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+	return decode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
 }
 
 static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c190e9c..6f1c1e3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -496,12 +496,12 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 {
 	u32 oldseq, newseq;
 
-	oldseq = be32_to_cpu(lo->plh_stateid.stateid.seqid);
-	newseq = be32_to_cpu(new->stateid.seqid);
+	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
+	newseq = be32_to_cpu(new->seqid);
 	if ((int)(newseq - oldseq) > 0) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
 		if (update_barrier) {
-			u32 new_barrier = be32_to_cpu(new->stateid.seqid);
+			u32 new_barrier = be32_to_cpu(new->seqid);
 
 			if ((int)(new_barrier - lo->plh_barrier))
 				lo->plh_barrier = new_barrier;
@@ -525,7 +525,7 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 			int lget)
 {
 	if ((stateid) &&
-	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
+	    (int)(lo->plh_barrier - be32_to_cpu(stateid->seqid)) >= 0)
 		return true;
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
@@ -759,7 +759,7 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
 		}
 	if (!found) {
 		struct pnfs_layout_hdr *lo = nfsi->layout;
-		u32 current_seqid = be32_to_cpu(lo->plh_stateid.stateid.seqid);
+		u32 current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
 
 		/* Since close does not return a layout stateid for use as
 		 * a barrier, we choose the worst-case barrier.
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 32345c2..834df8b 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -183,15 +183,12 @@ struct nfs4_acl {
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
 
-struct nfs41_stateid {
+struct nfs_stateid4 {
 	__be32 seqid;
 	char other[NFS4_STATEID_OTHER_SIZE];
 } __attribute__ ((packed));
 
-typedef union {
-	char data[NFS4_STATEID_SIZE];
-	struct nfs41_stateid stateid;
-} nfs4_stateid;
+typedef struct nfs_stateid4 nfs4_stateid;
 
 enum nfs_opnum4 {
 	OP_ACCESS = 3,
-- 
1.7.7.6

