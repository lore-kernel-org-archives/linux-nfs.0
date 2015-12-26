Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35753 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbbLZXIy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:08:54 -0500
Received: by mail-ig0-f178.google.com with SMTP id to4so126046368igc.0
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:08:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna.Schumaker@netapp.com
Subject: [PATCH] pNFS: Modify pnfs_update_layout tracepoints to use layout stateid
Date: Sat, 26 Dec 2015 18:08:15 -0500
Message-Id: <1451171295-25705-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1449762118-21016-1-git-send-email-jeff.layton@primarydata.com>
References: <1449762118-21016-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of displaying a layout segment pointer in these tracepoints,
let's use the layout stateid, now that Olga gave us a set of tools for
displaying them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4trace.h | 23 +++++++++++++++++------
 fs/nfs/pnfs.c      | 20 ++++++++++----------
 2 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 238925c1aafd..de5469a5b4f7 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1461,10 +1461,10 @@ TRACE_EVENT(pnfs_update_layout,
 			loff_t pos,
 			u64 count,
 			enum pnfs_iomode iomode,
-			struct pnfs_layout_segment *lseg,
+			struct pnfs_layout_hdr *lo,
 			enum pnfs_update_layout_reason reason
 		),
-		TP_ARGS(inode, pos, count, iomode, lseg, reason),
+		TP_ARGS(inode, pos, count, iomode, lo, reason),
 		TP_STRUCT__entry(
 			__field(dev_t, dev)
 			__field(u64, fileid)
@@ -1472,7 +1472,8 @@ TRACE_EVENT(pnfs_update_layout,
 			__field(loff_t, pos)
 			__field(u64, count)
 			__field(enum pnfs_iomode, iomode)
-			__field(struct pnfs_layout_segment *, lseg)
+			__field(int, layoutstateid_seq)
+			__field(u32, layoutstateid_hash)
 			__field(enum pnfs_update_layout_reason, reason)
 		),
 		TP_fast_assign(
@@ -1482,18 +1483,28 @@ TRACE_EVENT(pnfs_update_layout,
 			__entry->pos = pos;
 			__entry->count = count;
 			__entry->iomode = iomode;
-			__entry->lseg = lseg;
 			__entry->reason = reason;
+			if (lo != NULL) {
+				__entry->layoutstateid_seq =
+				be32_to_cpu(lo->plh_stateid->seqid);
+				__entry->layoutstateid_hash =
+				nfs_stateid_hash(lo->plh_stateid);
+			} else {
+				__entry->layoutstateid_seq = 0;
+				__entry->layoutstateid_hash = 0;
+			}
 		),
 		TP_printk(
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"iomode=%s pos=%llu count=%llu lseg=%p (%s)",
+			"iomode=%s pos=%llu count=%llu "
+			"layoutstateid=%d:0x%08x (%s)",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
 			show_pnfs_iomode(__entry->iomode),
 			(unsigned long long)__entry->pos,
-			(unsigned long long)__entry->count, __entry->lseg,
+			(unsigned long long)__entry->count,
+			__entry->layoutstateid_seq, __entry->layoutstateid_hash,
 			show_pnfs_update_layout_reason(__entry->reason)
 		)
 );
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1489065bb051..6095a8d42766 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1521,19 +1521,19 @@ pnfs_update_layout(struct inode *ino,
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
 				 PNFS_UPDATE_LAYOUT_NO_PNFS);
 		goto out;
 	}
 
 	if (iomode == IOMODE_READ && i_size_read(ino) == 0) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
 				 PNFS_UPDATE_LAYOUT_RD_ZEROLEN);
 		goto out;
 	}
 
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
 				 PNFS_UPDATE_LAYOUT_MDSTHRESH);
 		goto out;
 	}
@@ -1544,14 +1544,14 @@ lookup_again:
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
 		spin_unlock(&ino->i_lock);
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, NULL,
 				 PNFS_UPDATE_LAYOUT_NOMEM);
 		goto out;
 	}
 
 	/* Do we even need to bother with this? */
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				 PNFS_UPDATE_LAYOUT_BULK_RECALL);
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
@@ -1560,7 +1560,7 @@ lookup_again:
 	/* if LAYOUTGET already failed once we don't try again */
 	if (pnfs_layout_io_test_failed(lo, iomode) &&
 	    !pnfs_should_retry_layoutget(lo)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				 PNFS_UPDATE_LAYOUT_IO_TEST_FAIL);
 		goto out_unlock;
 	}
@@ -1584,7 +1584,7 @@ lookup_again:
 		 */
 		lseg = pnfs_find_lseg(lo, &arg);
 		if (lseg) {
-			trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+			trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 					PNFS_UPDATE_LAYOUT_FOUND_CACHED);
 			goto out_unlock;
 		}
@@ -1604,13 +1604,13 @@ lookup_again:
 			dprintk("%s retrying\n", __func__);
 			goto lookup_again;
 		}
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				PNFS_UPDATE_LAYOUT_RETURN);
 		goto out_put_layout_hdr;
 	}
 
 	if (pnfs_layoutgets_blocked(lo)) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				PNFS_UPDATE_LAYOUT_BLOCKED);
 		goto out_unlock;
 	}
@@ -1638,7 +1638,7 @@ lookup_again:
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	pnfs_clear_retry_layoutget(lo);
 	atomic_dec(&lo->plh_outstanding);
-	trace_pnfs_update_layout(ino, pos, count, iomode, lseg,
+	trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 out_put_layout_hdr:
 	if (first)
-- 
2.5.0

