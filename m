From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 14 of 16 - Filehandle lookup makes use of new export table structure.
Date: Thu, 12 Sep 2002 12:36:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023610.19691@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJqY-0002qx-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:46 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

Filehandle lookup currently breaks out the interesting pieces of 
a filehandle and passes them to exp_get or exp_get_fsid, which put the
pieces back into a filehandle fragment.

We define a new interface "exp_find" which does a lookup based on
a filehandle fragment to avoid this double handling.

In the process, common code in exp_get_key and exp_get_fsid_key is united
into exp_find_key.

Also, filehandle composition now uses the mk_fsid_v? inline functions.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   48 +++++++++++++++++++-----------------------
 ./fs/nfsd/nfsfh.c             |   34 +++++++++++++----------------
 ./include/linux/nfsd/export.h |   12 ++++++++--
 3 files changed, 47 insertions(+), 47 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 23:35:25	1.10
+++ ./include/linux/nfsd/export.h	2002/09/11 23:55:44	1.11
@@ -98,8 +98,7 @@ void			exp_readlock(void);
 void			exp_readunlock(void);
 struct svc_client *	exp_getclient(struct sockaddr_in *sin);
 void			exp_putclient(struct svc_client *clp);
-struct svc_export *	exp_get(struct svc_client *clp, dev_t dev, ino_t ino);
-struct svc_export *	exp_get_fsid(struct svc_client *clp, int fsid);
+struct svc_expkey *	exp_find_key(struct svc_client *clp, int fsid_type, u32 *fsidv);
 struct svc_export *	exp_get_by_name(struct svc_client *clp,
 					struct vfsmount *mnt,
 					struct dentry *dentry);
@@ -109,6 +108,15 @@ int			exp_rootfh(struct svc_client *, 
 					char *path, struct knfsd_fh *, int maxsize);
 int			nfserrno(int errno);
 
+static inline struct svc_export *
+exp_find(struct svc_client *clp, int fsid_type, u32 *fsidv)
+{
+	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv);
+	if (ek)
+		return ek->ek_export;
+	else
+		return NULL;
+}
 
 #endif /* __KERNEL__ */
 
--- ./fs/nfsd/export.c	2002/09/11 23:35:25	1.13
+++ ./fs/nfsd/export.c	2002/09/11 23:55:44	1.14
@@ -88,32 +88,39 @@ static int export_hash(svc_client *clp, 
 	return rv & EXPORT_HASHMASK;
 }
 
-/*
- * Find the client's export entry matching xdev/xino.
- */
 struct svc_expkey *
-exp_get_key(svc_client *clp, dev_t dev, ino_t ino)
+exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv)
 {
 	struct list_head *head;
 	struct svc_expkey *ek;
-	u32 fsidv[2];
 	
 	if (!clp)
 		return NULL;
 
-	mk_fsid_v0(fsidv, dev, ino);
-
-	head = &clp->cl_export[expkey_hash(0, fsidv)];
+	head = &clp->cl_export[expkey_hash(fsid_type, fsidv)];
 	list_for_each_entry(ek, head, ek_hash)
-		if (ek->ek_fsidtype == 0 &&
+		if (ek->ek_fsidtype == fsid_type &&
 		    fsidv[0] == ek->ek_fsid[0] &&
-		    fsidv[1] == ek->ek_fsid[1] &&
+		    (fsid_type == 1 || fsidv[1] == ek->ek_fsid[1]) &&
 		    clp      == ek->ek_client)
 			return ek;
 
 	return NULL;
 }
-inline svc_export *
+
+/*
+ * Find the client's export entry matching xdev/xino.
+ */
+static inline struct svc_expkey *
+exp_get_key(svc_client *clp, dev_t dev, ino_t ino)
+{
+	u32 fsidv[2];
+	
+	mk_fsid_v0(fsidv, dev, ino);
+	return exp_find_key(clp, 0, fsidv);
+}
+
+static inline svc_export *
 exp_get(svc_client *clp, dev_t dev, ino_t ino)
 {
 	struct svc_expkey *ek;
@@ -128,28 +135,17 @@ exp_get(svc_client *clp, dev_t dev, ino_
 /*
  * Find the client's export entry matching fsid
  */
-struct svc_expkey *
+static inline struct svc_expkey *
 exp_get_fsid_key(svc_client *clp, int fsid)
 {
-	struct list_head *head;
-	struct svc_expkey *ek;
 	u32 fsidv[2];
 
-	if (!clp)
-		return NULL;
-
 	mk_fsid_v1(fsidv, fsid);
 
-	head = &clp->cl_export[expkey_hash(1, fsidv)];
-	list_for_each_entry(ek, head, ek_hash) {
-		if (ek->ek_fsidtype == 1 &&
-		    fsidv[0] == ek->ek_fsid[0] &&
-		    clp      == ek->ek_client)
-			return ek;
-	}
-	return NULL;
+	return exp_find_key(clp, 1, fsidv);
 }
-inline svc_export *
+
+static inline svc_export *
 exp_get_fsid(svc_client *clp, int fsid)
 {
 	struct svc_expkey *ek;
--- ./fs/nfsd/nfsfh.c	2002/09/11 03:15:58	1.2
+++ ./fs/nfsd/nfsfh.c	2002/09/11 23:55:44	1.3
@@ -97,14 +97,10 @@ fh_verify(struct svc_rqst *rqstp, struct
 	rqstp->rq_reffh = fh;
 
 	if (!fhp->fh_dentry) {
-		dev_t xdev = 0;
-		ino_t xino = 0;
 		__u32 *datap=NULL;
 		__u32 tfh[3];		/* filehandle fragment for oldstyle filehandles */
 		int fileid_type;
 		int data_left = fh->fh_size/4;
-		int nfsdev;
-		int fsid = 0;
 
 		error = nfserr_stale;
 		if (rqstp->rq_vers > 2)
@@ -113,6 +109,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 			return nfserr_nofilehandle;
 
 		if (fh->fh_version == 1) {
+			int len;
 			datap = fh->fh_auth;
 			if (--data_left<0) goto out;
 			switch (fh->fh_auth_type) {
@@ -122,39 +119,37 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 			switch (fh->fh_fsid_type) {
 			case 0:
-				if ((data_left-=2)<0) goto out;
-				nfsdev = ntohl(*datap++);
-				xdev = MKDEV(nfsdev>>16, nfsdev&0xFFFF);
-				xino = *datap++;
+				len = 2;
 				break;
 			case 1:
-				if ((data_left-=1)<0) goto out;
-				fsid = *datap++;
+				len = 1;
 				break;
 			default:
 				goto out;
 			}
+			if ((data_left -= len)<0) goto out;
+			exp = exp_find(rqstp->rq_client, fh->fh_fsid_type, datap);
+			datap += len;
 		} else {
+			dev_t xdev;
+			ino_t xino;
 			if (fh->fh_size != NFS_FHSIZE)
 				goto out;
 			/* assume old filehandle format */
 			xdev = u32_to_dev_t(fh->ofh_xdev);
 			xino = u32_to_ino_t(fh->ofh_xino);
+			mk_fsid_v0(tfh, xdev, xino);
+			exp = exp_find(rqstp->rq_client, 0, tfh);
 		}
 
 		/*
 		 * Look up the export entry.
 		 */
 		error = nfserr_stale; 
-		if (fh->fh_version == 1 && fh->fh_fsid_type == 1)
-			exp = exp_get_fsid(rqstp->rq_client, fsid);
-		else
-			exp = exp_get(rqstp->rq_client, xdev, xino);
 
-		if (!exp) {
+		if (!exp)
 			/* export entry revoked */
 			goto out;
-		}
 
 		/* Check if the request originated from a secure port. */
 		error = nfserr_perm;
@@ -367,13 +362,14 @@ fh_compose(struct svc_fh *fhp, struct sv
 		    (ref_fh_fsid_type == 1)) {
 			fhp->fh_handle.fh_fsid_type = 1;
 			/* fsid_type 1 == 4 bytes filesystem id */
-			*datap++ = exp->ex_fsid;
+			mk_fsid_v1(datap, exp->ex_fsid);
+			datap += 1;
 			fhp->fh_handle.fh_size = 2*4;
 		} else {
 			fhp->fh_handle.fh_fsid_type = 0;
 			/* fsid_type 0 == 2byte major, 2byte minor, 4byte inode */
-			*datap++ = htonl((MAJOR(ex_dev)<<16)| MINOR(ex_dev));
-			*datap++ = ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
+			mk_fsid_v0(datap, ex_dev, exp->ex_dentry->d_inode->i_ino);
+			datap += 2;
 			fhp->fh_handle.fh_size = 3*4;
 		}
 		if (inode) {


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
