From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 13/38: CLIENT: space_used in nfs_fattr
Date: Tue, 13 Aug 2002 19:01:22 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131901030.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekfF-0001vB-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:01:25 -0700
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


If the NFS_ATTR_FATTR_V4 flag is set, use the NFSv3 convention for
the 'space_used' part of the fattr.

--- old/fs/nfs/inode.c	Tue Jul 30 10:28:00 2002
+++ new/fs/nfs/inode.c	Tue Jul 30 10:32:49 2002
@@ -714,7 +714,7 @@ __nfs_fhget(struct super_block *sb, stru
 		inode->i_nlink = fattr->nlink;
 		inode->i_uid = fattr->uid;
 		inode->i_gid = fattr->gid;
-		if (fattr->valid & NFS_ATTR_FATTR_V3) {
+		if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
 			/*
 			 * report the blocks in 512byte units
 			 */
@@ -1103,7 +1103,7 @@ __nfs_refresh_inode(struct inode *inode,
 	inode->i_uid = fattr->uid;
 	inode->i_gid = fattr->gid;

-	if (fattr->valid & NFS_ATTR_FATTR_V3) {
+	if (fattr->valid & (NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4)) {
 		/*
 		 * report the blocks in 512byte units
 		 */



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
