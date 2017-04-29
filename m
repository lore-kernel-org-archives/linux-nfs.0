Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34184 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031347AbdD2Ssv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Apr 2017 14:48:51 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so15958480ioi.1
        for <linux-nfs@vger.kernel.org>; Sat, 29 Apr 2017 11:48:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pNFS: Don't send COMMITs to the DSes if the server invalidated our layout
Date: Sat, 29 Apr 2017 14:48:44 -0400
Message-Id: <20170429184845.58057-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170429184845.58057-2-trond.myklebust@primarydata.com>
References: <20170429184845.58057-1-trond.myklebust@primarydata.com>
 <20170429184845.58057-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout was invalidated, then assume we should requeue all the
pending writes for the DS in question.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index dc4111d08a27..7697ac0ff81a 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -217,6 +217,13 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *cinfo,
 	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
 		if (list_empty(&bucket->committing))
 			continue;
+		/*
+		 * If the layout segment is invalid, then let
+		 * pnfs_generic_retry_commit() clean up the bucket.
+		 */
+		if (!pnfs_is_valid_lseg(bucket->clseg) &&
+		    !test_bit(NFS_LSEG_LAYOUTRETURN, &bucket->clseg->pls_flags))
+			continue;
 		data = nfs_commitdata_alloc(false);
 		if (!data)
 			break;
-- 
2.9.3

