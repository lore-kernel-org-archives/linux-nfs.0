Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35667 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdGLXLJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 19:11:09 -0400
Received: by mail-it0-f67.google.com with SMTP id v193so4447126itc.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 16:11:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] Revert commit 722f0b891198 ("pNFS: Don't send COMMITs to the DSes if...")
Date: Wed, 12 Jul 2017 19:10:59 -0400
Message-Id: <20170712231059.32293-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170712231059.32293-4-trond.myklebust@primarydata.com>
References: <20170712231059.32293-1-trond.myklebust@primarydata.com>
 <20170712231059.32293-2-trond.myklebust@primarydata.com>
 <20170712231059.32293-3-trond.myklebust@primarydata.com>
 <20170712231059.32293-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Doing the test without taking any locks is racy, and so really it makes
more sense to do it in the flexfiles code (which is the only case that
cares).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 7ceb86627e54..25f28fa64c57 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -224,13 +224,6 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *cinfo,
 	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
 		if (list_empty(&bucket->committing))
 			continue;
-		/*
-		 * If the layout segment is invalid, then let
-		 * pnfs_generic_retry_commit() clean up the bucket.
-		 */
-		if (bucket->clseg && !pnfs_is_valid_lseg(bucket->clseg) &&
-		    !test_bit(NFS_LSEG_LAYOUTRETURN, &bucket->clseg->pls_flags))
-			break;
 		data = nfs_commitdata_alloc(false);
 		if (!data)
 			break;
-- 
2.13.0

