Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:45254 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726444AbeHAUQV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 16:16:21 -0400
Received: by mail-io0-f194.google.com with SMTP id k16-v6so16900348iom.12
        for <linux-nfs@vger.kernel.org>; Wed, 01 Aug 2018 11:29:20 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs: pnfs_find_lseg() should not check NFS_LSEG_LAYOUTRETURN
Date: Wed,  1 Aug 2018 14:28:57 -0400
Message-Id: <20180801182857.59882-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Layout segment validity is determined only by the NFS_LSEG_VALID flag. If
it is set, the layout segment is finable. As it is, when the flexfiles
driver sets NFS_LSEG_LAYOUTRETURN to indicate that we cannot discard
the layout segment, but that it must be returned, then this can result
in an unnecessary layoutget storm.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7020f726275c..8f03bdb191aa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1650,7 +1650,6 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
-		    !test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
 		    pnfs_lseg_range_match(&lseg->pls_range, range,
 					  strict_iomode)) {
 			ret = pnfs_get_lseg(lseg);
-- 
2.17.1

