From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 4 - Fix the check for execute permissions on parent directories in NFSd
Date: Wed, 18 Jun 2003 10:30:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQq3-0000Wn-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQlp-0007E0-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 17:25:49 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 10:25:35 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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

[4 patches for nfsd in 2.4.22-pre]

The previous check fails on directories with uid=0, gid=0, and
permissions in ACLs.  A similar check to this one is also found in
the 2.5 kernel in fs/nfsd/nfsfh.c:nfsd_acceptable().


diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2003-06-18 10:05:17.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2003-06-18 10:05:17.000000000 +1000
@@ -697,33 +697,23 @@ fh_verify(struct svc_rqst *rqstp, struct
 	error = 0;
 
 	if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {
-		if (exp->ex_dentry != dentry) {
-			struct dentry *tdentry = dentry;
+		struct dentry *tdentry = dentry;
 
-			do {
-				tdentry = tdentry->d_parent;
-				if (exp->ex_dentry == tdentry)
-					break;
-				/* executable only by root and we can't be root */
-				if (current->fsuid
-				    && (exp->ex_flags & NFSEXP_ROOTSQUASH)
-				    && !(tdentry->d_inode->i_uid
-					 && (tdentry->d_inode->i_mode & S_IXUSR))
-				    && !(tdentry->d_inode->i_gid
-					 && (tdentry->d_inode->i_mode & S_IXGRP))
-				    && !(tdentry->d_inode->i_mode & S_IXOTH)
-					) {
-					error = nfserr_stale;
-					dprintk("fh_verify: no root_squashed access.\n");
-				}
-			} while ((tdentry != tdentry->d_parent));
-			if (exp->ex_dentry != tdentry) {
-				error = nfserr_stale;
-				printk("nfsd Security: %s/%s bad export.\n",
-				       dentry->d_parent->d_name.name,
-				       dentry->d_name.name);
-				goto out;
-			}
+		while (tdentry != exp->ex_dentry && !IS_ROOT(tdentry)) {
+			struct dentry *parent = tdentry->d_parent;
+
+			/* make sure parents give x permission to user */
+			error = permission(parent->d_inode, MAY_EXEC);
+			if (error)
+				break;
+			tdentry = parent;
+		}
+		if (exp->ex_dentry != tdentry) {
+			error = nfserr_stale;
+			printk("fh_verify: no root_squashed access at %s/%s.\n",
+			       dentry->d_parent->d_name.name,
+			       dentry->d_name.name);
+			goto out;
 		}
 	}
 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
