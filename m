From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 4 - Fix incorrect call for follow_up
Date: Fri, 21 Nov 2003 14:26:59 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AN1wh-0008So-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AN1xX-0003hF-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Nov 2003 19:27:51 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AN1xW-0003tL-RF
	for nfs@lists.sourceforge.net; Thu, 20 Nov 2003 19:27:51 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 21 Nov 2003 14:27:44 +1100
To: Linus Torvalds <torvalds@osdl.org>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

follow_up doesn't check that the passed dentry is at the 
root of the mounted file system, so we have to do that, to 
avoid calling follow_up too many times.

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-11-21 14:10:43.000000000 +1100
+++ ./fs/nfsd/vfs.c	2003-11-21 14:10:56.000000000 +1100
@@ -161,7 +161,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			struct dentry *dp;
 			struct vfsmount *mnt = mntget(exp->ex_mnt);
 			dentry = dget(dparent);
-			while(follow_up(&mnt, &dentry))
+			while(dentry == mnt->mnt_root && follow_up(&mnt, &dentry))
 				;
 			dp = dget_parent(dentry);
 			dput(dentry);


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
