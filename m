From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/32] SUNRPC: Remove the global temporary write buffer in
 net/sunrpc/cache.c
Date: Wed, 19 Aug 2009 19:38:45 -0400
Message-ID: <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754137AbZHSXlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:03 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe90f028534
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:51 -0700 (PDT)
In-Reply-To: <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While we do want to protect against multiple concurrent readers and writers
on each upcall/downcall pipe, we don't want to limit concurrent reading and
writing to separate caches.

This patch therefore replaces the static buffer 'write_buf', which can only
be used by one writer at a time, with use of the page cache as the
temporary buffer for downcalls. We still fall back to using the the old
global buffer if the downcall is larger than PAGE_CACHE_SIZE, since this is
apparently needed by the SPKM security context initialisation.

It then replaces the use of the global 'queue_io_mutex' with the
inode->i_mutex in cache_read() and cache_write().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/cache.c |   95 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 70 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 062d4f4..c8e7d2d 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -27,6 +27,7 @@
 #include <linux/net.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
+#include <linux/pagemap.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -702,13 +703,14 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 {
 	struct cache_reader *rp = filp->private_data;
 	struct cache_request *rq;
-	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct cache_detail *cd = PDE(inode)->data;
 	int err;
 
 	if (count == 0)
 		return 0;
 
-	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
+	mutex_lock(&inode->i_mutex); /* protect against multiple concurrent
 			      * readers on this file */
  again:
 	spin_lock(&queue_lock);
@@ -721,7 +723,7 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 	}
 	if (rp->q.list.next == &cd->queue) {
 		spin_unlock(&queue_lock);
-		mutex_unlock(&queue_io_mutex);
+		mutex_unlock(&inode->i_mutex);
 		BUG_ON(rp->offset);
 		return 0;
 	}
@@ -768,38 +770,81 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 	}
 	if (err == -EAGAIN)
 		goto again;
-	mutex_unlock(&queue_io_mutex);
+	mutex_unlock(&inode->i_mutex);
 	return err ? err :  count;
 }
 
-static char write_buf[8192]; /* protected by queue_io_mutex */
+static ssize_t cache_do_downcall(char *kaddr, const char __user *buf,
+				 size_t count, struct cache_detail *cd)
+{
+	ssize_t ret;
 
-static ssize_t
-cache_write(struct file *filp, const char __user *buf, size_t count,
-	    loff_t *ppos)
+	if (copy_from_user(kaddr, buf, count))
+		return -EFAULT;
+	kaddr[count] = '\0';
+	ret = cd->cache_parse(cd, kaddr, count);
+	if (!ret)
+		ret = count;
+	return ret;
+}
+
+static ssize_t cache_slow_downcall(const char __user *buf,
+				   size_t count, struct cache_detail *cd)
 {
-	int err;
-	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+	static char write_buf[8192]; /* protected by queue_io_mutex */
+	ssize_t ret = -EINVAL;
 
-	if (count == 0)
-		return 0;
 	if (count >= sizeof(write_buf))
-		return -EINVAL;
-
+		goto out;
 	mutex_lock(&queue_io_mutex);
+	ret = cache_do_downcall(write_buf, buf, count, cd);
+	mutex_unlock(&queue_io_mutex);
+out:
+	return ret;
+}
 
-	if (copy_from_user(write_buf, buf, count)) {
-		mutex_unlock(&queue_io_mutex);
-		return -EFAULT;
-	}
-	write_buf[count] = '\0';
-	if (cd->cache_parse)
-		err = cd->cache_parse(cd, write_buf, count);
-	else
-		err = -EINVAL;
+static ssize_t cache_downcall(struct address_space *mapping,
+			      const char __user *buf,
+			      size_t count, struct cache_detail *cd)
+{
+	struct page *page;
+	char *kaddr;
+	ssize_t ret = -ENOMEM;
+
+	if (count >= PAGE_CACHE_SIZE)
+		goto out_slow;
+
+	page = find_or_create_page(mapping, 0, GFP_KERNEL);
+	if (!page)
+		goto out_slow;
+
+	kaddr = kmap(page);
+	ret = cache_do_downcall(kaddr, buf, count, cd);
+	kunmap(page);
+	unlock_page(page);
+	page_cache_release(page);
+	return ret;
+out_slow:
+	return cache_slow_downcall(buf, count, cd);
+}
 
-	mutex_unlock(&queue_io_mutex);
-	return err ? err : count;
+static ssize_t
+cache_write(struct file *filp, const char __user *buf, size_t count,
+	    loff_t *ppos)
+{
+	struct address_space *mapping = filp->f_mapping;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct cache_detail *cd = PDE(inode)->data;
+	ssize_t ret = -EINVAL;
+
+	if (!cd->cache_parse)
+		goto out;
+
+	mutex_lock(&inode->i_mutex);
+	ret = cache_downcall(mapping, buf, count, cd);
+	mutex_unlock(&inode->i_mutex);
+out:
+	return ret;
 }
 
 static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
-- 
1.6.0.4
