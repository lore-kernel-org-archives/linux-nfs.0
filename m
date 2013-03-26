Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:64691 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753066Ab3CZLLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 07:11:42 -0400
Message-ID: <51517A15.3010805@cn.fujitsu.com>
Date: Tue, 26 Mar 2013 18:36:05 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfsd-block: cause oops when alloc pnfs_blocklayout_layout_t
 fail
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

if using dprintk and alloc pnfs_blocklayout_layout_t fail, it
maybe cause oops. we should assert the new pnfs_blocklayout_layout_t
is not null first.

 Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
 Reviewed-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
---
 fs/nfsd/bl_ops.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index fa129e8..a7046c6 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -1210,14 +1210,14 @@ layout_cache_fill_from_list(bl_layout_rec_t *r, struct list_head *h,
 			n = bll_alloc(seg->offset,
 			    MIN(seg->length, BLL_F_END(b) - seg->offset),
 			    BLOCK_LAYOUT_CACHE, h);
+			if (!n)
+				return False;
+
 			dprintk("  CACHE hit: Found %Lu(f):%Lu(l): "
 			    "in %Lu(f):%Lu(l):%Lu(s):%d\n",
 			    _2SECTS(n->bll_foff), _2SECTS(n->bll_len),
 			    _2SECTS(b->bll_foff), _2SECTS(b->bll_len),
 			    _2SECTS(b->bll_soff), b->bll_es);
-			if (!n)
-				return False;
-			
 			n->bll_soff = b->bll_soff + seg->offset - b->bll_foff;
 			n->bll_vol_id.sbid = sbid;
 			n->bll_vol_id.devid = b->bll_vol_id.devid;
-- 
1.5.5.1


