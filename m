Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35944 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdGLXLH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 19:11:07 -0400
Received: by mail-it0-f67.google.com with SMTP id k3so4446521ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 16:11:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] NFS: Fix another COMMIT race in pNFS
Date: Wed, 12 Jul 2017 19:10:57 -0400
Message-Id: <20170712231059.32293-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170712231059.32293-2-trond.myklebust@primarydata.com>
References: <20170712231059.32293-1-trond.myklebust@primarydata.com>
 <20170712231059.32293-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must make sure that cinfo->ds->ncommitting is in sync with the
commit list, since it is checked as part of pnfs_commit_list().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 3e6de85faf42..7ceb86627e54 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -187,6 +187,7 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
 	struct pnfs_commit_bucket *bucket;
 	struct pnfs_layout_segment *freeme;
+	struct list_head *pos;
 	LIST_HEAD(pages);
 	int i;
 
@@ -197,6 +198,8 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 			continue;
 		freeme = bucket->clseg;
 		bucket->clseg = NULL;
+		list_for_each(pos, &bucket->committing)
+			cinfo->ds->ncommitting--;
 		list_splice_init(&bucket->committing, &pages);
 		spin_unlock(&cinfo->inode->i_lock);
 		nfs_retry_commit(&pages, freeme, cinfo, i);
@@ -247,9 +250,12 @@ void pnfs_fetch_commit_bucket_list(struct list_head *pages,
 		struct nfs_commit_info *cinfo)
 {
 	struct pnfs_commit_bucket *bucket;
+	struct list_head *pos;
 
 	bucket = &cinfo->ds->buckets[data->ds_commit_index];
 	spin_lock(&cinfo->inode->i_lock);
+	list_for_each(pos, &bucket->committing)
+		cinfo->ds->ncommitting--;
 	list_splice_init(&bucket->committing, pages);
 	data->lseg = bucket->clseg;
 	bucket->clseg = NULL;
@@ -334,7 +340,6 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		}
 	}
 out:
-	cinfo->ds->ncommitting = 0;
 	return PNFS_ATTEMPTED;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_commit_pagelist);
-- 
2.13.0

