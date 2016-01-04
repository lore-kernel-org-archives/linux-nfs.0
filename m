Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:32930 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbcADSV7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:59 -0500
Received: by mail-io0-f172.google.com with SMTP id q21so162464376iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:59 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 17/18] NFSv4.1/pnfs: Cleanup copying of pnfs_layout_range structures
Date: Mon,  4 Jan 2016 13:21:15 -0500
Message-Id: <1451931676-68481-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-16-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-15-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 4 ++--
 fs/nfs/pnfs.h | 7 +++++++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f86f060f853d..ebf896b54d9d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -863,7 +863,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
-	   struct pnfs_layout_range *range,
+	   const struct pnfs_layout_range *range,
 	   gfp_t gfp_flags)
 {
 	struct inode *ino = lo->plh_inode;
@@ -896,7 +896,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 				lgp->args.minlength = i_size - range->offset;
 		}
 		lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
-		lgp->args.range = *range;
+		pnfs_copy_range(&lgp->args.range, range);
 		lgp->args.type = server->pnfs_curr_ld->id;
 		lgp->args.inode = ino;
 		lgp->args.ctx = get_nfs_open_context(ctx);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3d0f513a4a77..dcc76335fd4b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -578,6 +578,13 @@ pnfs_mark_layout_returned_if_empty(struct pnfs_layout_hdr *lo)
 		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 }
 
+static inline void
+pnfs_copy_range(struct pnfs_layout_range *dst,
+		const struct pnfs_layout_range *src)
+{
+	memcpy(dst, src, sizeof(*dst));
+}
+
 extern unsigned int layoutstats_timer;
 
 #ifdef NFS_DEBUG
-- 
2.5.0

