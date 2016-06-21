Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36120 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbcFUVfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 17:35:22 -0400
Received: by mail-it0-f68.google.com with SMTP id h190so4082687ith.3
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 14:35:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/12] NFS: writepage of a single page should not be synchronous
Date: Tue, 21 Jun 2016 17:34:46 -0400
Message-Id: <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is almost always better to wait for more so that we can issue a
bulk commit.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 980d44f3a84c..b13d48881d3a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -625,7 +625,7 @@ static int nfs_writepage_locked(struct page *page,
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
-	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
+	nfs_pageio_init_write(&pgio, inode, 0,
 				false, &nfs_async_write_completion_ops);
 	err = nfs_do_writepage(page, wbc, &pgio, launder);
 	nfs_pageio_complete(&pgio);
-- 
2.5.5

