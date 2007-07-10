From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 20] knfsd: nfsd4: make readonly access depend
	on pseudoflavor
Date: Tue, 10 Jul 2007 12:26:15 +1000
Message-ID: <1070710022615.13375@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Rg-00055s-B8
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:20 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Rh-0001T4-Up
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:22 -0700
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


From: J. Bruce Fields <bfields@citi.umich.edu>

Allow readonly access to vary depending on the pseudoflavor, using the
flag passed with each pseudoflavor in the export downcall.  The rest of
the flags are ignored for now, though some day we might also allow id
squashing to vary based on the flavor.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c             |    2 +-
 ./fs/nfsd/nfsproc.c           |    3 ++-
 ./fs/nfsd/vfs.c               |   13 +++++++------
 ./include/linux/nfsd/export.h |   13 ++++++++++++-
 ./include/linux/nfsd/nfsd.h   |    3 ++-
 5 files changed, 24 insertions(+), 10 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-07-10 11:39:34.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-07-10 11:40:31.000000000 +1000
@@ -255,7 +255,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		goto out;
 
 	/* Finally, check access permissions. */
-	error = nfsd_permission(exp, dentry, access);
+	error = nfsd_permission(rqstp, exp, dentry, access);
 
 	if (error) {
 		dprintk("fh_verify: %s/%s permission failure, "

diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
--- .prev/fs/nfsd/nfsproc.c	2007-07-10 11:19:55.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2007-07-10 11:40:31.000000000 +1000
@@ -278,7 +278,8 @@ nfsd_proc_create(struct svc_rqst *rqstp,
 					 *   echo thing > device-special-file-or-pipe
 					 * by doing a CREATE with type==0
 					 */
-					nfserr = nfsd_permission(newfhp->fh_export,
+					nfserr = nfsd_permission(rqstp,
+								 newfhp->fh_export,
 								 newfhp->fh_dentry,
 								 MAY_WRITE|MAY_LOCAL_ACCESS);
 					if (nfserr && nfserr != nfserr_rofs)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-07-10 11:39:34.000000000 +1000
+++ ./fs/nfsd/vfs.c	2007-07-10 11:40:31.000000000 +1000
@@ -328,7 +328,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	/* The size case is special. It changes the file as well as the attributes.  */
 	if (iap->ia_valid & ATTR_SIZE) {
 		if (iap->ia_size < inode->i_size) {
-			err = nfsd_permission(fhp->fh_export, dentry, MAY_TRUNC|MAY_OWNER_OVERRIDE);
+			err = nfsd_permission(rqstp, fhp->fh_export, dentry, MAY_TRUNC|MAY_OWNER_OVERRIDE);
 			if (err)
 				goto out;
 		}
@@ -616,7 +616,7 @@ nfsd_access(struct svc_rqst *rqstp, stru
 
 			sresult |= map->access;
 
-			err2 = nfsd_permission(export, dentry, map->how);
+			err2 = nfsd_permission(rqstp, export, dentry, map->how);
 			switch (err2) {
 			case nfs_ok:
 				result |= map->access;
@@ -1027,7 +1027,7 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	__be32		err;
 
 	if (file) {
-		err = nfsd_permission(fhp->fh_export, fhp->fh_dentry,
+		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
 				MAY_READ|MAY_OWNER_OVERRIDE);
 		if (err)
 			goto out;
@@ -1056,7 +1056,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	__be32			err = 0;
 
 	if (file) {
-		err = nfsd_permission(fhp->fh_export, fhp->fh_dentry,
+		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
 				MAY_WRITE|MAY_OWNER_OVERRIDE);
 		if (err)
 			goto out;
@@ -1785,7 +1785,8 @@ nfsd_statfs(struct svc_rqst *rqstp, stru
  * Check for a user's access permissions to this inode.
  */
 __be32
-nfsd_permission(struct svc_export *exp, struct dentry *dentry, int acc)
+nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
+					struct dentry *dentry, int acc)
 {
 	struct inode	*inode = dentry->d_inode;
 	int		err;
@@ -1816,7 +1817,7 @@ nfsd_permission(struct svc_export *exp, 
 	 */
 	if (!(acc & MAY_LOCAL_ACCESS))
 		if (acc & (MAY_WRITE | MAY_SATTR | MAY_TRUNC)) {
-			if (EX_RDONLY(exp) || IS_RDONLY(inode))
+			if (EX_RDONLY(exp, rqstp) || IS_RDONLY(inode))
 				return nfserr_rofs;
 			if (/* (acc & MAY_WRITE) && */ IS_IMMUTABLE(inode))
 				return nfserr_perm;

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-07-10 11:39:34.000000000 +1000
+++ ./include/linux/nfsd/export.h	2007-07-10 11:40:31.000000000 +1000
@@ -112,10 +112,21 @@ struct svc_expkey {
 
 #define EX_SECURE(exp)		(!((exp)->ex_flags & NFSEXP_INSECURE_PORT))
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
-#define EX_RDONLY(exp)		((exp)->ex_flags & NFSEXP_READONLY)
 #define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 
+static inline int EX_RDONLY(struct svc_export *exp, struct svc_rqst *rqstp)
+{
+	struct exp_flavor_info *f;
+	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
+
+	for (f = exp->ex_flavors; f < end; f++) {
+		if (f->pseudoflavor == rqstp->rq_flavor)
+			return f->flags & NFSEXP_READONLY;
+	}
+	return exp->ex_flags & NFSEXP_READONLY;
+}
+
 __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
 
 /*

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-07-10 11:39:34.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2007-07-10 11:40:31.000000000 +1000
@@ -119,7 +119,8 @@ __be32		nfsd_statfs(struct svc_rqst *, s
 				struct kstatfs *);
 
 int		nfsd_notify_change(struct inode *, struct iattr *);
-__be32		nfsd_permission(struct svc_export *, struct dentry *, int);
+__be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
+				struct dentry *, int);
 int		nfsd_sync_dir(struct dentry *dp);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
