Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34850 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbbH0X14 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 19:27:56 -0400
Received: by qkbm65 with SMTP id m65so19818541qkb.2
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2015 16:27:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pNFS: pnfs_mark_matching_lsegs_return must notify of layout return
Date: Thu, 27 Aug 2015 19:27:53 -0400
Message-Id: <1440718073-8294-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not sufficient to just mark the layout segment for layout return. We
also need to set the NFS_LAYOUT_RETURN_BEFORE_CLOSE flag in the layout header.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 914c1daf08df..4eec540de9ea 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1717,6 +1717,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				lseg->pls_range.length);
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			mark_lseg_invalid(lseg, tmp_list);
+			set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					&lo->plh_flags);
 		}
 }
 
-- 
2.4.3

