From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - Be more careful with readlock in exp_parent
Date: Wed, 26 Mar 2003 11:10:54 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18xyVK-0004To-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xyVp-0002NV-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 16:11:25 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 26 Mar 2003 11:11:12 +1100
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

We currently hold a read_lock of dparent_lock
while calling exp_get_by_name on several ancestors
of a given dentry.  However exp_get_by_name can
malloc(GFP_KERNEL), so that isn't a good idea.

Now we only claim the lock while actually
stepping up the parent chain.

This addresses bug 29 @ bugme.osdl.org

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-26 10:03:50.000000000 +1100
+++ ./fs/nfsd/export.c	2003-03-26 10:07:08.000000000 +1100
@@ -496,13 +496,19 @@ exp_parent(svc_client *clp, struct vfsmo
 {
 	svc_export *exp;
 
-	read_lock(&dparent_lock);
+	dget(dentry);
 	exp = exp_get_by_name(clp, mnt, dentry, reqp);
+
 	while (exp == NULL && dentry != dentry->d_parent) {
-		dentry = dentry->d_parent;
+		struct dentry *parent;
+		read_lock(&dparent_lock);
+		parent = dget(dentry->d_parent);
+		dput(dentry);
+		dentry = parent;
+		read_unlock(&dparent_lock);
 		exp = exp_get_by_name(clp, mnt, dentry, reqp);
 	}
-	read_unlock(&dparent_lock);
+	dput(dentry);
 	return exp;
 }
 


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
