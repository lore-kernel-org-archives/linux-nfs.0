From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd -  Tidy up new filehandle type.
Date: Fri, 05 Mar 2004 16:42:55 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1Az86p-0001o6-00@notabene>
References: <20040305163625.1829.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Az8DI-0004MD-4D
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 21:49:36 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1Az7mi-0002OS-Q9
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 21:22:08 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 5 Mar 2004 16:42:57 +1100
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

Hi Andrew,
 I would really like this patch to go into 2.6.4.  I think it is ready - it 
is fairly simple and tested.  But if it is too late, so be it.

A change was made to nfsd filehandles about 6 months ago when the 32bit dev_t 
stuff went in which I wasn't consulted on and I don't like.  It basically wastes 32bits 
of the filehandle when the filesystem is on a device with a new/large device number.
Not only don't I like it, but it broken handling for 'fsid=' for such filesystems.

This patch fixes it in an upwards-compatable way (so people already serving files from 
such a filesystem with a 2.6.3 kernel should not notice any issues).
NeilBrown

======================================
nfsd uses several different mechanisms for identifying the filesystem
from the filehandle.

This patch:
  Marks type 2 as deprecated - it wastes space, and space if the filehandle
     is not unlimited
  Adds type 3 which handles new, large device number in 32bits of space
  Tidies up the code for determining which type to use in a newly created
  filehandle - the addition type 2 broke this code.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c           |   13 ++----
 ./fs/nfsd/nfsfh.c            |   80 +++++++++++++++++++++++++------------------
 ./include/linux/nfsd/nfsfh.h |   21 ++++++++++-
 3 files changed, 71 insertions(+), 43 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2004-03-05 16:36:13.000000000 +1100
+++ ./fs/nfsd/export.c	2004-03-05 16:36:13.000000000 +1100
@@ -56,11 +56,6 @@ static int		exp_verify_string(char *cp, 
 #define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
 static struct cache_head *expkey_table[EXPKEY_HASHMAX];
 
-static inline int key_len(int type)
-{
-	return type == 0 ? 8 : type == 1 ? 4 : 12;
-}
-
 static inline int svc_expkey_hash(struct svc_expkey *item)
 {
 	int hash = item->ek_fsidtype;
@@ -547,8 +542,8 @@ exp_get_key(svc_client *clp, dev_t dev, 
 		mk_fsid_v0(fsidv, dev, ino);
 		return exp_find_key(clp, 0, fsidv, NULL);
 	}
-	mk_fsid_v2(fsidv, dev, ino);
-	return exp_find_key(clp, 2, fsidv, NULL);
+	mk_fsid_v3(fsidv, dev, ino);
+	return exp_find_key(clp, 3, fsidv, NULL);
 }
 
 /*
@@ -684,8 +679,8 @@ static int exp_hash(struct auth_domain *
 		mk_fsid_v0(fsid, dev, inode->i_ino);
 		return exp_set_key(clp, 0, fsid, exp);
 	}
-	mk_fsid_v2(fsid, dev, inode->i_ino);
-	return exp_set_key(clp, 2, fsid, exp);
+	mk_fsid_v3(fsid, dev, inode->i_ino);
+	return exp_set_key(clp, 3, fsid, exp);
 }
 
 static void exp_unhash(struct svc_export *exp)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-03-05 16:36:13.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2004-03-05 16:36:13.000000000 +1100
@@ -117,19 +117,14 @@ fh_verify(struct svc_rqst *rqstp, struct
 			case 0: break;
 			default: goto out;
 			}
-
-			switch (fh->fh_fsid_type) {
-			case 0:
-				len = 2;
-				break;
-			case 1:
-				len = 1;
-				break;
-			case 2:
+			len = key_len(fh->fh_fsid_type) / 4;
+			if (len == 0) goto out;
+			if  (fh->fh_fsid_type == 2) {
+				/* deprecated, convert to type 3 */
 				len = 3;
-				break;
-			default:
-				goto out;
+				fh->fh_fsid_type = 3;
+				fh->fh_fsid[0] = new_encode_dev(MKDEV(ntohl(fh->fh_fsid[0]), ntohl(fh->fh_fsid[1])));
+				fh->fh_fsid[1] = fh->fh_fsid[2];
 			}
 			if ((data_left -= len)<0) goto out;
 			exp = exp_find(rqstp->rq_client, fh->fh_fsid_type, datap, &rqstp->rq_chandle);
@@ -336,19 +331,31 @@ fh_compose(struct svc_fh *fhp, struct sv
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
-	/* for large devnums rules are simple */
-	if (!old_valid_dev(ex_dev)) {
-		ref_fh_version = 1;
-		if (exp->ex_flags & NFSEXP_FSID)
-			ref_fh_fsid_type = 1;
-		else
-			ref_fh_fsid_type = 2;
-	} else if (ref_fh) {
+	if (ref_fh) {
 		ref_fh_version = ref_fh->fh_handle.fh_version;
-		ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
-		if (!(exp->ex_flags & NFSEXP_FSID) || ref_fh_fsid_type == 2)
+		if (ref_fh_version == 0xca)
 			ref_fh_fsid_type = 0;
+		else
+			ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
+		if (ref_fh_fsid_type > 3)
+			ref_fh_fsid_type = 0;
+	}
+	/* make sure ref_fh type works for given export */
+	if (ref_fh_fsid_type == 1 &&
+	    !(exp->ex_flags & NFSEXP_FSID)) {
+		/* if we don't have an fsid, we cannot provide one... */
+		ref_fh_fsid_type = 0;
+	}
+	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
+		/* for newer device numbers, we must use a newer fsid format */
+		ref_fh_version = 1;
+		ref_fh_fsid_type = 3;
 	}
+	if (old_valid_dev(ex_dev) &&
+	    (ref_fh_fsid_type == 2 || ref_fh_fsid_type == 3))
+		/* must use type1 for smaller device numbers */
+		ref_fh_fsid_type = 0;
+
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
 
@@ -376,16 +383,22 @@ fh_compose(struct svc_fh *fhp, struct sv
 		if (inode)
 			_fh_update_old(dentry, exp, &fhp->fh_handle);
 	} else {
+		int len;
 		fhp->fh_handle.fh_version = 1;
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
 		fhp->fh_handle.fh_fsid_type = ref_fh_fsid_type;
 		switch (ref_fh_fsid_type) {
+			case 0:
+				/*
+				 * fsid_type 0:
+				 * 2byte major, 2byte minor, 4byte inode
+				 */
+				mk_fsid_v0(datap, ex_dev,
+					exp->ex_dentry->d_inode->i_ino);
 			case 1:
 				/* fsid_type 1 == 4 bytes filesystem id */
 				mk_fsid_v1(datap, exp->ex_fsid);
-				datap += 1;
-				fhp->fh_handle.fh_size = 2*4;
 				break;
 			case 2:
 				/*
@@ -394,21 +407,22 @@ fh_compose(struct svc_fh *fhp, struct sv
 				 */
 				mk_fsid_v2(datap, ex_dev,
 					exp->ex_dentry->d_inode->i_ino);
-				datap += 3;
-				fhp->fh_handle.fh_size = 4*4;
 				break;
-			default:
+			case 3:
 				/*
-				 * fsid_type 0:
-				 * 2byte major, 2byte minor, 4byte inode
+				 * fsid_type 3:
+				 * 4byte devicenumber, 4byte inode
 				 */
-				mk_fsid_v0(datap, ex_dev,
+				mk_fsid_v3(datap, ex_dev,
 					exp->ex_dentry->d_inode->i_ino);
-				datap += 2;
-				fhp->fh_handle.fh_size = 3*4;
+				break;
 		}
+		len = key_len(ref_fh_fsid_type);
+		datap += len/4;
+		fhp->fh_handle.fh_size = 4 + len;
+
 		if (inode) {
-			int size = fhp->fh_maxsize/4 - 3;
+			int size = (fhp->fh_maxsize-len-4)/4;
 			fhp->fh_handle.fh_fileid_type =
 				_fh_update(dentry, exp, datap, &size);
 			fhp->fh_handle.fh_size += size*4;

diff ./include/linux/nfsd/nfsfh.h~current~ ./include/linux/nfsd/nfsfh.h
--- ./include/linux/nfsd/nfsfh.h~current~	2004-03-05 16:36:13.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2004-03-05 16:36:13.000000000 +1100
@@ -66,8 +66,9 @@ struct nfs_fhbase_old {
  *     0  - 4 byte device id (ms-2-bytes major, ls-2-bytes minor), 4byte inode number
  *        NOTE: we cannot use the kdev_t device id value, because kdev_t.h
  *              says we mustn't.  We must break it up and reassemble.
- *  Possible future encodings:
  *     1  - 4 byte user specified identifier
+ *     2  - 4 byte major, 4 byte minor, 4 byte inode number - DEPRECATED
+ *     3  - 4 byte device id, encoded for user-space, 4 byte inode number
  *
  * The fileid_type identified how the file within the filesystem is encoded.
  * This is (will be) passed to, and set by, the underlying filesystem if it supports
@@ -114,6 +115,7 @@ struct knfsd_fh {
 #define	fh_auth_type		fh_base.fh_new.fb_auth_type
 #define	fh_fileid_type		fh_base.fh_new.fb_fileid_type
 #define	fh_auth			fh_base.fh_new.fb_auth
+#define	fh_fsid			fh_base.fh_new.fb_auth
 
 #ifdef __KERNEL__
 
@@ -183,6 +185,23 @@ static inline void mk_fsid_v2(u32 *fsidv
 	fsidv[2] = ino_t_to_u32(ino);
 }
 
+static inline void mk_fsid_v3(u32 *fsidv, dev_t dev, ino_t ino)
+{
+	fsidv[0] = new_encode_dev(dev);
+	fsidv[1] = ino_t_to_u32(ino);
+}
+
+static inline int key_len(int type)
+{
+	switch(type) {
+	case 0: return 8;
+	case 1: return 4;
+	case 2: return 12;
+	case 3: return 8;
+	default: return 0;
+	}
+}
+
 /*
  * Shorthand for dprintk()'s
  */


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
