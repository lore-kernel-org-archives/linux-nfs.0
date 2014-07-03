Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40340 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaGCFIP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:08:15 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so13054317pdb.25
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:08:15 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>,
        Tom Haynes <Thomas.Haynes@primarydata.com>
Subject: [PATCH 2/2] pnfs/filelayout: retry ds commit if nfs_commitdata_alloc fails
Date: Thu,  3 Jul 2014 13:07:46 +0800
Message-Id: <1404364066-13031-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1404364066-13031-1-git-send-email-tao.peng@primarydata.com>
References: <1404364066-13031-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 39 ++++++++++++++++++++++++++-------------
 1 file changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index a928f92..2576d28b 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1237,15 +1237,33 @@ restart:
 	spin_unlock(cinfo->lock);
 }
 
+static void filelayout_retry_commit(struct nfs_commit_info *cinfo, int idx)
+{
+	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
+	struct pnfs_commit_bucket *bucket = fl_cinfo->buckets;
+	struct pnfs_layout_segment *freeme;
+	int i;
+
+	for (i = idx; i < fl_cinfo->nbuckets; i++, bucket++) {
+		if (list_empty(&bucket->committing))
+			continue;
+		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
+		spin_lock(cinfo->lock);
+		freeme = bucket->clseg;
+		bucket->clseg = NULL;
+		spin_unlock(cinfo->lock);
+		pnfs_put_lseg(freeme);
+	}
+}
+
 static unsigned int
 alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 {
 	struct pnfs_ds_commit_info *fl_cinfo;
 	struct pnfs_commit_bucket *bucket;
 	struct nfs_commit_data *data;
-	int i, j;
+	int i;
 	unsigned int nreq = 0;
-	struct pnfs_layout_segment *freeme;
 
 	fl_cinfo = cinfo->ds;
 	bucket = fl_cinfo->buckets;
@@ -1265,16 +1283,7 @@ alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 	}
 
 	/* Clean up on error */
-	for (j = i; j < fl_cinfo->nbuckets; j++, bucket++) {
-		if (list_empty(&bucket->committing))
-			continue;
-		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
-		spin_lock(cinfo->lock);
-		freeme = bucket->clseg;
-		bucket->clseg = NULL;
-		spin_unlock(cinfo->lock);
-		pnfs_put_lseg(freeme);
-	}
+	filelayout_retry_commit(cinfo, i);
 	/* Caller will clean up entries put on list */
 	return nreq;
 }
@@ -1294,8 +1303,12 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			data->lseg = NULL;
 			list_add(&data->pages, &list);
 			nreq++;
-		} else
+		} else {
 			nfs_retry_commit(mds_pages, NULL, cinfo);
+			filelayout_retry_commit(cinfo, 0);
+			cinfo->completion_ops->error_cleanup(NFS_I(inode));
+			return -ENOMEM;
+		}
 	}
 
 	nreq += alloc_ds_commits(cinfo, &list);
-- 
1.9.1

