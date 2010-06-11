From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 14/26] pnfs_submit: use fsdata to pass lseg
Date: Fri, 11 Jun 2010 03:31:41 -0400
Message-ID: <1276241513-17942-15-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
 <1276241513-17942-13-git-send-email-iisaman@netapp.com>
 <1276241513-17942-14-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757682Ab0FKHcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:23 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3u7024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:23 -0700 (PDT)
In-Reply-To: <1276241513-17942-14-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparing for LAYUTGET invocation in nfs_write_begin to be the
only invocation in the write path.

It isn't used at all yet, but it should be properly referenced/dereferenced

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 03601d2..e308244 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -414,12 +414,17 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
+	struct pnfs_layout_segment *lseg;
 
 	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+	pnfs_update_layout(mapping->host,
+			   nfs_file_open_context(file),
+			   NFS4_MAX_UINT64, 0, IOMODE_RW,
+			   &lseg);
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
@@ -428,11 +433,13 @@ start:
 	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
 	if (ret)
-		return ret;
+		goto out;
 
 	page = grab_cache_page_write_begin(mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	*pagep = page;
 
 	ret = nfs_flush_incompatible(file, page);
@@ -447,6 +454,12 @@ start:
 		if (!ret)
 			goto start;
 	}
+	*fsdata = lseg;
+ out:
+	if (ret) {
+		put_lseg(lseg);
+		*fsdata = NULL;
+	}
 	return ret;
 }
 
@@ -456,6 +469,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 {
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	int status;
+	struct pnfs_layout_segment *lseg = fsdata;
 
 	dfprintk(PAGECACHE, "NFS: write_end(%s/%s(%ld), %u@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
@@ -486,6 +500,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 	unlock_page(page);
 	page_cache_release(page);
+	put_lseg(lseg);
 
 	if (status < 0)
 		return status;
-- 
1.6.6.1

