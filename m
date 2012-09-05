Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:59678 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab2IEGiE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2012 02:38:04 -0400
Received: by qaas11 with SMTP id s11so318081qaa.19
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2012 23:38:03 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 5 Sep 2012 14:38:03 +0800
Message-ID: <CAPgLHd8a+6FGVDScg25XGKc8bAZDdkS6aU4tmknyDMKvZ-DgDg@mail.gmail.com>
Subject: [PATCH] pnfsblock: use list_move_tail instead of list_del/list_add_tail
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move_tail() instead of list_del() + list_add_tail().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 fs/nfs/blocklayout/extents.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 1f9a603..9c3e117 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -683,8 +683,7 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		p = xdr_encode_hyper(p, lce->bse_length << SECTOR_SHIFT);
 		p = xdr_encode_hyper(p, 0LL);
 		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
-		list_del(&lce->bse_node);
-		list_add_tail(&lce->bse_node, &bl->bl_committing);
+		list_move_tail(&lce->bse_node, &bl->bl_committing);
 		bl->bl_count--;
 		count++;
 	}


