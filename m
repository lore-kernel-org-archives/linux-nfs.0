From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 7/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:10:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.26101.536822.637339@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3VD-0004Lw-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:10:59 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This is a nontrivial change to the NFS client.

NFSv4 defines a new file attribute, change_attr.  This is a per-file
opaque quantity returned by the server, whose value is required to
change whenever the file is modified.  If it exists, we want to use
it for all cache consistency checks in nfs_refresh_inode().  Some
operations also return a "pre-operation" value of the change_attr;
we want to take this into account too.

First, define flags
  NFS_ATTR_FATTR_V4 - indicates that the 'struct nfs_fattr' is an
                      NFSv4 fattr, so the change_attr field is valid
  NFS_ATTR_PRE_CHANGE - indicates that the server returned a pre-operation
                      change_attr, so the pre_change_attr field is valid

Second, change nfs_refresh_inode() so that the caches are invalidated
if there is a change_attr mismatch.  Exception: If the pre_change_attr
tells us that the mismatch was caused by our operation, then do not
invalidate the caches.

This patch should leave the logic in nfs_refresh_inode() unchanged
if neither of the new flags are set.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E06/fs/nfs/inode.c linux-2.5.41-nfsv4-E07/fs/nfs/inode.c
--- linux-2.5.41-nfsv4-E06/fs/nfs/inode.c	2002-10-08 18:43:57.000000000 -0400
+++ linux-2.5.41-nfsv4-E07/fs/nfs/inode.c	2002-10-08 18:45:07.000000000 -0400
@@ -716,6 +716,8 @@
 		inode->i_mtime = nfs_time_to_secs(new_mtime);
 		NFS_MTIME_UPDATE(inode) = fattr->timestamp;
 		NFS_CACHE_ISIZE(inode) = new_size;
+		if (fattr->valid & NFS_ATTR_FATTR_V4)
+			NFS_CHANGE_ATTR(inode) = fattr->change_attr;
 		inode->i_size = new_isize;
 		inode->i_mode = fattr->mode;
 		inode->i_nlink = fattr->nlink;
@@ -1067,12 +1069,25 @@
 		invalid = 1;
 	}
 
+	if ((fattr->valid & NFS_ATTR_FATTR_V4)
+	    && NFS_CHANGE_ATTR(inode) != fattr->change_attr) {
+#ifdef NFS_DEBUG_VERBOSE
+		printk(KERN_DEBUG "NFS: change_attr change on %s/%ld\n",
+		       inode->i_sb->s_id, inode->i_ino);
+#endif
+		invalid = 1;
+	}
+
 	/* Check Weak Cache Consistency data.
 	 * If size and mtime match the pre-operation values, we can
 	 * assume that any attribute changes were caused by our NFS
          * operation, so there's no need to invalidate the caches.
          */
-        if ((fattr->valid & NFS_ATTR_WCC)
+	if ((fattr->valid & NFS_ATTR_PRE_CHANGE)
+	    && NFS_CHANGE_ATTR(inode) == fattr->pre_change_attr) {
+		invalid = 0;
+	}
+	else if ((fattr->valid & NFS_ATTR_WCC)
 	    && NFS_CACHE_ISIZE(inode) == fattr->pre_size
 	    && NFS_CACHE_MTIME(inode) == fattr->pre_mtime) {
 		invalid = 0;
@@ -1110,6 +1125,9 @@
 		}
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_V4)
+		NFS_CHANGE_ATTR(inode) = fattr->change_attr;
+
 	inode->i_mode = fattr->mode;
 	inode->i_nlink = fattr->nlink;
 	inode->i_uid = fattr->uid;
diff -u --recursive --new-file linux-2.5.41-nfsv4-E06/include/linux/nfs_fs.h linux-2.5.41-nfsv4-E07/include/linux/nfs_fs.h
--- linux-2.5.41-nfsv4-E06/include/linux/nfs_fs.h	2002-10-08 18:43:11.000000000 -0400
+++ linux-2.5.41-nfsv4-E07/include/linux/nfs_fs.h	2002-10-08 18:45:07.000000000 -0400
@@ -144,6 +144,7 @@
 	__u64			read_cache_isize;
 	unsigned long		attrtimeo;
 	unsigned long		attrtimeo_timestamp;
+	__u64			change_attr;		/* v4 only */
 
 	/*
 	 * Timestamp that dates the change made to read_cache_mtime.
@@ -208,6 +209,7 @@
 #define NFS_CACHE_CTIME(inode)		(NFS_I(inode)->read_cache_ctime)
 #define NFS_CACHE_MTIME(inode)		(NFS_I(inode)->read_cache_mtime)
 #define NFS_CACHE_ISIZE(inode)		(NFS_I(inode)->read_cache_isize)
+#define NFS_CHANGE_ATTR(inode)		(NFS_I(inode)->change_attr)
 #define NFS_NEXTSCAN(inode)		(NFS_I(inode)->nextscan)
 #define NFS_CACHEINV(inode) \
 do { \
diff -u --recursive --new-file linux-2.5.41-nfsv4-E06/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E07/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E06/include/linux/nfs_xdr.h	2002-10-08 18:44:43.000000000 -0400
+++ linux-2.5.41-nfsv4-E07/include/linux/nfs_xdr.h	2002-10-08 18:45:07.000000000 -0400
@@ -35,12 +35,16 @@
 	__u64			atime;
 	__u64			mtime;
 	__u64			ctime;
+	__u64			change_attr;	/* NFSv4 change attribute */
+	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	unsigned long		timestamp;
 };
 
 #define NFS_ATTR_WCC		0x0001		/* pre-op WCC data    */
 #define NFS_ATTR_FATTR		0x0002		/* post-op attributes */
 #define NFS_ATTR_FATTR_V3	0x0004		/* NFSv3 attributes */
+#define NFS_ATTR_FATTR_V4	0x0008
+#define NFS_ATTR_PRE_CHANGE	0x0010
 
 /*
  * Info on the file system


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
