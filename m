Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33830 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbbBBWlA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:00 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so87844164pab.11
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:59 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 38/53] nfs41: add a debug warning if we destroy an unempty layout
Date: Mon,  2 Feb 2015 14:38:52 -0800
Message-Id: <1422916747-86649-39-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
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

