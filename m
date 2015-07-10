Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:36370 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932612AbbGJT7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 15:59:33 -0400
Received: by ykey15 with SMTP id y15so75375999yke.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 12:59:33 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: remove some dead code in ff_layout_pg_get_mirror_count_write
Date: Fri, 10 Jul 2015 15:59:26 -0400
Message-Id: <1436558366-23823-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already know that pg_lseg is NULL here.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c12951b9551e..8d4582eb4b99 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -728,8 +728,6 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 		return FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg);
 
 	/* no lseg means that pnfs is not in use, so no mirroring here */
-	pnfs_put_lseg(pgio->pg_lseg);
-	pgio->pg_lseg = NULL;
 	nfs_pageio_reset_write_mds(pgio);
 	return 1;
 }
-- 
2.4.3

