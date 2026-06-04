Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 115053DCDAB
	for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2026 20:24:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780604649; cv=none; b=joxQQOapmxfyLzxeXIC7J4IKBicW0ArNHVhSl/M3gF1LZyfCe6k6BWwiv/xrZ7w86pxPU5OjY9xjjHWqf1MotggLnCxf+jcSkO5uhZRQn5eIhqYtx/czIoPTSmiS1AbDvdSLgeY+K4JWU5H0CqCQ0abbC/B5uBYyOCYvfb2yX5Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780604649; c=relaxed/simple;
	bh=2x3nCaA9q1Rfx35a4ZXPboLzJEGR/wbl+zgT8sV8sPs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JqnZKK4kuVU9X4hcAmBSrRmhK5zgNKlmjQvKZBblQvlsoprVujpaRW5ZXM1F3SVxgU9Uol30DS/IhmVF++U3XoODMvDBJzZuMjHjQN8TQH4V+yNEq6/oV5HRuslKYZAK5E0FsNHq8XpFY6Yqw8HNgA1M4WETHORAE0WsetOaRh0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kthY1V0T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kthY1V0T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79B911F00893;
	Thu,  4 Jun 2026 20:24:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780604647;
	bh=SwZE2C2lYlzWm2jMR0V0ptBfUMYyL6MhYJHv/DeMVRI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kthY1V0TNSv9HdlYYuD77l2l/lK+GyVK0yZ2O4OrZpkc5QJfViAjXYlkeARrdrTwm
	 FnDy/hD7t3SGpc1ZIjNEWcJZ6hPVoOJzgZcyvepWbWYQDV12S2DDz9LlVUFzT7beCg
	 XJQdJisnY8i4YY+wX5yRsO150mMpTYVJBGloJtjy5U5NYzDooMCw/RB7ljGZthFwfi
	 iLGuvDcFMeDrJmGGVyfPNEqpY+net/s+0lVz0jGl/wAd3zntz3zR+cu+z5MWNhNIrG
	 jWzja+ILcLT/owLHHVSCK7qXKliQmmC1xxnMNFIrqnv34qdJHtEYFgW0M0raliOH8L
	 litPUmwYB9v3A==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write
Date: Thu,  4 Jun 2026 16:24:03 -0400
Message-ID: <20260604202403.20856-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260604202403.20856-1-snitzer@kernel.org>
References: <20260604202403.20856-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The FF_FLAGS_NO_IO_THRU_MDS flag lives on each lseg, so any fallback
decision made when there is no current lseg (e.g. between LAYOUTRETURN
and the next LAYOUTGET) cannot run the per-lseg check.

Introduce a sticky hdr-level ditto for FF_FLAGS_NO_IO_THRU_MDS in
struct nfs4_flexfile_layout::flags (NFS4_FF_HDR_NO_IO_THRU_MDS bit),
set whenever ff_layout_alloc_lseg() parses an lseg with the flag.  The
bit is never cleared for the lifetime of the layout hdr; the server is
assumed to be consistent in its no-fallback policy per file.
kzalloc() in ff_layout_alloc_layout_hdr() zero-initializes the field.

Use the new ff_layout_hdr_no_fallback_to_mds() helper to gate
ff_layout_pg_get_mirror_count_write(): when pnfs_update_layout() returns
NULL (e.g. NFS_LAYOUT_BULK_RECALL, pnfs_layout_io_test_failed,
pnfs_layoutgets_blocked) the existing code unconditionally calls
nfs_pageio_reset_write_mds().  This is a source of unwanted WRITE to
MDS.  Fix it by checking NFS4_FF_HDR_NO_IO_THRU_MDS bit, and if set
surface -EAGAIN instead; the writepage-side caller (nfs_do_writepage()
for buffered, nfs_direct_write_reschedule() for O_DIRECT) then
redirties the request so writeback retries via pNFS.

Fixes: 260074cd8413 ("pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS")
Assisted-by: Claude:claude-opus-4-7
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 13 +++++++++++++
 fs/nfs/flexfilelayout/flexfilelayout.h | 16 ++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 38bcd260e0a91..a63f90be11dfd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -636,6 +636,9 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	if (!p)
 		goto out_sort_mirrors;
 	fls->flags = be32_to_cpup(p);
+	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS)
+		set_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
+			&FF_LAYOUT_FROM_HDR(lh)->flags);
 
 	p = xdr_inline_decode(&stream, 4);
 	if (!p)
@@ -1185,6 +1188,16 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
+	if (NFS_I(pgio->pg_inode)->layout &&
+	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
+		/*
+		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
+		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
+		 * retries rather than silently issuing the WRITE via MDS.
+		 */
+		pgio->pg_error = -EAGAIN;
+		goto out;
+	}
 	/* no lseg means that pnfs is not in use, so no mirroring here */
 	nfs_pageio_reset_write_mds(pgio);
 out:
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 17a008c8e97ce..a5bd00f69e824 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -112,12 +112,16 @@ struct nfs4_ff_layout_segment {
 	struct nfs4_ff_layout_mirror	*mirror_array[] __counted_by(mirror_array_cnt);
 };
 
+/* nfs4_flexfile_layout::flags bit indices */
+#define NFS4_FF_HDR_NO_IO_THRU_MDS  0   /* any lseg has had FF_FLAGS_NO_IO_THRU_MDS */
+
 struct nfs4_flexfile_layout {
 	struct pnfs_layout_hdr generic_hdr;
 	struct pnfs_ds_commit_info commit_info;
 	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
 	ktime_t			last_report_time; /* Layoutstat report times */
+	unsigned long		flags;
 };
 
 struct nfs4_flexfile_layoutreturn_args {
@@ -184,6 +188,18 @@ ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
 	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_IO_THRU_MDS;
 }
 
+/*
+ * Sticky hdr-level mirror of FF_FLAGS_NO_IO_THRU_MDS so callers that have
+ * no current lseg (e.g. between LAYOUTRETURN and the next LAYOUTGET) can
+ * still honor the no-MDS-fallback policy.
+ */
+static inline bool
+ff_layout_hdr_no_fallback_to_mds(struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
+			&FF_LAYOUT_FROM_HDR(lo)->flags);
+}
+
 static inline bool
 ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 {
-- 
2.44.0

