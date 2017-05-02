Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33501 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbdEBQlL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:41:11 -0400
Received: by mail-it0-f67.google.com with SMTP id v135so3039083itv.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:41:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pNFS: Fix a typo in pnfs_generic_alloc_ds_commits
Date: Tue,  2 May 2017 12:41:05 -0400
Message-Id: <20170502164105.6373-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170502164105.6373-3-trond.myklebust@primarydata.com>
References: <20170502164105.6373-1-trond.myklebust@primarydata.com>
 <20170502164105.6373-2-trond.myklebust@primarydata.com>
 <20170502164105.6373-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout segment is invalid, we want to just resend the remaining
writes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 7697ac0ff81a..ae600ab1a646 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -223,7 +223,7 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *cinfo,
 		 */
 		if (!pnfs_is_valid_lseg(bucket->clseg) &&
 		    !test_bit(NFS_LSEG_LAYOUTRETURN, &bucket->clseg->pls_flags))
-			continue;
+			break;
 		data = nfs_commitdata_alloc(false);
 		if (!data)
 			break;
-- 
2.9.3

