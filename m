Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34557 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbbHaJIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 05:08:09 -0400
Received: by pabzx8 with SMTP id zx8so133251940pab.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2015 02:08:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFSv4.1/pNFS: Don't request a minimal read layout beyond the end of file
Date: Mon, 31 Aug 2015 02:08:05 -0700
Message-Id: <1441012085-4071-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441012085-4071-2-git-send-email-trond.myklebust@primarydata.com>
References: <1441012085-4071-1-git-send-email-trond.myklebust@primarydata.com>
 <1441012085-4071-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have a read layout, then sanity check the minimal layout length
so that it does not extend beyond the end of file.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c4f918eca3d2..ba1246433794 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -868,6 +868,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	struct nfs_server *server = NFS_SERVER(ino);
 	struct nfs4_layoutget *lgp;
 	struct pnfs_layout_segment *lseg;
+	loff_t i_size;
 
 	dprintk("--> %s\n", __func__);
 
@@ -875,9 +876,17 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	if (lgp == NULL)
 		return NULL;
 
+	i_size = i_size_read(ino);
+
 	lgp->args.minlength = PAGE_CACHE_SIZE;
 	if (lgp->args.minlength > range->length)
 		lgp->args.minlength = range->length;
+	if (range->iomode == IOMODE_READ) {
+		if (range->offset >= i_size)
+			lgp->args.minlength = 0;
+		else if (i_size - range->offset < lgp->args.minlength)
+			lgp->args.minlength = i_size - range->offset;
+	}
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range = *range;
 	lgp->args.type = server->pnfs_curr_ld->id;
-- 
2.4.3

