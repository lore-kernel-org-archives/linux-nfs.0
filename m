From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Reduce the number of getattr/lookup calls in nfs_lookup_revalidate()
Date: Fri, 26 Jul 2002 22:12:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32065.1836380877$1027714494@news.gmane.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YBS0-0008Tm-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Jul 2002 13:12:36 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Reduce the number of getattr/lookup calls in nfs_lookup_revalidate()
by making the latter rely on the ordinary attribute cache, and moving
the close-to-open data consistency checking into nfs_open().

This does mean that we can end up calling GETATTR twice: once in
nfs_lookup_revalidate() then immediately after in nfs_open(), however
it also means that sys_stat() and friends now use cached attributes.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.28-rpc_buf/fs/nfs/dir.c linux-2.5.28-cto2/fs/nfs/dir.c
--- linux-2.5.28-rpc_buf/fs/nfs/dir.c	Mon Jul 22 23:33:48 2002
+++ linux-2.5.28-cto2/fs/nfs/dir.c	Fri Jul 26 21:15:30 2002
@@ -430,16 +430,9 @@
 }
 
 static inline
-int nfs_lookup_verify_inode(struct inode *inode, int flags)
+int nfs_lookup_verify_inode(struct inode *inode)
 {
-	struct nfs_server *server = NFS_SERVER(inode);
-	/*
-	 * If we're interested in close-to-open cache consistency,
-	 * then we revalidate the inode upon lookup.
-	 */
-	if (!(server->flags & NFS_MOUNT_NOCTO) && !(flags & LOOKUP_CONTINUE))
-		NFS_CACHEINV(inode);
-	return nfs_revalidate_inode(server, inode);
+	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
 }
 
 /*
@@ -497,7 +490,7 @@
 
 	/* Force a full look up iff the parent directory has changed */
 	if (nfs_check_verifier(dir, dentry)) {
-		if (nfs_lookup_verify_inode(inode, flags))
+		if (nfs_lookup_verify_inode(inode))
 			goto out_bad;
 		goto out_valid;
 	}
diff -u --recursive --new-file linux-2.5.28-rpc_buf/fs/nfs/inode.c linux-2.5.28-cto2/fs/nfs/inode.c
--- linux-2.5.28-rpc_buf/fs/nfs/inode.c	Fri Jul 26 00:05:29 2002
+++ linux-2.5.28-cto2/fs/nfs/inode.c	Fri Jul 26 21:04:48 2002
@@ -855,15 +855,23 @@
 {
 	struct rpc_auth *auth;
 	struct rpc_cred *cred;
+	int err = 0;
 
 	lock_kernel();
+	/* Ensure that we revalidate the data cache */
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO) {
+		err = __nfs_revalidate_inode(NFS_SERVER(inode),inode);
+		if (err)
+			goto out;
+	}
 	auth = NFS_CLIENT(inode)->cl_auth;
 	cred = rpcauth_lookupcred(auth, 0);
 	filp->private_data = cred;
 	if (filp->f_mode & FMODE_WRITE)
 		nfs_set_mmcred(inode, cred);
+out:
 	unlock_kernel();
-	return 0;
+	return err;
 }
 
 int nfs_release(struct inode *inode, struct file *filp)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
