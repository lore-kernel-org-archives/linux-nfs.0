Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36840 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753847AbdECQat (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 12:30:49 -0400
Received: by mail-it0-f68.google.com with SMTP id x188so6694377itb.3
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 09:30:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <fred.isaman@gmail.com>
Subject: [PATCH] pNFS: Fix NULL dereference in pnfs_generic_alloc_ds_commits
Date: Wed,  3 May 2017 12:30:45 -0400
Message-Id: <20170503163045.16067-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index ae600ab1a646..d40755a0984b 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -221,7 +221,7 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *cinfo,
 		 * If the layout segment is invalid, then let
 		 * pnfs_generic_retry_commit() clean up the bucket.
 		 */
-		if (!pnfs_is_valid_lseg(bucket->clseg) &&
+		if (bucket->clseg && !pnfs_is_valid_lseg(bucket->clseg) &&
 		    !test_bit(NFS_LSEG_LAYOUTRETURN, &bucket->clseg->pls_flags))
 			break;
 		data = nfs_commitdata_alloc(false);
-- 
2.9.3

