Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab2IXUAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 16:00:00 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 27/28] NFSv4.1: _pnfs_return_layout() shouldn't invalidate the layout on failure
Date: Mon, 24 Sep 2012 15:56:45 -0400
Message-Id: <1348516606-22721-27-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-26-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-21-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-22-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-23-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-24-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-25-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-26-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Failure of the layoutreturn allocation fails is not a good reason to
mark the pnfs_layout_hdr as having failed a layoutget or i/o. Just
exit cleanly.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 28f7126..4aeebb9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -718,8 +718,9 @@ _pnfs_return_layout(struct inode *ino)
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (unlikely(lrp == NULL)) {
 		status = -ENOMEM;
-		pnfs_layout_io_set_failed(lo, IOMODE_RW);
-		pnfs_layout_io_set_failed(lo, IOMODE_READ);
+		spin_lock(&ino->i_lock);
+		lo->plh_block_lgets--;
+		spin_unlock(&ino->i_lock);
 		pnfs_put_layout_hdr(lo);
 		goto out;
 	}
-- 
1.7.11.4

