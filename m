Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:43504 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964814AbaKMVaf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 16:30:35 -0500
From: Pieter Smith <pieter@boesman.nl>
To: pieter@boesman.nl
Cc: Josh Triplett <josh@joshtriplett.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND...),
        linux-kernel@vger.kernel.org (open list)
Subject: [PATCH 32/56] fs/nfs: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:09 +0100
Message-Id: <1415913813-362-33-git-send-email-pieter@boesman.nl>
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compile out splice support from nfs when the splice-family of syscalls is not
supported by the system (i.e. CONFIG_SYSCALL_SPLICE is undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/nfs/file.c     | 6 ++++--
 fs/nfs/nfs4file.c | 4 ++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80..b36b4fb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -187,6 +187,7 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 }
 EXPORT_SYMBOL_GPL(nfs_file_read);
 
+#ifdef CONFIG_SYSCALL_SPLICE
 ssize_t
 nfs_file_splice_read(struct file *filp, loff_t *ppos,
 		     struct pipe_inode_info *pipe, size_t count,
@@ -207,6 +208,7 @@ nfs_file_splice_read(struct file *filp, loff_t *ppos,
 	return res;
 }
 EXPORT_SYMBOL_GPL(nfs_file_splice_read);
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 int
 nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
@@ -915,8 +917,8 @@ const struct file_operations nfs_file_operations = {
 	.fsync		= nfs_file_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= iter_file_splice_write,
+	SPLICE_READ_INIT(nfs_file_splice_read)
+	SPLICE_WRITE_INIT(iter_file_splice_write)
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index a816f06..81dd4c8 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -128,8 +128,8 @@ const struct file_operations nfs4_file_operations = {
 	.fsync		= nfs4_file_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.splice_write	= iter_file_splice_write,
+	SPLICE_READ_INIT(nfs_file_splice_read)
+	SPLICE_WRITE_INIT(iter_file_splice_write)
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
-- 
1.9.1

