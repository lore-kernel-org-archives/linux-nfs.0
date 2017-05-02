Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35587 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdEBQiV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:21 -0400
Received: by mail-io0-f196.google.com with SMTP id d203so31589806iof.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] pNFS: Fix a typo in pnfs_generic_alloc_ds_commits
Date: Tue,  2 May 2017 12:38:10 -0400
Message-Id: <20170502163812.6211-7-trond.myklebust@primarydata.com>
In-Reply-To: <20170502163812.6211-6-trond.myklebust@primarydata.com>
References: <20170502163812.6211-1-trond.myklebust@primarydata.com>
 <20170502163812.6211-2-trond.myklebust@primarydata.com>
 <20170502163812.6211-3-trond.myklebust@primarydata.com>
 <20170502163812.6211-4-trond.myklebust@primarydata.com>
 <20170502163812.6211-5-trond.myklebust@primarydata.com>
 <20170502163812.6211-6-trond.myklebust@primarydata.com>
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

