Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56621 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbBJBsl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 20:48:41 -0500
Received: by mail-pa0-f41.google.com with SMTP id kx10so13313940pab.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 17:48:41 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
Subject: [PATCH] pnfs/flexfiles: Do not dprintk after the free
Date: Mon,  9 Feb 2015 17:48:32 -0800
Message-Id: <1423532912-79079-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Found by 0-DAY kernel test infrastructure:

fs/nfs/flexfilelayout/flexfilelayoutdev.c:520:13-16: ERROR: reference preceded by free on line 518
fs/nfs/flexfilelayout/flexfilelayoutdev.c:520:26-29: ERROR: reference preceded by free on line 518
fs/nfs/flexfilelayout/flexfilelayoutdev.c:520:39-42: ERROR: reference preceded by free on line 518
fs/nfs/flexfilelayout/flexfilelayoutdev.c:521:3-6: ERROR: reference preceded by free on line 518

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 3bbb16b..e2c01f2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -515,10 +515,10 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 		*p++ = cpu_to_be32(err->opnum);
 		*count += 1;
 		list_del(&err->list);
-		kfree(err);
 		dprintk("%s: offset %llu length %llu status %d op %d count %d\n",
 			__func__, err->offset, err->length, err->status,
 			err->opnum, *count);
+		kfree(err);
 	}
 
 	return 0;
-- 
1.9.3

