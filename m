Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35392 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbITPEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 11:04:34 -0400
Received: by pacfv12 with SMTP id fv12so95014586pac.2
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 08:04:34 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/2] NFS: Fix an infinite loop when layoutget fail with
 BAD_STATEID
Message-ID: <55FECAF6.7070406@gmail.com>
Date: Sun, 20 Sep 2015 23:04:22 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If layouget fail with BAD_STATEID, restart should not using the old stateid.
But, nfs client choose the layout stateid at first, and then the open stateid.

To avoid the infinite loop of using bad stateid for layoutget,
this patch sets the layout flag'ss NFS_LAYOUT_INVALID_STID bit to
skip choosing the bad layout stateid.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 693b903..10ba6c1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7820,6 +7820,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			 * Mark the bad layout state as invalid, then retry
 			 * with the current stateid.
 			 */
+			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
-- 
2.5.0

