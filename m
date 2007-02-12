From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 4] knfsd: Tidy up choice of
	filesystem-identifier when creating a filehandle.
Date: Mon, 12 Feb 2007 16:49:46 +1100
Message-ID: <1070212054946.26790@suse.de>
References: <20070212164133.26352.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGU5H-0001t7-MG
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:39 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGU5H-0001sG-K4
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:41 -0800
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


If we are using the same version/fsid as a current filehandle, then
there is no need to verify the the numbers are valid for this
export, and they must be (we used them to find this export).

This allows us to simplify the fsid selection code.

Also change "ref_fh_version" and "ref_fh_fsid_type" to "version" and
"fsid_type", as the important thing isn't that they are the
version/type of the reference filehandle, but they are the chosen type
for the new filehandle.

And tidy up some indenting.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |  124 ++++++++++++++++++++++++++----------------------------
 1 file changed, 60 insertions(+), 64 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-02-12 16:39:19.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2007-02-12 16:39:36.000000000 +1100
@@ -211,7 +211,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 				fileid_type = 2;
 		} else
 			fileid_type = fh->fh_fileid_type;
-		
+
 		if (fileid_type == 0)
 			dentry = dget(exp->ex_dentry);
 		else {
@@ -291,7 +291,7 @@ static inline int _fh_update(struct dent
 			     __u32 *datap, int *maxsize)
 {
 	struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-	
+
 	if (dentry == exp->ex_dentry) {
 		*maxsize = 0;
 		return 0;
@@ -316,7 +316,8 @@ static inline void _fh_update_old(struct
 }
 
 __be32
-fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry, struct svc_fh *ref_fh)
+fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
+	   struct svc_fh *ref_fh)
 {
 	/* ref_fh is a reference file handle.
 	 * if it is non-null and for the same filesystem, then we should compose
@@ -326,8 +327,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 *
 	 */
 
-	u8 ref_fh_version = 0;
-	u8 ref_fh_fsid_type = 0;
+	u8 version = 1;
+	u8 fsid_type = 0;
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
@@ -339,57 +340,52 @@ fh_compose(struct svc_fh *fhp, struct sv
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
+	/* Choose filehandle version and fsid type based on
+	 * the reference filehandle (if it is in the same export)
+	 * or the export options.
+	 */
 	if (ref_fh && ref_fh->fh_export == exp) {
-		ref_fh_version = ref_fh->fh_handle.fh_version;
-		if (ref_fh_version == 0xca)
-			ref_fh_fsid_type = 0;
+		version = ref_fh->fh_handle.fh_version;
+		if (version == 0xca)
+			fsid_type = 0;
 		else
-			ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
-		if (ref_fh_fsid_type > 3)
-			ref_fh_fsid_type = 0;
-
-		/* make sure ref_fh type works for given export */
-		if (ref_fh_fsid_type == 1 &&
-		    !(exp->ex_flags & NFSEXP_FSID)) {
-			/* if we don't have an fsid, we cannot provide one... */
-			ref_fh_fsid_type = 0;
-		}
+			fsid_type = ref_fh->fh_handle.fh_fsid_type;
+		/* We know this version/type works for this export
+		 * so there is no need for further checks.
+		 */
 	} else if (exp->ex_flags & NFSEXP_FSID)
-		ref_fh_fsid_type = 1;
-
-	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
+		fsid_type = 1;
+	else if (!old_valid_dev(ex_dev))
 		/* for newer device numbers, we must use a newer fsid format */
-		ref_fh_version = 1;
-		ref_fh_fsid_type = 3;
-	}
-	if (old_valid_dev(ex_dev) &&
-	    (ref_fh_fsid_type == 2 || ref_fh_fsid_type == 3))
-		/* must use type1 for smaller device numbers */
-		ref_fh_fsid_type = 0;
+		fsid_type = 3;
+	else
+		fsid_type = 0;
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
 
 	if (fhp->fh_locked || fhp->fh_dentry) {
 		printk(KERN_ERR "fh_compose: fh %s/%s not initialized!\n",
-			parent->d_name.name, dentry->d_name.name);
+		       parent->d_name.name, dentry->d_name.name);
 	}
 	if (fhp->fh_maxsize < NFS_FHSIZE)
 		printk(KERN_ERR "fh_compose: called with maxsize %d! %s/%s\n",
-		       fhp->fh_maxsize, parent->d_name.name, dentry->d_name.name);
+		       fhp->fh_maxsize,
+		       parent->d_name.name, dentry->d_name.name);
 
 	fhp->fh_dentry = dget(dentry); /* our internal copy */
 	fhp->fh_export = exp;
 	cache_get(&exp->h);
 
-	if (ref_fh_version == 0xca) {
+	if (version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
 		fhp->fh_handle.ofh_dcookie = 0xfeebbaca;
 		fhp->fh_handle.ofh_dev =  old_encode_dev(ex_dev);
 		fhp->fh_handle.ofh_xdev = fhp->fh_handle.ofh_dev;
-		fhp->fh_handle.ofh_xino = ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
+		fhp->fh_handle.ofh_xino =
+			ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
 		fhp->fh_handle.ofh_dirino = ino_t_to_u32(parent_ino(dentry));
 		if (inode)
 			_fh_update_old(dentry, exp, &fhp->fh_handle);
@@ -398,38 +394,38 @@ fh_compose(struct svc_fh *fhp, struct sv
 		fhp->fh_handle.fh_version = 1;
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
-		fhp->fh_handle.fh_fsid_type = ref_fh_fsid_type;
-		switch (ref_fh_fsid_type) {
-			case 0:
-				/*
-				 * fsid_type 0:
-				 * 2byte major, 2byte minor, 4byte inode
-				 */
-				mk_fsid_v0(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
-			case 1:
-				/* fsid_type 1 == 4 bytes filesystem id */
-				mk_fsid_v1(datap, exp->ex_fsid);
-				break;
-			case 2:
-				/*
-				 * fsid_type 2:
-				 * 4byte major, 4byte minor, 4byte inode
-				 */
-				mk_fsid_v2(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
-			case 3:
-				/*
-				 * fsid_type 3:
-				 * 4byte devicenumber, 4byte inode
-				 */
-				mk_fsid_v3(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
+		fhp->fh_handle.fh_fsid_type = fsid_type;
+		switch (fsid_type) {
+		case 0:
+			/*
+			 * fsid_type 0:
+			 * 2byte major, 2byte minor, 4byte inode
+			 */
+			mk_fsid_v0(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
+		case 1:
+			/* fsid_type 1 == 4 bytes filesystem id */
+			mk_fsid_v1(datap, exp->ex_fsid);
+			break;
+		case 2:
+			/*
+			 * fsid_type 2:
+			 * 4byte major, 4byte minor, 4byte inode
+			 */
+			mk_fsid_v2(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
+		case 3:
+			/*
+			 * fsid_type 3:
+			 * 4byte devicenumber, 4byte inode
+			 */
+			mk_fsid_v3(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
 		}
-		len = key_len(ref_fh_fsid_type);
+		len = key_len(fsid_type);
 		datap += len/4;
 		fhp->fh_handle.fh_size = 4 + len;
 
@@ -456,7 +452,7 @@ fh_update(struct svc_fh *fhp)
 {
 	struct dentry *dentry;
 	__u32 *datap;
-	
+
 	if (!fhp->fh_dentry)
 		goto out_bad;
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
