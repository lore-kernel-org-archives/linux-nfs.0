From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 4 - Convert error status for failed lookup("..") properly.
Date: Fri, 21 Nov 2003 14:26:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AN1wb-0008Sh-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AN1xQ-0003gx-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Nov 2003 19:27:44 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AN1xP-0007nt-UV
	for nfs@lists.sourceforge.net; Thu, 20 Nov 2003 19:27:44 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 21 Nov 2003 14:27:37 +1100
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

Linus,
  Here are 4 patches to knfsd that I believe are appropriate for pre 2.6.0.
  The first two are simple bug fixes.
  The third is the largest and need to change a little bit of infrastructure
    to avoid ignoring a possible NULL return from kmalloc.
  The fourth extends dnotify functionality w.r.t. nfsd file access.

Thanks,
NeilBrown

### Comments for ChangeSet

We weren't converting the -E* error code to an nfserr_*
error code as we should.

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-11-21 13:59:33.000000000 +1100
+++ ./fs/nfsd/vfs.c	2003-11-21 14:10:43.000000000 +1100
@@ -173,7 +173,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 				err = PTR_ERR(exp2);
 				dput(dentry);
 				mntput(mnt);
-				goto out;
+				goto out_nfserr;
 			}
 			if (!exp2) {
 				dput(dentry);


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
