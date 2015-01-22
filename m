Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:57642 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbbAVXiK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:38:10 -0500
Received: by mail-pd0-f177.google.com with SMTP id y13so4598255pdi.8
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:38:10 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 38/51] nfs41: add a debug warning if we destroy an unempty layout
Date: Thu, 22 Jan 2015 15:36:10 -0800
Message-Id: <1421969783-92997-39-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

So that we can detect the case if some layout segments are still
pinned which is surely a bug that we need to fix.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5f7c422..e123cfc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -242,6 +242,8 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
 	struct inode *inode = lo->plh_inode;
 
 	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
+		if (!list_empty(&lo->plh_segs))
+			WARN_ONCE(1, "NFS: BUG unfreed layout segments.\n");
 		pnfs_detach_layout_hdr(lo);
 		spin_unlock(&inode->i_lock);
 		pnfs_free_layout_hdr(lo);
-- 
1.9.3

