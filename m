From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 8 - New routine exp_pseudoroot() to find 'root' filehandle for nfsv4
Date: Fri, 11 Oct 2002 10:05:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIw-0007ds-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZX-00087a-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:31 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:23 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

NFSv4 has a concept of a 'root' filehandle (from which all other can 
be found via LOOKUP, so no need for mountd).

This patch defines exp_pseudoroot(), which is used to set the filehandle
for the root of the pseudofs. The root is defined to be the export
point with fsid == 0.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   17 +++++++++++++++++
 ./include/linux/nfsd/export.h |    1 +
 2 files changed, 18 insertions(+)

--- ./include/linux/nfsd/export.h	2002/10/10 23:11:42	1.1
+++ ./include/linux/nfsd/export.h	2002/10/10 23:16:29	1.2
@@ -100,6 +100,7 @@ struct svc_export *	exp_parent(struct sv
 				   struct dentry *dentry);
 int			exp_rootfh(struct svc_client *, 
 					char *path, struct knfsd_fh *, int maxsize);
+int			exp_pseudoroot(struct svc_client *, struct svc_fh *fhp);
 int			nfserrno(int errno);
 
 static inline struct svc_export *
--- ./fs/nfsd/export.c	2002/10/10 23:11:42	1.1
+++ ./fs/nfsd/export.c	2002/10/10 23:16:29	1.2
@@ -550,6 +550,23 @@ out:
 	return err;
 }
 
+/*
+ * Called when we need the filehandle for the root of the pseudofs,
+ * for a given NFSv4 client.   The root is defined to be the
+ * export point with fsid==0
+ */
+int
+exp_pseudoroot(struct svc_client *clp, struct svc_fh *fhp)
+{
+	struct svc_export *exp;
+
+	exp = exp_get_fsid(clp, 0);
+	if (!exp)
+		return nfserr_perm;
+
+	dget(exp->ex_dentry);
+	return fh_compose(fhp, exp, exp->ex_dentry, NULL);
+}
 
 /*
  * Find a valid client given an inet address. We always move the most


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
