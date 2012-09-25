Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:53495 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864Ab2IYFnc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2012 01:43:32 -0400
Received: by qaat11 with SMTP id t11so1499091qaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 Sep 2012 22:43:32 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 25 Sep 2012 13:43:32 +0800
Message-ID: <CAPgLHd__m_A5gqBP1GgUJb=_fib7bOiJunVoNZn2HCiKyXVjrw@mail.gmail.com>
Subject: [PATCH] NFS: fix the return value of nfs4_blkdev_get()
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function nfs4_blkdev_get() return NULL pointer.
But the user nfs4_blk_decode_device() check the return value by using
IS_ERR() and get error code from the return value. So we should better
change the return value of nfs4_blkdev_get() to return ERR_PTR().

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfs/blocklayout/blocklayoutdev.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index c965542..8c51518 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -61,12 +61,9 @@ struct block_device *nfs4_blkdev_get(dev_t dev)
 	dprintk("%s enter\n", __func__);
 	bd = blkdev_get_by_dev(dev, FMODE_READ, NULL);
 	if (IS_ERR(bd))
-		goto fail;
+		dprintk("%s failed to open device : %ld\n",
+				__func__, PTR_ERR(bd));
 	return bd;
-fail:
-	dprintk("%s failed to open device : %ld\n",
-			__func__, PTR_ERR(bd));
-	return NULL;
 }
 
 /*


