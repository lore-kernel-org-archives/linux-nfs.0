From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 8/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 02:19:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.30208.724605.756236@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z4ZS-00012r-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 17:19:26 -0700
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

If the NFS_ATTR_FATTR_V4 flag is set, use the NFSv3 convention for
the 'space_used' part of the fattr.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E07/fs/nfs/inode.c linux-2.5.41-nfsv4-E08/fs/nfs/inode.c
--- linux-2.5.41-nfsv4-E07/fs/nfs/inode.c	2002-10-08 19:43:05.000000000 -0400
+++ linux-2.5.41-nfsv4-E08/fs/nfs/inode.c	2002-10-08 19:43:30.000000000 -0400
@@ -723,7 +723,7 @@
 		inode->i_nlink = fattr->nlink;
 		inode->i_uid = fattr->uid;
 		inode->i_gid = fattr->gid;
-		if (fattr->valid & NFS_ATTR_FATTR_V3) {
+		if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
 			/*
 			 * report the blocks in 512byte units
 			 */
@@ -1133,7 +1133,7 @@
 	inode->i_uid = fattr->uid;
 	inode->i_gid = fattr->gid;
 
-	if (fattr->valid & NFS_ATTR_FATTR_V3) {
+	if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
 		/*
 		 * report the blocks in 512byte units
 		 */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
