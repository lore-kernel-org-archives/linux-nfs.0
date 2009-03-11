From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/30] NFS: Kill the "defined but not used" compile error
 on nommu machines
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184108.5578.47203.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbZCKSoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:12 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3YM021751
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:09 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Wu reports that when compiling NFS on nommu machines he gets a
"defined but not used" error on nfs_file_mmap().

The easiest fix is simply to get rid of the special casing in NFS, and
just always call generic_file_mmap() to set up the file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 404c19c..1eab9c9 100644
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
@@ -304,11 +300,13 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 	dprintk("NFS: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	status = nfs_revalidate_mapping(inode, file->f_mapping);
+	/* Note: generic_file_mmap() returns ENOSYS on nommu systems
+	 *       so we call that before revalidating the mapping
+	 */
+	status = generic_file_mmap(file, vma);
 	if (!status) {
 		vma->vm_ops = &nfs_file_vm_ops;
-		vma->vm_flags |= VM_CAN_NONLINEAR;
-		file_accessed(file);
+		status = nfs_revalidate_mapping(inode, file->f_mapping);
 	}
 	return status;
 }

