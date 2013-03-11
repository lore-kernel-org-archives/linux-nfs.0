Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:57090 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753886Ab3CKLxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 07:53:12 -0400
Message-ID: <513DC5BE.9000103@cn.fujitsu.com>
Date: Mon, 11 Mar 2013 19:53:34 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: bhalevy@tonian.com
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH]spnfs-block: reserve space error in bl_encode_stripe
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 when useing spnfs-block, reserve space error in bl_encode_stripe.

 Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
---
 fs/exportfs/nfs4blocklayoutxdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/exportfs/nfs4blocklayoutxdr.c b/fs/exportfs/nfs4blocklayoutxdr.c
index 439e647..c942d34 100644
--- a/fs/exportfs/nfs4blocklayoutxdr.c
+++ b/fs/exportfs/nfs4blocklayoutxdr.c
@@ -53,7 +53,7 @@ static int
 bl_encode_stripe(struct exp_xdr_stream *xdr, pnfs_blocklayout_devinfo_t *bld)
 {
        int i;
-       __be32 *p = exp_xdr_reserve_space(xdr,
+       __be32 *p = exp_xdr_reserve_qwords(xdr,
                                          2 + 1 + bld->u.stripe.bld_stripes);

        p = exp_xdr_encode_u64(p, bld->u.stripe.bld_chunk_size);
--
1.7.1

