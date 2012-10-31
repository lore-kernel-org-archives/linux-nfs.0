Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63711 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab2JaIOt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 04:14:49 -0400
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: Check whether a layout pointer is NULL before free it
Date: Wed, 31 Oct 2012 16:05:48 +0800
Message-Id: <1351670748-21927-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The new layout pointer in pnfs_find_alloc_layout() may be NULL because of 
out of memory. we must do some check work, otherwise pnfs_free_layout_hdr()
will go wrong because it can not deal with a NULL pointer.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/pnfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fe624c9..2878f97 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -925,8 +925,8 @@ pnfs_find_alloc_layout(struct inode *ino,
 	if (likely(nfsi->layout == NULL)) {	/* Won the race? */
 		nfsi->layout = new;
 		return new;
-	}
-	pnfs_free_layout_hdr(new);
+	} else if (new != NULL)
+		pnfs_free_layout_hdr(new);
 out_existing:
 	pnfs_get_layout_hdr(nfsi->layout);
 	return nfsi->layout;
-- 
1.7.4.4

