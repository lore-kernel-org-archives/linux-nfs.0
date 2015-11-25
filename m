Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35415 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbKYSnW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 13:43:22 -0500
Received: by qgec40 with SMTP id c40so38555887qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2015 10:43:21 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@Primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4: resend LAYOUTGET when there is a race that changes the seqid
Date: Wed, 25 Nov 2015 13:43:14 -0500
Message-Id: <1448476994-17047-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_layout_process will check the returned layout stateid against what
the kernel has in-core. If it turns out that the stateid we received is
older, then we should resend the LAYOUTGET instead of falling back to
MDS I/O.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 58 ++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 32 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 49e1489563b7..3688189ac2b2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -872,33 +872,38 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 
-	lgp = kzalloc(sizeof(*lgp), gfp_flags);
-	if (lgp == NULL)
-		return NULL;
-
-	i_size = i_size_read(ino);
-
-	lgp->args.minlength = PAGE_CACHE_SIZE;
-	if (lgp->args.minlength > range->length)
-		lgp->args.minlength = range->length;
-	if (range->iomode == IOMODE_READ) {
-		if (range->offset >= i_size)
-			lgp->args.minlength = 0;
-		else if (i_size - range->offset < lgp->args.minlength)
-			lgp->args.minlength = i_size - range->offset;
-	}
-	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
-	lgp->args.range = *range;
-	lgp->args.type = server->pnfs_curr_ld->id;
-	lgp->args.inode = ino;
-	lgp->args.ctx = get_nfs_open_context(ctx);
-	lgp->gfp_flags = gfp_flags;
-	lgp->cred = lo->plh_lc_cred;
-
-	/* Synchronously retrieve layout information from server and
-	 * store in lseg.
+	/*
+	 * Synchronously retrieve layout information from server and
+	 * store in lseg. If we race with a concurrent seqid morphing
+	 * op, then re-send the LAYOUTGET.
 	 */
-	lseg = nfs4_proc_layoutget(lgp, gfp_flags);
+	do {
+		lgp = kzalloc(sizeof(*lgp), gfp_flags);
+		if (lgp == NULL)
+			return NULL;
+
+		i_size = i_size_read(ino);
+
+		lgp->args.minlength = PAGE_CACHE_SIZE;
+		if (lgp->args.minlength > range->length)
+			lgp->args.minlength = range->length;
+		if (range->iomode == IOMODE_READ) {
+			if (range->offset >= i_size)
+				lgp->args.minlength = 0;
+			else if (i_size - range->offset < lgp->args.minlength)
+				lgp->args.minlength = i_size - range->offset;
+		}
+		lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
+		lgp->args.range = *range;
+		lgp->args.type = server->pnfs_curr_ld->id;
+		lgp->args.inode = ino;
+		lgp->args.ctx = get_nfs_open_context(ctx);
+		lgp->gfp_flags = gfp_flags;
+		lgp->cred = lo->plh_lc_cred;
+
+		lseg = nfs4_proc_layoutget(lgp, gfp_flags);
+	} while (lseg == ERR_PTR(-EAGAIN));
+
 	if (IS_ERR(lseg)) {
 		switch (PTR_ERR(lseg)) {
 		case -ENOMEM:
@@ -1713,6 +1718,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		/* existing state ID, make sure the sequence number matches. */
 		if (pnfs_layout_stateid_blocked(lo, &res->stateid)) {
 			dprintk("%s forget reply due to sequence\n", __func__);
+			status = -EAGAIN;
 			goto out_forget_reply;
 		}
 		pnfs_set_layout_stateid(lo, &res->stateid, false);
-- 
2.4.3

