Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35000 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbdEBQlJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:41:09 -0400
Received: by mail-it0-f66.google.com with SMTP id 131so3218860itz.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:41:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pNFS: Fix a deadlock when coalescing writes and returning the layout
Date: Tue,  2 May 2017 12:41:04 -0400
Message-Id: <20170502164105.6373-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170502164105.6373-2-trond.myklebust@primarydata.com>
References: <20170502164105.6373-1-trond.myklebust@primarydata.com>
 <20170502164105.6373-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Consider the following deadlock:

Process P1	Process P2		Process P3
==========	==========		==========
					lock_page(page)

		lseg = pnfs_update_layout(inode)

lo = NFS_I(inode)->layout
pnfs_error_mark_layout_for_return(lo)

		lock_page(page)

					lseg = pnfs_update_layout(inode)

In this scenario,
- P1 has declared the layout to be in error, but P2 holds a reference to
  a layout segment on that inode, so the layoutreturn is deferred.
- P2 is waiting for a page lock held by P3.
- P3 is asking for a new layout segment, but is blocked waiting
  for the layoutreturn.

The fix is to ensure that pnfs_error_mark_layout_for_return() does
not set the NFS_LAYOUT_RETURN flag, which blocks P3. Instead, we allow
the latter to call LAYOUTGET so that it can make progress and unblock
P2.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cea1e838efae..adc6ec28d4b5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2063,8 +2063,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		return;
 	}
 	pnfs_set_plh_return_info(lo, range.iomode, 0);
-	/* Block LAYOUTGET */
-	set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
-- 
2.9.3

