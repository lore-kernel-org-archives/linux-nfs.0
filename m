From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 001/112] NFS: Optimise nfs_vm_page_mkwrite()
Date: Fri, 25 Jan 2008 11:37:23 -0500
Message-ID: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14323 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbYAYQ7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:42 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdsm010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:41 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current model locks the page twice for no good reason. Optimise by
inlining the parts of nfs_write_begin()/nfs_write_end() that we care about.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |   36 ++++++++++++++----------------------
 1 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index b3bb89f..4560fc2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -392,35 +392,27 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 	struct file *filp = vma->vm_file;
 	unsigned pagelen;
 	int ret = -EINVAL;
-	void *fsdata;
 	struct address_space *mapping;
-	loff_t offset;
 
 	lock_page(page);
 	mapping = page->mapping;
-	if (mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping) {
-		unlock_page(page);
-		return -EINVAL;
-	}
+	if (mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping)
+		goto out_unlock;
+
+	ret = 0;
 	pagelen = nfs_page_length(page);
-	offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	unlock_page(page);
+	if (pagelen == 0)
+		goto out_unlock;
 
-	/*
-	 * we can use mapping after releasing the page lock, because:
-	 * we hold mmap_sem on the fault path, which should pin the vma
-	 * which should pin the file, which pins the dentry which should
-	 * hold a reference on inode.
-	 */
+	ret = nfs_flush_incompatible(filp, page);
+	if (ret != 0)
+		goto out_unlock;
 
-	if (pagelen) {
-		struct page *page2 = NULL;
-		ret = nfs_write_begin(filp, mapping, offset, pagelen,
-			       	0, &page2, &fsdata);
-		if (!ret)
-			ret = nfs_write_end(filp, mapping, offset, pagelen,
-				       	pagelen, page2, fsdata);
-	}
+	ret = nfs_updatepage(filp, page, 0, pagelen);
+	if (ret == 0)
+		ret = pagelen;
+out_unlock:
+	unlock_page(page);
 	return ret;
 }
 
