From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 18] separate a little of logic from fh_verify into new function
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000js-3t@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7D-000899-8l
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7C-0006Bl-H9
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
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



Separate out the little bit of logic in fh_verify that checks the i_mode into a
separate function.  This is nicely encapsulated, fh_verify() is overly long
anyway, and this change helps make a subsequent nfs4 named attribute change
clearer.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   62 +++++++++++++++++++++++++++---------------------------
 1 files changed, 31 insertions(+), 31 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2004-09-24 14:47:35.000000000 +1000
@@ -71,6 +71,35 @@ int nfsd_acceptable(void *expv, struct d
 	return rv;
 }
 
+/* Type check. The correct error return for type mismatches does not seem to be
+ * generally agreed upon. SunOS seems to use EISDIR if file isn't S_IFREG; a
+ * comment in the NFSv3 spec says this is incorrect (implementation notes for
+ * the write call).
+ */
+static inline int
+nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
+{
+	/* Type can be negative when creating hardlinks - not to a dir */
+	if (type > 0 && (mode & S_IFMT) != type) {
+		if (rqstp->rq_vers == 4 && (mode & S_IFMT) == S_IFLNK)
+			return nfserr_symlink;
+		else if (type == S_IFDIR)
+			return nfserr_notdir;
+		else if ((mode & S_IFMT) == S_IFDIR)
+			return nfserr_isdir;
+		else
+			return nfserr_inval;
+	}
+	if (type < 0 && (mode & S_IFMT) == -type) {
+		if (rqstp->rq_vers == 4 && (mode & S_IFMT) == S_IFLNK)
+			return nfserr_symlink;
+		else if (type == -S_IFDIR)
+			return nfserr_isdir;
+		else
+			return nfserr_notdir;
+	}
+	return 0;
+}
 
 /*
  * Perform sanity checks on the dentry in a client's file handle.
@@ -87,7 +116,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 	struct knfsd_fh	*fh = &fhp->fh_handle;
 	struct svc_export *exp = NULL;
 	struct dentry	*dentry;
-	struct inode	*inode;
 	u32		error = 0;
 
 	dprintk("nfsd: fh_verify(%s)\n", SVCFH_fmt(fhp));
@@ -223,37 +251,9 @@ fh_verify(struct svc_rqst *rqstp, struct
 	}
 	cache_get(&exp->h);
 
-	inode = dentry->d_inode;
-
-
-	/* Type check. The correct error return for type mismatches
-	 * does not seem to be generally agreed upon. SunOS seems to
-	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3
-	 * spec says this is incorrect (implementation notes for the
-	 * write call).
-	 */
-
-	/* Type can be negative when creating hardlinks - not to a dir */
-	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
-		if (rqstp->rq_vers == 4 && (inode->i_mode & S_IFMT) == S_IFLNK)
-			error = nfserr_symlink;
-		else if (type == S_IFDIR)
-			error = nfserr_notdir;
-		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
-			error = nfserr_isdir;
-		else
-			error = nfserr_inval;
+	error = nfsd_mode_check(rqstp, dentry->d_inode->i_mode, type);
+	if (error)
 		goto out;
-	}
-	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {
-		if (rqstp->rq_vers == 4 && (inode->i_mode & S_IFMT) == S_IFLNK)
-			error = nfserr_symlink;
-		else if (type == -S_IFDIR)
-			error = nfserr_isdir;
-		else
-			error = nfserr_notdir;
-		goto out;
-	}
 
 	/* Finally, check access permissions. */
 	error = nfsd_permission(exp, dentry, access);


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
