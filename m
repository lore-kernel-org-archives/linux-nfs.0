From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 4 - Return correct result for ACCESS(READ) on eXecute-only file.
Date: Sun, 13 Apr 2003 16:18:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E194aod-0007lx-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 194api-0006h9-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Apr 2003 23:19:18 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Apr 2003 16:19:14 +1000
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


Currently, an NFSv3 ACCESS check for READ permission on an
eXecute-only file will succeed where it should fail.

This is because nfsd_permission allows READ access to eXecute only
files so that mode 711 executables can be loaded and run, and
nfsd_access simply uses nfsd_permission.

This patch changes nfsd_permission to only map eXecute permission to
read permission of MAY_OWNER_OVERRIDE was set.  This is only set
when trying to read from a file, so ACCESS will no longer be tricked.

This change will only affect callers of nfsd_permission that specify
MAY_READ and not MAY_OWNER_OVERRIDE, and nfsd_access is the only
routine that calls nfsd_permission (via fh_verify) that way.

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-04-13 16:15:09.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-04-13 16:15:09.000000000 +1000
@@ -1568,13 +1568,11 @@ nfsd_permission(struct svc_export *exp, 
 	    inode->i_uid == current->fsuid)
 		return 0;
 
-	acc &= ~ MAY_OWNER_OVERRIDE; /* This bit is no longer needed,
-                                        and gets in the way later */
-
 	err = permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
 
 	/* Allow read access to binaries even when mode 111 */
-	if (err == -EACCES && S_ISREG(inode->i_mode) && acc == MAY_READ)
+	if (err == -EACCES && S_ISREG(inode->i_mode) &&
+	    acc == (MAY_READ | MAY_OWNER_OVERRIDE))
 		err = permission(inode, MAY_EXEC);
 
 	return err? nfserrno(err) : 0;


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
