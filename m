From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: [PATCH 2/3] integrity: move ima_counts_get
Date: Tue, 19 May 2009 13:25:58 -0400
Message-ID: <4b26da825c7cff6c22e924012011bedb76f7079b.1242753148.git.zohar@linux.vnet.ibm.com>
References: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hooanon05@yahoo.co.jp,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Paris <eparis@redhat.com>,
	Hugh Dickins <hugh@veritas.com>,
	James Morris <jmorris@namei.org>,
	David Safford <safford@watson.ibm.com>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Mimi Zohar <zohar@us.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755785AbZESR01@vger.kernel.org>
In-Reply-To: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
In-Reply-To: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
References: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Based on discussion on lkml (Andrew Morton and Eric Paris),
move ima_counts_get down a layer into shmem/hugetlb__file_setup().
Resolves drm shmem_file_setup() usage case as well.

Signed-off-by: Mimi Zohar <zohar@us.ibm.com>
---
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 153d968..ccc62de 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -30,6 +30,7 @@
 #include <linux/dnotify.h>
 #include <linux/statfs.h>
 #include <linux/security.h>
+#include <linux/ima.h>
 
 #include <asm/uaccess.h>
 
@@ -997,6 +998,7 @@ struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
 			&hugetlbfs_file_operations);
 	if (!file)
 		goto out_dentry; /* inode is already attached */
+	ima_counts_get(file);
 
 	return file;
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 47b4642..5608183 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -384,7 +384,6 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
 		goto no_file;
-	ima_counts_get(file);
 
 	id = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
 	if (id < 0) {
diff --git a/mm/shmem.c b/mm/shmem.c
index a817f75..0132fbd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2659,6 +2659,7 @@ struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags)
 	if (error)
 		goto close_file;
 #endif
+	ima_counts_get(file);
 	return file;
 
 close_file:
@@ -2684,7 +2685,6 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-	ima_counts_get(file);
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	vma->vm_file = file;
-- 
1.6.0.6
