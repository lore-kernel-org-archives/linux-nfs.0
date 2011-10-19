Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619Ab1JSUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] NFS: Don't rely on PageError in nfs_readpage_release_partial
Date: Wed, 19 Oct 2011 13:50:17 -0700
Message-Id: <1319057418-9851-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-6-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't rely on the PageError flag to tell us if one of the partial reads of
the page failed. Instead, replace that with a dedicated flag in the
struct nfs_page.

Then clean out redundant uses of the PageError flag: the VM no longer
checks it for reads.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c            |    7 ++-----
 include/linux/nfs_page.h |    1 +
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 09829d96..fd58e90 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -276,7 +276,6 @@ nfs_async_read_error(struct list_head *head)
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		SetPageError(req->wb_page);
 		nfs_readpage_release(req);
 	}
 }
@@ -330,7 +329,6 @@ out_bad:
 		list_del(&data->list);
 		nfs_readdata_free(data);
 	}
-	SetPageError(page);
 	nfs_readpage_release(req);
 	return -ENOMEM;
 }
@@ -460,10 +458,10 @@ static void nfs_readpage_release_partial(void *calldata)
 	int status = data->task.tk_status;
 
 	if (status < 0)
-		SetPageError(page);
+		set_bit(PG_PARTIAL_READ_FAILED, &req->wb_flags);
 
 	if (atomic_dec_and_test(&req->wb_complete)) {
-		if (!PageError(page))
+		if (!test_bit(PG_PARTIAL_READ_FAILED, &req->wb_flags))
 			SetPageUptodate(page);
 		nfs_readpage_release(req);
 	}
@@ -656,7 +654,6 @@ readpage_async_filler(void *data, struct page *page)
 	return 0;
 out_error:
 	error = PTR_ERR(new);
-	SetPageError(page);
 out_unlock:
 	unlock_page(page);
 	return error;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index e2791a2..ab465fe 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -34,6 +34,7 @@ enum {
 	PG_NEED_COMMIT,
 	PG_NEED_RESCHED,
 	PG_PNFS_COMMIT,
+	PG_PARTIAL_READ_FAILED,
 };
 
 struct nfs_inode;
-- 
1.7.6.4

