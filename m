Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56E6E4E780F
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610881; cv=none; b=MAtLdXTjBo6L/fo65JLG9FHVviHQzsOLKosjki2FmvOUjKO494OXfFtW8ccI8A30y5a+ZxE3VzJTTdg+hx9LYG7h2Du0W4CJxsSRSPZQi/oZikqwTUUs04LoxPTkg1ccf9A4OoyNF8Wm7oY3Ua0B+1a0dzg1FiJrAAbPgklxUrU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610881; c=relaxed/simple;
	bh=S5FKSB8ydLeYsUDK0iF9nmTqw3HZlO6iWfEJ1QGS1Bc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GKlydmdXtYUp3oKq7gNV5L8sDfkU1smd3jDZmnyeAvJUZVI/uJvtznGEGDQO58cSCmsTOSowLnC1sUW7ywE4/5+65pPWroSy1r3I97XyuxOMtfKnkl1bwNEI159ArD2vPgE81ksrAaHTnqCVUSKjnrAlblUw4df/CUSCEevte0E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H8OUwv2n; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H8OUwv2n"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EF241F000FF;
	Mon, 28 Sep 2026 15:54:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610876;
	bh=rhNAvvxgYzvC8w8Z2CKOWVlQ8vRlTKvYjd8zvpCOIOI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=H8OUwv2npTq8QxqPWBF/xy5JYQMLfYKyDEkNKjTABPmDuhVJIghFMAUqjmvk95U8s
	 G/eCt8q3DnlhJsULUh9GZWGRoOQgUZcV16nzZ1ln3A3e92yBxHyatc8q+WBIoyqIkR
	 v7mBjGlnGcLJIq5iASVRCZe7644g264V6QWfwWVj8CQt5DjKFP70cQAIbQz6yHUzaF
	 VHWNkW1JSPUu4mXM6GD0AaGBpaAtPRqAejvmR7fUWvo23crYTOi1gFXn4Nwo0nDh42
	 MKawR13SnQQklPIl5tGJIezW0Bjtt2e7lXEPVHs5U2Wj1+2F3/g56x1t743EvFCXmA
	 Ag5wFmyAeHBig==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] pNFS/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS over the mdsthreshold hint
Date: Mon, 28 Sep 2026 11:54:28 -0400
Message-ID: <20260928155430.95985-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260928155430.95985-1-snitzer@kernel.org>
References: <20260928155430.95985-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A flexfiles layout may carry FF_FLAGS_NO_IO_THRU_MDS, which tells the
client that this file's data must not be read or written through the
metadata server.

The RFC 5661 mdsthreshold hint pulls the other way.  When a server returns
one, pnfs_within_mdsthreshold() answers "use MDS I/O" for every I/O below
the threshold, pnfs_update_layout() then hands back no segment, and
ff_layout_pg_init_read() reads through the MDS - the very thing the
layout forbids.  A server that sets both is asking for two incompatible
things; the layout flag is the stronger statement, and the one whose
violation the client cannot recover from.

Record the policy on the inode, where it outlives the layout hdr that
carried it, and consult it before the hint:

 - ff_layout_alloc_lseg() sets NFS_INO_NO_IO_THRU_MDS beside the existing
   sticky hdr-level NFS4_FF_HDR_NO_IO_THRU_MDS bit.

 - pnfs_within_mdsthreshold() returns false at once for such an inode, so
   no I/O is diverted to the MDS on the strength of the hint.

The bit is never cleared for the life of the in-core inode.  Servers are
assumed to be consistent in their no-fallback policy per file, which is
the assumption ff_layout_hdr_no_fallback_to_mds() already makes; a server
that was not would lose the effect of its mdsthreshold hint - a SHOULD -
on an inode that is already in core, and nothing else.

Fixes: 260074cd8413 ("pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS")
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 ++++-
 fs/nfs/internal.h                      | 29 ++++++++++++++++++++++++++
 fs/nfs/pnfs.c                          | 12 ++++++++++-
 3 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 94cc324b591f4..7d45401ee5b11 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -639,9 +639,12 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	if (!p)
 		goto out_sort_mirrors;
 	fls->flags = be32_to_cpup(p);
-	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS)
+	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS) {
 		set_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
 			&FF_LAYOUT_FROM_HDR(lh)->flags);
+		/* Outlives this layout hdr; see NFS_INO_NO_IO_THRU_MDS */
+		nfs_set_no_io_thru_mds(lh->plh_inode);
+	}
 
 	p = xdr_inline_decode(&stream, 4);
 	if (!p)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4c6fb5a612252..50273e41f27df 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -543,6 +543,35 @@ static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
 	return test_bit(NFS_INO_ODIRECT, &nfsi->flags) == 0;
 }
 
+/*
+ * Module-private nfs_inode->flags bit (not in <linux/nfs_fs.h>, so no
+ * exported layout changes): set, and never cleared for the life of the
+ * in-core inode, once a layout driver has seen the server forbid I/O
+ * through the MDS for this file (flexfiles sets it from
+ * FF_FLAGS_NO_IO_THRU_MDS in ff_layout_alloc_lseg()).  The RFC 5661
+ * mdsthreshold hint must not be acted on for such a file, since the only
+ * thing pnfs_within_mdsthreshold() can ask for is the one thing the
+ * layout forbids.  Servers are assumed to be consistent in their
+ * no-fallback policy per file, the same assumption
+ * ff_layout_hdr_no_fallback_to_mds() already makes; if one were not, the
+ * only effect is that its mdsthreshold hint - a SHOULD - stops being
+ * honored for an inode that is already in core.
+ */
+#define NFS_INO_NO_IO_THRU_MDS	(30)
+
+static inline void nfs_set_no_io_thru_mds(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (!test_bit(NFS_INO_NO_IO_THRU_MDS, &nfsi->flags))
+		set_bit(NFS_INO_NO_IO_THRU_MDS, &nfsi->flags);
+}
+
+static inline bool nfs_no_io_thru_mds(struct inode *inode)
+{
+	return test_bit(NFS_INO_NO_IO_THRU_MDS, &NFS_I(inode)->flags);
+}
+
 /* Must be called with exclusively locked inode->i_rwsem */
 static inline void nfs_file_block_o_direct(struct nfs_inode *nfsi)
 {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 65b806a76f8de..264d0c8efb6b6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2021,7 +2021,9 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
  * is set to IOMODE_READ for a READ request, and set to IOMODE_RW for a
  * WRITE request.
  *
- * A return of true means use MDS I/O.
+ * A return of true means use MDS I/O, so for a file whose layout forbids
+ * that (see NFS_INO_NO_IO_THRU_MDS) the hint is not evaluated at all:
+ * there is no answer it could give that this client may act on.
  *
  * From rfc 5661:
  * If a file's size is smaller than the file size threshold, data accesses
@@ -2042,6 +2044,14 @@ static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
 	if (t == NULL)
 		return ret;
 
+	/*
+	 * The server has told a layout driver that this file's I/O may not
+	 * go through the MDS (flexfiles FF_FLAGS_NO_IO_THRU_MDS).  Honor
+	 * that over its own mdsthreshold hint.
+	 */
+	if (nfs_no_io_thru_mds(ino))
+		return ret;
+
 	dprintk("%s bm=0x%x rd_sz=%llu wr_sz=%llu rd_io=%llu wr_io=%llu\n",
 		__func__, t->bm, t->rd_sz, t->wr_sz, t->rd_io_sz, t->wr_io_sz);
 
-- 
2.44.0

