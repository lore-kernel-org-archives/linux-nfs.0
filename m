From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 07/38: CLIENT: change hard limit on symlink length
Date: Wed, 14 Aug 2002 16:39:17 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141639000.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4vI-0003va-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:39:20 -0700
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


In NFSv4, there is no hard limit on the length of symlink text.
This patch changes the -ENAMETOOLONG test in nfs_symlink() accordingly.

--- old/fs/nfs/dir.c	Sun Aug 11 20:26:56 2002
+++ new/fs/nfs/dir.c	Sun Aug 11 20:28:25 2002
@@ -1022,15 +1022,15 @@ nfs_symlink(struct inode *dir, struct de
 	struct nfs_fattr sym_attr;
 	struct nfs_fh sym_fh;
 	struct qstr qsymname;
-	unsigned int maxlen;
 	int error;

 	dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name, symname);

 	error = -ENAMETOOLONG;
-	maxlen = (NFS_PROTO(dir)->version==2) ? NFS2_MAXPATHLEN : NFS3_MAXPATHLEN;
-	if (strlen(symname) > maxlen)
+	if (NFS_PROTO(dir)->version == 2 && strlen(symname) > NFS2_MAXPATHLEN)
+		goto out;
+	else if (NFS_PROTO(dir)->version == 3 && strlen(symname) > NFS3_MAXPATHLEN)
 		goto out;

 #ifdef NFS_PARANOIA



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
