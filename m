From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 5/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:09:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.26042.983383.63277@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3U8-0004Ha-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:09:52 -0700
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

In NFSv4, there is no hard limit on the length of symlink text.
This patch changes the -ENAMETOOLONG test in nfs_symlink() accordingly.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E04/fs/nfs/dir.c linux-2.5.41-nfsv4-E05/fs/nfs/dir.c
--- linux-2.5.41-nfsv4-E04/fs/nfs/dir.c	2002-10-08 18:43:34.000000000 -0400
+++ linux-2.5.41-nfsv4-E05/fs/nfs/dir.c	2002-10-08 18:44:21.000000000 -0400
@@ -1022,16 +1022,23 @@
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
-		goto out;
+	switch (NFS_PROTO(dir)->version) {
+		case 2:
+			if (strlen(symname) > NFS2_MAXPATHLEN)
+				goto out;
+			break;
+		case 3:
+			if (strlen(symname) > NFS3_MAXPATHLEN)
+				goto out;
+		default:
+			break;
+	}
 
 #ifdef NFS_PARANOIA
 if (dentry->d_inode)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
