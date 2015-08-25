Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35284 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755448AbbHYXxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 19:53:49 -0400
Received: by iodt126 with SMTP id t126so207554613iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 16:53:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1/pnfs: Add sanity check for the layout range returned by the server
Date: Tue, 25 Aug 2015 19:53:44 -0400
Message-Id: <1440546826-51922-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440546826-51922-1-git-send-email-trond.myklebust@primarydata.com>
References: <1440546826-51922-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3530bb703214..68cc4b169769 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1561,6 +1561,26 @@ out_unlock:
 }
 EXPORT_SYMBOL_GPL(pnfs_update_layout);
 
+static bool
+pnfs_sanity_check_layout_range(struct pnfs_layout_range *range)
+{
+	switch (range->iomode) {
+	case IOMODE_READ:
+	case IOMODE_RW:
+		break;
+	default:
+		return false;
+	}
+	if (range->offset == NFS4_MAX_UINT64)
+		return false;
+	if (range->length == 0)
+		return false;
+	if (range->length != NFS4_MAX_UINT64 &&
+	    range->length > NFS4_MAX_UINT64 - range->offset)
+		return false;
+	return true;
+}
+
 struct pnfs_layout_segment *
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
@@ -1569,7 +1589,10 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = lo->plh_inode;
 	LIST_HEAD(free_me);
-	int status = 0;
+	int status = -EINVAL;
+
+	if (!pnfs_sanity_check_layout_range(&res->range))
+		goto out;
 
 	/* Inject layout blob into I/O device driver */
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res, lgp->gfp_flags);
-- 
2.4.3

