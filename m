Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33835 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbcGXPIK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 11:08:10 -0400
Received: by mail-io0-f194.google.com with SMTP id g86so10393192ioj.1
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 08:08:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/7] pNFS: Remove redundant stateid invalidation
Date: Sun, 24 Jul 2016 11:07:34 -0400
Message-Id: <1469372857-29670-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469372857-29670-4-git-send-email-trond.myklebust@primarydata.com>
References: <1469372857-29670-1-git-send-email-trond.myklebust@primarydata.com>
 <1469372857-29670-2-git-send-email-trond.myklebust@primarydata.com>
 <1469372857-29670-3-git-send-email-trond.myklebust@primarydata.com>
 <1469372857-29670-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layout stateid will be invalidated once it holds no more layout
segments anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 12d4d1b55dd1..010f8803090b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1028,7 +1028,6 @@ _pnfs_return_layout(struct inode *ino)
 		goto out_put_layout_hdr;
 	}
 
-	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 	send = pnfs_prepare_layoutreturn(lo, &stateid, NULL);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
-- 
2.7.4

