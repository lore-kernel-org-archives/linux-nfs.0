From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 2 - Reduce range covered by dparent_lock even further
Date: Fri, 28 Mar 2003 12:48:55 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18yizH-0006fK-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yizc-0003tg-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 17:49:16 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 28 Mar 2003 12:49:05 +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

We are now calling dput under dparent_lock which (As akpm points out) 
is a bad thing.  So move the read_unlock to only protect the line of code
that needs protecting.

Also use IS_ROOT instead of testing ->d_parent directly.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-28 10:50:07.000000000 +1100
+++ ./fs/nfsd/export.c	2003-03-28 10:51:35.000000000 +1100
@@ -499,13 +499,13 @@ exp_parent(svc_client *clp, struct vfsmo
 	dget(dentry);
 	exp = exp_get_by_name(clp, mnt, dentry, reqp);
 
-	while (exp == NULL && dentry != dentry->d_parent) {
+	while (exp == NULL && !IS_ROOT(dentry)) {
 		struct dentry *parent;
 		read_lock(&dparent_lock);
 		parent = dget(dentry->d_parent);
+		read_unlock(&dparent_lock);
 		dput(dentry);
 		dentry = parent;
-		read_unlock(&dparent_lock);
 		exp = exp_get_by_name(clp, mnt, dentry, reqp);
 	}
 	dput(dentry);


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
