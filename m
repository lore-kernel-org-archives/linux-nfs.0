From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: alloc_nfs_open_context(): remove redundant refcounting
Date: Mon, 20 Sep 2004 23:08:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040920210831.GA21274@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C9VOp-0004fh-21
	for nfs@lists.sourceforge.net; Mon, 20 Sep 2004 14:08:39 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1C9VOo-0006Lj-3k
	for nfs@lists.sourceforge.net; Mon, 20 Sep 2004 14:08:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

get_rpccred() is called via the

	rpcauth_lookupcred() -> rpcauth_lookup_credcache()

path so it seems that alloc_nfs_open_context() itself doesn't need to
get_rpccred(). All parents immediately compensate by put_rpccred()

correct?

--- b/fs/nfs/inode.c.orig	2004-09-16 22:03:01.000000000 +0200
+++ b/fs/nfs/inode.c	2004-09-20 22:49:37.000000000 +0200
@@ -825,7 +825,7 @@
 	if (ctx != NULL) {
 		atomic_set(&ctx->count, 1);
 		ctx->dentry = dget(dentry);
-		ctx->cred = get_rpccred(cred);
+		ctx->cred = cred;
 		ctx->state = NULL;
 		ctx->lockowner = current->files;
 		ctx->error = 0;
@@ -909,7 +909,6 @@
 	if ((cred = rpcauth_lookupcred(NFS_CLIENT(inode)->cl_auth, 0)) == NULL)
 		return -ENOMEM;
 	ctx = alloc_nfs_open_context(filp->f_dentry, cred);
-	put_rpccred(cred);
 	if (ctx == NULL)
 		return -ENOMEM;
 	ctx->mode = filp->f_mode;
--- b/fs/nfs/nfs4proc.c.orig	2004-09-14 23:03:09.000000000 +0200
+++ b/fs/nfs/nfs4proc.c	2004-09-20 22:49:52.000000000 +0200
@@ -2015,7 +2015,6 @@
 	if (unlikely(cred == NULL))
 		return -ENOMEM;
 	ctx = alloc_nfs_open_context(dentry, cred);
-	put_rpccred(cred);
 	if (unlikely(ctx == NULL))
 		return -ENOMEM;
 	status = -EIO; /* ERACE actually */

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
