Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35309 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbbHYXxw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 19:53:52 -0400
Received: by iodt126 with SMTP id t126so207555268iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 16:53:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4.1/flexfiles: Allow coalescing of new layout segments and existing ones
Date: Tue, 25 Aug 2015 19:53:46 -0400
Message-Id: <1440546826-51922-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440546826-51922-3-git-send-email-trond.myklebust@primarydata.com>
References: <1440546826-51922-1-git-send-email-trond.myklebust@primarydata.com>
 <1440546826-51922-2-git-send-email-trond.myklebust@primarydata.com>
 <1440546826-51922-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to ensure atomicity of updates, we merge the old layout segments
into the new ones, and then invalidate the old ones.

Also ensure that we order the list of layout segments so that
RO segments are preferred over RW.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 60 ++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h                          | 16 +++++++++
 2 files changed, 76 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fefa8ad9578..4ec624cfcf8b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -265,6 +265,65 @@ static void _ff_layout_free_lseg(struct nfs4_ff_layout_segment *fls)
 	}
 }
 
+static bool
+ff_lseg_range_is_after(const struct pnfs_layout_range *l1,
+		const struct pnfs_layout_range *l2)
+{
+	u64 end1, end2;
+
+	if (l1->iomode != l2->iomode)
+		return l1->iomode != IOMODE_READ;
+	end1 = pnfs_calc_offset_end(l1->offset, l1->length);
+	end2 = pnfs_calc_offset_end(l2->offset, l2->length);
+	if (end1 < l2->offset)
+		return false;
+	if (end2 < l1->offset)
+		return true;
+	return l2->offset <= l1->offset;
+}
+
+static bool
+ff_lseg_merge(struct pnfs_layout_segment *new,
+		struct pnfs_layout_segment *old)
+{
+	u64 new_end, old_end;
+
+	if (new->pls_range.iomode != old->pls_range.iomode)
+		return false;
+	old_end = pnfs_calc_offset_end(old->pls_range.offset,
+			old->pls_range.length);
+	if (old_end < new->pls_range.offset)
+		return false;
+	new_end = pnfs_calc_offset_end(new->pls_range.offset,
+			new->pls_range.length);
+	if (new_end < old->pls_range.offset)
+		return false;
+
+	/* Mergeable: copy info from 'old' to 'new' */
+	if (new_end < old_end)
+		new_end = old_end;
+	if (new->pls_range.offset < old->pls_range.offset)
+		new->pls_range.offset = old->pls_range.offset;
+	new->pls_range.length = pnfs_calc_offset_length(new->pls_range.offset,
+			new_end);
+	if (test_bit(NFS_LSEG_ROC, &old->pls_flags))
+		set_bit(NFS_LSEG_ROC, &new->pls_flags);
+	if (test_bit(NFS_LSEG_LAYOUTRETURN, &old->pls_flags))
+		set_bit(NFS_LSEG_LAYOUTRETURN, &new->pls_flags);
+	return true;
+}
+
+static void
+ff_layout_add_lseg(struct pnfs_layout_hdr *lo,
+		struct pnfs_layout_segment *lseg,
+		struct list_head *free_me)
+{
+	pnfs_generic_layout_insert_lseg(lo, lseg,
+			ff_lseg_range_is_after,
+			ff_lseg_merge,
+			free_me);
+}
+
 static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
 {
 	int i, j;
@@ -2046,6 +2105,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.free_layout_hdr	= ff_layout_free_layout_hdr,
 	.alloc_lseg		= ff_layout_alloc_lseg,
 	.free_lseg		= ff_layout_free_lseg,
+	.add_lseg		= ff_layout_add_lseg,
 	.pg_read_ops		= &ff_layout_pg_read_ops,
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 869069d8b996..78c9351ff117 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -539,6 +539,22 @@ pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 					nfss->pnfs_curr_ld->id == src->l_type);
 }
 
+static inline u64
+pnfs_calc_offset_end(u64 offset, u64 len)
+{
+	if (len == NFS4_MAX_UINT64 || len >= NFS4_MAX_UINT64 - offset)
+		return NFS4_MAX_UINT64;
+	return offset + len - 1;
+}
+
+static inline u64
+pnfs_calc_offset_length(u64 offset, u64 end)
+{
+	if (end == NFS4_MAX_UINT64 || end <= offset)
+		return NFS4_MAX_UINT64;
+	return 1 + end - offset;
+}
+
 extern unsigned int layoutstats_timer;
 
 #ifdef NFS_DEBUG
-- 
2.4.3

