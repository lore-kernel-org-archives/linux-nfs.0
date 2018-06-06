Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga06-in.huawei.com ([45.249.212.32]:37003 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752713AbeFFBzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 21:55:52 -0400
From: Wei Yongjun <weiyongjun1@huawei.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Fred Isaman <fred.isaman@gmail.com>
CC: Wei Yongjun <weiyongjun1@huawei.com>, <linux-nfs@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
Subject: [PATCH -next] pnfs: Use GFP_ATOMIC under spin lock
Date: Wed, 6 Jun 2018 02:02:18 +0000
Message-ID: <1528250538-50721-1-git-send-email-weiyongjun1@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A spin lock is taken here so we should use GFP_ATOMIC.

Fixes: 2409a976a299 ("pnfs: Add LAYOUTGET to OPEN of a new file")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d93942f..1ff1998 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2009,7 +2009,7 @@ struct pnfs_layout_segment *
 	struct pnfs_layout_hdr *lo;
 
 	spin_lock(&ino->i_lock);
-	lo = pnfs_find_alloc_layout(ino, ctx, GFP_KERNEL);
+	lo = pnfs_find_alloc_layout(ino, ctx, GFP_ATOMIC);
 	if (!lo)
 		goto out_unlock;
 	if (!test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags))

