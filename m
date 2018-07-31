Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35844 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732203AbeGaWxU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 18:53:20 -0400
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org, Mark Fasheh <mfasheh@suse.de>
Subject: [PATCH 3/4] proc: use vfs helper to get ino/dev pairs for maps file
Date: Tue, 31 Jul 2018 14:10:44 -0700
Message-Id: <20180731211045.5671-4-mfasheh@suse.de>
In-Reply-To: <20180731211045.5671-1-mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Proc writes ino/dev into /proc/PID/maps which it gets from i_ino and s_dev.
The problem with this is that i_ino and s_dev are not guaranteed to be
unique - we can have duplicates in the maps file for otherwise distinct
inodes.

This breaks any software expecting them to be unique, including lsof(8).  We
can fix this by using vfs_map_unique_ino_dev() to map the unique ino/dev
pair for us.

Signed-off-by: Mark Fasheh <mfasheh@suse.de>
---
 fs/proc/nommu.c      | 11 ++++-------
 fs/proc/task_mmu.c   |  8 +++-----
 fs/proc/task_nommu.c |  8 +++-----
 3 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/fs/proc/nommu.c b/fs/proc/nommu.c
index 3b63be64e436..56c12d02c5ad 100644
--- a/fs/proc/nommu.c
+++ b/fs/proc/nommu.c
@@ -36,7 +36,7 @@
  */
 static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 {
-	unsigned long ino = 0;
+        u64 ino = 0;
 	struct file *file;
 	dev_t dev = 0;
 	int flags;
@@ -44,15 +44,12 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 	flags = region->vm_flags;
 	file = region->vm_file;
 
-	if (file) {
-		struct inode *inode = file_inode(region->vm_file);
-		dev = inode->i_sb->s_dev;
-		ino = inode->i_ino;
-	}
+	if (file)
+		vfs_map_unique_ino_dev(file_dentry(file), &ino, &dev); {
 
 	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
 	seq_printf(m,
-		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
+		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %llu ",
 		   region->vm_start,
 		   region->vm_end,
 		   flags & VM_READ ? 'r' : '-',
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfd73a4616ce..e9cd33425191 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -276,7 +276,7 @@ static int is_stack(struct vm_area_struct *vma)
 static void show_vma_header_prefix(struct seq_file *m,
 				   unsigned long start, unsigned long end,
 				   vm_flags_t flags, unsigned long long pgoff,
-				   dev_t dev, unsigned long ino)
+				   dev_t dev, u64 ino)
 {
 	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
 	seq_put_hex_ll(m, NULL, start, 8);
@@ -299,16 +299,14 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 	struct mm_struct *mm = vma->vm_mm;
 	struct file *file = vma->vm_file;
 	vm_flags_t flags = vma->vm_flags;
-	unsigned long ino = 0;
+	u64 ino = 0;
 	unsigned long long pgoff = 0;
 	unsigned long start, end;
 	dev_t dev = 0;
 	const char *name = NULL;
 
 	if (file) {
-		struct inode *inode = file_inode(vma->vm_file);
-		dev = inode->i_sb->s_dev;
-		ino = inode->i_ino;
+		vfs_map_unique_ino_dev(file_dentry(file), &ino, &dev);
 		pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
 	}
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 5b62f57bd9bc..1198e979ed3f 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -146,7 +146,7 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 			  int is_pid)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long ino = 0;
+	u64 ino = 0;
 	struct file *file;
 	dev_t dev = 0;
 	int flags;
@@ -156,15 +156,13 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 	file = vma->vm_file;
 
 	if (file) {
-		struct inode *inode = file_inode(vma->vm_file);
-		dev = inode->i_sb->s_dev;
-		ino = inode->i_ino;
+		vfs_map_unique_inode_dev(file_dentry(file), &ino, &dev));
 		pgoff = (loff_t)vma->vm_pgoff << PAGE_SHIFT;
 	}
 
 	seq_setwidth(m, 25 + sizeof(void *) * 6 - 1);
 	seq_printf(m,
-		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu ",
+		   "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %llu ",
 		   vma->vm_start,
 		   vma->vm_end,
 		   flags & VM_READ ? 'r' : '-',
-- 
2.15.1

