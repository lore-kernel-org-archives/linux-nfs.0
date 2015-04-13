Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60683 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636AbbDMWGj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 18:06:39 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6973520F51
	for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2015 18:06:39 -0400 (EDT)
From: Sergei Zviagintsev <sergei@s15v.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Sergei Zviagintsev <sergei@s15v.net>
Subject: [PATCH] nfs: Fix unused variable build warning when CONFIG_SUNRPC_DEBUG is not set
Date: Tue, 14 Apr 2015 01:06:19 +0300
Message-Id: <1428962779-3741-1-git-send-email-sergei@s15v.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit f52cbe4c9838 ("nfs: generic_write_checks() shouldn't be done on
swapout...") caused unused variable build warning in fs/nfs/file.c
when CONFIG_SUNRPC_DEBUG is not set as pos variable is used only in
dprintk() call. Fix it.

Signed-off-by: Sergei Zviagintsev <sergei@s15v.net>
Fixes: f52cbe4c9838 ("nfs: generic_write_checks() shouldn't be done on swapout...")
---
 fs/nfs/file.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 031ddcb1061d..c40e4363e746 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -674,7 +674,6 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	unsigned long written = 0;
 	ssize_t result;
 	size_t count = iov_iter_count(from);
-	loff_t pos = iocb->ki_pos;
 
 	result = nfs_key_timeout_notify(file, inode);
 	if (result)
@@ -688,7 +687,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	}
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
-		file, count, (long long) pos);
+		file, count, (long long) iocb->ki_pos);
 
 	result = -EBUSY;
 	if (IS_SWAPFILE(inode))
-- 
1.8.3.1

