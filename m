From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: [PATCH 1/3] integrity: path_check update
Date: Tue, 19 May 2009 13:25:57 -0400
Message-ID: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Paris <eparis@redhat.com>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	James Morris <jmorris@namei.org>,
	David Safford <safford-aZOuKsOsJu3MbYB6QlFGEg@public.gmane.org>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Mimi Zohar <zohar@us.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:50627 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484AbZESR0B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 13:26:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Add support in ima_path_check() for integrity checking without
incrementing the counts. (Required for nfsd.)
- rename and export opencount_get to ima_counts_get
- replace ima_shm_check calls with ima_counts_get
- export ima_path_check

Signed-off-by: Mimi Zohar <zohar@us.ibm.com>
---
diff --git a/fs/exec.c b/fs/exec.c
index 998e856..618d6d1 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -130,7 +130,8 @@ SYSCALL_DEFINE1(uselib, const char __user *, library)
 				 MAY_READ | MAY_EXEC | MAY_OPEN);
 	if (error)
 		goto exit;
-	error = ima_path_check(&nd.path, MAY_READ | MAY_EXEC | MAY_OPEN);
+	error = ima_path_check(&nd.path, MAY_READ | MAY_EXEC | MAY_OPEN,
+			       IMA_COUNT_UPDATE);
 	if (error)
 		goto exit;
 
@@ -680,7 +681,7 @@ struct file *open_exec(const char *name)
 	err = inode_permission(nd.path.dentry->d_inode, MAY_EXEC | MAY_OPEN);
 	if (err)
 		goto out_path_put;
-	err = ima_path_check(&nd.path, MAY_EXEC | MAY_OPEN);
+	err = ima_path_check(&nd.path, MAY_EXEC | MAY_OPEN, IMA_COUNT_UPDATE);
 	if (err)
 		goto out_path_put;
 
diff --git a/fs/namei.c b/fs/namei.c
index 78f253c..b05a2b1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -853,7 +853,8 @@ static int __link_path_walk(const char *name, struct nameidata *nd)
 			err = inode_permission(nd->path.dentry->d_inode,
 					       MAY_EXEC);
 		if (!err)
-			err = ima_path_check(&nd->path, MAY_EXEC);
+			err = ima_path_check(&nd->path, MAY_EXEC,
+				             IMA_COUNT_UPDATE);
  		if (err)
 			break;
 
@@ -1515,7 +1516,8 @@ int may_open(struct path *path, int acc_mode, int flag)
 		return error;
 
 	error = ima_path_check(path,
-			       acc_mode & (MAY_READ | MAY_WRITE | MAY_EXEC));
+			       acc_mode & (MAY_READ | MAY_WRITE | MAY_EXEC),
+			       IMA_COUNT_UPDATE);
 	if (error)
 		return error;
 	/*
diff --git a/include/linux/ima.h b/include/linux/ima.h
index 0e2aa45..b1b827d 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -13,14 +13,17 @@
 #include <linux/fs.h>
 struct linux_binprm;
 
+#define IMA_COUNT_UPDATE 1
+#define IMA_COUNT_LEAVE 0
+
 #ifdef CONFIG_IMA
 extern int ima_bprm_check(struct linux_binprm *bprm);
 extern int ima_inode_alloc(struct inode *inode);
 extern void ima_inode_free(struct inode *inode);
-extern int ima_path_check(struct path *path, int mask);
+extern int ima_path_check(struct path *path, int mask, int update_counts);
 extern void ima_file_free(struct file *file);
 extern int ima_file_mmap(struct file *file, unsigned long prot);
-extern void ima_shm_check(struct file *file);
+extern void ima_counts_get(struct file *file);
 
 #else
 static inline int ima_bprm_check(struct linux_binprm *bprm)
@@ -38,7 +41,7 @@ static inline void ima_inode_free(struct inode *inode)
 	return;
 }
 
-static inline int ima_path_check(struct path *path, int mask)
+static inline int ima_path_check(struct path *path, int mask, int update_counts)
 {
 	return 0;
 }
@@ -53,7 +56,7 @@ static inline int ima_file_mmap(struct file *file, unsigned long prot)
 	return 0;
 }
 
-static inline void ima_shm_check(struct file *file)
+static inline void ima_counts_get(struct file *file)
 {
 	return;
 }
diff --git a/ipc/shm.c b/ipc/shm.c
index faa46da..47b4642 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -384,7 +384,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
 		goto no_file;
-	ima_shm_check(file);
+	ima_counts_get(file);
 
 	id = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
 	if (id < 0) {
@@ -891,7 +891,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 	file = alloc_file(path.mnt, path.dentry, f_mode, &shm_file_operations);
 	if (!file)
 		goto out_free;
-	ima_shm_check(file);
+	ima_counts_get(file);
 
 	file->private_data = sfd;
 	file->f_mapping = shp->shm_file->f_mapping;
diff --git a/mm/shmem.c b/mm/shmem.c
index b25f95c..a817f75 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2684,7 +2684,7 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-	ima_shm_check(file);
+	ima_counts_get(file);
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	vma->vm_file = file;
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index c4228c0..a2eb233 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -125,6 +125,15 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
 	return rc;
 }
 
+static void ima_update_counts(struct ima_iint_cache *iint, int mask)
+{
+	iint->opencount++;
+	if ((mask & MAY_WRITE) || (mask == 0))
+		iint->writecount++;
+	else if (mask & (MAY_READ | MAY_EXEC))
+		iint->readcount++;
+}
+
 /**
  * ima_path_check - based on policy, collect/store measurement.
  * @path: contains a pointer to the path to be measured
@@ -143,7 +152,7 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
  * Return 0 on success, an error code on failure.
  * (Based on the results of appraise_measurement().)
  */
-int ima_path_check(struct path *path, int mask)
+int ima_path_check(struct path *path, int mask, int update_counts)
 {
 	struct inode *inode = path->dentry->d_inode;
 	struct ima_iint_cache *iint;
@@ -157,11 +166,8 @@ int ima_path_check(struct path *path, int mask)
 		return 0;
 
 	mutex_lock(&iint->mutex);
-	iint->opencount++;
-	if ((mask & MAY_WRITE) || (mask == 0))
-		iint->writecount++;
-	else if (mask & (MAY_READ | MAY_EXEC))
-		iint->readcount++;
+	if (update_counts)
+		ima_update_counts(iint, mask);
 
 	rc = ima_must_measure(iint, inode, MAY_READ, PATH_CHECK);
 	if (rc < 0)
@@ -197,6 +203,7 @@ out:
 	kref_put(&iint->refcount, iint_free);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ima_path_check);
 
 static int process_measurement(struct file *file, const unsigned char *filename,
 			       int mask, int function)
@@ -225,7 +232,16 @@ out:
 	return rc;
 }
 
-static void opencount_get(struct file *file)
+/*
+ * ima_opens_get - increment file counts
+ *
+ * - for IPC shm and shmat file.
+ * - for nfsd exported files.
+ *
+ * Increment the counts for these files to prevent unnecessary
+ * imbalance messages.
+ */
+void ima_counts_get(struct file *file)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct ima_iint_cache *iint;
@@ -237,8 +253,14 @@ static void opencount_get(struct file *file)
 		return;
 	mutex_lock(&iint->mutex);
 	iint->opencount++;
+	if ((file->f_mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
+		iint->readcount++;
+
+	if (file->f_mode & FMODE_WRITE)
+		iint->writecount++;
 	mutex_unlock(&iint->mutex);
 }
+EXPORT_SYMBOL_GPL(ima_counts_get);
 
 /**
  * ima_file_mmap - based on policy, collect/store measurement.
@@ -263,18 +285,6 @@ int ima_file_mmap(struct file *file, unsigned long prot)
 	return 0;
 }
 
-/*
- * ima_shm_check - IPC shm and shmat create/fput a file
- *
- * Maintain the opencount for these files to prevent unnecessary
- * imbalance messages.
- */
-void ima_shm_check(struct file *file)
-{
-	opencount_get(file);
-	return;
-}
-
 /**
  * ima_bprm_check - based on policy, collect/store measurement.
  * @bprm: contains the linux_binprm structure
-- 
1.6.0.6

