Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39976 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbLCMEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 07:04:37 -0500
From: Christoph Hellwig <hch@lst.de>
To: viro@zeniv.linux.org.uk
Cc: tao.peng@primarydata.com, jeff.layton@primarydata.com,
        bfields@fieldses.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: [PATCH 1/4] locks: new locks_mandatory_area calling convention
Date: Thu,  3 Dec 2015 12:59:49 +0100
Message-Id: <1449143992-7415-2-git-send-email-hch@lst.de>
In-Reply-To: <1449143992-7415-1-git-send-email-hch@lst.de>
References: <1449143992-7415-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass a loff_t end for the last byte instead of the 32-bit count
parameter to allow full file clones even on 32-bit architectures.
While we're at it also drop the pointless inode argument and simplify
the read/write selection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c         | 22 +++++++++-------------
 fs/read_write.c    |  5 ++---
 include/linux/fs.h | 28 +++++++++++++---------------
 3 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 0d2b326..ab2ea2e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1227,21 +1227,17 @@ int locks_mandatory_locked(struct file *file)
 
 /**
  * locks_mandatory_area - Check for a conflicting lock
- * @read_write: %FLOCK_VERIFY_WRITE for exclusive access, %FLOCK_VERIFY_READ
- *		for shared
- * @inode:      the file to check
  * @filp:       how the file was opened (if it was)
- * @offset:     start of area to check
- * @count:      length of area to check
+ * @start:	first byte in the file to check
+ * @end:	lastbyte in the file to check
+ * @type:	%F_WRLCK for a write lock, else %F_RDLCK
  *
  * Searches the inode's list of locks to find any POSIX locks which conflict.
- * This function is called from rw_verify_area() and
- * locks_verify_truncate().
  */
-int locks_mandatory_area(int read_write, struct inode *inode,
-			 struct file *filp, loff_t offset,
-			 size_t count)
+int locks_mandatory_area(struct file *filp, loff_t start, loff_t end,
+		unsigned char type)
 {
+	struct inode *inode = file_inode(filp);
 	struct file_lock fl;
 	int error;
 	bool sleep = false;
@@ -1252,9 +1248,9 @@ int locks_mandatory_area(int read_write, struct inode *inode,
 	fl.fl_flags = FL_POSIX | FL_ACCESS;
 	if (filp && !(filp->f_flags & O_NONBLOCK))
 		sleep = true;
-	fl.fl_type = (read_write == FLOCK_VERIFY_WRITE) ? F_WRLCK : F_RDLCK;
-	fl.fl_start = offset;
-	fl.fl_end = offset + count - 1;
+	fl.fl_type = type;
+	fl.fl_start = start;
+	fl.fl_end = end;
 
 	for (;;) {
 		if (filp) {
diff --git a/fs/read_write.c b/fs/read_write.c
index c81ef39..6c1aa73 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -396,9 +396,8 @@ int rw_verify_area(int read_write, struct file *file, const loff_t *ppos, size_t
 	}
 
 	if (unlikely(inode->i_flctx && mandatory_lock(inode))) {
-		retval = locks_mandatory_area(
-			read_write == READ ? FLOCK_VERIFY_READ : FLOCK_VERIFY_WRITE,
-			inode, file, pos, count);
+		retval = locks_mandatory_area(file, pos, pos + count - 1,
+				read_write == READ ? F_RDLCK : F_WRLCK);
 		if (retval < 0)
 			return retval;
 	}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 870a76e..af559ac 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2030,12 +2030,9 @@ extern struct kobject *fs_kobj;
 
 #define MAX_RW_COUNT (INT_MAX & PAGE_CACHE_MASK)
 
-#define FLOCK_VERIFY_READ  1
-#define FLOCK_VERIFY_WRITE 2
-
 #ifdef CONFIG_FILE_LOCKING
 extern int locks_mandatory_locked(struct file *);
-extern int locks_mandatory_area(int, struct inode *, struct file *, loff_t, size_t);
+extern int locks_mandatory_area(struct file *, loff_t, loff_t, unsigned char);
 
 /*
  * Candidates for mandatory locking have the setgid bit set
@@ -2068,14 +2065,16 @@ static inline int locks_verify_truncate(struct inode *inode,
 				    struct file *filp,
 				    loff_t size)
 {
-	if (inode->i_flctx && mandatory_lock(inode))
-		return locks_mandatory_area(
-			FLOCK_VERIFY_WRITE, inode, filp,
-			size < inode->i_size ? size : inode->i_size,
-			(size < inode->i_size ? inode->i_size - size
-			 : size - inode->i_size)
-		);
-	return 0;
+	if (!inode->i_flctx || !mandatory_lock(inode))
+		return 0;
+
+	if (size < inode->i_size) {
+		return locks_mandatory_area(filp, size, inode->i_size - 1,
+				F_WRLCK);
+	} else {
+		return locks_mandatory_area(filp, inode->i_size, size - 1,
+				F_WRLCK);
+	}
 }
 
 static inline int break_lease(struct inode *inode, unsigned int mode)
@@ -2144,9 +2143,8 @@ static inline int locks_mandatory_locked(struct file *file)
 	return 0;
 }
 
-static inline int locks_mandatory_area(int rw, struct inode *inode,
-				       struct file *filp, loff_t offset,
-				       size_t count)
+static inline int locks_mandatory_area(struct file *filp, loff_t start,
+		loff_t end, unsigned char type)
 {
 	return 0;
 }
-- 
1.9.1

