From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH] nfs client: kill compile warning on NOMMU machine
Date: Thu,  6 Nov 2008 17:15:21 +0800
Message-ID: <1225962921-6424-1-git-send-email-cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org, Bryan Wu <cooloney@kernel.org>
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:64994 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbYKFJOB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 04:14:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On nommu machine such as Blackfin, when compling NFS we got an warning about
nfs_file_mmap() function defined but not used.

This patch kills this warning.

Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 fs/nfs/file.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d319b49..66b8b8e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -64,11 +64,7 @@ const struct file_operations nfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
-#ifdef CONFIG_MMU
 	.mmap		= nfs_file_mmap,
-#else
-	.mmap		= generic_file_mmap,
-#endif
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
 	.release	= nfs_file_release,
@@ -294,6 +290,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	return res;
 }
 
+#ifdef CONFIG_MMU
 static int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
@@ -312,6 +309,17 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	}
 	return status;
 }
+#else
+static int
+nfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	/* Kill warning: 'nfs_file_vm_ops' defined but not used */
+	struct vm_operations_struct *vm_ops;
+	vm_ops = &nfs_file_vm_ops;
+
+	return generic_file_mmap(file, vma);
+}
+#endif
 
 /*
  * Flush any dirty pages for this process, and check for write errors.
-- 
1.5.6.3
