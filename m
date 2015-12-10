Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34651 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbbLJPmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Dec 2015 10:42:04 -0500
Received: by qgeb1 with SMTP id b1so148312094qge.1
        for <linux-nfs@vger.kernel.org>; Thu, 10 Dec 2015 07:42:04 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: add new tracepoint for pnfs_update_layout
Date: Thu, 10 Dec 2015 10:41:58 -0500
Message-Id: <1449762118-21016-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_update_layout is really the "nexus" of layout handling. If it
returns NULL then we end up going through the MDS. This patch adds
some tracepoints to that function that allow us to determine the
cause when we end up going through the MDS unexpectedly.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4trace.h   | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c        | 38 +++++++++++++++++++++++++++++------
 include/linux/nfs4.h | 14 +++++++++++++
 3 files changed, 102 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 671cf68fe56b..26a78f48c2d6 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1198,6 +1198,62 @@ DEFINE_NFS4_INODE_EVENT(nfs4_layoutcommit);
 DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn);
 DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn_on_close);
 
+#define show_pnfs_update_layout_reason(reason)				\
+	__print_symbolic(reason,					\
+		{ PNFS_UPDATE_LAYOUT_UNKNOWN, "unknown" },		\
+		{ PNFS_UPDATE_LAYOUT_NO_PNFS, "no pnfs" },		\
+		{ PNFS_UPDATE_LAYOUT_RD_ZEROLEN, "read+zerolen" },	\
+		{ PNFS_UPDATE_LAYOUT_MDSTHRESH, "mdsthresh" },		\
+		{ PNFS_UPDATE_LAYOUT_NOMEM, "nomem" },			\
+		{ PNFS_UPDATE_LAYOUT_BULK_RECALL, "bulk recall" },	\
+		{ PNFS_UPDATE_LAYOUT_IO_TEST_FAIL, "io test fail" },	\
+		{ PNFS_UPDATE_LAYOUT_FOUND_CACHED, "found cached" },	\
+		{ PNFS_UPDATE_LAYOUT_RETURN, "layoutreturn" },		\
+		{ PNFS_UPDATE_LAYOUT_BLOCKED, "layouts blocked" },	\
+		{ PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET, "sent layoutget" })
+
+TRACE_EVENT(pnfs_update_layout,
+		TP_PROTO(struct inode *inode,
+			loff_t pos,
+			u64 count,
+			enum pnfs_iomode iomode,
+			struct pnfs_layout_segment *lseg,
+			enum pnfs_update_layout_reason reason
+		),
+		TP_ARGS(inode, pos, count, iomode, lseg, reason),
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u64, fileid)
+			__field(u32, fhandle)
+			__field(loff_t, pos)
+			__field(u64, count)
+			__field(enum pnfs_iomode, iomode)
+			__field(struct pnfs_layout_segment *, lseg)
+			__field(enum pnfs_update_layout_reason, reason)
+		),
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->pos = pos;
+			__entry->count = count;
+			__entry->iomode = iomode;
+			__entry->lseg = lseg;
+			__entry->reason = reason;
+		),
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"iomode=%s pos=%llu count=%llu lseg=%p (%s)",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			show_pnfs_iomode(__entry->iomode),
+			(unsigned long long)__entry->pos,
+			(unsigned long long)__entry->count, __entry->lseg,
+			show_pnfs_update_layout_reason(__entry->reason)
+		)
+);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* _TRACE_NFS4_H */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5a8ae2125b50..3688189ac2b2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1520,14 +1520,23 @@ pnfs_update_layout(struct inode *ino,
 	struct pnfs_layout_segment *lseg = NULL;
 	bool first;
 
-	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
+	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_NO_PNFS);
 		goto out;
+	}
 
-	if (iomode == IOMODE_READ && i_size_read(ino) == 0)
+	if (iomode == IOMODE_READ && i_size_read(ino) == 0) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_RD_ZEROLEN);
 		goto out;
+	}
 
-	if (pnfs_within_mdsthreshold(ctx, ino, iomode))
+	if (pnfs_within_mdsthreshold(ctx, ino, iomode)) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_MDSTHRESH);
 		goto out;
+	}
 
 lookup_again:
 	first = false;
@@ -1535,19 +1544,26 @@ lookup_again:
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
 		spin_unlock(&ino->i_lock);
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_NOMEM);
 		goto out;
 	}
 
 	/* Do we even need to bother with this? */
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_BULK_RECALL);
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
 	if (pnfs_layout_io_test_failed(lo, iomode) &&
-	    !pnfs_should_retry_layoutget(lo))
+	    !pnfs_should_retry_layoutget(lo)) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_IO_TEST_FAIL);
 		goto out_unlock;
+	}
 
 	first = list_empty(&lo->plh_segs);
 	if (first) {
@@ -1567,8 +1583,11 @@ lookup_again:
 		 * already exists
 		 */
 		lseg = pnfs_find_lseg(lo, &arg);
-		if (lseg)
+		if (lseg) {
+			trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+					PNFS_UPDATE_LAYOUT_FOUND_CACHED);
 			goto out_unlock;
+		}
 	}
 
 	/*
@@ -1585,11 +1604,16 @@ lookup_again:
 			dprintk("%s retrying\n", __func__);
 			goto lookup_again;
 		}
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				PNFS_UPDATE_LAYOUT_RETURN);
 		goto out_put_layout_hdr;
 	}
 
-	if (pnfs_layoutgets_blocked(lo))
+	if (pnfs_layoutgets_blocked(lo)) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				PNFS_UPDATE_LAYOUT_BLOCKED);
 		goto out_unlock;
+	}
 	atomic_inc(&lo->plh_outstanding);
 	spin_unlock(&ino->i_lock);
 
@@ -1614,6 +1638,8 @@ lookup_again:
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	pnfs_clear_retry_layoutget(lo);
 	atomic_dec(&lo->plh_outstanding);
+	trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 out_put_layout_hdr:
 	if (first)
 		pnfs_clear_first_layoutget(lo);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e7e78537aea2..0e30f2c5ff49 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -592,4 +592,18 @@ enum data_content4 {
 	NFS4_CONTENT_HOLE		= 1,
 };
 
+enum pnfs_update_layout_reason {
+	PNFS_UPDATE_LAYOUT_UNKNOWN = 0,
+	PNFS_UPDATE_LAYOUT_NO_PNFS,
+	PNFS_UPDATE_LAYOUT_RD_ZEROLEN,
+	PNFS_UPDATE_LAYOUT_MDSTHRESH,
+	PNFS_UPDATE_LAYOUT_NOMEM,
+	PNFS_UPDATE_LAYOUT_BULK_RECALL,
+	PNFS_UPDATE_LAYOUT_IO_TEST_FAIL,
+	PNFS_UPDATE_LAYOUT_FOUND_CACHED,
+	PNFS_UPDATE_LAYOUT_RETURN,
+	PNFS_UPDATE_LAYOUT_BLOCKED,
+	PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET,
+};
+
 #endif
-- 
2.5.0

