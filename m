From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 6 - Fix incorrect call for follow_up
Date: Fri, 16 Jan 2004 12:27:22 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AhIle-0002nX-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AhIlq-0007NS-Dk
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:34 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AhIlq-0008E8-28
	for nfs@lists.sourceforge.net; Thu, 15 Jan 2004 17:27:34 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 16 Jan 2004 12:27:25 +1100
To: Andrew Morton <akpm@osdl.org>
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


follow_up doesn't check that the passed dentry is at the 
root of the mounted file system, so we have to do that, to 
avoid calling follow_up too many times.

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-01-16 12:20:00.000000000 +1100
+++ ./fs/nfsd/vfs.c	2004-01-16 12:20:18.000000000 +1100
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
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
