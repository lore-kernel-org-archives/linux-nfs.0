Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34092 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbcGXVbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:46 -0400
Received: by mail-io0-f196.google.com with SMTP id g86so10762356ioj.1
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 12/14] pNFS: Remove redundant stateid invalidation
Date: Sun, 24 Jul 2016 17:30:57 -0400
Message-Id: <1469395859-83194-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-12-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layout stateid will be invalidated once it holds no more layout
segments anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 49e952968ede..c9a684c128b8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1040,7 +1040,6 @@ _pnfs_return_layout(struct inode *ino)
 		goto out_put_layout_hdr;
 	}
 
-	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 	send = pnfs_prepare_layoutreturn(lo, &stateid, NULL);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
-- 
2.7.4

