From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 18] nfsd4: don't take i_sem around call to ->getxattr
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000jz-8P@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi6t-00084X-S9
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:07 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi6s-0008Hm-A4
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:07 -0700
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


The ->getxattr op doesn't take the i_sem (see
Documentation/filesystems/Locking)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-09-24 14:47:49.000000000 +1000
@@ -448,39 +448,35 @@ _get_posix_acl(struct dentry *dentry, ch
 	int buflen, error = 0;
 	struct posix_acl *pacl = NULL;
 
-	down(&inode->i_sem);
-
 	buflen = inode->i_op->getxattr(dentry, key, NULL, 0);
 	if (buflen <= 0) {
 		error = buflen < 0 ? buflen : -ENODATA;
-		goto out_sem;
+		goto out_err;
 	}
 
 	buf = kmalloc(buflen, GFP_KERNEL);
 	if (buf == NULL) {
 		error = -ENOMEM;
-		goto out_sem;
+		goto out_err;
 	}
 
 	error = -EOPNOTSUPP;
 	if (inode->i_op && inode->i_op->getxattr) {
 		error = security_inode_getxattr(dentry, key);
 		if (error)
-			goto out_sem;
+			goto out_err;
 		error = inode->i_op->getxattr(dentry, key, buf, buflen);
 	}
 	if (error < 0)
-		goto out_sem;
+		goto out_err;
 
 	error = 0;
-	up(&inode->i_sem);
 
 	pacl = posix_acl_from_xattr(buf, buflen);
  out:
 	kfree(buf);
 	return pacl;
- out_sem:
-	up(&inode->i_sem);
+ out_err:
 	pacl = ERR_PTR(error);
 	goto out;
 }


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
