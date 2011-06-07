Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52865 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab1FGR0v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:51 -0400
Date: Tue, 7 Jun 2011 13:26:50 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 08/88] HACK: propagate fsdata into nfs_writepage_setup
Message-ID: <16a8e2bf277999bbc976b115467394f4d7c9a292.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

This is needed for the eof hack

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c          |    4 ++--
 fs/nfs/write.c         |    9 ++++++---
 include/linux/nfs_fs.h |    3 ++-
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3af1c00..1768762 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -469,7 +469,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 	status = pnfs_write_end(file, page, pos, len, copied, lseg);
 	if (status)
 		goto out;
-	status = nfs_updatepage(file, page, offset, copied);
+	status = nfs_updatepage(file, page, offset, copied, lseg, fsdata);
 
 out:
 	unlock_page(page);
@@ -597,7 +597,7 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	ret = VM_FAULT_LOCKED;
 	if (nfs_flush_incompatible(filp, page) == 0 &&
-	    nfs_updatepage(filp, page, 0, pagelen) == 0)
+	    nfs_updatepage(filp, page, 0, pagelen, NULL, NULL) == 0)
 		goto out;
 
 	ret = VM_FAULT_SIGBUS;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e268e3b..fc36db8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -673,7 +673,9 @@ out:
 }
 
 static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
-		unsigned int offset, unsigned int count)
+		unsigned int offset, unsigned int count,
+		struct pnfs_layout_segment *lseg, void *fsdata)
+
 {
 	struct nfs_page	*req;
 
@@ -734,7 +736,8 @@ static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
  * things with a page scheduled for an RPC call (e.g. invalidate it).
  */
 int nfs_updatepage(struct file *file, struct page *page,
-		unsigned int offset, unsigned int count)
+		unsigned int offset, unsigned int count,
+		struct pnfs_layout_segment *lseg, void *fsdata)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode	*inode = page->mapping->host;
@@ -759,7 +762,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}
 
-	status = nfs_writepage_setup(ctx, page, offset, count);
+	status = nfs_writepage_setup(ctx, page, offset, count, lseg, fsdata);
 	if (status < 0)
 		nfs_set_pageerror(page);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1b93b9c..d45e3b3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -510,7 +510,8 @@ extern int  nfs_congestion_kb;
 extern int  nfs_writepage(struct page *page, struct writeback_control *wbc);
 extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
-extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
+extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int,
+			   struct pnfs_layout_segment *, void *);
 extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 
 /*
-- 
1.7.4.1

