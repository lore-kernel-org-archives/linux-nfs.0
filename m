From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 18] make sure getxattr inode op is non-NULL before calling it
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000k4-9i@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7C-00088v-EC
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7B-0006Be-On
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
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



Make sure getxattr inode op is non-NULL before calling it.

Also, security hook should probably be called before calling the getxattr op
the first time.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-09-24 14:47:49.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-09-24 14:48:07.000000000 +1000
@@ -448,6 +448,16 @@ _get_posix_acl(struct dentry *dentry, ch
 	int buflen, error = 0;
 	struct posix_acl *pacl = NULL;
 
+	error = -EOPNOTSUPP;
+	if (inode->i_op == NULL)
+		goto out_err;
+	if (inode->i_op->getxattr == NULL)
+		goto out_err;
+
+	error = security_inode_getxattr(dentry, key);
+	if (error)
+		goto out_err;
+
 	buflen = inode->i_op->getxattr(dentry, key, NULL, 0);
 	if (buflen <= 0) {
 		error = buflen < 0 ? buflen : -ENODATA;
@@ -460,18 +470,10 @@ _get_posix_acl(struct dentry *dentry, ch
 		goto out_err;
 	}
 
-	error = -EOPNOTSUPP;
-	if (inode->i_op && inode->i_op->getxattr) {
-		error = security_inode_getxattr(dentry, key);
-		if (error)
-			goto out_err;
-		error = inode->i_op->getxattr(dentry, key, buf, buflen);
-	}
+	error = inode->i_op->getxattr(dentry, key, buf, buflen);
 	if (error < 0)
 		goto out_err;
 
-	error = 0;
-
 	pacl = posix_acl_from_xattr(buf, buflen);
  out:
 	kfree(buf);


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
