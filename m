From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 9] knfsd: nfsd4: acls: fix handling of
	zero-length acls
Date: Tue, 5 Sep 2006 09:16:08 +1000
Message-ID: <1060904231608.23162@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfu-0000T0-22
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:18 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfw-0004Jw-K1
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:22 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

It is legal to have zero-length NFSv4 acls; they just deny everything.

Also, nfs4_acl_nfsv4_to_posix will always return with pacl and dpacl set on
success, so the caller doesn't need to check this.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   15 +--------------
 ./fs/nfsd/vfs.c     |   10 ++++------
 2 files changed, 5 insertions(+), 20 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2006-09-04 17:27:48.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2006-09-04 17:28:10.000000000 +1000
@@ -357,33 +357,20 @@ nfs4_acl_nfsv4_to_posix(struct nfs4_acl 
 		goto out;
 
 	error = nfs4_acl_split(acl, dacl);
-	if (error < 0)
+	if (error)
 		goto out_acl;
 
-	if (acl->naces == 0) {
-		error = -ENODATA;
-		goto try_dpacl;
-	}
-
 	*pacl = _nfsv4_to_posix_one(acl, flags);
 	if (IS_ERR(*pacl)) {
 		error = PTR_ERR(*pacl);
 		*pacl = NULL;
 		goto out_acl;
 	}
-try_dpacl:
-	if (dacl->naces == 0) {
-		if (pacl == NULL || *pacl == NULL)
-			error = -ENODATA;
-		goto out_acl;
-	}
 
-	error = 0;
 	*dpacl = _nfsv4_to_posix_one(dacl, flags);
 	if (IS_ERR(*dpacl)) {
 		error = PTR_ERR(*dpacl);
 		*dpacl = NULL;
-		goto out_acl;
 	}
 out_acl:
 	if (error) {

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2006-09-04 17:09:47.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-09-04 17:28:10.000000000 +1000
@@ -447,13 +447,11 @@ nfsd4_set_nfs4_acl(struct svc_rqst *rqst
 	} else if (error < 0)
 		goto out_nfserr;
 
-	if (pacl) {
-		error = set_nfsv4_acl_one(dentry, pacl, POSIX_ACL_XATTR_ACCESS);
-		if (error < 0)
-			goto out_nfserr;
-	}
+	error = set_nfsv4_acl_one(dentry, pacl, POSIX_ACL_XATTR_ACCESS);
+	if (error < 0)
+		goto out_nfserr;
 
-	if (dpacl) {
+	if (S_ISDIR(inode->i_mode)) {
 		error = set_nfsv4_acl_one(dentry, dpacl, POSIX_ACL_XATTR_DEFAULT);
 		if (error < 0)
 			goto out_nfserr;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
