From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 2/2] NFS: Fix a potential deadlock in nfs_file_mmap()
Date: Fri, 08 Jan 2010 19:56:24 -0500
Message-ID: <20100109005624.7473.15560.stgit@localhost.localdomain>
References: <20100109005624.7473.33215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754314Ab0AIBHm@vger.kernel.org>
In-Reply-To: <20100109005624.7473.33215.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We cannot call nfs_invalidate_mapping() inside file->f_ops->mmap(), since
this would cause us to grab the inode->i_mutex while already holding the
current->mm->mmap_sem (thus causing a potential ABBA deadlock with the file
write code, which can grab those locks in the opposite order).

We can fix this situation for the mmap() system call by using the new
mmap_pgoff() callback, which is called prior to taking the
current->mm->mmap_sem mutex.

We also add ensure that open() invalidates the mapping if the inode data is
stale so that other users of mmap() (mainly the exec and uselib system
calls) get up to date data too.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c  |   28 ++++++++++++++++++++++------
 fs/nfs/inode.c |    4 ++++
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..723e254 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -42,6 +42,9 @@ static int nfs_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
 static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
+static unsigned long nfs_file_mmap_pgoff(struct file * file,
+		unsigned long addr, unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long pgoff);
 static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
 					struct pipe_inode_info *pipe,
 					size_t count, unsigned int flags);
@@ -78,6 +81,7 @@ const struct file_operations nfs_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+	.mmap_pgoff	= nfs_file_mmap_pgoff,
 };
 
 const struct inode_operations nfs_file_inode_operations = {
@@ -290,24 +294,36 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 static int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
-	struct dentry *dentry = file->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
 	int	status;
 
 	dprintk("NFS: mmap(%s/%s)\n",
-		dentry->d_parent->d_name.name, dentry->d_name.name);
+			file->f_path.dentry->d_parent->d_name.name,
+			file->f_path.dentry->d_name.name);
 
 	/* Note: generic_file_mmap() returns ENOSYS on nommu systems
 	 *       so we call that before revalidating the mapping
 	 */
 	status = generic_file_mmap(file, vma);
-	if (!status) {
+	if (!status)
 		vma->vm_ops = &nfs_file_vm_ops;
-		status = nfs_revalidate_mapping(inode, file->f_mapping);
-	}
 	return status;
 }
 
+static unsigned long
+nfs_file_mmap_pgoff(struct file * file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long pgoff)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	int status;
+
+	status = nfs_revalidate_mapping(inode, file->f_mapping);
+	if (status < 0)
+		return status;
+
+	return generic_file_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+}
+
 /*
  * Flush any dirty pages for this process, and check for write errors.
  * The return status from this call provides a reliable indication of
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..90e1d67 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -56,6 +56,8 @@
 static int enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
 
 static void nfs_invalidate_inode(struct inode *);
+static int nfs_invalidate_mapping(struct inode *inode,
+		struct address_space *mapping);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
 static struct kmem_cache * nfs_inode_cachep;
@@ -694,6 +696,8 @@ int nfs_open(struct inode *inode, struct file *filp)
 	nfs_file_set_open_context(filp, ctx);
 	put_nfs_open_context(ctx);
 	nfs_fscache_set_inode_cookie(inode, filp);
+	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA)
+		nfs_invalidate_mapping(inode, filp->f_mapping);
 	return 0;
 }
 
