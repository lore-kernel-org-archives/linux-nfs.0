From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: Always enable NFS direct I/O
Date: Thu, 14 Feb 2008 15:58:04 -0500
Message-ID: <20080214205804.11765.66305.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:15885 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbYBNU6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:58:07 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKw43G009405
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:58:05 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKw4JY011793
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:04 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since O_DIRECT is a standard feature that is enabled in most distros,
eliminate the CONFIG_NFS_DIRECTIO build option, and change the
fs/nfs/Makefile to always build in the NFS direct I/O engine.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig        |   24 ------------------------
 fs/nfs/Makefile   |    3 +--
 fs/nfs/file.c     |    6 ------
 fs/nfs/internal.h |    5 -----
 4 files changed, 1 insertions(+), 37 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 1704e31..63b02d9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1638,30 +1638,6 @@ config NFS_V4
 
 	  If unsure, say N.
 
-config NFS_DIRECTIO
-	bool "Allow direct I/O on NFS files"
-	depends on NFS_FS
-	help
-	  This option enables applications to perform uncached I/O on files
-	  in NFS file systems using the O_DIRECT open() flag.  When O_DIRECT
-	  is set for a file, its data is not cached in the system's page
-	  cache.  Data is moved to and from user-level application buffers
-	  directly.  Unlike local disk-based file systems, NFS O_DIRECT has
-	  no alignment restrictions.
-
-	  Unless your program is designed to use O_DIRECT properly, you are
-	  much better off allowing the NFS client to manage data caching for
-	  you.  Misusing O_DIRECT can cause poor server performance or network
-	  storms.  This kernel build option defaults OFF to avoid exposing
-	  system administrators unwittingly to a potentially hazardous
-	  feature.
-
-	  For more details on NFS O_DIRECT, see fs/nfs/direct.c.
-
-	  If unsure, say N.  This reduces the size of the NFS client, and
-	  causes open() to return EINVAL if a file residing in NFS is
-	  opened with the O_DIRECT flag.
-
 config NFSD
 	tristate "NFS server support"
 	depends on INET
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index f54c4d7..344bccb 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -8,7 +8,7 @@ EXTRA_CFLAGS = -W -Wall -Wextra -Wsign-compare \
 obj-$(CONFIG_NFS_FS) += nfs.o
 
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
-			   pagelist.o proc.o read.o symlink.o unlink.o \
+			   direct.o pagelist.o proc.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
@@ -17,5 +17,4 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
-nfs-$(CONFIG_NFS_DIRECTIO) += direct.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ef57a5a..10e8b80 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -234,10 +234,8 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
-#ifdef CONFIG_NFS_DIRECTIO
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_read(iocb, iov, nr_segs, pos);
-#endif
 
 	dfprintk(VFS, "nfs: read(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -383,9 +381,7 @@ const struct address_space_operations nfs_file_aops = {
 	.write_end = nfs_write_end,
 	.invalidatepage = nfs_invalidate_page,
 	.releasepage = nfs_release_page,
-#ifdef CONFIG_NFS_DIRECTIO
 	.direct_IO = nfs_direct_IO,
-#endif
 	.launder_page = nfs_launder_page,
 };
 
@@ -443,10 +439,8 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result;
 	size_t count = iov_length(iov, nr_segs);
 
-#ifdef CONFIG_NFS_DIRECTIO
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return nfs_file_direct_write(iocb, iov, nr_segs, pos);
-#endif
 
 	dfprintk(VFS, "nfs: write(%s/%s(%ld), %lu@%Ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fbe5ba4..13f43d6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -113,13 +113,8 @@ extern void nfs_destroy_readpagecache(void);
 extern int __init nfs_init_writepagecache(void);
 extern void nfs_destroy_writepagecache(void);
 
-#ifdef CONFIG_NFS_DIRECTIO
 extern int __init nfs_init_directcache(void);
 extern void nfs_destroy_directcache(void);
-#else
-#define nfs_init_directcache() (0)
-#define nfs_destroy_directcache() do {} while(0)
-#endif
 
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(int);

