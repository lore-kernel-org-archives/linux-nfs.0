From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 11/38: CLIENT: add change_attr to nfs_fattr
Date: Wed, 14 Aug 2002 16:41:29 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141641070.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4xQ-0004BC-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:41:32 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


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

--- old/fs/nfs/inode.c	Sun Aug 11 20:37:29 2002
+++ new/fs/nfs/inode.c	Sun Aug 11 20:38:57 2002
@@ -720,6 +720,8 @@ __nfs_fhget(struct super_block *sb, stru
 		inode->i_mtime = nfs_time_to_secs(new_mtime);
 		NFS_MTIME_UPDATE(inode) = fattr->timestamp;
 		NFS_CACHE_ISIZE(inode) = new_size;
+		if (fattr->valid & NFS_ATTR_FATTR_V4)
+			NFS_CHANGE_ATTR(inode) = fattr->change_attr;
 		inode->i_size = new_isize;
 		inode->i_mode = fattr->mode;
 		inode->i_nlink = fattr->nlink;
@@ -1072,12 +1074,25 @@ __nfs_refresh_inode(struct inode *inode,
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
@@ -1115,6 +1130,9 @@ __nfs_refresh_inode(struct inode *inode,
 		}
 	}

+	if (fattr->valid & NFS_ATTR_FATTR_V4)
+		NFS_CHANGE_ATTR(inode) = fattr->change_attr;
+
 	inode->i_mode = fattr->mode;
 	inode->i_nlink = fattr->nlink;
 	inode->i_uid = fattr->uid;
--- old/include/linux/nfs_fs.h	Sun Aug 11 20:37:29 2002
+++ new/include/linux/nfs_fs.h	Sun Aug 11 20:38:57 2002
@@ -143,6 +143,7 @@ struct nfs_inode {
 	__u64			read_cache_isize;
 	unsigned long		attrtimeo;
 	unsigned long		attrtimeo_timestamp;
+	__u64			change_attr;		/* v4 only */

 	/*
 	 * Timestamp that dates the change made to read_cache_mtime.
@@ -207,6 +208,7 @@ static inline struct nfs_inode *NFS_I(st
 #define NFS_CACHE_CTIME(inode)		(NFS_I(inode)->read_cache_ctime)
 #define NFS_CACHE_MTIME(inode)		(NFS_I(inode)->read_cache_mtime)
 #define NFS_CACHE_ISIZE(inode)		(NFS_I(inode)->read_cache_isize)
+#define NFS_CHANGE_ATTR(inode)		(NFS_I(inode)->change_attr)
 #define NFS_NEXTSCAN(inode)		(NFS_I(inode)->nextscan)
 #define NFS_CACHEINV(inode) \
 do { \
--- old/include/linux/nfs_xdr.h	Sun Aug 11 20:29:03 2002
+++ new/include/linux/nfs_xdr.h	Sun Aug 11 20:38:57 2002
@@ -33,6 +33,8 @@ struct nfs_fattr {
 	__u64			atime;
 	__u64			mtime;
 	__u64			ctime;
+	__u64			change_attr;	/* NFSv4 change attribute */
+	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	unsigned long		timestamp;
 };
 #define fsid			fsid_u.nfs3
@@ -40,6 +42,8 @@ struct nfs_fattr {
 #define NFS_ATTR_WCC		0x0001		/* pre-op WCC data    */
 #define NFS_ATTR_FATTR		0x0002		/* post-op attributes */
 #define NFS_ATTR_FATTR_V3	0x0004		/* NFSv3 attributes */
+#define NFS_ATTR_FATTR_V4	0x0008
+#define NFS_ATTR_PRE_CHANGE	0x0010

 /*
  * Info on the file system



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
