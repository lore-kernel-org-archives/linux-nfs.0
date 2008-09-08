From: Hisashi Hifumi <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH] NFS: Pagecache usage optimization on nfs
Date: Mon, 08 Sep 2008 13:31:25 +0900
Message-ID: <6.0.0.20.2.20080908132950.04ab2d50@172.19.0.2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:47924 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbYIHEeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2008 00:34:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

The new address_space_ops is_partially_uptodate was added at 2.6.27-rc1.
On ext3, this aops checks whether buffer_heads that are attached to a page are
uptodate or not when a page is not uptodate. When all buffers which correspond
to a portion we want to read are uptodate even if a page is not uptodate, 
we can avoid actual read IO.

See
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8ab22b9abb5c55413802e4adc9aa6223324547c3;hp=d84a52f62f6a396ed77aa0052da74ca9e760b28a

I wrote is_partially_uptodate aops for nfs named nfs_is_partially_uptodate.This aops
checks whether read IO to a page is between wb_pgbase and wb_pgbase + wb_bytes of
nfs_page that is attached to this page. If this aops succeed, we do not have to do actual read.
I think random read/write mixed workloads or random read after random write 
workloads can be optimized with this patch.

Thanks.

Signed-off-by: Hisashi Hifumi <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>

diff -Nrup linux-2.6.27-rc5.org/fs/nfs/file.c linux-2.6.27-rc5.nfs/fs/nfs/file.c
--- linux-2.6.27-rc5.org/fs/nfs/file.c	2008-09-03 14:56:16.000000000 +0900
+++ linux-2.6.27-rc5.nfs/fs/nfs/file.c	2008-09-08 10:53:00.000000000 +0900
@@ -446,6 +446,7 @@ const struct address_space_operations nf
 	.releasepage = nfs_release_page,
 	.direct_IO = nfs_direct_IO,
 	.launder_page = nfs_launder_page,
+	.is_partially_uptodate = nfs_is_partially_uptodate,
 };
 
 static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
diff -Nrup linux-2.6.27-rc5.org/fs/nfs/read.c linux-2.6.27-rc5.nfs/fs/nfs/read.c
--- linux-2.6.27-rc5.org/fs/nfs/read.c	2008-07-14 06:51:29.000000000 +0900
+++ linux-2.6.27-rc5.nfs/fs/nfs/read.c	2008-09-08 11:02:59.000000000 +0900
@@ -605,6 +605,33 @@ out:
 	return ret;
 }
 
+int nfs_is_partially_uptodate(struct page *page, read_descriptor_t *desc,
+					unsigned long from)
+{
+	struct inode *inode = page->mapping->host;
+	unsigned to;
+	struct nfs_page *req = NULL;
+
+	spin_lock(&inode->i_lock);
+	if (PagePrivate(page)) {
+		req = (struct nfs_page *)page_private(page);
+		if (req)
+			kref_get(&req->wb_kref);
+	}
+	spin_unlock(&inode->i_lock);
+	if (!req)
+		return 0;
+
+	to = min_t(unsigned, PAGE_CACHE_SIZE - from, desc->count);
+	to = from + to;
+	if (from >= req->wb_pgbase && to <= req->wb_pgbase + req->wb_bytes) {
+		nfs_release_request(req);
+		return 1;
+	}
+	nfs_release_request(req);
+	return 0;
+}
+
 int __init nfs_init_readpagecache(void)
 {
 	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
diff -Nrup linux-2.6.27-rc5.org/include/linux/nfs_fs.h linux-2.6.27-rc5.nfs/include/linux/nfs_fs.h
--- linux-2.6.27-rc5.org/include/linux/nfs_fs.h	2008-09-03 14:56:20.000000000 +0900
+++ linux-2.6.27-rc5.nfs/include/linux/nfs_fs.h	2008-09-08 11:04:28.000000000 +0900
@@ -504,6 +504,8 @@ extern int  nfs_readpages(struct file *,
 		struct list_head *, unsigned);
 extern int  nfs_readpage_result(struct rpc_task *, struct nfs_read_data *);
 extern void nfs_readdata_release(void *data);
+extern int  nfs_is_partially_uptodate(struct page *, read_descriptor_t *,
+		unsigned long);
 
 /*
  * Allocate nfs_read_data structures

