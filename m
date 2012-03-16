Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab2CPSoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 14:44:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH v2 2/2] NFSv4.1: Fix a few issues in filelayout_commit_pagelist
Date: Fri, 16 Mar 2012 14:43:53 -0400
Message-Id: <1331923433-12055-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1331923433-12055-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1331923433-12055-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Fix a race in which NFS_I(inode)->commits_outstanding could potentially
  go to zero (triggering a call to nfs_commit_clear_lock()) before we're
  done sending out all the commit RPC calls.

- If nfs_commitdata_alloc fails, there is no reason why we shouldn't
  try to send off all the commits-to-ds.

- Simplify the error handling.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   45 +++++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e351bdf..fa3aebd 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -982,12 +982,14 @@ out_done:
 	return rv;
 }
 
-static int alloc_ds_commits(struct inode *inode, struct list_head *list)
+static unsigned int
+alloc_ds_commits(struct inode *inode, struct list_head *list)
 {
 	struct pnfs_layout_segment *lseg;
 	struct nfs4_filelayout_segment *fl;
 	struct nfs_write_data *data;
 	int i, j;
+	unsigned int nreq = 0;
 
 	/* Won't need this when non-whole file layout segments are supported
 	 * instead we will use a pnfs_layout_hdr structure */
@@ -1000,15 +1002,14 @@ static int alloc_ds_commits(struct inode *inode, struct list_head *list)
 			continue;
 		data = nfs_commitdata_alloc();
 		if (!data)
-			goto out_bad;
+			break;
 		data->ds_commit_index = i;
 		data->lseg = lseg;
 		list_add(&data->pages, list);
+		nreq++;
 	}
-	put_lseg(lseg);
-	return 0;
 
-out_bad:
+	/* Clean up on error */
 	for (j = i; j < fl->number_of_buckets; j++) {
 		if (list_empty(&fl->commit_buckets[i].committing))
 			continue;
@@ -1017,7 +1018,7 @@ out_bad:
 	}
 	put_lseg(lseg);
 	/* Caller will clean up entries put on list */
-	return -ENOMEM;
+	return nreq;
 }
 
 /* This follows nfs_commit_list pretty closely */
@@ -1027,21 +1028,29 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 {
 	struct nfs_write_data	*data, *tmp;
 	LIST_HEAD(list);
+	unsigned int nreq = 0;
 
 	if (!list_empty(mds_pages)) {
 		data = nfs_commitdata_alloc();
-		if (!data)
-			goto out_bad;
-		data->lseg = NULL;
-		list_add(&data->pages, &list);
+		if (data != NULL) {
+			data->lseg = NULL;
+			list_add(&data->pages, &list);
+			nreq++;
+		} else
+			nfs_retry_commit(mds_pages, NULL);
 	}
 
-	if (alloc_ds_commits(inode, &list))
-		goto out_bad;
+	nreq += alloc_ds_commits(inode, &list);
+
+	if (nreq == 0) {
+		nfs_commit_clear_lock(NFS_I(inode));
+		goto out;
+	}
+
+	atomic_add(nreq, &NFS_I(inode)->commits_outstanding);
 
 	list_for_each_entry_safe(data, tmp, &list, pages) {
 		list_del_init(&data->pages);
-		atomic_inc(&NFS_I(inode)->commits_outstanding);
 		if (!data->lseg) {
 			nfs_init_commit(data, mds_pages, NULL);
 			nfs_initiate_commit(data, NFS_CLIENT(inode),
@@ -1051,16 +1060,8 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			filelayout_initiate_commit(data, how);
 		}
 	}
+out:
 	return 0;
- out_bad:
-	list_for_each_entry_safe(data, tmp, &list, pages) {
-		nfs_retry_commit(&data->pages, data->lseg);
-		list_del_init(&data->pages);
-		nfs_commit_free(data);
-	}
-	nfs_retry_commit(mds_pages, NULL);
-	nfs_commit_clear_lock(NFS_I(inode));
-	return -ENOMEM;
 }
 
 static void
-- 
1.7.7.6

