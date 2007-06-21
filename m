From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 8] knfsd: nfsd4: fix handling of acl errrors
Date: Thu, 21 Jun 2007 14:30:59 +1000
Message-ID: <1070621043059.1111@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-kernel@vger.kernel.org, Alexander Soule <soule@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EK3-0005ri-PL
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:07 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EK6-0002H7-Dw
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:11 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: "J. Bruce Fields" <bfields@fieldses.org>


nfs4_acl_nfsv4_to_posix() returns an error and returns any posix acls
calculated in two caller-provided pointers.  It was setting these
pointers to -errno in some error cases, resulting in
nfsd4_set_nfs4_acl() calling posix_acl_release() with a -errno as an
argument.

Fix both the caller and the callee, by modifying nfsd4_set_nfs4_acl() to
stop relying on the passed-in-pointers being left as NULL in the error
case, and by modifying nfs4_acl_nfsv4_to_posix() to stop returning
garbage in those pointers.

Thanks to Alex Soule for reporting the bug.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: Alexander Soule <soule@umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    3 +++
 ./fs/nfsd/vfs.c     |   22 +++++++---------------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-06-21 14:10:06.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2007-06-21 14:11:02.000000000 +1000
@@ -737,13 +737,16 @@ int nfs4_acl_nfsv4_to_posix(struct nfs4_
 	*pacl = posix_state_to_acl(&effective_acl_state, flags);
 	if (IS_ERR(*pacl)) {
 		ret = PTR_ERR(*pacl);
+		*pacl = NULL;
 		goto out_dstate;
 	}
 	*dpacl = posix_state_to_acl(&default_acl_state,
 						flags | NFS4_ACL_TYPE_DEFAULT);
 	if (IS_ERR(*dpacl)) {
 		ret = PTR_ERR(*dpacl);
+		*dpacl = NULL;
 		posix_acl_release(*pacl);
+		*pacl = NULL;
 		goto out_dstate;
 	}
 	sort_pacl(*pacl);

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-06-21 13:46:38.000000000 +1000
+++ ./fs/nfsd/vfs.c	2007-06-21 14:11:02.000000000 +1000
@@ -435,7 +435,7 @@ nfsd4_set_nfs4_acl(struct svc_rqst *rqst
 	/* Get inode */
 	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, MAY_SATTR);
 	if (error)
-		goto out;
+		return error;
 
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
@@ -444,33 +444,25 @@ nfsd4_set_nfs4_acl(struct svc_rqst *rqst
 
 	host_error = nfs4_acl_nfsv4_to_posix(acl, &pacl, &dpacl, flags);
 	if (host_error == -EINVAL) {
-		error = nfserr_attrnotsupp;
-		goto out;
+		return nfserr_attrnotsupp;
 	} else if (host_error < 0)
 		goto out_nfserr;
 
 	host_error = set_nfsv4_acl_one(dentry, pacl, POSIX_ACL_XATTR_ACCESS);
 	if (host_error < 0)
-		goto out_nfserr;
+		goto out_release;
 
-	if (S_ISDIR(inode->i_mode)) {
+	if (S_ISDIR(inode->i_mode))
 		host_error = set_nfsv4_acl_one(dentry, dpacl, POSIX_ACL_XATTR_DEFAULT);
-		if (host_error < 0)
-			goto out_nfserr;
-	}
-
-	error = nfs_ok;
 
-out:
+out_release:
 	posix_acl_release(pacl);
 	posix_acl_release(dpacl);
-	return (error);
 out_nfserr:
 	if (host_error == -EOPNOTSUPP)
-		error = nfserr_attrnotsupp;
+		return nfserr_attrnotsupp;
 	else
-		error = nfserrno(host_error);
-	goto out;
+		return nfserrno(host_error);
 }
 
 static struct posix_acl *

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
