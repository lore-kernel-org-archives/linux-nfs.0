Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D075E3E5A08
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 21:09:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785186591; cv=none; b=A3WO7HJ7uZ6nw6NbvfvRQJ/u5u77qeicavtW0Ln2kAoDQDyowiWfvhEEwtMdAxI4SOAxtm0O6duIDV1KZULI3uWEr364yz/oyeUsdVEipIRey0wqWVGDldm8cZgQudxOUY0EZFZhvlRdQUYDPhpYHdOf+vHIoKbAAijqPhd84rY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785186591; c=relaxed/simple;
	bh=VYR10FeO1FiTcB+AprvL3PcJMMNF/Z47uQ5YtITgSSU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=B5dFBRTv9xFMEsETSpz5sXzRDFaSAAtbvlD7fb7hzocxyiNEq97jIFY+FpxJcBR17j42EIgzwX7Gu9Gp44IxetmNq81o3ZvX6WyUldHUJyQf0bS3AB3YkwbfxJqwvbtuCAIqdHYNNuZBF+leuOM+d/JIk+fKIo8XVLJXnMka06A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=apdvFPpf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="apdvFPpf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C52C1F000E9;
	Mon, 27 Jul 2026 21:09:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785186589;
	bh=dLeY+gUCOIee89iw7hzzlaAHumxGVvlcPeRVHj8nMpo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=apdvFPpfchZha1MsnldkKZXH5TUAzkMESGYJrT0VEE/e6QzKzuEWK3tZmmaWRt+FB
	 ALQyh+cyElZgyiwXp0bB/mXZ/ArTpPHCJvTKhTdpsB1xaIRmdpfFwE8vGiHK8DZ9oO
	 IwRCeZQXJ+T853tBs4+ZcChl+DrOs2Nb6o8zH/DT4BOU8HLci6S/KUv1GAyRCyMeoa
	 fdDmWPYUzjH+kI2A/ViZAzofytMq+LRBkxcp3syXJo9hO1b63qi0TmEmkPy16nda5t
	 NnNRXxAV0/nqMdDr39vk70EkyqcdE7hgD7eTIXSQUUfeXzvFV1joDxHkN1D9LtuLzi
	 yPUB3TcwxAHEw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 4/6] nfs4.2: add UNCACHEABLE_DIRENT_METADATA attribute support
Date: Mon, 27 Jul 2026 17:09:41 -0400
Message-ID: <67fa3924952bb75d2c68af3844ee3a7e9b11a73c.1785140181.git.snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <cover.1785140181.git.snitzer@kernel.org>
References: <cover.1785140181.git.snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Recognize the NFSv4.2 per-directory UNCACHEABLE_DIRENT_METADATA attribute
(attr 88, draft-ietf-nfsv4-uncacheable-directories): decode it via
GETATTR, track per-exported-filesystem support, and record on the inode
whether a directory's directory-entry metadata must not be cached.
Honoring the attribute (refetching directory-entry metadata from the
server on each READDIR) is done by a subsequent change.

If the NFSv4 server reports a directory's UNCACHEABLE_DIRENT_METADATA as
true, it indicates the directory's directory-entry metadata must not be
cached; the client records this in
NFS_I(inode)->uncacheable_dirent_metadata for use by the readdir path.

The UNCACHEABLE_DIRENT_METADATA attribute applies only to directory
objects (NF4DIR) and is independent of the companion
UNCACHEABLE_FILE_DATA attribute (attr 87); the two govern different
aspects of client caching and may be used separately.  A subsequent
commit gates the client accordingly so the attribute is requested only
for directories.

Unlike the per-file UNCACHEABLE_FILE_DATA attribute -- which is requested
lazily and kept coherent via an NFS_INO_INVALID_UNCACHEABLE_FILE_DATA
cache-validity bit -- this directory attribute is deliberately not tied
to the cache_validity / file-delegation machinery
(nfs4_bitmap_copy_adjust()'s delegation block, nfs4_bitmask_set()) and
needs no invalidation bit of its own.  It is requested unconditionally
for directories via the nfs4_bitmap_copy_adjust() type gate, so it is
refetched on every directory GETATTR and cannot go stale.  (A directory
cannot hold an NFSv4 read/write delegation, and per the draft a server
must recall or withhold a directory delegation while the attribute is
set, so there is never an authoritative cached state to optimize
against; an invalidation bit would only be useful alongside a lazy
re-request path such as nfs4_bitmask_set(), which is not type-gated and
would request a directory-only attribute on regular files ->
NFS4ERR_INVAL.)
A comment at the inode recording site documents this deliberate asymmetry.

Link: https://datatracker.ietf.org/doc/draft-ietf-nfsv4-uncacheable-directories/

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/inode.c          | 15 +++++++++++++++
 fs/nfs/nfs4proc.c       |  4 +++-
 fs/nfs/nfs4trace.h      |  3 ++-
 fs/nfs/nfs4xdr.c        | 31 ++++++++++++++++++++++++++++++-
 include/linux/nfs4.h    |  9 +++++++++
 include/linux/nfs_fs.h  |  1 +
 include/linux/nfs_xdr.h |  5 ++++-
 7 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bb6e58123341..215d96b3e059 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -508,6 +508,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		nfsi->write_io = 0;
 		nfsi->read_io = 0;
 		nfsi->uncacheable_file_data = false;
+		nfsi->uncacheable_dirent_metadata = false;
 
 		nfsi->read_cache_jiffies = fattr->time_start;
 		nfsi->attr_gencount = fattr->gencount;
@@ -568,6 +569,16 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		else if (S_ISREG(inode->i_mode) &&
 			 (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_UNCACHEABLE_FILE_DATA);
+		/*
+		 * No invalidation bit for uncacheable_dirent_metadata: unlike
+		 * uncacheable_file_data, attr 88 is requested unconditionally
+		 * for directories via the nfs4_bitmap_copy_adjust() type gate,
+		 * so it is refetched on every directory getattr and cannot go
+		 * stale.
+		 */
+		if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA)
+			nfsi->uncacheable_dirent_metadata =
+				fattr->aux_flags & NFS_AUX_UNCACHEABLE_DIRENT_METADATA;
 
 		nfs_setsecurity(inode, fattr);
 
@@ -2479,6 +2490,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		nfsi->cache_validity |=
 			save_cache_validity & NFS_INO_INVALID_UNCACHEABLE_FILE_DATA;
 
+	if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA)
+		nfsi->uncacheable_dirent_metadata =
+				fattr->aux_flags & NFS_AUX_UNCACHEABLE_DIRENT_METADATA;
+
 	/* Update attrtimeo value if we're out of the unstable period */
 	if (attr_changed) {
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e1dbdee65bb..35156c54dac3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3881,7 +3881,7 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 #define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
 #define FATTR4_WORD2_NFS41_MASK (2*FATTR4_WORD2_SUPPATTR_EXCLCREAT - 1UL)
-#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_UNCACHEABLE_FILE_DATA - 1UL)
+#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA - 1UL)
 
 #define FATTR4_WORD2_NFS42_TIME_DELEG_MASK \
 	(FATTR4_WORD2_TIME_DELEG_MODIFY|FATTR4_WORD2_TIME_DELEG_ACCESS)
@@ -4007,6 +4007,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
 		if (!(res.attr_bitmask[2] & FATTR4_WORD2_UNCACHEABLE_FILE_DATA))
 			server->fattr_valid &= ~NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA;
+		if (!(res.attr_bitmask[2] & FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA))
+			server->fattr_valid &= ~NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA;
 
 		if (res.open_caps.oa_share_access_want[0] &
 		    NFS4_SHARE_WANT_OPEN_XOR_DELEGATION)
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 3298dab34a78..868c201d024f 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -34,7 +34,8 @@
 		{ NFS_ATTR_FATTR_OWNER_NAME, "OWNER_NAME" }, \
 		{ NFS_ATTR_FATTR_GROUP_NAME, "GROUP_NAME" }, \
 		{ NFS_ATTR_FATTR_BTIME, "BTIME" }, \
-		{ NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA, "UNCACHEABLE_FILE_DATA" })
+		{ NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA, "UNCACHEABLE_FILE_DATA" }, \
+		{ NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA, "UNCACHEABLE_DIRENT_METADATA" })
 
 DECLARE_EVENT_CLASS(nfs4_clientid_event,
 		TP_PROTO(
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc049ce4ba8a..8329d5baf90e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -121,7 +121,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 				nfs4_owner_maxsz + \
 				nfs4_group_maxsz + nfs4_label_maxsz + \
 				 decode_mdsthreshold_maxsz + \
-				 1)) /* uncacheable_file_data */
+				 1)) /* uncacheable_file_data / dirent_metadata */
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
 				nfs4_fattr_value_maxsz)
 #define decode_getattr_maxsz    (op_decode_hdr_maxsz + nfs4_fattr_maxsz)
@@ -4405,6 +4405,30 @@ static int decode_attr_uncacheable_file_data(struct xdr_stream *xdr, uint32_t *b
 	return status;
 }
 
+static int decode_attr_uncacheable_dirent_metadata(struct xdr_stream *xdr, uint32_t *bitmap,
+				   uint32_t *res, uint64_t *flags)
+{
+	int status = 0;
+	__be32 *p;
+
+	if (unlikely(bitmap[2] & (FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA - 1U)))
+		return -EIO;
+	if (likely(bitmap[2] & FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
+		if (be32_to_cpup(p))
+			*res |= NFS_AUX_UNCACHEABLE_DIRENT_METADATA;
+		else
+			*res &= ~NFS_AUX_UNCACHEABLE_DIRENT_METADATA;
+		bitmap[2] &= ~FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA;
+		*flags |= NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA;
+	}
+	dprintk("%s: uncacheable_dirent_metadata: =%s\n", __func__,
+		(*res & NFS_AUX_UNCACHEABLE_DIRENT_METADATA) == 0 ? "false" : "true");
+	return status;
+}
+
 static int verify_attr_len(struct xdr_stream *xdr, unsigned int savep, uint32_t attrlen)
 {
 	unsigned int attrwords = XDR_QUADLEN(attrlen);
@@ -4875,6 +4899,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (status < 0)
 		goto xdr_error;
 
+	status = decode_attr_uncacheable_dirent_metadata(xdr, bitmap, &fattr->aux_flags,
+					 &fattr->valid);
+	if (status < 0)
+		goto xdr_error;
+
 	status = 0;
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1a3981c26b23..a30905cb4118 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -397,6 +397,14 @@ enum {
 	FATTR4_UNCACHEABLE_FILE_DATA	= 87,
 };
 
+/*
+ * Symbol name and value are from draft-ietf-nfsv4-uncacheable-directories
+ * Section 8.  "XDR for Uncacheable Dirents Attribute"
+ */
+enum {
+	FATTR4_UNCACHEABLE_DIRENT_METADATA	= 88,
+};
+
 /*
  * The following internal definitions enable processing the above
  * attribute bits within 32-bit word boundaries.
@@ -484,6 +492,7 @@ enum {
 #define FATTR4_WORD2_POSIX_DEFAULT_ACL	BIT(FATTR4_POSIX_DEFAULT_ACL - 64)
 #define FATTR4_WORD2_POSIX_ACCESS_ACL	BIT(FATTR4_POSIX_ACCESS_ACL - 64)
 #define FATTR4_WORD2_UNCACHEABLE_FILE_DATA	BIT(FATTR4_UNCACHEABLE_FILE_DATA - 64)
+#define FATTR4_WORD2_UNCACHEABLE_DIRENT_METADATA	BIT(FATTR4_UNCACHEABLE_DIRENT_METADATA - 64)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 48b806aa3a2f..887b76c2a5dd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -164,6 +164,7 @@ struct nfs_inode {
 	struct timespec64	btime;
 
 	bool			uncacheable_file_data : 1;
+	bool			uncacheable_dirent_metadata : 1;
 
 	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e1987ac403d..2018cc3c9c31 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -19,6 +19,7 @@
 
 /* aux_flags in nfs_fattr */
 #define NFS_AUX_UNCACHEABLE_FILE_DATA	BIT(0)
+#define NFS_AUX_UNCACHEABLE_DIRENT_METADATA	BIT(1)
 
 struct nfs4_string {
 	unsigned int len;
@@ -113,6 +114,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_V4_SECURITY_LABEL BIT_ULL(25)
 #define NFS_ATTR_FATTR_BTIME		BIT_ULL(26)
 #define NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA	BIT_ULL(27)
+#define NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA	BIT_ULL(28)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -135,7 +137,8 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_SPACE_USED \
 		| NFS_ATTR_FATTR_BTIME \
 		| NFS_ATTR_FATTR_V4_SECURITY_LABEL \
-		| NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
+		| NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA \
+		| NFS_ATTR_FATTR_UNCACHEABLE_DIRENT_METADATA)
 
 /*
  * Maximal number of supported layout drivers.
-- 
2.47.3

