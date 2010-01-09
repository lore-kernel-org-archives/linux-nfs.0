From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 1/2] VFS: Add a mmap_file() callback to struct
 file_operations
Date: Fri, 08 Jan 2010 19:56:24 -0500
Message-ID: <20100109005624.7473.24670.stgit@localhost.localdomain>
References: <20100109005624.7473.33215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20544 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab0AIBHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 20:07:31 -0500
In-Reply-To: <20100109005624.7473.33215.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper function to allow the NFS filesystem to hook mmap() system
calls and do the necessary page cache revalidation before passing control
to the VM layer.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/fs.h |    5 +++++
 mm/filemap.c       |   23 +++++++++++++++++++++++
 mm/mmap.c          |   11 ++++++++---
 mm/nommu.c         |   11 ++++++++---
 4 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9147ca8..5d66b16 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1504,6 +1504,9 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	unsigned long (*mmap_pgoff)(struct file *, unsigned long,
+			unsigned long, unsigned long,
+			unsigned long, unsigned long);
 };
 
 struct inode_operations {
@@ -2191,6 +2194,8 @@ extern int set_blocksize(struct block_device *, int);
 extern int sb_set_blocksize(struct super_block *, int);
 extern int sb_min_blocksize(struct super_block *, int);
 
+extern unsigned long generic_file_mmap_pgoff(struct file *, unsigned long,
+		unsigned long, unsigned long, unsigned long, unsigned long);
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
 extern int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size);
diff --git a/mm/filemap.c b/mm/filemap.c
index 96ac6b0..f7717b9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1594,6 +1594,29 @@ const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 };
 
+/**
+ * generic_file_mmap_pgoff - generic filesystem mmap_pgoff routine
+ * @file: file to mmap
+ * @addr: memory address to map to
+ * @len: length of the mapping
+ * @prot: memory protection flags
+ * @flags: mapping type
+ * @pgoff: starting page offset
+ */ 
+unsigned long generic_file_mmap_pgoff(struct file *file, unsigned long addr,
+			unsigned long len, unsigned long prot,
+			unsigned long flags, unsigned long pgoff)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long retval;
+
+	down_write(&mm->mmap_sem);
+	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&mm->mmap_sem);
+	return retval;
+}
+EXPORT_SYMBOL(generic_file_mmap_pgoff);
+
 /* This is used for a general mmap of a disk file */
 
 int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
diff --git a/mm/mmap.c b/mm/mmap.c
index ee22989..3931811 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1047,6 +1047,9 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		unsigned long, prot, unsigned long, flags,
 		unsigned long, fd, unsigned long, pgoff)
 {
+	unsigned long (*func)(struct file *, unsigned long,
+			unsigned long, unsigned long,
+			unsigned long, unsigned long);
 	struct file *file = NULL;
 	unsigned long retval = -EBADF;
 
@@ -1073,9 +1076,11 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
-	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	if (file && file->f_op && file->f_op->mmap_pgoff)
+		func = file->f_op->mmap_pgoff;
+	else
+		func = generic_file_mmap_pgoff;
+	retval = func(file, addr, len, prot, flags, pgoff);
 
 	if (file)
 		fput(file);
diff --git a/mm/nommu.c b/mm/nommu.c
index 1777386..4e31cb2 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1407,6 +1407,9 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		unsigned long, prot, unsigned long, flags,
 		unsigned long, fd, unsigned long, pgoff)
 {
+	unsigned long (*func)(struct file *, unsigned long,
+			unsigned long, unsigned long,
+			unsigned long, unsigned long);
 	struct file *file = NULL;
 	unsigned long retval = -EBADF;
 
@@ -1418,9 +1421,11 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
-	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	if (file && file->f_op && file->f_op->mmap_pgoff)
+		func = file->f_op->mmap_pgoff;
+	else
+		func = generic_file_mmap_pgoff;
+	retval = func(file, addr, len, prot, flags, pgoff);
 
 	if (file)
 		fput(file);

