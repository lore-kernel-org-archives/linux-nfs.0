Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45103 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab1JJUeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Oct 2011 16:34:05 -0400
Received: by qyk30 with SMTP id 30so2789636qyk.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Oct 2011 13:34:04 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, mikem@redhat.com
Subject: [PATCH][RFC] nfs: don't redirty inode when ncommit == 0 in nfs_commit_unstable_pages
Date: Mon, 10 Oct 2011 16:33:58 -0400
Message-Id: <1318278838-26653-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current test in nfs_commit_unstable_pages does not handle the edge
condition properly. When ncommit == 0, then that likely means that the
kernel doesn't need to do anything more for the inode. The current test
though will return true in that case, and the inode will end up being
marked dirty.

Fix this by not re-marking the inode dirty when ncommit == 0.

Mike noticed this problem initially in RHEL5 (2.6.18-based kernel) which
has a backported version of 420e3646. The inode cache there was
growing very large, but calling sync() would essentially "fix" the
problem.

What I'm not clear on is how big a problem this is in mainline kernels
as the writeback code there is very different. I think this basically
means that the inode will remain dirty until there's a WB_SYNC_ALL
flush. Either way, it seems incorrect to mark the inode dirty in this
case.

Also, another question I have here -- shouldn't we be holding the i_lock
when doing this check?

Reported-by: Mike McLean <mikem@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 17e20e4..6395e98 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1557,7 +1557,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 		/* Don't commit yet if this is a non-blocking flush and there
 		 * are a lot of outstanding writes for this mapping.
 		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (nfsi->ncommit && nfsi->ncommit <= (nfsi->npages >> 1))
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */
-- 
1.7.6.4

